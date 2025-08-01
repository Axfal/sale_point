import 'dart:convert';
import 'package:point_of_sales/models/sale%20summary/invoice_summary_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/contacts_model.dart';

class MySharedPrefs {
  // 🔐 Keys
  static const String _userKey = 'user_data';
  static const String _loginStatusKey = 'is_logged_in';

  static const String _productsKey = 'cached_products';
  static const String _productsTimestampKey = 'products_timestamp';

  static const String _categoriesKey = 'cached_categories';
  static const String _categoriesTimestampKey = 'categories_timestamp';

  static const String _childCategoriesKey = 'cached_child_categories';
  static const String _childCategoriesTimestampKey = 'child_categories_timestamp';

  static const String _contactsKey = 'cached_contacts';
  static const String _contactsTimestampKey = 'contacts_timestamp';

  static const String _lastInvoiceNumberKey = 'last_invoice_number';

  static const String _salesSummaryKey = 'cached_sales_summary';
  static const String _salesSummaryTimestampKey = 'sales_summary_timestamp';

  // Add new keys for tax caching
  static const String _taxDataKey = 'cached_tax_data';
  static const String _taxDataTimestampKey = 'tax_data_timestamp';

  // ⬇⬇⬇ TAX DATA SECTION ⬇⬇⬇

  /// ✅ Cache Tax Data
  Future<void> setTaxData(Map<String, dynamic> taxData) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(taxData);
    await prefs.setString(_taxDataKey, encoded);
    await prefs.setInt(
        _taxDataTimestampKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// ✅ Retrieve Cached Tax Data
  Future<Map<String, dynamic>?> getTaxData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encoded = prefs.getString(_taxDataKey);

    if (encoded == null) return null;

    try {
      return jsonDecode(encoded) as Map<String, dynamic>;
    } catch (e) {
      print('❌ Error decoding cached tax data: $e');
      return null;
    }
  }

  /// ✅ Check If Tax Data Cache Expired (e.g., 24 hours)
  Future<bool> isTaxDataCacheExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final int? cachedTime = prefs.getInt(_taxDataTimestampKey);
    if (cachedTime == null) return true;

    final int currentTime = DateTime.now().millisecondsSinceEpoch;
    final int diffInHours =
        ((currentTime - cachedTime) / (1000 * 60 * 60)).round();
    return diffInHours >= 24; // Cache expires after 24 hours
  }

  /// ✅ Clear Cached Tax Data
  Future<void> clearTaxData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_taxDataKey);
    await prefs.remove(_taxDataTimestampKey);
  }

  // ⬇⬇⬇ SALES SUMMARY SECTION ⬇⬇⬇

  /// ✅ Cache Sales Summary List
  Future<void> setSalesSummary(List<InvoiceSummaryModel> summaryList) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded =
        jsonEncode(summaryList.map((s) => s.toJson()).toList());
    await prefs.setString(_salesSummaryKey, encoded);
    await prefs.setInt(
        _salesSummaryTimestampKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// ✅ Retrieve Cached Sales Summary List
  Future<List<InvoiceSummaryModel>> getSalesSummary() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encoded = prefs.getString(_salesSummaryKey);

    if (encoded == null) return [];

    try {
      final List decoded = jsonDecode(encoded);
      return decoded.map((e) => InvoiceSummaryModel.fromJson(e)).toList();
    } catch (e) {
      print('❌ Error decoding cached sales summary: $e');
      return [];
    }
  }

  /// ✅ Check If Sales Summary Cache Expired (e.g., 12 hours)
  Future<bool> isSalesSummaryCacheExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final int? cachedTime = prefs.getInt(_salesSummaryTimestampKey);
    if (cachedTime == null) return true;

    final int currentTime = DateTime.now().millisecondsSinceEpoch;
    final int diffInHours =
        ((currentTime - cachedTime) / (1000 * 60 * 60)).round();
    return diffInHours >= 12;
  }

  /// ✅ Clear Cached Sales Summary
  Future<void> clearSalesSummary() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_salesSummaryKey);
    await prefs.remove(_salesSummaryTimestampKey);
  }

  /// ✅ Get Sales Summary Timestamp
  Future<int?> getSalesSummaryTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_salesSummaryTimestampKey);
  }

  /// ✅ Set Sales Summary Timestamp
  Future<void> setSalesSummaryTimestamp(int timestamp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_salesSummaryTimestampKey, timestamp);
  }

  /// ✅ Clear Sales Summary Timestamp
  Future<void> clearSalesSummaryTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_salesSummaryTimestampKey);
  }

  // ⬇⬇⬇ invoice number SECTION ⬇⬇⬇

  Future<void> setLastInvoiceNumber(String invoiceNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastInvoiceNumberKey, invoiceNumber);
  }

  Future<String?> getLastInvoiceNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastInvoiceNumberKey);
  }

  // ⬇⬇⬇ CATEGORY SECTION ⬇⬇⬇

  /// ✅ Store Categories
  Future<void> setCategories(List<Map<String, dynamic>> categories) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_categoriesKey, jsonEncode(categories));
    await prefs.setInt(
        _categoriesTimestampKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// ✅ Get Categories
  Future<List<Map<String, dynamic>>> getCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonCategories = prefs.getString(_categoriesKey);
    if (jsonCategories != null) {
      return List<Map<String, dynamic>>.from(jsonDecode(jsonCategories));
    }
    return [];
  }

  /// ✅ Check if Categories Cache Expired (24 hours)
  Future<bool> isCategoryCacheExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final int? cachedTime = prefs.getInt(_categoriesTimestampKey);
    if (cachedTime == null) return true;

    final int currentTime = DateTime.now().millisecondsSinceEpoch;
    final int diffInHours =
        ((currentTime - cachedTime) / (1000 * 60 * 60)).round();

    return diffInHours >= 24;
  }

  /// ✅ Clear Cached Categories
  Future<void> clearCategories() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_categoriesKey);
    await prefs.remove(_categoriesTimestampKey);
  }

  // ⬇⬇⬇ CHILD CATEGORY SECTION ⬇⬇⬇

  /// ✅ Store Child Categories
  Future<void> setChildCategories(
      List<Map<String, dynamic>> childCategories) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_childCategoriesKey, jsonEncode(childCategories));
    await prefs.setInt(
        _childCategoriesTimestampKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// ✅ Get Child Categories
  Future<List<Map<String, dynamic>>> getChildCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonChildCategories = prefs.getString(_childCategoriesKey);
    if (jsonChildCategories != null) {
      return List<Map<String, dynamic>>.from(jsonDecode(jsonChildCategories));
    }
    return [];
  }

  /// ✅ Check if Child Categories Cache Expired (24 hours)
  Future<bool> isChildCategoryCacheExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final int? cachedTime = prefs.getInt(_childCategoriesTimestampKey);
    if (cachedTime == null) return true;

    final int currentTime = DateTime.now().millisecondsSinceEpoch;
    final int diffInHours =
        ((currentTime - cachedTime) / (1000 * 60 * 60)).round();

    return diffInHours >= 24;
  }

  /// ✅ Clear Child Category Cache
  Future<void> clearChildCategories() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_childCategoriesKey);
    await prefs.remove(_childCategoriesTimestampKey);
  }

  // ⬇⬇⬇ PRODUCTS SECTION ⬇⬇⬇

  /// ✅ Store Products
  Future<void> setProducts(List<Map<String, dynamic>> products) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_productsKey, jsonEncode(products));
    await prefs.setInt(
        _productsTimestampKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// ✅ Get Cached Products
  Future<List<Map<String, dynamic>>> getProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonProducts = prefs.getString(_productsKey);
    if (jsonProducts != null) {
      return List<Map<String, dynamic>>.from(jsonDecode(jsonProducts));
    }
    return [];
  }

  /// ✅ Check if Products Cache Expired (24 hours)
  Future<bool> isProductCacheExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final int? cachedTime = prefs.getInt(_productsTimestampKey);
    if (cachedTime == null) return true;

    final int currentTime = DateTime.now().millisecondsSinceEpoch;
    final int diffInHours =
        ((currentTime - cachedTime) / (1000 * 60 * 60)).round();

    return diffInHours >= 24;
  }

  /// ✅ Clear Products Cache
  Future<void> clearProducts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_productsKey);
    await prefs.remove(_productsTimestampKey);
  }

  // ⬇⬇⬇ USER SESSION SECTION ⬇⬇⬇

  /// ✅ Store User Data & Login Status
  Future<void> setUserData(String userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, userData);
    await prefs.setBool(_loginStatusKey, true);
  }

  /// ✅ Get Stored User Data
  Future<String?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userKey);
  }

  /// ✅ Get Stored User id from "getUserData method"
  Future<int> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);
    if (userData != null) {
      final Map<String, dynamic> decoded = jsonDecode(userData);
      return decoded["id"] ?? 0;
    }
    return 0;
  }

  /// ✅ Check Login Status
  Future<bool> isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_loginStatusKey) ?? false;
  }

  /// ✅ Clear User Session
  Future<void> clearUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.setBool(_loginStatusKey, false);
  }

  // ⬇⬇⬇ CONTACTS SECTION ⬇⬇⬇

  /// ✅ Save Contacts
  Future<void> setContacts(List<ContactsModel> contacts) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonContacts =
        jsonEncode(contacts.map((c) => c.toJson()).toList());
    await prefs.setString(_contactsKey, jsonContacts);
    await prefs.setInt(
        _contactsTimestampKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// ✅ Get Cached Contacts
  Future<List<ContactsModel>> getContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonContacts = prefs.getString(_contactsKey);
    if (jsonContacts == null) return [];

    try {
      final List decodedList = jsonDecode(jsonContacts);
      return decodedList.map((json) => ContactsModel.fromJson(json)).toList();
    } catch (e) {
      print("❌ Error decoding cached contacts: $e");
      return [];
    }
  }

  /// ✅ Check if Contacts Cache Expired (12 hours)
  Future<bool> isContactsCacheExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final int? cachedTime = prefs.getInt(_contactsTimestampKey);
    if (cachedTime == null) return true;

    final int currentTime = DateTime.now().millisecondsSinceEpoch;
    final int diffInHours =
        ((currentTime - cachedTime) / (1000 * 60 * 60)).round();

    return diffInHours >= 12;
  }

  /// ✅ Clear Contacts Cache
  Future<void> clearContacts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_contactsKey);
    await prefs.remove(_contactsTimestampKey);
  }
}
