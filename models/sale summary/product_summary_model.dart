class ProductSummaryModel {
  final String productId;
  final String productName;

  ProductSummaryModel({
    required this.productId,
    required this.productName,
  });

  factory ProductSummaryModel.fromJson(Map<String, dynamic> json) {
    return ProductSummaryModel(
      productId: json['product_id'],
      productName: json['product_name'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
    };
  }
}
