import 'package:flutter/material.dart';
import '../../../../../models/bank_account_model.dart';
import '../../../../../services/fetch_bank_service.dart';

class BankProvider with ChangeNotifier {
  final FetchBankService _bankService = FetchBankService();

  List<Map<String, dynamic>> _bankAccounts = [];
  Map<String, dynamic>? _selectedBank;
  bool _isUsingDefaultAccounts = false;
  bool _isLoading = false;

  // Getters
  List<Map<String, dynamic>> get bankAccounts => _bankAccounts;
  Map<String, dynamic>? get selectedBank => _selectedBank;
  bool get isUsingDefaultAccounts => _isUsingDefaultAccounts;
  bool get isLoading => _isLoading;

  Future<void> fetchBankAccounts() async {
    if (_isLoading) return;

    print('🔄 BankProvider: Starting to fetch bank accounts...');
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _bankService.fetchBankAccounts();
      print('📊 BankProvider: API response received');

      final rawData = List<Map<String, dynamic>>.from(response['data']);
      _bankAccounts = [];

      for (var bankJson in rawData) {
        final bankModel = BankAccountModel.fromJson(bankJson);

        // Only include banks with a non-empty Code
        if (bankModel.code != null && bankModel.code!.trim().isNotEmpty) {
          _bankAccounts.add(bankModel.toJson());
        }
      }

      _isUsingDefaultAccounts = response['isDefault'] ?? false;

      print(
          '📊 BankProvider: Loaded ${_bankAccounts.length} filtered bank accounts');

      // Debug: Print first few valid banks
      for (int i = 0; i < _bankAccounts.length && i < 3; i++) {
        final bank = _bankAccounts[i];
        print(
            '🏦 BankProvider: Bank $i - Name: ${bank['Name']}, Code: ${bank['Code']}, EnablePayments: ${bank['EnablePaymentsToAccount']}, Status: ${bank['Status']}');
      }

      // Auto-select first default bank if applicable
      if (_isUsingDefaultAccounts &&
          _selectedBank == null &&
          _bankAccounts.isNotEmpty) {
        _selectedBank = _bankAccounts.first;
        print(
            '✅ BankProvider: Auto-selected first default bank: ${_selectedBank!['Name']}');
      }
    } catch (e) {
      print("❌ BankProvider: Error fetching bank accounts: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
      print('✅ BankProvider: Fetch completed, notifying listeners');
    }
  }

  /// Sets the selected bank
  void setSelectedBank(Map<String, dynamic>? bank) {
    _selectedBank = bank;
    notifyListeners();
  }

  /// Gets bank name by ID
  String? getBankNameById(String accountId) {
    final bank = _bankAccounts.firstWhere(
      (bank) => bank['AccountID'] == accountId,
      orElse: () => {'Name': 'Unknown Bank'},
    );
    return bank['Name'];
  }

  /// Gets bank details by ID
  Map<String, dynamic>? getBankDetailsById(String accountId) {
    try {
      return _bankAccounts.firstWhere(
        (bank) => bank['AccountID'] == accountId,
      );
    } catch (e) {
      return null;
    }
  }

  /// Checks if bank is active
  bool isBankActive(String accountId) {
    final bank = getBankDetailsById(accountId);
    return bank != null && bank['Status'] == 'ACTIVE';
  }

  /// Gets active banks
  List<Map<String, dynamic>> getActiveBanks() {
    return _bankAccounts.where((bank) => bank['Status'] == 'ACTIVE').toList();
  }
}
