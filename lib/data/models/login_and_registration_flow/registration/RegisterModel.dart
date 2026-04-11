// class RegisterModel {
//   bool? status;
//   String? message;
//   User? user;
//   String? accessToken;
//   String? refreshToken;
//
//   RegisterModel(
//       {this.status,
//         this.message,
//         this.user,
//         this.accessToken,
//         this.refreshToken});
//
//   RegisterModel.fromJson(Map<String, dynamic> json) {
//     status = json['status'];
//     message = json['message'];
//     user = json['user'] != null ? User.fromJson(json['user']) : null;
//     accessToken = json['accessToken'];
//     refreshToken = json['refreshToken'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['status'] = status;
//     data['message'] = message;
//     if (user != null) {
//       data['user'] = user?.toJson();
//     }
//     data['accessToken'] = accessToken;
//     data['refreshToken'] = refreshToken;
//     return data;
//   }
// }
//
// class User {
//   String? sId;
//   String? fullName;
//   String? email;
//   String? number;
//   String? referralCode;
//   String? mlmStatus;
//   String? sponsor;
//
//   User(
//       {this.sId,
//         this.fullName,
//         this.email,
//         this.number,
//         this.referralCode,
//         this.mlmStatus,
//         this.sponsor});
//
//   User.fromJson(Map<String, dynamic> json) {
//     sId = json['_id'];
//     fullName = json['fullName'];
//     email = json['email'];
//     number = json['number'];
//     referralCode = json['referralCode'];
//     mlmStatus = json['mlmStatus'];
//     sponsor = json['sponsor'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['_id'] = sId;
//     data['fullName'] = fullName;
//     data['email'] = email;
//     data['number'] = number;
//     data['referralCode'] = referralCode;
//     data['mlmStatus'] = mlmStatus;
//     data['sponsor'] = sponsor;
//     return data;
//   }
// }


import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterModel {
  final bool status;
  final String message;
  final UserModel? user;
  final String? accessToken;
  final String? refreshToken;

  const RegisterModel({
    required this.status,
    required this.message,
    this.user,
    this.accessToken,
    this.refreshToken,
  });

  factory RegisterModel.fromJson(Map<String, dynamic> json) {
    return RegisterModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      user: json['user'] != null
          ? UserModel.fromApi(json['user'])
          : null,
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
    );
  }
}



class UserModel {
  final String uid;
  final String phone;
  final String fullName;
  final String email;
  final String role;

  /// BUSINESS DATA
  final String restaurantName;
  final String restaurantAddress;
  final String city;
  final String state;
  final String pincode;
  final String gstNumber;
  final String fssaiLicenseNumber;

  /// META
  final String profilePhoto;
  final String fcmToken;
  final DateTime createdAt;
  final bool isProfileCompleted;
  final bool isActive;

  const UserModel({
    required this.uid,
    required this.phone,
    required this.fullName,
    required this.email,
    required this.role,
    required this.restaurantName,
    required this.restaurantAddress,
    required this.city,
    required this.state,
    required this.pincode,
    required this.gstNumber,
    required this.fssaiLicenseNumber,
    required this.profilePhoto,
    required this.fcmToken,
    required this.createdAt,
    required this.isProfileCompleted,
    required this.isActive,
  });

  // ================= FROM API =================
  factory UserModel.fromApi(Map<String, dynamic> json) {
    return UserModel(
      uid: json['_id'] ?? '',
      phone: json['number'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',

      restaurantName: '',
      restaurantAddress: '',
      city: '',
      state: '',
      pincode: '',
      gstNumber: '',
      fssaiLicenseNumber: '',

      profilePhoto: '',
      fcmToken: '',
      createdAt: DateTime.now(),
      isProfileCompleted: false,
      isActive: true,
    );
  }

  // ================= FROM FIRESTORE =================
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      phone: map['phone'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'user',
      restaurantName: map['restaurantName'] ?? '',
      restaurantAddress: map['restaurantAddress'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      pincode: map['pincode'] ?? '',
      gstNumber: map['gstNumber'] ?? '',
      fssaiLicenseNumber: map['fssaiLicenseNumber'] ?? '',
      profilePhoto: map['profilePhoto'] ?? '',
      fcmToken: map['fcmToken'] ?? '',
      createdAt:
      (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isProfileCompleted: map['isProfileCompleted'] ?? false,
      isActive: map['isActive'] ?? true,
    );
  }

  // ================= TO FIRESTORE =================
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'phone': phone,
      'fullName': fullName,
      'email': email,
      'role': role,
      'restaurantName': restaurantName,
      'restaurantAddress': restaurantAddress,
      'city': city,
      'state': state,
      'pincode': pincode,
      'gstNumber': gstNumber,
      'fssaiLicenseNumber': fssaiLicenseNumber,
      'profilePhoto': profilePhoto,
      'fcmToken': fcmToken,
      'createdAt': Timestamp.fromDate(createdAt),
      'isProfileCompleted': isProfileCompleted,
      'isActive': isActive,
    };
  }
}

