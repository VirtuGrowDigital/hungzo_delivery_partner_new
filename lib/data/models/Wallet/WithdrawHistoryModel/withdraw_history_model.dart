class WithdrawHistoryModel {
  bool? status;
  String? message;
  Data? data;

  WithdrawHistoryModel({this.status, this.message, this.data});

  WithdrawHistoryModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> jsonData = <String, dynamic>{};
    jsonData['status'] = status;
    jsonData['message'] = message;
    if (data != null) {
      jsonData['data'] = data!.toJson();
    }
    return jsonData;
  }
}

class Data {
  List<Withdrawals>? withdrawals;
  Pagination? pagination;
  Balances? balances;

  Data({this.withdrawals, this.pagination, this.balances});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['withdrawals'] != null) {
      withdrawals = <Withdrawals>[];
      json['withdrawals'].forEach((v) {
        withdrawals!.add(Withdrawals.fromJson(v));
      });
    }
    pagination =
    json['pagination'] != null ? Pagination.fromJson(json['pagination']) : null;
    balances = json['balances'] != null ? Balances.fromJson(json['balances']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> jsonData = <String, dynamic>{};
    if (withdrawals != null) {
      jsonData['withdrawals'] = withdrawals!.map((v) => v.toJson()).toList();
    }
    if (pagination != null) {
      jsonData['pagination'] = pagination!.toJson();
    }
    if (balances != null) {
      jsonData['balances'] = balances!.toJson();
    }
    return jsonData;
  }
}

class Withdrawals {
  String? sId;
  int? amount;
  String? status;
  String? withdrawalType;
  String? createdAt;

  Withdrawals({this.sId, this.amount, this.status, this.withdrawalType, this.createdAt});

  Withdrawals.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    amount = json['amount'];
    status = json['status'];
    withdrawalType = json['withdrawalType'];
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> jsonData = <String, dynamic>{};
    jsonData['_id'] = sId;
    jsonData['amount'] = amount;
    jsonData['status'] = status;
    jsonData['withdrawalType'] = withdrawalType;
    jsonData['createdAt'] = createdAt;
    return jsonData;
  }
}

class Pagination {
  int? total;
  int? page;
  int? limit;
  int? pages;

  Pagination({this.total, this.page, this.limit, this.pages});

  Pagination.fromJson(Map<String, dynamic> json) {
    total = json['total'];
    page = json['page'];
    limit = json['limit'];
    pages = json['pages'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> jsonData = <String, dynamic>{};
    jsonData['total'] = total;
    jsonData['page'] = page;
    jsonData['limit'] = limit;
    jsonData['pages'] = pages;
    return jsonData;
  }
}

class Balances {
  int? wallet;
  double? commission;

  Balances({this.wallet, this.commission});

  Balances.fromJson(Map<String, dynamic> json) {
    wallet = json['wallet'];
    commission = json['commission'] is int
        ? (json['commission'] as int).toDouble()
        : json['commission'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> jsonData = <String, dynamic>{};
    jsonData['wallet'] = wallet;
    jsonData['commission'] = commission;
    return jsonData;
  }
}



// class WithdrawHistoryModel {
//   bool? status;
//   String? message;
//   Data? data;
//
//   WithdrawHistoryModel({this.status, this.message, this.data});
//
//   WithdrawHistoryModel.fromJson(Map<String, dynamic> json) {
//     status = json['status'];
//     message = json['message'];
//     data = json['data'] != null ? new Data.fromJson(json['data']) : null;
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['status'] = this.status;
//     data['message'] = this.message;
//     if (this.data != null) {
//       data['data'] = this.data!.toJson();
//     }
//     return data;
//   }
// }
//
// class Data {
//   List<Withdrawals>? withdrawals;
//   Pagination? pagination;
//   Balances? balances;
//
//   Data({this.withdrawals, this.pagination, this.balances});
//
//   Data.fromJson(Map<String, dynamic> json) {
//     if (json['withdrawals'] != null) {
//       withdrawals = <Withdrawals>[];
//       json['withdrawals'].forEach((v) {
//         withdrawals!.add(new Withdrawals.fromJson(v));
//       });
//     }
//     pagination = json['pagination'] != null
//         ? new Pagination.fromJson(json['pagination'])
//         : null;
//     balances = json['balances'] != null
//         ? new Balances.fromJson(json['balances'])
//         : null;
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     if (this.withdrawals != null) {
//       data['withdrawals'] = this.withdrawals!.map((v) => v.toJson()).toList();
//     }
//     if (this.pagination != null) {
//       data['pagination'] = this.pagination!.toJson();
//     }
//     if (this.balances != null) {
//       data['balances'] = this.balances!.toJson();
//     }
//     return data;
//   }
// }
//
// class Withdrawals {
//   String? sId;
//   int? amount;
//   String? status;
//   String? withdrawalType;
//   String? createdAt;
//
//   Withdrawals(
//       {this.sId,
//         this.amount,
//         this.status,
//         this.withdrawalType,
//         this.createdAt});
//
//   Withdrawals.fromJson(Map<String, dynamic> json) {
//     sId = json['_id'];
//     amount = json['amount'];
//     status = json['status'];
//     withdrawalType = json['withdrawalType'];
//     createdAt = json['createdAt'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['_id'] = this.sId;
//     data['amount'] = this.amount;
//     data['status'] = this.status;
//     data['withdrawalType'] = this.withdrawalType;
//     data['createdAt'] = this.createdAt;
//     return data;
//   }
// }
//
// class Pagination {
//   int? total;
//   int? page;
//   int? limit;
//   int? pages;
//
//   Pagination({this.total, this.page, this.limit, this.pages});
//
//   Pagination.fromJson(Map<String, dynamic> json) {
//     total = json['total'];
//     page = json['page'];
//     limit = json['limit'];
//     pages = json['pages'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['total'] = this.total;
//     data['page'] = this.page;
//     data['limit'] = this.limit;
//     data['pages'] = this.pages;
//     return data;
//   }
// }
//
// class Balances {
//   int? wallet;
//   int? commission;
//
//   Balances({this.wallet, this.commission});
//
//   Balances.fromJson(Map<String, dynamic> json) {
//     wallet = json['wallet'];
//     commission = json['commission'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['wallet'] = this.wallet;
//     data['commission'] = this.commission;
//     return data;
//   }
// }