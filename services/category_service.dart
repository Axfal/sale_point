import 'client/api_client.dart';

class CategoryService {
  final ApiClient _apiClient = ApiClient();
  final String _endpoint = "/categories.php";

  /// 📌 **Fetch Categories with Debugging**
  Future<Map<String, dynamic>?> getCategories() async {
    final response = await _apiClient.get(_endpoint);

    // Debug the raw response
    print("🔍 API Response from $_endpoint: $response");

    if (response == null || !response.containsKey('categories')) {
      print("❌ Error: No 'categories' key found in API response.");
      return null;
    }

    print("✅ Categories Found: ${response['categories']}");
    return response;
  }
}
