class MyAllServicesModel {
  List<Services>? services;
  bool? status;
  String? message;

  MyAllServicesModel({this.services, this.status, this.message});

  MyAllServicesModel.fromJson(Map<String, dynamic> json) {
    if (json['services'] != null) {
      services = [];
      json['services'].forEach((v) {
        services!.add(Services.fromJson(v));
      });
    }
    status = json['status'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (this.services != null) {
      data['services'] = services!.map((v) => v.toJson()).toList();
    }
    data['status'] = status;
    data['message'] = message;
    return data;
  }
}

class Services {
  String? sId;
  CustomerID? customerID;
  String? workshopID;
  String? serviceType;
  String? status;

  Services(
      {this.sId,
        this.customerID,
        this.workshopID,
        this.serviceType,
        this.status});

  Services.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    customerID = json['customerID'] != null
        ? CustomerID.fromJson(json['customerID'])
        : null;
    workshopID = json['workshopID'];
    serviceType = json['serviceType'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['_id'] = sId;
    if (customerID != null) {
      data['customerID'] = customerID!.toJson();
    }
    data['workshopID'] = workshopID;
    data['serviceType'] = serviceType;
    data['status'] = status;
    return data;
  }
}

class CustomerID {
  String? sId;
  String? fullName;
  String? number;
  String? email;

  CustomerID({this.sId, this.fullName, this.number, this.email});

  CustomerID.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    fullName = json['fullName'];
    number = json['number'];
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['_id'] = sId;
    data['fullName'] = fullName;
    data['number'] = number;
    data['email'] = email;
    return data;
  }
}
