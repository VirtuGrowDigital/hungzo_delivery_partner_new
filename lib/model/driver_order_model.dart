class DriverOrderModel {
  final String orderId;
  final double amount;
  final double subTotal;
  final double deliveryCharge;
  final String customerName;
  final String customerPhone;
  final String address;
  final String city;
  final String state;
  final String pincode;
  final double? lat;
  final double? lng;
  final double? driverLat;
  final double? driverLng;
  final List<DriverOrderItem> items;
  final String driverStatus;
  final String orderStatus;
  final String paymentStatus;
  final String paymentMethod;
  final String deliveryPaymentMethod;
  final String deliveryPaymentStatus;
  final String? qrUrl;
  final String? rejectionReasonCode;
  final String? rejectionReasonNote;
  final String? failureReasonCode;
  final String? failureReasonNote;
  final DateTime? rejectedAt;
  final DateTime? failedAt;
  final DateTime? acceptedAt;
  final DateTime? pickedAt;
  final DateTime? deliveredAt;
  final DateTime? createdAt;
  final String deliveryConfirmationMethod;
  final String deliveryRecipientName;
  final DateTime? deliveryConfirmedAt;
  final List<String> proofPhotos;
  final String proofNote;

  const DriverOrderModel({
    required this.orderId,
    required this.amount,
    required this.subTotal,
    required this.deliveryCharge,
    required this.customerName,
    required this.customerPhone,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    required this.lat,
    required this.lng,
    required this.driverLat,
    required this.driverLng,
    required this.items,
    required this.driverStatus,
    required this.orderStatus,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.deliveryPaymentMethod,
    required this.deliveryPaymentStatus,
    required this.qrUrl,
    required this.rejectionReasonCode,
    required this.rejectionReasonNote,
    required this.failureReasonCode,
    required this.failureReasonNote,
    required this.rejectedAt,
    required this.failedAt,
    required this.acceptedAt,
    required this.pickedAt,
    required this.deliveredAt,
    required this.createdAt,
    required this.deliveryConfirmationMethod,
    required this.deliveryRecipientName,
    required this.deliveryConfirmedAt,
    required this.proofPhotos,
    required this.proofNote,
  });

  bool get isPickedUp => driverStatus == "PICKED_UP";
  bool get isDelivered =>
      driverStatus == "DELIVERED" || orderStatus == "Delivered";
  bool get isRejectedByUser =>
      driverStatus == "REJECTED_BY_USER" ||
      rejectionReasonCode == "USER_ISSUE" ||
      failureReasonCode == "CUSTOMER_REJECTED";
  bool get isDeliveryFailed => driverStatus == "DELIVERY_FAILED";
  bool get requiresCollection => paymentStatus != "paid";
  bool get isQrPending => deliveryPaymentStatus == "QR_PENDING";

  factory DriverOrderModel.fromJson(Map<String, dynamic> json) {
    final address = Map<String, dynamic>.from(json["address"] ?? const {});
    final customer = Map<String, dynamic>.from(json["customer"] ?? const {});
    final location = json["location"] is Map<String, dynamic>
        ? Map<String, dynamic>.from(json["location"])
        : const <String, dynamic>{};
    final driverLocation = json["driverLocation"] is Map<String, dynamic>
        ? Map<String, dynamic>.from(json["driverLocation"])
        : const <String, dynamic>{};
    final deliveryPayment = json["deliveryPayment"] is Map<String, dynamic>
        ? Map<String, dynamic>.from(json["deliveryPayment"])
        : const <String, dynamic>{};
    final rejection = json["rejection"] is Map<String, dynamic>
        ? Map<String, dynamic>.from(json["rejection"])
        : const <String, dynamic>{};
    final failure = json["failure"] is Map<String, dynamic>
        ? Map<String, dynamic>.from(json["failure"])
        : const <String, dynamic>{};
    final timeline = json["timeline"] is Map<String, dynamic>
        ? Map<String, dynamic>.from(json["timeline"])
        : const <String, dynamic>{};
    final deliveryVerification =
        json["deliveryVerification"] is Map<String, dynamic>
        ? Map<String, dynamic>.from(json["deliveryVerification"])
        : const <String, dynamic>{};

    return DriverOrderModel(
      orderId: (json["orderId"] ?? "").toString(),
      amount: _num(json["amount"]),
      subTotal: _num(json["subTotal"]),
      deliveryCharge: _num(json["deliveryCharge"]),
      customerName: (customer["name"] ?? "Customer").toString(),
      customerPhone: (customer["phone"] ?? "").toString(),
      address: (address["full"] ?? "").toString(),
      city: (address["city"] ?? "").toString(),
      state: (address["state"] ?? "").toString(),
      pincode: (address["pincode"] ?? "").toString(),
      lat: _nullableNum(location["lat"]),
      lng: _nullableNum(location["lng"]),
      driverLat: _nullableNum(driverLocation["lat"]),
      driverLng: _nullableNum(driverLocation["lng"]),
      items: (json["items"] as List<dynamic>? ?? const [])
          .map(
            (item) => DriverOrderItem.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(),
      driverStatus: (json["driverStatus"] ?? "").toString(),
      orderStatus: (json["orderStatus"] ?? "").toString(),
      paymentStatus: (json["paymentStatus"] ?? "").toString(),
      paymentMethod: (json["paymentMethod"] ?? "").toString(),
      deliveryPaymentMethod: (deliveryPayment["method"] ?? "NONE").toString(),
      deliveryPaymentStatus: (deliveryPayment["status"] ?? "NONE").toString(),
      qrUrl: deliveryPayment["qrUrl"]?.toString(),
      rejectionReasonCode: rejection["reasonCode"]?.toString(),
      rejectionReasonNote: rejection["reasonNote"]?.toString(),
      failureReasonCode: failure["reasonCode"]?.toString(),
      failureReasonNote: failure["reasonNote"]?.toString(),
      rejectedAt: _date(rejection["rejectedAt"]),
      failedAt: _date(failure["failedAt"] ?? timeline["failedAt"]),
      acceptedAt: _date(timeline["acceptedAt"]),
      pickedAt: _date(timeline["pickedAt"]),
      deliveredAt: _date(timeline["deliveredAt"]),
      createdAt: _date(json["createdAt"]),
      deliveryConfirmationMethod:
          (deliveryVerification["method"] ?? "NONE").toString(),
      deliveryRecipientName:
          (deliveryVerification["recipientName"] ?? "").toString(),
      deliveryConfirmedAt: _date(deliveryVerification["confirmedAt"]),
      proofPhotos: (deliveryVerification["proofPhotos"] as List<dynamic>? ??
              const [])
          .map((item) => item.toString())
          .toList(),
      proofNote: (deliveryVerification["proofNote"] ?? "").toString(),
    );
  }

  DriverOrderModel copyWith({
    double? driverLat,
    double? driverLng,
    String? deliveryPaymentStatus,
    String? paymentStatus,
    String? driverStatus,
    String? orderStatus,
    String? qrUrl,
    String? rejectionReasonCode,
    String? rejectionReasonNote,
    DateTime? rejectedAt,
    String? failureReasonCode,
    String? failureReasonNote,
    DateTime? failedAt,
    String? deliveryConfirmationMethod,
    String? deliveryRecipientName,
    DateTime? deliveryConfirmedAt,
    List<String>? proofPhotos,
    String? proofNote,
  }) {
    return DriverOrderModel(
      orderId: orderId,
      amount: amount,
      subTotal: subTotal,
      deliveryCharge: deliveryCharge,
      customerName: customerName,
      customerPhone: customerPhone,
      address: address,
      city: city,
      state: state,
      pincode: pincode,
      lat: lat,
      lng: lng,
      driverLat: driverLat ?? this.driverLat,
      driverLng: driverLng ?? this.driverLng,
      items: items,
      driverStatus: driverStatus ?? this.driverStatus,
      orderStatus: orderStatus ?? this.orderStatus,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod,
      deliveryPaymentMethod: deliveryPaymentMethod,
      deliveryPaymentStatus:
          deliveryPaymentStatus ?? this.deliveryPaymentStatus,
      qrUrl: qrUrl ?? this.qrUrl,
      rejectionReasonCode: rejectionReasonCode ?? this.rejectionReasonCode,
      rejectionReasonNote: rejectionReasonNote ?? this.rejectionReasonNote,
      rejectedAt: rejectedAt ?? this.rejectedAt,
      failureReasonCode: failureReasonCode ?? this.failureReasonCode,
      failureReasonNote: failureReasonNote ?? this.failureReasonNote,
      failedAt: failedAt ?? this.failedAt,
      acceptedAt: acceptedAt,
      pickedAt: pickedAt,
      deliveredAt: deliveredAt,
      createdAt: createdAt,
      deliveryConfirmationMethod:
          deliveryConfirmationMethod ?? this.deliveryConfirmationMethod,
      deliveryRecipientName:
          deliveryRecipientName ?? this.deliveryRecipientName,
      deliveryConfirmedAt: deliveryConfirmedAt ?? this.deliveryConfirmedAt,
      proofPhotos: proofPhotos ?? this.proofPhotos,
      proofNote: proofNote ?? this.proofNote,
    );
  }

  static double _num(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? "") ?? 0;
  }

  static double? _nullableNum(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static DateTime? _date(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}

class DriverOrderItem {
  final String name;
  final int quantity;
  final double price;
  final double total;

  const DriverOrderItem({
    required this.name,
    required this.quantity,
    required this.price,
    required this.total,
  });

  factory DriverOrderItem.fromJson(Map<String, dynamic> json) {
    return DriverOrderItem(
      name: (json["name"] ?? "").toString(),
      quantity: (json["quantity"] as num?)?.toInt() ?? 0,
      price: DriverOrderModel._num(json["price"]),
      total: DriverOrderModel._num(json["total"]),
    );
  }
}
