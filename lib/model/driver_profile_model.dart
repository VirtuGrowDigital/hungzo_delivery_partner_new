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
}
