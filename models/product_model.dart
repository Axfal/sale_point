import '../utils/helpers/data_parser.dart';

class ProductModel {
  final int categoryId;
  final String itemId;
  final String productCode;
  final String productName;
  final String productDescription;
  final double salesPrice;
  final String categoryName;
  final String? subCategoryId;
  final String? subCategoryName;
  final String? quantityOnHand;
  final String? imageUrl;
  final List<String> imageUrls;
  int quantity;
  double taxAmount;

  ProductModel({
    required this.categoryId,
    required this.itemId,
    required this.productCode,
    required this.productName,
    required this.productDescription,
    required this.salesPrice,
    required this.categoryName,
    required this.quantityOnHand,
    this.subCategoryId,
    this.subCategoryName,
    this.imageUrl,
    this.imageUrls = const [],
    this.quantity = 1,
    this.taxAmount = 0.0,
  });

  /// ✅ Copy with method to modify fields without changing the original object
  ProductModel copyWith({
    int? categoryId,
    String? itemId,
    String? productCode,
    String? productName,
    String? productDescription,
    double? salesPrice,
    String? categoryName,
    String? subCategoryId,
    String? subCategoryName,
    String? quantityOnHand,
    String? imageUrl,
    List<String>? imageUrls,
    int? quantity,
    double? taxAmount,
  }) {
    return ProductModel(
      categoryId: categoryId ?? this.categoryId,
      itemId: itemId ?? this.itemId,
      productCode: productCode ?? this.productCode,
      productName: productName ?? this.productName,
      productDescription: productDescription ?? this.productDescription,
      salesPrice: salesPrice ?? this.salesPrice,
      categoryName: categoryName ?? this.categoryName,
      subCategoryId: subCategoryId ?? this.subCategoryId,
      subCategoryName: subCategoryName ?? this.subCategoryName,
      quantityOnHand: quantityOnHand ?? this.quantityOnHand,
      imageUrl: imageUrl ?? this.imageUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      quantity: quantity ?? this.quantity,
      taxAmount: taxAmount ?? this.taxAmount,
    );
  }

  /// ✅ Factory constructor to create `ProductModel` from JSON data
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    List<String> urls = [];
    if (json["image_urls"] != null) {
      urls = (json["image_urls"] as List).map((url) => url.toString()).toList();
    }

    return ProductModel(
      categoryId: (json["category_id"] as int?) ?? 0,
      itemId: json["item_id"]?.toString() ?? "",
      productCode: json["code"]?.toString() ?? "N/A",
      productName: json["name"]?.toString() ?? "No Name",
      productDescription: json["description"]?.toString() ?? "No Description",
      salesPrice:
          DataParser.parseDouble(json["sales_price"], defaultValue: 0.0),
      categoryName: json["category_name"]?.toString() ?? "Uncategorized",
      subCategoryId: json["sub_category_id"]?.toString(),
      subCategoryName: json["sub_category_name"]?.toString(),
      quantityOnHand: json["quantity_on_hand"]?.toString(),
      imageUrl: DataParser.validateImageUrl(json["image"]),
      imageUrls: urls,
      quantity: DataParser.parseInt(json["quantity"], defaultValue: 1),
      taxAmount: DataParser.parseDouble(json["tax_amount"], defaultValue: 0.0),
    );
  }

  factory ProductModel.fromInvoiceJson(Map<String, dynamic> json) {
    return ProductModel(
      categoryId: 0,
      itemId: json["product_id"]?.toString() ?? "",
      productCode: "", // This could be null or an empty string
      productName: json["product_name"] ?? "Unnamed Product",
      quantityOnHand: json["quantity_on_hand"] ?? "0.00",
      productDescription: "", // If there's a description, include it here
      salesPrice:
          DataParser.parseDouble(json["product_price"], defaultValue: 0.0),
      categoryName: "", // If you have a category name, include it
      quantity: DataParser.parseInt(json["quantity"], defaultValue: 1),
      taxAmount: DataParser.parseDouble(json["tax_amount"], defaultValue: 0.0),
    );
  }

  /// ✅ Convert `ProductModel` instance to JSON
  Map<String, dynamic> toJson() {
    return {
      "category_id": categoryId,
      "item_id": itemId,
      "code": productCode,
      "name": productName,
      "description": productDescription,
      "sales_price": salesPrice,
      "category_name": categoryName,
      "sub_category_id": subCategoryId,
      "sub_category_name": subCategoryName,
      "quantity_on_hand": quantityOnHand,
      "image": imageUrl,
      "image_urls": imageUrls,
      "quantity": quantity,
      "tax_amount": taxAmount,
    };
  }
}
