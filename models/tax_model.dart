class TaxModel {
  bool? success;
  int? count;
  List<Data>? data;

  TaxModel({this.success, this.count, this.data});

  TaxModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    count = json['count'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['count'] = this.count;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? id;
  String? name;
  String? taxType;
  String? status;
  String? displayRate;
  String? effectiveRate;
  List<Components>? components;
  String? createdAt;

  Data(
      {this.id,
        this.name,
        this.taxType,
        this.status,
        this.displayRate,
        this.effectiveRate,
        this.components,
        this.createdAt});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    taxType = json['tax_type'];
    status = json['status'];
    displayRate = json['display_rate'];
    effectiveRate = json['effective_rate'];
    if (json['components'] != null) {
      components = <Components>[];
      json['components'].forEach((v) {
        components!.add(new Components.fromJson(v));
      });
    }
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['tax_type'] = this.taxType;
    data['status'] = this.status;
    data['display_rate'] = this.displayRate;
    data['effective_rate'] = this.effectiveRate;
    if (this.components != null) {
      data['components'] = this.components!.map((v) => v.toJson()).toList();
    }
    data['created_at'] = this.createdAt;
    return data;
  }
}

class Components {
  String? name;
  int? rate;
  bool? isCompound;
  bool? isNonRecoverable;

  Components({this.name, this.rate, this.isCompound, this.isNonRecoverable});

  Components.fromJson(Map<String, dynamic> json) {
    name = json['Name'];
    rate = json['Rate'];
    isCompound = json['IsCompound'];
    isNonRecoverable = json['IsNonRecoverable'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Name'] = this.name;
    data['Rate'] = this.rate;
    data['IsCompound'] = this.isCompound;
    data['IsNonRecoverable'] = this.isNonRecoverable;
    return data;
  }
}
