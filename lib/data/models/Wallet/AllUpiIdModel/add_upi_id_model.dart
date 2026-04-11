class AddUpiIdModel {
  bool? success;
  String? message;
  List<String>? upiIds;

  AddUpiIdModel({this.success, this.message, this.upiIds});

  AddUpiIdModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    upiIds = json['upiIds'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    data['upiIds'] = this.upiIds;
    return data;
  }
}