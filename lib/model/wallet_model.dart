class WalletModel {
  final int balance;
  final List<WalletTransaction> transactions;

  WalletModel({
    required this.balance,
    required this.transactions,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      balance: json['wallet']['balance'],
      transactions: (json['wallet']['transactions'] as List)
          .map((e) => WalletTransaction.fromJson(e))
          .toList(),
    );
  }
}

class WalletTransaction {
  final String id;
  final String type;
  final int amount;
  final String reason;
  final String? note;
  final String status;
  final String createdAt;

  WalletTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.reason,
    this.note,
    required this.status,
    required this.createdAt,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['_id'],
      type: json['type'],
      amount: json['amount'],
      reason: json['reason'],
      note: json['note'],
      status: json['status'],
      createdAt: json['createdAt'],
    );
  }
}
