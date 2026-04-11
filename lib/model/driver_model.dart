class DriverModel {
  final String uid;
  final String name;
  final String vehicleType;
  final String vehicleNumber;
  final String aadharUrl;
  final String licenseUrl;
  final String vehicleUrl;
  final String? profilePic;

  DriverModel({
    required this.uid,
    required this.name,
    required this.vehicleType,
    required this.vehicleNumber,
    required this.aadharUrl,
    required this.licenseUrl,
    required this.vehicleUrl,
    this.profilePic,
  });

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "name": name,
      "vehicleType": vehicleType,
      "vehicleNumber": vehicleNumber,
      "aadharImage": aadharUrl,
      "licenseImage": licenseUrl,
      "vehicleImage": vehicleUrl,
      "profilePic": profilePic,
      "createdAt": DateTime.now().toIso8601String(),
    };
  }
}