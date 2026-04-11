class WithdrawModel {
  bool? status;
  String? message;
  Data? data;

  WithdrawModel({this.status, this.message, this.data});

  WithdrawModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  String? withdrawalId;
  int? amount;
  String? status;
  String? createdAt;
  String? estimatedProcessingTime;

  Data(
      {this.withdrawalId,
        this.amount,
        this.status,
        this.createdAt,
        this.estimatedProcessingTime});

  Data.fromJson(Map<String, dynamic> json) {
    withdrawalId = json['withdrawalId'];
    amount = json['amount'];
    status = json['status'];
    createdAt = json['createdAt'];
    estimatedProcessingTime = json['estimatedProcessingTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['withdrawalId'] = this.withdrawalId;
    data['amount'] = this.amount;
    data['status'] = this.status;
    data['createdAt'] = this.createdAt;
    data['estimatedProcessingTime'] = this.estimatedProcessingTime;
    return data;
  }
}