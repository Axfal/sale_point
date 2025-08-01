import 'package:point_of_sales/models/product_model.dart';
import 'package:point_of_sales/models/tax_model.dart';

class InvoiceModel {
  int userId;
  String? accountId;
  String? contactId;
  final String customerName;
  final DateTime datedToday;
  final DateTime dueToday;
  String invoiceNumber;
  final List<ProductModel> products;
  final String? taxStatus;
  final Data? selectedTax;
  final double? taxAmount;
  final double? subtotal;
  final String? paymentMethod;
  final String? notes;

  InvoiceModel({
    required this.userId,
    this.accountId,
    this.contactId,
    required this.customerName,
    required this.datedToday,
    required this.dueToday,
    required this.invoiceNumber,
    required this.products,
    this.taxStatus,
    this.selectedTax,
    this.taxAmount,
    this.subtotal,
    this.paymentMethod,
    this.notes,
  });

  double get totalAmount {
    final baseTotal = products.fold(
        0.0, (sum, product) => sum + (product.salesPrice * product.quantity));
    return taxAmount != null ? baseTotal + taxAmount! : baseTotal;
  }

  String? get taxName => selectedTax?.name;

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      userId: json['user_id'] ?? 0,
      accountId: json['account_id'],
      contactId: json['contact_id'],
      customerName: json["customer_name"] ?? "",
      datedToday:
          DateTime.tryParse(json["dated_today"] ?? "") ?? DateTime.now(),
      dueToday: DateTime.tryParse(json["due_today"] ?? "") ?? DateTime.now(),
      invoiceNumber: json["invoice_number"] ?? "",
      products: (json["products"] as List<dynamic>?)
              ?.map((item) => ProductModel.fromInvoiceJson(item))
              .toList() ??
          [],
      taxStatus: json["tax_status"],
      selectedTax: json["selected_tax"],
      taxAmount: json["tax_amount"]?.toDouble(),
      subtotal: json["subtotal"]?.toDouble(),
      paymentMethod: json["payment_method"],
      notes: json["notes"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "user_id": userId,
      "account_id": accountId,
      "contact_id": contactId,
      "customer_name": customerName,
      "dated_today": _formatDate(datedToday),
      "due_today": _formatDate(dueToday),
      "invoice_number": invoiceNumber,
      "products": products.map((p) => p.toJson()).toList(),
      "tax_status": taxStatus,
      "selected_tax": selectedTax,
      "tax_amount": taxAmount,
      "subtotal": subtotal,
      "payment_method": paymentMethod,
      "notes": notes,
      "tax_name": taxName,
    };
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${_twoDigits(date.month)}-${_twoDigits(date.day)} ${_twoDigits(date.hour)}:${_twoDigits(date.minute)}:${_twoDigits(date.second)}";
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');
}
