class TransactionModel {
  final bool? status;
  final String? razorpayOrderId;
  final String? message;
  final int? amount;
  final String? currency;
  final String? receipt;

  TransactionModel({
    this.status,
    this.razorpayOrderId,
    this.message,
    this.amount,
    this.currency,
    this.receipt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      status: json['status'] as bool?,
      razorpayOrderId: json['razorpayOrderId'] as String?,
      message: json['message'] as String?,
      amount: json['amount'] as int?,
      currency: json['currency'] as String?,
      receipt: json['receipt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'razorpayOrderId': razorpayOrderId,
      'message': message,
      'amount': amount,
      'currency': currency,
      'receipt': receipt,
    };
  }
}
