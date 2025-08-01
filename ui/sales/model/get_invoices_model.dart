class GetInvoiceModel {
  bool? success;
  List<Invoices>? invoices;

  GetInvoiceModel({this.success, this.invoices});

  GetInvoiceModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['invoices'] != null) {
      invoices = <Invoices>[];
      json['invoices'].forEach((v) {
        invoices!.add(new Invoices.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.invoices != null) {
      data['invoices'] = this.invoices!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Invoices {
  int? id;
  int? userId;
  String? accountId;
  String? contactId;
  String? customerName;
  String? datedToday;
  String? dueToday;
  String? invoiceNumber;
  String? totalAmount;
  String? taxAmount;
  String? createdAt;
  String? accountName;
  List<Products>? products;

  Invoices(
      {this.id,
        this.userId,
        this.accountId,
        this.contactId,
        this.customerName,
        this.datedToday,
        this.dueToday,
        this.invoiceNumber,
        this.totalAmount,
        this.taxAmount,
        this.createdAt,
        this.accountName,
        this.products});

  Invoices.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    accountId = json['account_id'];
    contactId = json['contact_id'];
    customerName = json['customer_name'];
    datedToday = json['dated_today'];
    dueToday = json['due_today'];
    invoiceNumber = json['invoice_number'];
    totalAmount = json['total_amount'];
    taxAmount = json['tax_amount'];
    createdAt = json['created_at'];
    accountName = json['account_name'];
    if (json['products'] != null) {
      products = <Products>[];
      json['products'].forEach((v) {
        products!.add(new Products.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['account_id'] = this.accountId;
    data['contact_id'] = this.contactId;
    data['customer_name'] = this.customerName;
    data['dated_today'] = this.datedToday;
    data['due_today'] = this.dueToday;
    data['invoice_number'] = this.invoiceNumber;
    data['total_amount'] = this.totalAmount;
    data['tax_amount'] = this.taxAmount;
    data['created_at'] = this.createdAt;
    data['account_name'] = this.accountName;
    if (this.products != null) {
      data['products'] = this.products!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Products {
  String? productId;
  String? productName;

  Products({this.productId, this.productName});

  Products.fromJson(Map<String, dynamic> json) {
    productId = json['product_id'];
    productName = json['product_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['product_id'] = this.productId;
    data['product_name'] = this.productName;
    return data;
  }
}
