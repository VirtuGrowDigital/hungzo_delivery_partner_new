class DriverProfileModel {
  final String driverId;
  final String name;
  final String phone;
  final String? email;
  final String? profilePic;
  final String vehicleType;
  final String vehicleNumber;
  final String verificationStatus;
  final String accountStatus;
  final bool isBlocked;
  final String? blockType;
  final String? restrictionReasonCode;
  final String? restrictionReasonText;
  final DateTime? blockedAt;
  final DateTime? blockedUntil;
  final bool isActive;
  final bool isOnline;
  final double ratingAverage;
  final int ratingCount;

  DriverProfileModel({
    required this.driverId,
    required this.name,
    required this.phone,
    this.email,
    this.profilePic,
    required this.vehicleType,
    required this.vehicleNumber,
    required this.verificationStatus,
    required this.accountStatus,
    required this.isBlocked,
    this.blockType,
    this.restrictionReasonCode,
    this.restrictionReasonText,
    this.blockedAt,
    this.blockedUntil,
    required this.isActive,
    required this.isOnline,
    required this.ratingAverage,
    required this.ratingCount,
  });

  factory DriverProfileModel.fromJson(Map<String, dynamic> json) {
    final restriction = json['restriction'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(json['restriction'])
        : <String, dynamic>{};

    return DriverProfileModel(
      driverId: json['driverId'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'],
      profilePic: json['profilePic'],
      vehicleType: json['vehicleType'] ?? '',
      vehicleNumber: json['vehicleNumber'] ?? '',
      verificationStatus: json['verificationStatus'] ?? '',
      accountStatus:
          restriction['accountStatus'] ?? json['accountStatus'] ?? 'ACTIVE',
      isBlocked: restriction['isBlocked'] ?? false,
      blockType: restriction['blockType'],
      restrictionReasonCode: restriction['reasonCode'],
      restrictionReasonText: restriction['reasonText'],
      blockedAt: restriction['blockedAt'] != null
          ? DateTime.tryParse(restriction['blockedAt'].toString())
          : null,
      blockedUntil: restriction['blockedUntil'] != null
          ? DateTime.tryParse(restriction['blockedUntil'].toString())
          : null,
      isActive: json['isActive'] ?? false,
      isOnline: json['isOnline'] ?? false,
      ratingAverage: (json['ratingAverage'] ?? 0).toDouble(),
      ratingCount: json['ratingCount'] ?? 0,
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
    String? accountStatus,
    bool? isBlocked,
    String? blockType,
    String? restrictionReasonCode,
    String? restrictionReasonText,
    DateTime? blockedAt,
    DateTime? blockedUntil,
    bool? isActive,
    bool? isOnline,
    double? ratingAverage,
    int? ratingCount,
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
      accountStatus: accountStatus ?? this.accountStatus,
      isBlocked: isBlocked ?? this.isBlocked,
      blockType: blockType ?? this.blockType,
      restrictionReasonCode:
          restrictionReasonCode ?? this.restrictionReasonCode,
      restrictionReasonText:
          restrictionReasonText ?? this.restrictionReasonText,
      blockedAt: blockedAt ?? this.blockedAt,
      blockedUntil: blockedUntil ?? this.blockedUntil,
      isActive: isActive ?? this.isActive,
      isOnline: isOnline ?? this.isOnline,
      ratingAverage: ratingAverage ?? this.ratingAverage,
      ratingCount: ratingCount ?? this.ratingCount,
    );
  }
}
