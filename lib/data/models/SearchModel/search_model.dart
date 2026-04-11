class SearchModel {
  List<Products>? products;
  bool? status;
  String? message;

  SearchModel({this.products, this.status, this.message});

  SearchModel.fromJson(Map<String, dynamic> json) {
    if (json['products'] != null) {
      products = <Products>[];  // Corrected initialization
      json['products'].forEach((v) {
        products!.add(Products.fromJson(v));  // Nullable list handling with '!'
      });
    }
    status = json['status'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (this.products != null) {
      data['products'] = this.products!.map((v) => v.toJson()).toList();
    }
    data['status'] = this.status;
    data['message'] = this.message;
    return data;
  }
}

class Products {
  String? sId;
  String? category;
  String? brand;
  String? title;
  int? price;
  int? quantity;
  String? description;
  List<String>? images;  // List of strings for image URLs
  String? createdAt;
  String? updatedAt;
  int? iV;

  Products(
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

  Products.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    category = json['category'];
    brand = json['brand'];
    title = json['title'];
    price = json['price'];
    quantity = json['quantity'];
    description = json['description'];
    // Handle 'images' field as a list of strings
    images = json['images'] != null ? List<String>.from(json['images']) : null;
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['_id'] = this.sId;
    data['category'] = this.category;
    data['brand'] = this.brand;
    data['title'] = this.title;
    data['price'] = this.price;
    data['quantity'] = this.quantity;
    data['description'] = this.description;
    data['images'] = this.images;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}
