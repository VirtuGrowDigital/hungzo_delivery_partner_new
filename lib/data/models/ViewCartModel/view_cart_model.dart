class ViewCartModel {
  String? message;
  bool? status;
  List<Cart>? cart;

  ViewCartModel({ this.message,  this.status,  this.cart});

  factory ViewCartModel.fromJson(Map<String, dynamic> json) {
    return ViewCartModel(
      message: json['message'] ?? '',
      status: json['status'] ?? false,
      cart: json['cart'] != null
          ? List<Cart>.from(json['cart'].map((v) => Cart.fromJson(v)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'status': status,
      'cart': cart?.map((v) => v.toJson()).toList(),  // Convert each cart item to JSON
    };
  }
}

class Cart {
  ProductId? productId;
  int? quantity;
  String? sId;

  Cart({ this.productId,  this.quantity,  this.sId});

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      productId: json['productId'] != null
          ? ProductId.fromJson(json['productId'])
          : ProductId(sId: '', category: '', brand: '', title: '', price: 0, images: []),
      quantity: json['quantity'] ?? 0,
      sId: json['_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId?.toJson(),
      'quantity': quantity,
      '_id': sId,
    };
  }
}

class ProductId {
  String? sId;
  String? category;
  String? brand;
  String? title;
  int? price;
  List<String>? images;

  ProductId({
      this.sId,
     this.category,
     this.brand,
     this.title,
     this.price,
     this.images,
  });

  factory ProductId.fromJson(Map<String, dynamic> json) {
    return ProductId(
      sId: json['_id'] ?? '',
      category: json['category'] ?? '',
      brand: json['brand'] ?? '',
      title: json['title'] ?? '',
      price: json['price'] ?? 0,
      images: List<String>.from(json['images'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': sId,
      'category': category,
      'brand': brand,
      'title': title,
      'price': price,
      'images': images,
    };
  }
}
