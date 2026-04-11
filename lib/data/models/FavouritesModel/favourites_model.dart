class FavouritesModel {
  String? message;
  bool? status;
  List<String>? favorites;

  FavouritesModel({this.message, this.status, this.favorites});

  FavouritesModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    status = json['status'];
    favorites = json['favorites'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    data['status'] = status;
    data['favorites'] = favorites;
    return data;
  }
}