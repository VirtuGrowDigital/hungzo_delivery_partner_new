import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:hungzo_delivery_partner/services/Api/api_constants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';

import '../utils/ColorConstants.dart';
import 'package:mime/mime.dart';


class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final FlutterSecureStorage secureStorage =
  const FlutterSecureStorage();

  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();

  late String initialName;
  late String initialEmail;

  File? selectedImage;
  String? profileImageUrl;

  String verificationStatus = "PENDING";
  bool isActive = false;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  /// ================= FETCH PROFILE =================
  Future<void> fetchProfile() async {
    try {
      final token = await secureStorage.read(key: 'accessToken');
      if (token == null) return;

      final response = await http.get(
        Uri.parse("${ApiConstants.baseURL}restaurant/myProfile"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final profile = jsonDecode(response.body)["profile"];

        nameCtrl.text = profile["ownerName"] ?? "";
        emailCtrl.text = profile["email"] ?? "";
        phoneCtrl.text = profile["phone"] ?? "";
        profileImageUrl = profile["profilePic"];

        verificationStatus = profile["verificationStatus"] ?? "PENDING";
        isActive = profile["isActive"] ?? false;

        initialName = nameCtrl.text;
        initialEmail = emailCtrl.text;
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// ================= UPDATE PROFILE =================
  Future<void> updateProfile() async {
    final token = await secureStorage.read(key: 'accessToken');
    if (token == null) return;

    final request = http.MultipartRequest(
      "PUT",
      Uri.parse("${ApiConstants.baseURL}restaurant/profile"),
    );

    if (nameCtrl.text.trim() != initialName) {
      request.fields["ownerName"] = nameCtrl.text.trim();
    }
    if (emailCtrl.text.trim() != initialEmail) {
      request.fields["email"] = emailCtrl.text.trim();
    }
    if (selectedImage != null) {
      final file = selectedImage!;
      final mimeType = lookupMimeType(file.path) ?? "image/jpeg";

      request.files.add(
        await http.MultipartFile.fromPath(
          "profilePic", // ⚠️ must match backend field name
          file.path,
          contentType: http.MediaType.parse(mimeType),
        ),
      );
    }

    if (request.fields.isEmpty && request.files.isEmpty) {
      Get.snackbar("No Changes", "Nothing to update");
      return;
    }

    request.headers["Authorization"] = "Bearer $token";

    final response = await request.send();

    if (response.statusCode == 200) {
      Get.snackbar("Success", "Profile updated successfully");
      initialName = nameCtrl.text;
      initialEmail = emailCtrl.text;
    } else {
      Get.snackbar("Error", "Update failed");
    }
  }

  /// ================= EDIT POPUP =================
  void _showEditProfilePopup() {
    final tempName = TextEditingController(text: nameCtrl.text);
    final tempEmail = TextEditingController(text: emailCtrl.text);

    ImageProvider? imageProvider;
    if (selectedImage != null) {
      imageProvider = FileImage(selectedImage!);
    } else if (profileImageUrl != null) {
      imageProvider = NetworkImage(profileImageUrl!);
    }

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// DRAG HANDLE
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const SizedBox(height: 18),

              /// TITLE
              const Text(
                "Edit Profile",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 22),

              /// PROFILE IMAGE WITH RING + EDIT ICON
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          ColorConstants.success,
                          ColorConstants.success.withOpacity(0.6),
                        ],
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 46,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage: imageProvider,
                      child: imageProvider == null
                          ? const Icon(Icons.person, size: 36)
                          : null,
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final picked = await ImagePicker().pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 85,
                      );
                      if (picked != null) {
                        setState(() {
                          selectedImage = File(picked.path);
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 26),

              /// NAME FIELD
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Name",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              _inputField(controller: tempName, hint: "Full name"),

              const SizedBox(height: 18),

              /// EMAIL FIELD
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Email",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              _inputField(
                controller: tempEmail,
                hint: "abc@gmail.com",
                keyboard: TextInputType.emailAddress,
              ),

              const SizedBox(height: 30),

              /// SAVE BUTTON (REAL CTA)
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorConstants.success,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    elevation: 6,
                  ),
                  onPressed: () {
                    if (tempName.text.trim().isEmpty ||
                        tempEmail.text.trim().isEmpty) {
                      Get.snackbar("Error", "All fields are required");
                      return;
                    }

                    if (tempName.text.trim() == initialName &&
                        tempEmail.text.trim() == initialEmail &&
                        selectedImage == null) {
                      Get.snackbar("No Changes", "Nothing to update");
                      return;
                    }

                    nameCtrl.text = tempName.text.trim();
                    emailCtrl.text = tempEmail.text.trim();

                    Get.back();
                    updateProfile();
                  },
                  child: const Text(
                    "Save Changes",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  /// ================= UI =================
  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;
    if (selectedImage != null) {
      imageProvider = FileImage(selectedImage!);
    } else if (profileImageUrl != null) {
      imageProvider = NetworkImage(profileImageUrl!);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(title: const Text("Profile"), centerTitle: true),
      body: isLoading
          ? _buildShimmer()
          : RefreshIndicator(
        color: ColorConstants.success,
        onRefresh: () async {
          setState(() {
            isLoading = true;
          });
          await fetchProfile();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(), // ⭐ THIS FIX
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _profileHeader(imageProvider),
              const SizedBox(height: 24),
              _statusCard(),
              const SizedBox(height: 20),
              _infoTile(Icons.phone, "Phone", phoneCtrl.text),
              _infoTile(Icons.email, "Email", emailCtrl.text),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text("Edit Profile"),
                trailing:
                const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _showEditProfilePopup,
              ),
            ],
          ),
        ),
      ),

    );
  }

  /// ================= UI HELPERS =================
  Widget _profileHeader(ImageProvider? imageProvider) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            InkWell(
              onTap: () {
                showSimpleDialog(context, profileImageUrl!);
                print("Hi ${nameCtrl.text}");
              },
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey.shade300,
                backgroundImage: imageProvider,
                child: imageProvider == null
                    ? const Icon(Icons.person, size: 40)
                    : null,
              ),
            ),

            /// 🟢 Active / 🔴 Inactive
            Container(
              margin: const EdgeInsets.only(right: 6, bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isActive ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Text(
                isActive ? "ACTIVE" : "INACTIVE",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Text(
          nameCtrl.text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),

        Text(
          emailCtrl.text,
          style: TextStyle(color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _statusCard() {
    Color color;
    IconData icon;

    switch (verificationStatus) {
      case "APPROVED":
        color = Colors.green;
        icon = Icons.verified;
        break;
      case "REJECTED":
        color = Colors.red;
        icon = Icons.cancel;
        break;
      default:
        color = Colors.orange;
        icon = Icons.hourglass_top;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.12),
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              "Verification: $verificationStatus",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: color,
                fontSize: 15,
              ),
            ),
          ),


        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return Center(
      child:Column(
        children: [
          const SizedBox(height: 40),
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: const CircleAvatar(radius: 60),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String title, String value) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: ColorConstants.success),
      title: Text(title),
      subtitle: Text(value),
    );
  }


  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF7F9FC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  void showSimpleDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.75),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16),
          child: Stack(
            children: [
              /// Image Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    imageUrl,
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const SizedBox(
                        height: 300,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    },
                    errorBuilder: (_, __, ___) => SizedBox(
                      height: 300,
                      child: Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 60,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              /// CLOSE ICON
              Positioned(
                top: 10,
                right: 10,
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  child: const CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.black54,
                    child: Icon(Icons.close, size: 18, color: Colors.white),
                  ),
                ),
              ),

              /// EDIT ICON (ONLY IMAGE CHANGE)
              Positioned(
                bottom: 14,
                right: 14,
                child: InkWell(
                  onTap: () async {
                    final picked = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 85,
                    );

                    if (picked != null) {
                      setState(() {
                        selectedImage = File(picked.path);
                      });

                      Navigator.pop(context); // close dialog
                      updateProfile(); // upload image
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.35),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

}
