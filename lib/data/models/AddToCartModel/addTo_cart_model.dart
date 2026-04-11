class AddToCartModel {
  bool? status;
  String? message;
  List<Cart>? cart;
  int? totalItems;
  int? totalQuantity;

  AddToCartModel(
      {this.status,
        this.message,
        this.cart,
        this.totalItems,
        this.totalQuantity});

  AddToCartModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['cart'] != null) {
      cart = [];
      json['cart'].forEach((v) {
        cart?.add(Cart.fromJson(v));
      });
    }
    totalItems = json['totalItems'];
    totalQuantity = json['totalQuantity'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['status'] = status;
    data['message'] = message;
    if (cart != null) {
      data['cart'] = cart?.map((v) => v.toJson()).toList();
    }
    data['totalItems'] = totalItems;
    data['totalQuantity'] = totalQuantity;
    return data;
  }
}

class Cart {
  ProductId? productId;
  int? quantity;
  String? sId;

  Cart({this.productId, this.quantity, this.sId});

  Cart.fromJson(Map<String, dynamic> json) {
    productId = json['productId'] != null
        ? ProductId.fromJson(json['productId'])
        : null;
    quantity = json['quantity'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (productId != null) {
      data['productId'] = productId?.toJson();
    }
    data['quantity'] = quantity;
    data['_id'] = sId;
    return data;
  }
}

class ProductId {
  String? sId;
  String? category;
  String? brand;
  String? title;
  int? price;
  List<String>? images;

  ProductId(
      {this.sId,
        this.category,
        this.brand,
        this.title,
        this.price,
        this.images});

  ProductId.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    category = json['category'];
    brand = json['brand'];
    title = json['title'];
    price = json['price'];
    images = json['images']?.cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['_id'] = sId;
    data['category'] = category;
    data['brand'] = brand;
    data['title'] = title;
    data['price'] = price;
    data['images'] = images;
    return data;
  }
}




// class AddToCartModel {
//   String? message;
//   bool? status;
//   List<Cart>? cart;
//
//   AddToCartModel({this.message, this.status, this.cart});
//
//   AddToCartModel.fromJson(Map<String, dynamic> json) {
//     message = json['message'];
//     status = json['status'];
//     if (json['cart'] != null) {
//       cart = List<Cart>.from(json['cart'].map((v) => Cart.fromJson(v)));
//     }
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = {};
//     data['message'] = message;
//     data['status'] = status;
//     if (cart != null) {
//       data['cart'] = cart!.map((v) => v.toJson()).toList();
//     }
//     return data;
//   }
// }
//
// class Cart {
//   String? productId;
//   int? quantity;
//   String? sId;
//
//   Cart({this.productId, this.quantity, this.sId});
//
//   Cart.fromJson(Map<String, dynamic> json) {
//     productId = json['productId'];
//     quantity = json['quantity'];
//     sId = json['_id'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = {};
//     data['productId'] = productId;
//     data['quantity'] = quantity;
//     data['_id'] = sId;
//     return data;
//   }
// }
