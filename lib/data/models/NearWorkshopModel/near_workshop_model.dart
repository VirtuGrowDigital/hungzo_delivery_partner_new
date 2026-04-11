class NearWorkshopModel {
  bool? status;
  String? message;
  List<Workshop>? workshops;

  NearWorkshopModel({
    this.status,
    this.message,
    this.workshops,
  });

  factory NearWorkshopModel.fromJson(Map<String, dynamic> json) {
    return NearWorkshopModel(
      status: json['status'],
      message: json['message'],
      workshops: json['workshops'] != null
          ? List<Workshop>.from(
          json['workshops'].map((x) => Workshop.fromJson(x)))
          : [],
    );
  }

  // Method to convert the model to JSON
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'workshops': workshops != null
          ? List<dynamic>.from(workshops!.map((x) => x.toJson()))
          : [],
    };
  }
}

class Workshop {
  String? id;
  String? workshopName;
  String? ownerName;
  List<String>? numbers;
  Address? address;
  List<String>? workshopImage;
  String? distance;
  String? googleMapLink;

  Workshop({
    this.id,
    this.workshopName,
    this.ownerName,
    this.numbers,
    this.address,
    this.workshopImage,
    this.distance,
    this.googleMapLink,
  });

  // Method to create an instance from JSON
  factory Workshop.fromJson(Map<String, dynamic> json) {
    return Workshop(
      id: json['_id'],
      workshopName: json['workshopName'],
      ownerName: json['ownerName'],
      numbers: json['numbers'] != null
          ? List<String>.from(json['numbers'])
          : [],
      address: json['address'] != null
          ? Address.fromJson(json['address'])
          : null,
      workshopImage: json['workshopImage'] != null
          ? List<String>.from(json['workshopImage'])
          : [],
      distance: json['distance'],
      googleMapLink: json['googleMapLink'],
    );
  }

  // Method to convert the model to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'workshopName': workshopName,
      'ownerName': ownerName,
      'numbers': numbers != null ? List<dynamic>.from(numbers!) : [],
      'address': address?.toJson(),
      'workshopImage': workshopImage != null
          ? List<dynamic>.from(workshopImage!)
          : [],
      'distance': distance,
      'googleMapLink': googleMapLink,
    };
  }
}

class Address {
  String? text;
  List<double>? coordinates;

  Address({
    this.text,
    this.coordinates,
  });

  // Method to create an instance from JSON
  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      text: json['text'],
      coordinates: json['coordinates'] != null
          ? List<double>.from(json['coordinates'])
          : [],
    );
  }

  // Method to convert the model to JSON
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'coordinates': coordinates != null ? List<dynamic>.from(coordinates!) : [],
    };
  }
}
