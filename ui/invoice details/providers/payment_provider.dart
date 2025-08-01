import 'package:flutter/material.dart';

enum PaymentMethod {
  bank,
  cod,
  pay_later,
  partial_payment;

  String get displayName {
    switch (this) {
      case PaymentMethod.bank:
        return 'Credit Card';
      case PaymentMethod.cod:
        return 'Cash';
      case PaymentMethod.pay_later:
        return 'Pay Later';
      case PaymentMethod.partial_payment:
        return 'Partial Payment';
    }
  }

  IconData get icon {
    switch (this) {
      case PaymentMethod.bank:
        return Icons.account_balance;
      case PaymentMethod.cod:
        return Icons.money;
      case PaymentMethod.pay_later:
        return Icons.schedule;
      case PaymentMethod.partial_payment:
        return Icons.payments_outlined;
    }
  }
}

class PaymentProvider with ChangeNotifier {
  PaymentMethod? _selectedPaymentMethod;
  Map<String, dynamic>? _selectedBank;
  bool _isProcessing = false;
  double _receivedAmount = 0.0;
  String _receivedAmountError = '';
  final TextEditingController cashReceivedController = TextEditingController();
  final TextEditingController partialAmountController = TextEditingController();

  PaymentProvider() {
    // Listen to cash received controller changes
    cashReceivedController.addListener(_handleCashReceivedChange);
    partialAmountController.addListener(_handlePartialAmountChange);
  }

  @override
  void dispose() {
    cashReceivedController.removeListener(_handleCashReceivedChange);
    partialAmountController.removeListener(_handlePartialAmountChange);
    cashReceivedController.dispose();
    partialAmountController.dispose();
    super.dispose();
  }

  void _handleCashReceivedChange() {
    final value = double.tryParse(cashReceivedController.text);
    if (value != null) {
      _receivedAmount = value;
      notifyListeners();
    }
  }

  void _handlePartialAmountChange() {
    final value = double.tryParse(partialAmountController.text);
    if (value != null) {
      _receivedAmount = value;
      notifyListeners();
    }
  }

  // Getters
  PaymentMethod? get selectedPaymentMethod => _selectedPaymentMethod;
  Map<String, dynamic>? get selectedBank => _selectedBank;
  bool get isProcessing => _isProcessing;
  double get receivedAmount => _receivedAmount;
  String get receivedAmountError => _receivedAmountError;
  bool get isCashOnDelivery => _selectedPaymentMethod == PaymentMethod.cod;
  bool get isPartialPayment =>
      _selectedPaymentMethod == PaymentMethod.partial_payment;

  // Check if current payment configuration is valid
  bool get isValidPaymentConfig {
    print('🔍 Validating payment configuration...');
    print('Current payment method: ${_selectedPaymentMethod?.displayName}');
    print('Selected bank: ${_selectedBank?.toString()}');

    if (_selectedPaymentMethod == null) {
      print('❌ No payment method selected');
      return false;
    }

    print('✓ Payment method: ${_selectedPaymentMethod?.displayName}');

    // For Pay Later, we don't need bank account or received amount validation
    if (_selectedPaymentMethod == PaymentMethod.pay_later) {
      print('✓ Pay Later payment is valid');
      return true;
    }

    // For Partial Payment, validate the partial amount
    if (_selectedPaymentMethod == PaymentMethod.partial_payment) {
      if (_receivedAmount <= 0) {
        print('❌ Invalid partial amount: $_receivedAmount');
        return false;
      }
      print('✓ Valid partial amount: $_receivedAmount');
      return true;
    }

    // Bank selection is required for both bank and COD payment methods
    if (_selectedBank == null || _selectedBank!.isEmpty) {
      print('❌ No bank account selected');
      return false;
    }

    print('✓ Bank account selected: ${_selectedBank!['Name']}');
    print('✓ Bank account number: ${_selectedBank!['BankAccountNumber']}');

    // For COD, validate received amount
    if (_selectedPaymentMethod == PaymentMethod.cod) {
      if (_receivedAmount <= 0) {
        print('❌ Invalid received amount: $_receivedAmount');
        return false;
      }
      if (_receivedAmountError.isNotEmpty) {
        print('❌ Received amount error: $_receivedAmountError');
        return false;
      }
      print('✓ Valid received amount: $_receivedAmount');
    } else if (_selectedPaymentMethod == PaymentMethod.bank) {
      // For bank transfer, we only need valid bank account
      print('✓ Bank transfer payment is valid');
      return true;
    }

    print('✅ Payment configuration is valid');
    return true;
  }

  // Setters
  void setPaymentMethod(PaymentMethod? method) {
    print('🔄 Setting payment method: ${method?.displayName}');
    if (_selectedPaymentMethod != method) {
      _selectedPaymentMethod = method;

      // Clear received amount when switching payment methods
      if (method != PaymentMethod.cod) {
        _receivedAmount = 0.0;
        cashReceivedController.text = '';
      }

      notifyListeners();
    }
  }

  void setSelectedBank(Map<String, dynamic>? bank) {
    print('🏦 Setting selected bank: ${bank?.toString()}');
    if (_selectedBank != bank) {
      _selectedBank = bank;
      print('✓ Bank account set successfully: ${bank?['Name']}');
      print('✓ Bank account number: ${bank?['BankAccountNumber']}');
      notifyListeners();
    }
  }

  void setProcessing(bool processing) {
    print('🔄 Setting processing state: $processing');
    if (_isProcessing != processing) {
      _isProcessing = processing;
      notifyListeners();
    }
  }

  void updateCashReceived(double amount) {
    print(
        '💰 Updating cash received amount to: \$${amount.toStringAsFixed(2)}');
    if (isCashOnDelivery && amount > 0) {
      _receivedAmount = amount;
      // Update controller text without triggering the listener
      cashReceivedController.value = TextEditingValue(
        text: amount.toStringAsFixed(2),
        selection:
            TextSelection.collapsed(offset: amount.toStringAsFixed(2).length),
      );
      validateReceivedAmount(amount);
      notifyListeners();
    }
  }

  void validateReceivedAmount(double totalDue) {
    print(
        '🔄 Validating received amount: $_receivedAmount against total: $totalDue');
    if (_receivedAmount < totalDue) {
      _receivedAmountError = 'Received amount must be at least the total due';
      print('❌ Received amount is less than total due');
    } else {
      _receivedAmountError = '';
      print('✓ Received amount is valid');
    }
    notifyListeners();
  }

  double getChange(double totalDue) {
    final change = _receivedAmount - totalDue;
    print('💰 Calculating change: $_receivedAmount - $totalDue = $change');
    return change;
  }

  void reset() {
    print('🔄 Resetting payment provider state');
    _selectedPaymentMethod = null;
    _selectedBank = null;
    _isProcessing = false;
    _receivedAmount = 0.0;
    _receivedAmountError = '';
    cashReceivedController.text = '';
    notifyListeners();
  }
}
