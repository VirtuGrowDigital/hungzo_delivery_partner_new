// class WorkshopModel {
//   final List<Workshop>? workshops;
//   final bool? status;
//   final String? message;
//
//   WorkshopModel({
//    this.workshops,
//    this.status,
//     this.message
//   });
//
//   factory WorkshopModel.fromJson(Map<String, dynamic> json) {
//     return WorkshopModel(
//       workshops: (json['workshops'] as List)
//           .map((item) => Workshop.fromJson(item))
//           .toList(),
//       status: json['status'],
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'workshops': workshops!.map((workshop) => workshop.toJson()).toList(),
//       'status': status,
//       'message':message
//     };
//   }
// }
//
// class Workshop {
//   final String? id;
//   final Address? address;
//   final String? workshopName;
//   final String? ownerName;
//   final List<String>? numbers;
//   final List<String>? workshopImage;
//   final DateTime? createdAt;
//   final DateTime? updatedAt;
//   final int? v;
//   final List<String>? services;
//
//   Workshop({
//     this.id,
//     this.address,
//     this.workshopName,
//     this.ownerName,
//     this.numbers,
//     this.workshopImage,
//     this.createdAt,
//     this.updatedAt,
//     this.v,
//    this.services,
//   });
//
//
//   factory Workshop.fromJson(Map<String, dynamic> json) {
//     return Workshop(
//       id: json['_id'],
//       address: Address.fromJson(json['address']),
//       workshopName: json['workshopName'],
//       ownerName: json['ownerName'],
//       numbers: List<String>.from(json['numbers']),
//       workshopImage: List<String>.from(json['workshopImage']),
//       createdAt: DateTime.parse(json['createdAt']),
//       updatedAt: DateTime.parse(json['updatedAt']),
//       v: json['__v'],
//       services: List<String>.from(json['services']),
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       '_id': id,
//       'address': address!.toJson(),
//       'workshopName': workshopName,
//       'ownerName': ownerName,
//       'numbers': numbers,
//       'workshopImage': workshopImage,
//       'createdAt': createdAt!.toIso8601String(),
//       'updatedAt': updatedAt!.toIso8601String(),
//       '__v': v,
//       'services': services,
//     };
//   }
// }
//
// class Address {
//   final String? text;
//   final List<double>? coordinates;
//
//   Address({
//     this.text,
//     this.coordinates,
//   });
//
//   factory Address.fromJson(Map<String, dynamic> json) {
//     return Address(
//       text: json['text'],
//       coordinates: List<double>.from(json['coordinates']),
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'text': text,
//       'coordinates': coordinates,
//     };
//   }
// }
