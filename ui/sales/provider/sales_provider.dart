import 'dart:async';
import 'package:flutter/material.dart';
import 'package:point_of_sales/utils/helpers/show_toast_dialouge.dart';
import '../../../models/sale summary/invoice_summary_model.dart';
import '../../../services/sales.dart';
import '../../../utils/constants/my_sharePrefs.dart';

class SalesProvider with ChangeNotifier {
  final SalesService _salesService = SalesService();
  final MySharedPrefs _mySharedPrefs = MySharedPrefs();

  bool _isLoading = false;
  bool _isSaleDetailLoading = false;

  List<InvoiceSummaryModel> _invoices = [];
  List<InvoiceSummaryModel> _filteredInvoices = [];

  String _searchQuery = '';
  String _selectedDate = '';
  DateTime? _customStartDate;
  DateTime? _customEndDate;
  Timer? _debounce;
  int? _lastUpdatedTimestamp;

  // Toggle for debug logging
  bool debug = false;

  // Getters
  bool get isLoading => _isLoading;
  bool get isSaleDetailLoading => _isSaleDetailLoading;

  List<InvoiceSummaryModel> get invoices =>
      _filteredInvoices.isEmpty ? _invoices : _filteredInvoices;

  String get searchQuery => _searchQuery;
  String get selectedDate => _selectedDate;

  String get lastUpdatedTime => _lastUpdatedTimestamp != null
      ? DateTime.fromMillisecondsSinceEpoch(_lastUpdatedTimestamp!).toString()
      : '';

  /// Delete loading state
  bool _delLoad = false;
  bool get delLoad => _delLoad;

  /// Deletes a sale invoice by its invoice number.
  Future<void> deleteInvoice(String invoiceNumber) async {
    _delLoad = true;
    notifyListeners();

    final data = {"invoice_number": invoiceNumber};

    try {
      final response = await _salesService.deleteSaleInvoice(data);

      if (response != null && response['message'] != null) {
        ShowToastDialog.showToast(response['message']);
      }
    } catch (e) {
      debugPrint("Delete Invoice Error: $e");
      ShowToastDialog.showToast('An error occurred while deleting.');
    } finally {
      _delLoad = false;
      notifyListeners();
    }
  }


  /// 🔍 Search with Debounce
  void updateSearch(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final trimmed = query.trim().toLowerCase();
      if (_searchQuery != trimmed) {
        _searchQuery = trimmed;
        _applyFilters();
      }
    });
  }

  void updateDate(String date) {
    if (_selectedDate != date) {
      _selectedDate = date;
      _applyFilters();
    }
  }

  void setCustomDateRange(DateTime? startDate, DateTime? endDate) {
    _customStartDate = startDate;
    _customEndDate = endDate;
    _applyFilters();
  }

  Future<int> getUserId() async => await _mySharedPrefs.getUserId();

  /// ✅ Core Filtering Logic
  void _applyFilters() {
    List<InvoiceSummaryModel> filtered = _invoices;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((invoice) {
        final invoiceNum = invoice.invoiceNumber.toLowerCase();
        final customer = invoice.customerName.toLowerCase();
        return invoiceNum.contains(_searchQuery) ||
            customer.contains(_searchQuery);
      }).toList();
    }

    if (_customStartDate != null && _customEndDate != null) {
      filtered = filtered.where((invoice) {
        final date = DateTime.tryParse(invoice.datedToday);
        if (date == null) return false;
        return !date.isBefore(_customStartDate!) &&
            !date.isAfter(_customEndDate!);
      }).toList();
    } else if (_selectedDate.isNotEmpty) {
      filtered = filtered
          .where((invoice) => invoice.datedToday == _selectedDate)
          .toList();
    }

    _filteredInvoices = filtered;
    notifyListeners();
  }

  /// 📥 Fetch Invoices with Cache Check
  Future<void> fetchInvoices() async {
    _isLoading = true;
    notifyListeners();

    try {
      final userId = await getUserId();
      final isFilterApplied = _searchQuery.isNotEmpty ||
          _selectedDate.isNotEmpty ||
          (_customStartDate != null && _customEndDate != null);
      final isCacheExpired = await _mySharedPrefs.isSalesSummaryCacheExpired();

      // If no filters are applied and cache is not expired, use cached data
      if (!isFilterApplied && !isCacheExpired) {
        final cached = await _mySharedPrefs.getSalesSummary();
        if (cached.isNotEmpty) {
          _invoices = cached;
          _lastUpdatedTimestamp =
              await _mySharedPrefs.getSalesSummaryTimestamp();
          _applyFilters();
          _isLoading = false;
          notifyListeners();
          return;
        }
      }

      // Fetch new invoices from the API
      final data = await _salesService
          .getInvoices(userId); // No query or date parameters here

      // Map the fetched data to InvoiceSummaryModel
      _invoices =
          data.map((json) => InvoiceSummaryModel.fromJson(json)).toList();

      // Save the invoices in cache if no filters are applied
      if (!isFilterApplied) {
        await _mySharedPrefs.setSalesSummary(_invoices);
        await _mySharedPrefs
            .setSalesSummaryTimestamp(DateTime.now().millisecondsSinceEpoch);
      }

      // Apply the filters after fetching data
      _applyFilters();
    } catch (e) {
      if (debug) debugPrint("❌ Error fetching invoices: $e");
      _invoices = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  /// ♻️ Reset Filters
  void _resetFilters() {
    _searchQuery = '';
    _selectedDate = '';
    _customStartDate = null;
    _customEndDate = null;
    _filteredInvoices.clear();
  }

  /// 🧹 Clear Cache
  Future<void> clearCachedInvoices() async {
    await _mySharedPrefs.clearSalesSummary();
    await _mySharedPrefs.clearSalesSummaryTimestamp();
  }

  /// 🔄 Refresh by clearing cache + filters
  Future<void> refreshInvoices() async {
    _resetFilters();
    await clearCachedInvoices();
    await fetchInvoices();
  }

  /// 📤 Placeholder for PDF export
  Future<void> exportInvoicesToPDF(List<InvoiceSummaryModel> invoices) async {
    // TODO: Implement export logic
  }

  /// 💥 Dispose Debounce on Provider Destruction
  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
