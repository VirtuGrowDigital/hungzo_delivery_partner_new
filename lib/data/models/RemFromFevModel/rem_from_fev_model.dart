class RemFromFevModel {
  String? message;
  bool? status;
  List<String>? favorites;

  RemFromFevModel({this.message, this.status, this.favorites});

  RemFromFevModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    status = json['status'];
    if (json['favorites'] != null) {
      favorites = List<String>.from(json['favorites']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['message'] = message;
    data['status'] = status;
    data['favorites'] = favorites;
    return data;
  }
}
