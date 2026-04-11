class RemFromCartModel {
  String? message;
  bool? status;
  List<Cart>? cart;

  RemFromCartModel({this.message, this.status, this.cart});

  RemFromCartModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    status = json['status'];
    if (json['cart'] != null) {
      cart = List<Cart>.from(json['cart'].map((v) => Cart.fromJson(v)));
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['message'] = message;
    data['status'] = status;
    if (cart != null) {
      data['cart'] = cart!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Cart {
  String? productId;
  int? quantity;
  String? sId;

  Cart({this.productId, this.quantity, this.sId});

  Cart.fromJson(Map<String, dynamic> json) {
    productId = json['productId'];
    quantity = json['quantity'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['productId'] = productId;
    data['quantity'] = quantity;
    data['_id'] = sId;
    return data;
  }
}
