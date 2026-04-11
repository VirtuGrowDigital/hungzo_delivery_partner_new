class UserModel {
  final String id;
  final String firebaseUid;
  final String phone;
  final String? email;
  final String role;
  final bool isVerified;
  final List<String> fcmTokens;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;

  const UserModel({
    required this.id,
    required this.firebaseUid,
    required this.phone,
    required this.email,
    required this.role,
    required this.isVerified,
    required this.fcmTokens,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
  });

  /// ================= FROM JSON =================
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '',
      firebaseUid: json['firebaseUid'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'],
      role: json['role'] ?? '',
      isVerified: json['isVerified'] ?? false,
      fcmTokens: List<String>.from(json['fcmTokens'] ?? []),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ??
          DateTime.now(),
      version: json['__v'] ?? 0,
    );
  }

  /// ================= TO JSON =================
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'firebaseUid': firebaseUid,
      'phone': phone,
      'email': email,
      'role': role,
      'isVerified': isVerified,
      'fcmTokens': fcmTokens,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': version,
    };
  }

  /// ================= COPY WITH =================
  UserModel copyWith({
    String? id,
    String? firebaseUid,
    String? phone,
    String? email,
    String? role,
    bool? isVerified,
    List<String>? fcmTokens,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? version,
  }) {
    return UserModel(
      id: id ?? this.id,
      firebaseUid: firebaseUid ?? this.firebaseUid,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      role: role ?? this.role,
      isVerified: isVerified ?? this.isVerified,
      fcmTokens: fcmTokens ?? this.fcmTokens,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
    );
  }
}
// class DriverModel {
//   final String uid;
//   final String name;
//   final String vehicleType;
//   final String vehicleNumber;
//   final String aadharUrl;
//   final String licenseUrl;
//   final String vehicleUrl;
//   final String? profilePic;
//
//   DriverModel({
//     required this.uid,
//     required this.name,
//     required this.vehicleType,
//     required this.vehicleNumber,
//     required this.aadharUrl,
//     required this.licenseUrl,
//     required this.vehicleUrl,
//     this.profilePic,
//   });
//
//   Map<String, dynamic> toMap() {
//     return {
//       "uid": uid,
//       "name": name,
//       "vehicleType": vehicleType,
//       "vehicleNumber": vehicleNumber,
//       "aadharUrl": aadharUrl,
//       "licenseUrl": licenseUrl,
//       "vehicleUrl": vehicleUrl,
//       "profilePic": profilePic,
//     };
//   }
// }