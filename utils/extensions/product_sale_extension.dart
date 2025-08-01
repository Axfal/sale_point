import '../../models/product_model.dart';
import '../../utils/helpers/data_parser.dart';

extension ProductModelSaleExtension on ProductModel {
  Map<String, dynamic> toSaleJson() {
    return {
      "product_id": itemId,
      "sales_price": DataParser.parseDouble(salesPrice),
      "quantity": quantity,
    };
  }
}
