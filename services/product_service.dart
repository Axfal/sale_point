import 'client/api_client.dart';

/// 🔹 **Product Service**
class ProductService {
  final ApiClient _apiClient = ApiClient();
  final String _endpoint = "/products.php";

  /// 📌 **Fetch Categories**
  Future<Map<String, dynamic>?> getProducts() async {
    return _apiClient.get(_endpoint);
  }
}