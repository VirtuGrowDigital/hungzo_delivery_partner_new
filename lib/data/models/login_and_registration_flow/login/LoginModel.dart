class LoginModel {
  bool? status;
  String? message;
  String? accessToken;
  String? refreshToken;
  UserModel? user;

  LoginModel({this.status, this.message, this.accessToken, this.refreshToken, this.user});

  LoginModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    accessToken = json['accessToken'];
    refreshToken = json['refreshToken'];
    user = json['user'] != null ? UserModel.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['status'] = status;
    data['message'] = message;
    data['accessToken'] = accessToken;
    data['refreshToken'] = refreshToken;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }
}

class UserModel {
  String? sId;
  String? fullName;
  String? number;
  String? email;
  String? mlmStatus;
  int? walletBalance;
  String? referralCode;
  int? directReferralsCount;
  AvailableForWithdrawal? availableForWithdrawal;
  String? id;

  UserModel({this.sId, this.fullName, this.number, this.email, this.mlmStatus, this.walletBalance, this.referralCode, this.directReferralsCount, this.availableForWithdrawal, this.id});

  UserModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    fullName = json['fullName'];
    number = json['number'];
    email = json['email'];
    mlmStatus = json['mlmStatus'];
    walletBalance = json['walletBalance'];
    referralCode = json['referralCode'];
    directReferralsCount = json['directReferralsCount'];
    availableForWithdrawal = json['availableForWithdrawal'] != null ? AvailableForWithdrawal.fromJson(json['availableForWithdrawal']) : null;
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['_id'] = sId;
    data['fullName'] = fullName;
    data['number'] = number;
    data['email'] = email;
    data['mlmStatus'] = mlmStatus;
    data['walletBalance'] = walletBalance;
    data['referralCode'] = referralCode;
    data['directReferralsCount'] = directReferralsCount;
    if (availableForWithdrawal != null) {
      data['availableForWithdrawal'] = availableForWithdrawal!.toJson();
    }
    data['id'] = id;
    return data;
  }
}

class AvailableForWithdrawal {
  int? wallet;
  int? commission;
  Minimums? minimums;

  AvailableForWithdrawal({this.wallet, this.commission, this.minimums});

  AvailableForWithdrawal.fromJson(Map<String, dynamic> json) {
    wallet = json['wallet'];
    commission = json['commission'];
    minimums = json['minimums'] != null ? Minimums.fromJson(json['minimums']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['wallet'] = wallet;
    data['commission'] = commission;
    if (minimums != null) {
      data['minimums'] = minimums!.toJson();
    }
    return data;
  }
}

class Minimums {
  int? wallet;
  int? commission;

  Minimums({this.wallet, this.commission});

  Minimums.fromJson(Map<String, dynamic> json) {
    wallet = json['wallet'];
    commission = json['commission'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['wallet'] = wallet;
    data['commission'] = commission;
    return data;
  }
}



// class LoginModel {
//   bool? status;
//   String? message;
//   String? accessToken;
//   String? refreshToken;
//   User? user;
//
//   LoginModel(
//       {this.status,
//         this.message,
//         this.accessToken,
//         this.refreshToken,
//         this.user});
//
//   LoginModel.fromJson(Map<String, dynamic> json) {
//     status = json['status'];
//     message = json['message'];
//     accessToken = json['accessToken'];
//     refreshToken = json['refreshToken'];
//     user = json['user'] != null ? User.fromJson(json['user']) : null;
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['status'] = status;
//     data['message'] = message;
//     data['accessToken'] = accessToken;
//     data['refreshToken'] = refreshToken;
//     if (user != null) {
//       data['user'] = user?.toJson();
//     }
//     return data;
//   }
// }
//
// class User {
//   String? sId;
//   String? fullName;
//   String? number;
//   String? email;
//   String? referralCode;
//
//   User({this.sId, this.fullName, this.number, this.email, this.referralCode});
//
//   User.fromJson(Map<String, dynamic> json) {
//     sId = json['_id'];
//     fullName = json['fullName'];
//     number = json['number'];
//     email = json['email'];
//     referralCode = json['referralCode'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['_id'] = sId;
//     data['fullName'] = fullName;
//     data['number'] = number;
//     data['email'] = email;
//     data['referralCode'] = referralCode;
//     return data;
//   }
// }
