import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../controllers/auth_controller.dart';
import '../../utils/ColorConstants.dart';
import '../../utils/snack_bar.dart';

class CreateAccountScreen extends StatefulWidget {
  final User user;
  const CreateAccountScreen({super.key, required this.user});

  @override
  State<CreateAccountScreen> createState() =>
      _CreateAccountScreenState();
}

class _CreateAccountScreenState
    extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthController _authController =
  Get.find<AuthController>();

  final _nameController = TextEditingController();
  final _vehicleNumberController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  File? _profileImage;
  File? _aadharImage;
  File? _licenseImage;
  File? _vehicleImage;

  String? _selectedVehicleType;

  /// ✅ MATCHES BACKEND ENUM
  final List<String> _vehicleTypes = [
    "BIKE",
    "SCOOTY",
    "PICKUP",
  ];

  // ================= IMAGE PICK =================

  Future<void> _pickImage(Function(File) onSelected) async {
    final XFile? image =
    await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      onSelected(File(image.path));
      setState(() {});
    }
  }

  String? _validateRequired(String? value, String field) {
    if (value == null || value.trim().isEmpty) {
      return "$field is required";
    }
    return null;
  }

  // ================= SUBMIT =================

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      CustomSnackBar("Fix form errors", "E");
      return;
    }

    if (_selectedVehicleType == null ||
        _aadharImage == null ||
        _licenseImage == null ||
        _vehicleImage == null) {
      CustomSnackBar("Please complete all fields", "E");
      return;
    }

    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      await _authController.createDriverProfile(
        name: _nameController.text.trim(),
        vehicleType: _selectedVehicleType!,
        vehicleNumber:
        _vehicleNumberController.text.trim().toUpperCase(),
        aadharImage: _aadharImage!,
        licenseImage: _licenseImage!,
        vehicleImage: _vehicleImage!,
      );

      Get.back();
    } catch (e) {
      Get.back();
    }
  }

  // ================= INPUT =================

  Widget _input(String hint,
      {required TextEditingController controller}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextFormField(
        controller: controller,
        validator: (v) => _validateRequired(v, hint),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: const Icon(Icons.edit_outlined),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // ================= DROPDOWN =================

  Widget _vehicleDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: DropdownButtonFormField<String>(
        value: _selectedVehicleType,
        items: _vehicleTypes
            .map((e) => DropdownMenuItem(
          value: e,
          child: Text(e),
        ))
            .toList(),
        onChanged: (val) =>
            setState(() => _selectedVehicleType = val),
        validator: (v) =>
        v == null ? "Vehicle type required" : null,
        decoration: InputDecoration(
          hintText: "Select Vehicle Type",
          prefixIcon: const Icon(Icons.two_wheeler),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // ================= IMAGE CARD =================

  Widget _imagePicker(
      String title, File? image, Function(File) onPick) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _pickImage(onPick),
          child: Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border:
              Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                )
              ],
            ),
            child: image == null
                ? const Center(
              child: Column(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_upload_outlined,
                      size: 28),
                  SizedBox(height: 6),
                  Text("Tap to upload"),
                ],
              ),
            )
                : ClipRRect(
              borderRadius:
              BorderRadius.circular(16),
              child: Image.file(image,
                  fit: BoxFit.cover),
            ),
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      ColorConstants.scaffoldBackground,
      appBar: AppBar(
        title: const Text("Create Driver Profile"),
        centerTitle: true,
        elevation: 0,
        backgroundColor:
        ColorConstants.scaffoldBackground,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding:
            const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 16),

                // ================= PROFILE IMAGE =================
                GestureDetector(
                  onTap: () =>
                      _pickImage((f) => _profileImage = f),
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 55,
                        backgroundColor: Colors.white,
                        backgroundImage:
                        _profileImage != null
                            ? FileImage(_profileImage!)
                            : null,
                        child: _profileImage == null
                            ? const Icon(Icons.person,
                            size: 40)
                            : null,
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt,
                            size: 16, color: Colors.white),
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                _input("Full Name",
                    controller: _nameController),

                _vehicleDropdown(),

                _input("Vehicle Number",
                    controller: _vehicleNumberController),

                const SizedBox(height: 10),

                _imagePicker("Aadhar Image", _aadharImage,
                        (f) => _aadharImage = f),

                _imagePicker("License Image", _licenseImage,
                        (f) => _licenseImage = f),

                _imagePicker("Vehicle Image", _vehicleImage,
                        (f) => _vehicleImage = f),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      ColorConstants.success,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      "Submit",
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
