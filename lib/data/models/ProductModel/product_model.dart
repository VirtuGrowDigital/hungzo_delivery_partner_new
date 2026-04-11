import 'dart:convert';

class ProductModel {
  final bool? status;
  final String? message;
  final List<Product>? products;

  ProductModel({this.status, this.message, this.products});

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      status: json['status'],
      message: json['message'],
      products: json['products'] != null
          ? List<Product>.from(json['products'].map((x) => Product.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'products': products?.map((x) => x.toJson()).toList(),
    };
  }
}

class Product {
  final String? id;
  final String? category;
  final String? brand;
  final String? title;
  final int? price;
  int quantity;
  final String? description;
  final List<String>? images;

  Product({
    this.id,
    this.category,
    this.brand,
    this.title,
    this.price,
    this.quantity = 1,
    this.description,
    this.images,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'],
      category: json['category'],
      brand: json['brand'],
      title: json['title'],
      price: json['price'],
      quantity: json['quantity'] ?? 1,
      description: json['description'],
      images: json['images'] != null
          ? List<String>.from(json['images'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'category': category,
      'brand': brand,
      'title': title,
      'price': price,
      'quantity': quantity,
      'description': description,
      'images': images,
    };
  }

  static int? _parsePrice(dynamic price) {
    if (price is String) {
      return int.tryParse(price);
    } else if (price is int) {
      return price;
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Product &&
              runtimeType == other.runtimeType &&
              id == other.id; // Compare using unique ID

  @override
  int get hashCode => id.hashCode;

}




// To parse this JSON data, do
//
//     final menuModel = menuModelFromJson(jsonString);


MenuModel menuModelFromJson(String str) => MenuModel.fromJson(json.decode(str));

String menuModelToJson(MenuModel data) => json.encode(data.toJson());

class MenuModel {
  bool? success;
  List<Menu>? menu;

  MenuModel({
    this.success,
    this.menu,
  });

  factory MenuModel.fromJson(Map<String, dynamic> json) => MenuModel(
    success: json["success"],
    menu: json["menu"] == null ? [] : List<Menu>.from(json["menu"]!.map((x) => Menu.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "menu": menu == null ? [] : List<dynamic>.from(menu!.map((x) => x.toJson())),
  };
}

class Menu {
  String? id;
  List<Product>? products;
  String? category;

  Menu({
    this.id,
    this.products,
    this.category,
  });

  factory Menu.fromJson(Map<String, dynamic> json) => Menu(
    id: json["_id"],
    products: json["products"] == null ? [] : List<Product>.from(json["products"]!.map((x) => Product.fromJson(x))),
    category: json["category"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "products": products == null ? [] : List<dynamic>.from(products!.map((x) => x.toJson())),
    "category": category,
  };
}

class Products {
  String? id;
  String? name;
  String? description;
  List<dynamic>? images;
  List<Variety>? varieties;

  Products({
    this.id,
    this.name,
    this.description,
    this.images,
    this.varieties,
  });

  factory Products.fromJson(Map<String, dynamic> json) => Products(
    id: json["_id"],
    name: json["name"],
    description: json["description"],
    images: json["images"] == null ? [] : List<dynamic>.from(json["images"]!.map((x) => x)),
    varieties: json["varieties"] == null ? [] : List<Variety>.from(json["varieties"]!.map((x) => Variety.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "description": description,
    "images": images == null ? [] : List<dynamic>.from(images!.map((x) => x)),
    "varieties": varieties == null ? [] : List<dynamic>.from(varieties!.map((x) => x.toJson())),
  };
}

class Variety {
  String? name;
  int? price;
  bool? isAvailable;
  String? id;

  Variety({
    this.name,
    this.price,
    this.isAvailable,
    this.id,
  });

  factory Variety.fromJson(Map<String, dynamic> json) => Variety(
    name: json["name"],
    price: json["price"],
    isAvailable: json["isAvailable"],
    id: json["_id"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "price": price,
    "isAvailable": isAvailable,
    "_id": id,
  };
}
