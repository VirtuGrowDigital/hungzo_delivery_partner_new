class UpdateAddressModel {
  bool? status; // Nullable status
  String? message; // Nullable message
  Data? data; // Nullable Data object containing the address details

  UpdateAddressModel({this.status, this.message, this.data});

  // Factory method to create an object from JSON
  UpdateAddressModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  // Method to convert the object back to JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data?.toJson();
    }
    return data;
  }
}

class Data {
  String? sId; // Nullable
  String? houseNumber; // Nullable
  String? area; // Nullable
  String? pinCode; // Nullable
  String? city; // Nullable
  String? state; // Nullable
  bool? isDefault; // Nullable
  String? userId; // Nullable
  String? createdAt; // Nullable
  String? updatedAt; // Nullable
  int? iV; // Nullable

  Data({
    this.sId,
    this.houseNumber,
    this.area,
    this.pinCode,
    this.city,
    this.state,
    this.isDefault,
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.iV,
  });

  // Factory method to create a Data object from JSON
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

  // Method to convert the Data object back to JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['_id'] = this.sId;
    data['houseNumber'] = this.houseNumber;
    data['area'] = this.area;
    data['pinCode'] = this.pinCode;
    data['city'] = this.city;
    data['state'] = this.state;
    data['isDefault'] = this.isDefault;
    data['userId'] = this.userId;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}
