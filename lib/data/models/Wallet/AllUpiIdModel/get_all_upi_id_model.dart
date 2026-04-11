class GetUpiIdModel {
  bool? success;
  List<String>? upiIds;

  GetUpiIdModel({this.success, this.upiIds});

  GetUpiIdModel.fromJson(Map<String, dynamic> json) {
    try {
      success = json['success'] ?? false;
      upiIds = (json['upiIds'] as List?)?.map((e) => e.toString()).toList() ?? [];
    } catch (e) {
      throw Exception("Failed to parse API response");
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'upiIds': upiIds,
    };
  }
}
