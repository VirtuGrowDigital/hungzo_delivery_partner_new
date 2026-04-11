class AddAddressModel {
  bool? status;
  String? message;
  Data? data;

  AddAddressModel({this.status, this.message, this.data});

  AddAddressModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data?.toJson();
    }
    return data;
  }
}

class Data {
  String? houseNumber;
  String? area;
  String? pinCode;
  String? city;
  String? state;
  bool? isDefault;
  String? userId;
  String? sId;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Data({
    this.houseNumber,
    this.area,
    this.pinCode,
    this.city,
    this.state,
    this.isDefault,
    this.userId,
    this.sId,
    this.createdAt,
    this.updatedAt,
    this.iV,
  });

  Data.fromJson(Map<String, dynamic> json) {
    houseNumber = json['houseNumber'];
    area = json['area'];
    pinCode = json['pinCode'];
    city = json['city'];
    state = json['state'];
    isDefault = json['isDefault'];
    userId = json['userId'];
    sId = json['_id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['houseNumber'] = this.houseNumber;
    data['area'] = this.area;
    data['pinCode'] = this.pinCode;
    data['city'] = this.city;
    data['state'] = this.state;
    data['isDefault'] = this.isDefault;
    data['userId'] = this.userId;
    data['_id'] = this.sId;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}
