import 'client/api_client.dart';

/// 🔹 **Authentication Service**
class AuthService {
  final ApiClient _apiClient = ApiClient();
  final String _endpoint = "/login_Api.php";

  /// 🔹 **Sign In**
  Future<Map<String, dynamic>?> signIn(String email, String password) async {
    return _apiClient.post(_endpoint, {
      "email": email,
      "password": password,
    });
  }
}
