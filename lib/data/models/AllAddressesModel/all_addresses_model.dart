class AllAddressesModel {
  bool? status;
  List<Data>? data;

  AllAddressesModel({this.status, this.data});

  AllAddressesModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? sId;
  String? houseNumber;
  String? area;
  String? pinCode;
  String? city;
  String? state;
  bool? isDefault;
  String? userId;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Data(
      {this.sId,
        this.houseNumber,
        this.area,
        this.pinCode,
        this.city,
        this.state,
        this.isDefault,
        this.userId,
        this.createdAt,
        this.updatedAt,
        this.iV});

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    houseNumber = json['houseNumber'];
    area = json['area'];
    pinCode = json['pinCode'];
    city = json['city'];
    state = json['state'];
    isDefault = json['isDefault'];
    userId = json['userId'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['houseNumber'] = houseNumber;
    data['area'] = area;
    data['pinCode'] = pinCode;
    data['city'] = city;
    data['state'] = state;
    data['isDefault'] = isDefault;
    data['userId'] = userId;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}
