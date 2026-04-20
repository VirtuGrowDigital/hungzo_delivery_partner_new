class DriverProfileModel {
  final String driverId;
  final String name;
  final String phone;
  final String? email;
  final String? profilePic;
  final String vehicleType;
  final String vehicleNumber;
  final String verificationStatus;
  final bool isActive;
  final bool isOnline;

  DriverProfileModel({
    required this.driverId,
    required this.name,
    required this.phone,
    this.email,
    this.profilePic,
    required this.vehicleType,
    required this.vehicleNumber,
    required this.verificationStatus,
    required this.isActive,
    required this.isOnline,
  });

  factory DriverProfileModel.fromJson(Map<String, dynamic> json) {
    return DriverProfileModel(
      driverId: json['driverId'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'],
      profilePic: json['profilePic'],
      vehicleType: json['vehicleType'] ?? '',
      vehicleNumber: json['vehicleNumber'] ?? '',
      verificationStatus: json['verificationStatus'] ?? '',
      isActive: json['isActive'] ?? false,
      isOnline: json['isOnline'] ?? false,
    );
  }

  DriverProfileModel copyWith({
    String? driverId,
    String? name,
    String? phone,
    String? email,
    String? profilePic,
    String? vehicleType,
    String? vehicleNumber,
    String? verificationStatus,
    bool? isActive,
    bool? isOnline,
  }) {
    return DriverProfileModel(
      driverId: driverId ?? this.driverId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      profilePic: profilePic ?? this.profilePic,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      isActive: isActive ?? this.isActive,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}
