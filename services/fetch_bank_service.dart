import 'client/api_client.dart';
import '../models/bank_account_model.dart';

class FetchBankService {
  final ApiClient _apiClient = ApiClient();
  final String _endpoint = "/fetch_bank_accounts.php";

  // Default bank accounts as fallback
  final List<Map<String, dynamic>> _defaultBankAccounts = [
    {
      "AccountID": "default_1",
      "Name": "Default Savings Account",
      "Status": "ACTIVE",
      "Type": "BANK",
      "TaxType": "BASEXCLUDED",
      "Class": "ASSET",
      "EnablePaymentsToAccount": true,
      "ShowInExpenseClaims": false,
      "BankAccountNumber": "000000000",
      "BankAccountType": "BANK",
      "CurrencyCode": "AUD",
      "ReportingCode": "ASS",
      "ReportingCodeName": "Assets",
      "HasAttachments": false,
      "UpdatedDateUTC": "/Date(${DateTime.now().millisecondsSinceEpoch}+0000)/",
      "AddToWatchlist": false
    }
  ];

  Future<Map<String, dynamic>> fetchBankAccounts() async {
    try {
      final response = await _apiClient.get(_endpoint);

      if (response != null &&
          response['success'] == true &&
          response['accounts'] != null) {
        print("✅ FetchBankService: Valid API response received");
        final List<dynamic> accountsJson = response['accounts'];
        print(
            "📊 FetchBankService: Raw accounts data length: ${accountsJson.length}");

        // Debug: Print first account structure
        if (accountsJson.isNotEmpty) {
          print(
              "📊 FetchBankService: First account structure: ${accountsJson.first}");
        }

        final List<BankAccountModel> accounts = accountsJson
            .map((json) => BankAccountModel.fromJson(json))
            .toList();

        // Convert BankAccountModel instances to maps
        final List<Map<String, dynamic>> accountMaps =
            accounts.map((account) => account.toJson()).toList();

        print(
            "✅ FetchBankService: Successfully processed ${accountMaps.length} bank accounts");

        // Debug: Print first processed account
        if (accountMaps.isNotEmpty) {
          print(
              "📊 FetchBankService: First processed account: ${accountMaps.first}");
        }

        return {
          'success': true,
          'count': accountMaps.length,
          'data': accountMaps,
          'isDefault': false,
        };
      }

      print(
          '⚠️ FetchBankService: API returned invalid response, using default accounts');
      print('⚠️ FetchBankService: Response success: ${response?['success']}');
      print('⚠️ FetchBankService: Response data: ${response?['data']}');
      return _getDefaultAccounts();
    } catch (e) {
      print('❌ FetchBankService: Error fetching bank accounts: $e');
      return _getDefaultAccounts();
    }
  }

  /// Returns default bank accounts when API fails
  Map<String, dynamic> _getDefaultAccounts() {
    print('ℹ️ Using default bank accounts');
    return {
      'success': true,
      'count': _defaultBankAccounts.length,
      'data': _defaultBankAccounts,
      'isDefault': true,
    };
  }
}
