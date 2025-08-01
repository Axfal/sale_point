import 'client/api_client.dart';
import 'dart:async';
import '../utils/constants/my_sharePrefs.dart';

class TaxService {
  final ApiClient _apiClient = ApiClient();
  final MySharedPrefs _mySharedPrefs = MySharedPrefs();
  final String _endpoint = "/get_taxes.php";

  // Default tax rates as fallback
  final List<Map<String, dynamic>> _defaultTaxes = [
    {"id": 1, "name": "GST", "percentage": 10.0},
    {"id": 2, "name": "No Tax", "percentage": 0.0},
  ];

  /// 📌 **Fetch Taxes with Enhanced Error Handling and Caching**
  Future<Map<String, dynamic>?> getTaxes() async {
    try {
      // Check if we have valid cached data
      // final isCacheExpired = await _mySharedPrefs.isTaxDataCacheExpired();
      // if (!isCacheExpired) {
      //   final cachedData = await _mySharedPrefs.getTaxData();
      //   if (cachedData != null) {
      //     print("✅ Using cached tax rates");
      //     return cachedData;
      //   }
      // }

      print("🔄 Fetching fresh tax data from API");
      final response = await _apiClient.get(_endpoint);
      print("🔍 API Response from $_endpoint: $response");

      // if (response == null ||
      //     !response.containsKey('data') ||
      //     response['success'] != true) {
      //   print("⚠️ Invalid API response, using default tax rates");
      //   final defaultResult = {
      //     "success": true,
      //     "data": _defaultTaxes,
      //     "isDefault": true
      //   };
      //
      //   // Cache the default result
      //   await _mySharedPrefs.setTaxData(defaultResult);
      //   return defaultResult;
      // }

      // Successfully fetched taxes
      // print("✅ Fresh tax data fetched: ${response['data']}");
      // final result = {...response, "isDefault": false};
      //
      // // Cache the fresh data
      // await _mySharedPrefs.setTaxData(result);
      // return result;
      return response;
    } catch (e) {
      print("⚠️ Error fetching taxes: $e");

      // Try to get cached data as fallback
      // final cachedData = await _mySharedPrefs.getTaxData();
      // if (cachedData != null) {
      //   print("✅ Using cached tax rates after error");
      //   return cachedData;
      // }
      //
      // // Use default rates if no cache available
      // final defaultResult = {
      //   "success": true,
      //   "data": _defaultTaxes,
      //   "isDefault": true
      // };
      //
      // // Cache the default result
      // await _mySharedPrefs.setTaxData(defaultResult);
      // return defaultResult;
    }
  }
}
