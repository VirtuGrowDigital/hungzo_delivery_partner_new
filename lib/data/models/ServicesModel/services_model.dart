class ServiceModel {
  NewService? newService;
  String? message;
  bool? status;

  ServiceModel({this.newService, this.message, this.status});

  ServiceModel.fromJson(Map<String, dynamic> json) {
    newService = json['newService'] != null
        ? NewService.fromJson(json['newService'])
        : null;
    message = json['message'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (newService != null) {
      data['newService'] = newService?.toJson();
    }
    data['message'] = message;
    data['status'] = status;
    return data;
  }
}

class NewService {
  String? customerID;
  String? paymentStatus;
  String? workshopID;
  String? serviceType;
  String? status;
  String? sId;
  String? createdAt;
  String? updatedAt;
  int? iV;

  NewService(
      {this.customerID,
        this.paymentStatus,
        this.workshopID,
        this.serviceType,
        this.status,
        this.sId,
        this.createdAt,
        this.updatedAt,
        this.iV});

  NewService.fromJson(Map<String, dynamic> json) {
    customerID = json['customerID'];
    paymentStatus = json['paymentStatus'];
    workshopID = json['workshopID'];
    serviceType = json['serviceType'];
    status = json['status'];
    sId = json['_id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['customerID'] = customerID;
    data['paymentStatus'] = paymentStatus;
    data['workshopID'] = workshopID;
    data['serviceType'] = serviceType;
    data['status'] = status;
    data['_id'] = sId;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}