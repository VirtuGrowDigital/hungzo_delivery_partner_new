class UpdateCartQuantityModel {
  String? message;
  bool? status;
  List<Cart>? cart;

  UpdateCartQuantityModel({this.message, this.status, this.cart});

  UpdateCartQuantityModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    status = json['status'];
    if (json['cart'] != null) {
      cart = [];
      json['cart'].forEach((v) {
        cart?.add(Cart.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['message'] = message;
    data['status'] = status;
    if (cart != null) {
      data['cart'] = cart?.map((v) => v.toJson()).toList();
    }
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
  int? quantity;
  String? description;
  List<String>? images;
  String? createdAt;
  String? updatedAt;
  int? iV;

  ProductId(
      {this.sId,
        this.category,
        this.brand,
        this.title,
        this.price,
        this.quantity,
        this.description,
        this.images,
        this.createdAt,
        this.updatedAt,
        this.iV});

  ProductId.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    category = json['category'];
    brand = json['brand'];
    title = json['title'];
    price = json['price'];
    quantity = json['quantity'];
    description = json['description'];
    images = json['images']?.cast<String>();
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['_id'] = sId;
    data['category'] = category;
    data['brand'] = brand;
    data['title'] = title;
    data['price'] = price;
    data['quantity'] = quantity;
    data['description'] = description;
    data['images'] = images;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}
