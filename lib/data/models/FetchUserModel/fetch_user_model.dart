class FetchUserModel {
  Data? data;
  bool? status;
  String? message;

  FetchUserModel({this.data, this.status, this.message});

  FetchUserModel.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    status = json['status'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['status'] = this.status;
    data['message'] = this.message;
    return data;
  }
}

class Data {
  dynamic withdrawalLimits;
  dynamic withdrawalStats;
  dynamic qualificationStatus;
  dynamic kycDetails;
  dynamic deviceInfo;
  String? sId;
  String? fullName;
  String? number;
  List<String>? upiIds;
  String? email;
  bool? isActive;
  String? status;
  dynamic sponsor;
  int? level;
  List<String>? downline;
  String? mlmStatus;
  double? commissionBalance;
  double? totalEarnings;
  int? walletBalance;
  int? investmentBalance;
  int? withdrawalThreshold;
  int? dailIncome;
  int? monthlyIncome;
  int? lifeTimeEarned;
  int? monthlyPV;
  int? monthlyGV;
  List<String>? addresses;
  List<String>? orders;
  List<String>? transactions;
  List<dynamic>? services;
  List<dynamic>? bankAccounts;
  List<dynamic>? favorites;
  String? accountType;
  String? kycStatus;
  List<dynamic>? withdrawals;
  List<dynamic>? commissionHistory;
  String? createdAt;
  String? updatedAt;
  String? referralCode;
  int? iV;
  List<dynamic>? cart;
  int? dailyIncome;
  int? totalRecahrge;
  int? directReferralsCount;
  dynamic availableForWithdrawal;
  String? id;

  Data({
    this.withdrawalLimits,
    this.withdrawalStats,
    this.qualificationStatus,
    this.kycDetails,
    this.deviceInfo,
    this.sId,
    this.fullName,
    this.number,
    this.upiIds,
    this.email,
    this.isActive,
    this.status,
    this.sponsor,
    this.level,
    this.downline,
    this.mlmStatus,
    this.commissionBalance,
    this.totalEarnings,
    this.walletBalance,
    this.investmentBalance,
    this.withdrawalThreshold,
    this.dailIncome,
    this.monthlyIncome,
    this.lifeTimeEarned,
    this.monthlyPV,
    this.monthlyGV,
    this.addresses,
    this.orders,
    this.transactions,
    this.services,
    this.bankAccounts,
    this.favorites,
    this.accountType,
    this.kycStatus,
    this.withdrawals,
    this.commissionHistory,
    this.createdAt,
    this.updatedAt,
    this.referralCode,
    this.iV,
    this.cart,
    this.dailyIncome,
    this.totalRecahrge,
    this.directReferralsCount,
    this.availableForWithdrawal,
    this.id
  });

  Data.fromJson(Map<String, dynamic> json) {
    withdrawalLimits = json['withdrawalLimits'];
    withdrawalStats = json['withdrawalStats'];
    qualificationStatus = json['qualificationStatus'];
    kycDetails = json['kycDetails'];
    deviceInfo = json['deviceInfo'];
    sId = json['_id'];
    fullName = json['fullName'];
    number = json['number'];
    upiIds = json['upiIds']?.cast<String>();
    email = json['email'];
    isActive = json['isActive'];
    status = json['status'];
    sponsor = json['sponsor'];
    level = json['level'];
    downline = json['downline']?.cast<String>();
    mlmStatus = json['mlmStatus'];
    commissionBalance = json['commissionBalance'];
    totalEarnings = json['totalEarnings'];
    walletBalance = json['walletBalance'];
    investmentBalance = json['InvestmentBalance'];
    withdrawalThreshold = json['withdrawalThreshold'];
    dailIncome = json['dailIncome'];
    monthlyIncome = json['monthlyIncome'];
    lifeTimeEarned = json['lifeTimeEarned'];
    monthlyPV = json['monthlyPV'];
    monthlyGV = json['monthlyGV'];
    addresses = json['addresses']?.cast<String>();
    orders = json['orders']?.cast<String>();
    transactions = json['transactions']?.cast<String>();
    services = json['services'];
    bankAccounts = json['bankAccounts'];
    favorites = json['favorites'];
    accountType = json['accountType'];
    kycStatus = json['kycStatus'];
    withdrawals = json['withdrawals'];
    commissionHistory = json['commissionHistory'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    referralCode = json['referralCode'];
    iV = json['__v'];
    cart = json['cart'];
    dailyIncome = json['dailyIncome'];
    totalRecahrge = json['totalRecahrge'];
    directReferralsCount = json['directReferralsCount'];
    availableForWithdrawal = json['availableForWithdrawal'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['withdrawalLimits'] = withdrawalLimits;
    data['withdrawalStats'] = withdrawalStats;
    data['qualificationStatus'] = qualificationStatus;
    data['kycDetails'] = kycDetails;
    data['deviceInfo'] = deviceInfo;
    data['_id'] = sId;
    data['fullName'] = fullName;
    data['number'] = number;
    data['upiIds'] = upiIds;
    data['email'] = email;
    data['isActive'] = isActive;
    data['status'] = status;
    data['sponsor'] = sponsor;
    data['level'] = level;
    data['downline'] = downline;
    data['mlmStatus'] = mlmStatus;
    data['commissionBalance'] = commissionBalance;
    data['totalEarnings'] = totalEarnings;
    data['walletBalance'] = walletBalance;
    data['InvestmentBalance'] = investmentBalance;
    data['withdrawalThreshold'] = withdrawalThreshold;
    data['dailIncome'] = dailIncome;
    data['monthlyIncome'] = monthlyIncome;
    data['lifeTimeEarned'] = lifeTimeEarned;
    data['monthlyPV'] = monthlyPV;
    data['monthlyGV'] = monthlyGV;
    data['addresses'] = addresses;
    data['orders'] = orders;
    data['transactions'] = transactions;
    data['services'] = services;
    data['bankAccounts'] = bankAccounts;
    data['favorites'] = favorites;
    data['accountType'] = accountType;
    data['kycStatus'] = kycStatus;
    data['withdrawals'] = withdrawals;
    data['commissionHistory'] = commissionHistory;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['referralCode'] = referralCode;
    data['__v'] = iV;
    data['cart'] = cart;
    data['dailyIncome'] = dailyIncome;
    data['totalRecahrge'] = totalRecahrge;
    data['directReferralsCount'] = directReferralsCount;
    data['availableForWithdrawal'] = availableForWithdrawal;
    data['id'] = id;
    return data;
  }
}