import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:point_of_sales/models/tax_model.dart';
import 'package:point_of_sales/utils/helpers/show_toast_dialouge.dart';
import '../../../../../models/contacts_model.dart';
import '../../../../../models/invoice_model.dart';
import '../../../../../models/product_model.dart';
import '../../../../../services/contacts.dart';
import '../../../../../services/sales.dart';
import '../../../../../services/tax_service.dart';
import '../../../../../utils/constants/my_sharePrefs.dart';
import '../../../../../utils/helpers/data_parser.dart';

class InvoiceProvider with ChangeNotifier {
  final contactsService = ContactsService();
  final MySharedPrefs _mySharedPrefs = MySharedPrefs();
  final SalesService _salesService = SalesService();
  final TaxService _taxService = TaxService();

  TaxModel? _taxModel;
  TaxModel? get taxModel => _taxModel;
  DateTime? _datedToday = DateTime.now();
  DateTime? _dueToday = DateTime.now();
  String? _customerName;
  String? _contactId;
  String? _accountId;
  String? _invoiceNumber;
  String? _taxStatus;
  List<Map<String, dynamic>> _availableTaxes = [];
  Map<String, dynamic>? _selectedTax;
  bool _isUsingDefaultTaxes = false;
  bool _isLoadingTaxes = false;
  bool _isDetailsExpanded = false;

  List<ContactsModel> _allContacts = [];
  List<ContactsModel> _contactSuggestions = [];
  List<ProductModel> products = [];
  List<ProductModel> _invoiceProducts = [];
  double get totalAmount {
    return _invoiceProducts.fold(
        0, (total, product) => total + (product.salesPrice * product.quantity));
  }

  DateTime? get datedToday => _datedToday;
  DateTime? get dueToday => _dueToday;
  String? get customerName => _customerName;
  String? get contactId => _contactId;
  String? get accountId => _accountId;
  String? get invoiceNumber => _invoiceNumber;
  String? get taxStatus => _taxStatus;
  List<ContactsModel> get contactSuggestions => _contactSuggestions;
  List<ProductModel> get invoiceProducts => _invoiceProducts;
  List<Map<String, dynamic>> get availableTaxes => _availableTaxes;
  Map<String, dynamic>? get selectedTax => _selectedTax;
  bool get isUsingDefaultTaxes => _isUsingDefaultTaxes;
  bool get isLoadingTaxes => _isLoadingTaxes;
  bool get isDetailsExpanded => _isDetailsExpanded;
  Data? _selectedTaxItem;
  Data? get selectedTaxItem => _selectedTaxItem;

  void clearInvoiceFields() {
    print('🧹 Clearing invoice fields...');

    // Preserve tax settings
    final currentTaxStatus = _taxStatus;
    final currentSelectedTax = _selectedTax;
    final currentTaxes = _availableTaxes;
    final isUsingDefaultTaxesState = _isUsingDefaultTaxes;

    // Clear customer info
    _customerName = '';
    _contactId = null;
    // _datedToday = DateTime.now();
    // _dueToday = null;

    // Clear products
    _invoiceProducts.clear();

    print('✨ Cleared customer info and products');

    // Restore tax settings
    _taxStatus = currentTaxStatus;
    _selectedTax = currentSelectedTax;
    _availableTaxes = currentTaxes;
    _isUsingDefaultTaxes = isUsingDefaultTaxesState;

    print('✅ Tax settings preserved');
    print('📝 Invoice ready for new entry');

    notifyListeners();
  }

  Future<void> fetchContactSuggestions(String query) async {
    if (query.isEmpty) {
      _contactSuggestions = [];
      notifyListeners();
      return;
    }
    // _customerName = query;
    // notifyListeners();
    try {
      bool isExpired = await _mySharedPrefs.isContactsCacheExpired();
      if (!isExpired) {
        _allContacts = await _mySharedPrefs.getContacts();
      } else {
    final contactsFromServer = await contactsService.getAllContacts();
    _allContacts = contactsFromServer;
      await _mySharedPrefs.setContacts(contactsFromServer);
    }

    _contactSuggestions = _allContacts.where((contact) {
      return contact.name?.toLowerCase().contains(query.toLowerCase()) ??
          false;
    }).toList();

    notifyListeners();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> setCustomerName(String? name) async {
    _customerName = name;
    final contact = _allContacts.firstWhere(
          (c) => c.name == name,
      orElse: () => ContactsModel(contactId: '', name: name),
    );
    _contactId = contact.contactId;
    notifyListeners();
  }

  void setSelectedTaxItem(Data? tax) {
    _selectedTaxItem = tax;
    notifyListeners();
  }

  void setDatedToday(DateTime date) {
    _datedToday = date;
    notifyListeners();
  }

  void setDueToday(DateTime date) {
    _dueToday = date;
    notifyListeners();
  }

  void setInvoiceNumber(String number) {
    if (_invoiceNumber != number) {
      _invoiceNumber = number;
      notifyListeners();
    }
  }

  void setTaxStatus(String status) {
    _taxStatus = status;
    notifyListeners();
  }

  void setAccountId(String? id) {
    if (_accountId != id) {
      _accountId = id;
      notifyListeners();
    }
  }

  void setContactId(String? id) {
    if (_contactId != id) {
      _contactId = id;
      notifyListeners();
    }
  }

  void addProduct(ProductModel product) {
    final quantityOnHand = double.tryParse(product.quantityOnHand ?? '0') ?? 0;

    // Check if the product already exists in the invoice
    final existingProductIndex =
        _invoiceProducts.indexWhere((p) => p.itemId == product.itemId);

    if (existingProductIndex != -1) {
      final existingProduct = _invoiceProducts[existingProductIndex];

      if (existingProduct.quantity < quantityOnHand) {
        // Increase quantity only if it's less than quantityOnHand
        final updatedQuantity = existingProduct.quantity + 1;
        _invoiceProducts[existingProductIndex] =
            existingProduct.copyWith(quantity: updatedQuantity);
        print(
            '📦 Increased quantity for ${product.productName} to $updatedQuantity');
      } else {
        ShowToastDialog.showToast("Only $quantityOnHand available in stock");
      }
    } else {
      if (quantityOnHand > 0) {
        _invoiceProducts.add(product.copyWith(quantity: 1));
        print('Added new product: ${product.productName}');
      } else {
        ShowToastDialog.showToast("Out of Stock");
      }
    }

    notifyListeners();
  }

  void removeProduct(ProductModel product) {
    final existingProductIndex =
        _invoiceProducts.indexWhere((p) => p.itemId == product.itemId);

    if (existingProductIndex != -1) {
      final existingProduct = _invoiceProducts[existingProductIndex];

      if (existingProduct.quantity > 1) {
        final updatedQuantity = existingProduct.quantity - 1;
        _invoiceProducts[existingProductIndex] =
            existingProduct.copyWith(quantity: updatedQuantity);
      } else {
        removeAllProduct(product);
      }

      notifyListeners();
    } else {
      ShowToastDialog.showToast(
          "${product.productName} is not in the invoice.");
    }
  }

  void removeAllProduct(ProductModel product) {
    _invoiceProducts.removeWhere((p) => p.itemId == product.itemId);
    notifyListeners();
  }

  void setInvoiceProducts(List<ProductModel> products) {
    print('📝 Initializing invoice products: ${products.length} items');
    _invoiceProducts = List.from(products);
    notifyListeners();
  }

  void updateProductQuantity(ProductModel product, int change) {
    final index =
        _invoiceProducts.indexWhere((p) => p.itemId == product.itemId);
    if (index != -1) {
      // final newQuantity = product.quantity + change;
      // if (newQuantity > 0) {
      //   _invoiceProducts[index] = product.copyWith(quantity: newQuantity);
      if (change == 1) {
        addProduct(product);
      } else {
        removeProduct(product);
      }
      notifyListeners();
      // }
    }
  }

  void updateProductPrice(ProductModel product, double newPrice) {
    print(
        '💰 Updating price for ${product.productName} from ${product.salesPrice} to $newPrice');
    final index =
        _invoiceProducts.indexWhere((p) => p.itemId == product.itemId);
    if (index != -1) {
      _invoiceProducts[index] = product.copyWith(salesPrice: newPrice);
      print('✅ Price updated successfully');
      notifyListeners();
    }
  }

  // Add this getter to retrieve userId
  Future<int> getUserId() async {
    final userId = await _mySharedPrefs.getUserId();
    return userId ?? 0;
  }

  /// 🔹 Post sale to the server
  Future<Map<String, dynamic>> chargeUserSale(InvoiceModel invoice) async {
    try {
      final userId = await _mySharedPrefs.getUserId();

      if (userId == 0) {
        return {
          "success": false,
          "message": "User is not logged in or invalid user session."
        };
      }

      invoice.userId = userId;
      invoice.accountId = _accountId;
      invoice.contactId = _contactId;

      await generateInvoiceNumber();
      invoice.invoiceNumber = _invoiceNumber ?? "";

      if (invoice.customerName.isEmpty) {
        return {"success": false, "message": "Customer name is required."};
      }

      if (invoice.invoiceNumber.isEmpty) {
        return {"success": false, "message": "Invoice number is required."};
      }

      if (invoice.products.isEmpty) {
        return {"success": false, "message": "No products in invoice."};
      }

      // Check if bank account is required based on payment method
      final isPayLater = invoice.paymentMethod == "Pay Later";
      if (!isPayLater &&
          (invoice.accountId == null || invoice.accountId!.isEmpty)) {
        return {
          "success": false,
          "message": "Bank account selection is required."
        };
      }

      // Calculate and assign tax to each product
      final taxValue = _selectedTaxItem?.displayRate ?? 0.0;
      final taxPercentage = DataParser.parseDouble(taxValue, defaultValue: 0.0);

      if (taxPercentage > 0) {
        for (var product in invoice.products) {
          product.taxAmount = product.salesPrice * (taxPercentage / 100);
        }
      }
      print("account id =====> ${invoice.accountId}");
      print("contact id =====> ${invoice.contactId}");

      final result = await _salesService.addSale(invoice: invoice);

      if (result!['success'] == true) {
        await _mySharedPrefs.setLastInvoiceNumber(invoice.invoiceNumber);
      }

      return result;
    } catch (e) {
      print("Error in chargeUserSale: $e");
      return {"success": false, "message": "An unexpected error occurred: $e"};
    }
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${_twoDigits(date.month)}-${_twoDigits(date.day)}";
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  Future<void> generateInvoiceNumber() async {
    try {
      final now = DateTime.now();
      final dateStr =
          "${now.year}${_twoDigits(now.month)}${_twoDigits(now.day)}";
      final timeStr =
          "${_twoDigits(now.hour)}${_twoDigits(now.minute)}${_twoDigits(now.second)}";

      final newInvoiceNumber = "INV-$dateStr-$timeStr";

      // Save to SharedPreferences
      await _mySharedPrefs.setLastInvoiceNumber(newInvoiceNumber);

      setInvoiceNumber(newInvoiceNumber); // Update state and notify listeners
    } catch (e) {
      print("Error generating invoice number: $e");
      // Optional: Add more detailed logging or a custom error handling mechanism
    }
  }

  Future<void> fetchTaxes() async {
    if (_isLoadingTaxes) return; // Prevent multiple simultaneous requests

    _isLoadingTaxes = true;
    notifyListeners();

    try {
      final response = await _taxService.getTaxes();
      if (response != null && response['success'] == true) {
        _taxModel = TaxModel.fromJson(response);
        _availableTaxes = List<Map<String, dynamic>>.from(response['data']);
        _isUsingDefaultTaxes = response['isDefault'] ?? false;

        // If using default taxes and no tax is selected, select the first default tax
        if (_isUsingDefaultTaxes &&
            _selectedTax == null &&
            _availableTaxes.isNotEmpty) {
          _selectedTax = _availableTaxes.first;
        }

        // Debug logging
        print("💰 Loaded ${_availableTaxes.length} tax rates");
        print("🔄 Using ${_isUsingDefaultTaxes ? 'default' : 'API'} tax rates");
      }
    } catch (e) {
      print("❌ Error in fetchTaxes: $e");
      // The TaxService will handle the fallback to default taxes
    } finally {
      _isLoadingTaxes = false;
      notifyListeners();
    }
  }

  void setSelectedTax(Map<String, dynamic>? tax) {
    _selectedTax = tax;
    notifyListeners();
  }

  double calculateTaxAmount(double subtotal) {
    if (_selectedTaxItem == null) {
      return 0.0;
    }

    final taxRate =
        double.tryParse(_selectedTaxItem!.displayRate.toString()) ?? 0.0;
    return subtotal * (taxRate / 100);
  }

  double get totalWithTax {
    final subtotal = totalAmount;
    return subtotal + calculateTaxAmount(subtotal);
  }

  void setDetailsExpanded(bool expanded) {
    _isDetailsExpanded = expanded;
    notifyListeners();
  }
}
