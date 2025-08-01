import 'package:point_of_sales/models/sale%20summary/product_summary_model.dart';

class InvoiceSummaryModel {
  final int id;
  final int userId;
  final String customerName;
  final String datedToday;
  final String dueToday;
  final String invoiceNumber;
  final String totalAmount;
  final List<ProductSummaryModel> products;

  InvoiceSummaryModel({
    required this.id,
    required this.userId,
    required this.customerName,
    required this.datedToday,
    required this.dueToday,
    required this.invoiceNumber,
    required this.totalAmount,
    required this.products,
  });

  factory InvoiceSummaryModel.fromJson(Map<String, dynamic> json) {
    return InvoiceSummaryModel(
      id: json['id'],
      userId: json['user_id'],
      customerName: json['customer_name'],
      datedToday: json['dated_today'],
      dueToday: json['due_today'],
      invoiceNumber: json['invoice_number'],
      totalAmount: json['total_amount'],
      products: (json['products'] as List)
          .map((item) => ProductSummaryModel.fromJson(item))
          .toList(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'customer_name': customerName,
      'dated_today': datedToday,
      'due_today': dueToday,
      'invoice_number': invoiceNumber,
      'total_amount': totalAmount,
      'products': products.map((product) => product.toJson()).toList(),
    };
  }

}
