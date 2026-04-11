class CommonModel {
  final bool? status;
  final String? message;
  final String? otp;
  final String? verifyToken;
  final dynamic user;
  final String? accessToken;  // Added accessToken
  final String? refreshToken; // Added refreshToken

  CommonModel({
    this.status,
    this.message,
    this.otp,
    this.user,
    this.verifyToken,
    this.accessToken,      // Added accessToken in constructor
    this.refreshToken,     // Added refreshToken in constructor
  });

  factory CommonModel.fromJson(Map<String, dynamic> json) {
    return CommonModel(
      status: json['status'] ?? false,
      message: json['message'],
      otp: json['otp'],
      verifyToken: json['VerifyToken'],
      user: json['user'],
      accessToken: json['accessToken'],  // Parsing accessToken
      refreshToken: json['refreshToken'], // Parsing refreshToken
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'otp': otp,
      'VerifyToken': verifyToken,
      'user': user,
      'accessToken': accessToken,   // Added accessToken to JSON
      'refreshToken': refreshToken, // Added refreshToken to JSON
    };
  }
}
