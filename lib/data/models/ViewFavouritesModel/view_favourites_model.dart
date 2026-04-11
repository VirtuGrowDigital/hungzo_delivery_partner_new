class ViewFavouritesModel {
  String? message;
  bool? status;
  List<Favorites>? favorites;

  ViewFavouritesModel({this.message, this.status, this.favorites});

  /// Factory constructor to parse JSON into a `ViewFavouritesModel` object.
  factory ViewFavouritesModel.fromJson(Map<String, dynamic> json) {
    return ViewFavouritesModel(
      message: json['message'] as String?,
      status: json['status'] as bool?,
      favorites: (json['favorites'] as List<dynamic>?)?.map((v) => Favorites.fromJson(v as Map<String, dynamic>)).toList(),
    );
  }

  /// Converts the `ViewFavouritesModel` object into a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'status': status,
      'favorites': favorites?.map((v) => v.toJson()).toList(),
    };
  }
}

class Favorites {
  String? sId;
  String? category;
  String? brand;
  String? title;
  int? price;
  List<String>? images;

  Favorites({
    this.sId,
    this.category,
    this.brand,
    this.title,
    this.price,
    this.images,
  });

  /// Factory constructor to parse JSON into a `Favorites` object.
  factory Favorites.fromJson(Map<String, dynamic> json) {
    return Favorites(
      sId: json['_id'] as String?,
      category: json['category'] as String?,
      brand: json['brand'] as String?,
      title: json['title'] as String?,
      price: json['price'] as int?,
      images: (json['images'] as List<dynamic>?)?.map((item) => item as String).toList(),
    );
  }

  /// Converts the `Favorites` object into a JSON map.
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
