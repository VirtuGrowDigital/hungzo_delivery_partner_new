class HomeModel {
  bool? status;  // Nullable
  String? message;  // Nullable
  Data? data;  // Nullable

  HomeModel({this.status, this.message, this.data});

  HomeModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = <String, dynamic>{};
    dataMap['status'] = status;
    dataMap['message'] = message;
    if (data != null) {
      dataMap['data'] = data?.toJson();
    }
    return dataMap;
  }
}

class Data {
  List<HomeBanner>? banner;  // Nullable (Renamed from 'Banner' to 'HomeBanner')
  List<SuperCategory>? superCategory;  // Nullable
  List<OriginalSPareParts>? originalSPareParts;  // Nullable
  List<PopularWorkshops>? popularWorkshops;  // Nullable

  Data({
    this.banner,
    this.superCategory,
    this.originalSPareParts,
    this.popularWorkshops,
  });

  Data.fromJson(Map<String, dynamic> json) {
    if (json['banner'] != null) {
      banner = List<HomeBanner>.from(json['banner'].map((v) => HomeBanner.fromJson(v)));
    }

    if (json['superCategory'] != null) {
      superCategory = List<SuperCategory>.from(json['superCategory'].map((v) => SuperCategory.fromJson(v)));
    }

    if (json['OriginalSPareParts'] != null) {
      originalSPareParts = List<OriginalSPareParts>.from(json['OriginalSPareParts'].map((v) => OriginalSPareParts.fromJson(v)));
    }

    if (json['popularWorkshops'] != null) {
      popularWorkshops = List<PopularWorkshops>.from(json['popularWorkshops'].map((v) => PopularWorkshops.fromJson(v)));
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = <String, dynamic>{};
    dataMap['banner'] = banner?.map((v) => v.toJson()).toList();
    dataMap['superCategory'] = superCategory?.map((v) => v.toJson()).toList();
    dataMap['OriginalSPareParts'] = originalSPareParts?.map((v) => v.toJson()).toList();
    dataMap['popularWorkshops'] = popularWorkshops?.map((v) => v.toJson()).toList();
    return dataMap;
  }
}

class HomeBanner {  // Renamed from Banner to HomeBanner
  String? img;  // Nullable
  String? title;  // Nullable
  String? sId;  // Nullable

  HomeBanner({this.img, this.title, this.sId});

  HomeBanner.fromJson(Map<String, dynamic> json) {
    img = json['img'];
    title = json['title'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = <String, dynamic>{};
    dataMap['img'] = img;
    dataMap['title'] = title;
    dataMap['_id'] = sId;
    return dataMap;
  }
}

class SuperCategory {
  String? img;  // Nullable
  String? title;  // Nullable
  String? sId;  // Nullable

  SuperCategory({this.img, this.title, this.sId});

  SuperCategory.fromJson(Map<String, dynamic> json) {
    img = json['img'];
    title = json['title'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = <String, dynamic>{};
    dataMap['img'] = img;
    dataMap['title'] = title;
    dataMap['_id'] = sId;
    return dataMap;
  }
}

class OriginalSPareParts {
  String? img;  // Nullable
  String? title;  // Nullable
  String? sId;  // Nullable

  OriginalSPareParts({this.img, this.title, this.sId});

  OriginalSPareParts.fromJson(Map<String, dynamic> json) {
    img = json['img'];
    title = json['title'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = <String, dynamic>{};
    dataMap['img'] = img;
    dataMap['title'] = title;
    dataMap['_id'] = sId;
    return dataMap;
  }
}

class PopularWorkshops {
  Address? address;  // Nullable
  String? sId;  // Nullable
  String? workshopName;  // Nullable
  String? ownerName;  // Nullable
  List<String>? numbers;  // Nullable
  List<String>? workshopImage;  // Nullable
  List<dynamic>? services;  // Nullable
  String? createdAt;  // Nullable
  String? updatedAt;  // Nullable
  int? iV;  // Nullable
  String? username;  // Nullable
  bool? available;  // Nullable
  String? email;  // Nullable
  bool? isAdvertised;  // Nullable

  PopularWorkshops({
    this.address,
    this.sId,
    this.workshopName,
    this.ownerName,
    this.numbers,
    this.workshopImage,
    this.services,
    this.createdAt,
    this.updatedAt,
    this.iV,
    this.username,
    this.available,
    this.email,
    this.isAdvertised,
  });

  PopularWorkshops.fromJson(Map<String, dynamic> json) {
    address = json['address'] != null ? Address.fromJson(json['address']) : null;
    sId = json['_id'];
    workshopName = json['workshopName'];
    ownerName = json['ownerName'];
    numbers = json['numbers'] != null ? List<String>.from(json['numbers']) : null;
    workshopImage = json['workshopImage'] != null ? List<String>.from(json['workshopImage']) : null;
    services = json['services'] != null ? List<dynamic>.from(json['services']) : null;
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    username = json['username'];
    available = json['available'];
    email = json['email'];
    isAdvertised = json['isAdvertised'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = <String, dynamic>{};
    if (address != null) {
      dataMap['address'] = address?.toJson();
    }
    dataMap['_id'] = sId;
    dataMap['workshopName'] = workshopName;
    dataMap['ownerName'] = ownerName;
    dataMap['numbers'] = numbers;
    dataMap['workshopImage'] = workshopImage;
    dataMap['services'] = services;
    dataMap['createdAt'] = createdAt;
    dataMap['updatedAt'] = updatedAt;
    dataMap['__v'] = iV;
    dataMap['username'] = username;
    dataMap['available'] = available;
    dataMap['email'] = email;
    dataMap['isAdvertised'] = isAdvertised;
    return dataMap;
  }
}

class Address {
  String? text;  // Nullable
  List<double>? coordinates;  // Nullable

  Address({this.text, this.coordinates});

  Address.fromJson(Map<String, dynamic> json) {
    text = json['text'];
    coordinates = json['coordinates'] != null ? List<double>.from(json['coordinates']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = <String, dynamic>{};
    dataMap['text'] = text;
    dataMap['coordinates'] = coordinates;
    return dataMap;
  }
}
