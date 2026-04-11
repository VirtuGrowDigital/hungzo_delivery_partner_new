class OrderHistoryModel {
  List<Orders>? orders;
  bool? status;
  String? message;

  OrderHistoryModel({this.orders, this.status, this.message});

  OrderHistoryModel.fromJson(Map<String, dynamic> json) {
    if (json['orders'] != null) {
      orders = [];
      json['orders'].forEach((v) {
        orders!.add(Orders.fromJson(v));
      });
    }
    status = json['status'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (orders != null) {
      data['orders'] = orders!.map((v) => v.toJson()).toList();
    }
    data['status'] = status;
    data['message'] = message;
    return data;
  }
}

class Orders {
  String? sId;
  UserID? userID;
  List<Products>? products;
  int? totalAmount;
  String? address;
  String? paymentStatus;
  String? orderStatus;
  String? transactionID;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Orders(
      {this.sId,
        this.userID,
        this.products,
        this.totalAmount,
        this.address,
        this.paymentStatus,
        this.orderStatus,
        this.transactionID,
        this.createdAt,
        this.updatedAt,
        this.iV});

  Orders.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userID = json['userID'] != null ? UserID.fromJson(json['userID']) : null;
    if (json['products'] != null) {
      products = [];
      json['products'].forEach((v) {
        products!.add(Products.fromJson(v));
      });
    }
    totalAmount = json['totalAmount'];
    address = json['address'];
    paymentStatus = json['paymentStatus'];
    orderStatus = json['orderStatus'];
    transactionID = json['transactionID'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['_id'] = sId;
    if (userID != null) {
      data['userID'] = userID?.toJson();
    }
    if (products != null) {
      data['products'] = products!.map((v) => v.toJson()).toList();
    }
    data['totalAmount'] = totalAmount;
    data['address'] = address;
    data['paymentStatus'] = paymentStatus;
    data['orderStatus'] = orderStatus;
    data['transactionID'] = transactionID;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}

class UserID {
  String? sId;
  String? fullName;
  String? number;

  UserID({this.sId, this.fullName, this.number});

  UserID.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    fullName = json['fullName'];
    number = json['number'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['_id'] = sId;
    data['fullName'] = fullName;
    data['number'] = number;
    return data;
  }
}

class Products {
  Product? product;
  int? quantity;
  String? sId;

  Products({this.product, this.quantity, this.sId});

  Products.fromJson(Map<String, dynamic> json) {
    product = json['product'] != null ? Product.fromJson(json['product']) : null;
    quantity = json['quantity'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (product != null) {
      data['product'] = product?.toJson();
    }
    data['quantity'] = quantity;
    data['_id'] = sId;
    return data;
  }
}

class Product {
  String? sId;
  String? title;
  int? price;
  List<String>? images;

  Product({this.sId, this.title, this.price, this.images});

  Product.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    title = json['title'];
    price = json['price'];
    images = json['images']?.cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['_id'] = sId;
    data['title'] = title;
    data['price'] = price;
    data['images'] = images;
    return data;
  }
}
