class MlmDownLinesModel {
  bool? status;
  String? message;
  Data? data;

  MlmDownLinesModel({this.status, this.message, this.data});

  MlmDownLinesModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data?.toJson();
    }
    return data;
  }
}

class Data {
  int? totalMembers;
  List<LevelStats>? levelStats;
  List<MembersByLevel>? membersByLevel;

  Data({this.totalMembers, this.levelStats, this.membersByLevel});

  Data.fromJson(Map<String, dynamic> json) {
    totalMembers = json['totalMembers'];
    levelStats = (json['levelStats'] as List?)?.map((v) => LevelStats.fromJson(v)).toList() ?? [];
    membersByLevel = (json['membersByLevel'] as List?)?.map((v) => MembersByLevel.fromJson(v)).toList() ?? [];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['totalMembers'] = totalMembers;
    if (levelStats != null) {
      data['levelStats'] = levelStats!.map((v) => v.toJson()).toList();
    }
    if (membersByLevel != null) {
      data['membersByLevel'] = membersByLevel!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class LevelStats {
  int? level;
  int? totalMembers;
  int? activeMembers;
  int? totalVolume;
  String? commissionRate;

  LevelStats({
    this.level,
    this.totalMembers,
    this.activeMembers,
    this.totalVolume,
    this.commissionRate,
  });

  LevelStats.fromJson(Map<String, dynamic> json) {
    level = json['level'];
    totalMembers = json['totalMembers'];
    activeMembers = json['activeMembers'];
    totalVolume = json['totalVolume'];
    commissionRate = json['commissionRate'];
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'totalMembers': totalMembers,
      'activeMembers': activeMembers,
      'totalVolume': totalVolume,
      'commissionRate': commissionRate,
    };
  }
}

class MembersByLevel {
  int? level;
  List<Members>? members;

  MembersByLevel({this.level, this.members});

  MembersByLevel.fromJson(Map<String, dynamic> json) {
    level = json['level'];
    members = (json['members'] as List?)?.map((v) => Members.fromJson(v)).toList() ?? [];
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'members': members?.map((v) => v.toJson()).toList(),
    };
  }
}

class Members {
  String? id;
  String? fullName;
  String? email;
  String? status;
  String? referralCode;
  int? personalVolume;
  String? joinedAt;
  int? directReferralsCount;
  Sponsor? sponsor;

  Members({
    this.id,
    this.fullName,
    this.email,
    this.status,
    this.referralCode,
    this.personalVolume,
    this.joinedAt,
    this.directReferralsCount,
    this.sponsor,
  });

  Members.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fullName = json['fullName'];
    email = json['email'];
    status = json['status'];
    referralCode = json['referralCode'];
    personalVolume = json['personalVolume'];
    joinedAt = json['joinedAt'];
    directReferralsCount = json['directReferralsCount'];
    sponsor = json['sponsor'] != null ? Sponsor.fromJson(json['sponsor']) : null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'status': status,
      'referralCode': referralCode,
      'personalVolume': personalVolume,
      'joinedAt': joinedAt,
      'directReferralsCount': directReferralsCount,
      if (sponsor != null) 'sponsor': sponsor?.toJson(),
    };
  }
}

class Sponsor {
  String? id;
  String? name;
  String? email;
  String? referralCode;

  Sponsor({this.id, this.name, this.email, this.referralCode});

  Sponsor.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    referralCode = json['referralCode'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'referralCode': referralCode,
    };
  }
}
