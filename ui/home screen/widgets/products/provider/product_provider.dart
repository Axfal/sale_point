import 'package:flutter/material.dart';
import 'package:point_of_sales/services/product_service.dart';
import '../../../../../models/product_model.dart';
import '../../../../../utils/constants/my_sharePrefs.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _apiService = ProductService();
  // final MySharedPrefs _mySharedPrefs = MySharedPrefs();

  List<ProductModel> _allProducts = [];
  List<ProductModel> _filteredProducts = [];

  List<ProductModel> get filteredProducts => _filteredProducts;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  // Fetch all products with cache check
  Future<void> fetchProducts() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    // bool isCacheExpired = await _mySharedPrefs.isProductCacheExpired();
    // if (!isCacheExpired) {
    //   List<Map<String, dynamic>> cachedProducts =
    //       await _mySharedPrefs.getProducts();
    //   _allProducts =
    //       cachedProducts.map((e) => ProductModel.fromJson(e)).toList();
    //   _filteredProducts = _allProducts;
    //   _isLoading = false;
    //   notifyListeners();
    //   return;
    // }

    try {
      final response = await _apiService.getProducts();
      if (response != null && response['success']) {
        _allProducts = (response['products'] as List)
            .map((e) => ProductModel.fromJson(e))
            .toList();
        _filteredProducts = _allProducts;

        // await _mySharedPrefs.setProducts(
        //   _allProducts.map((e) => e.toJson()).toList(),
        // );
      } else {
        _errorMessage = 'Failed to load products';
      }
    } catch (e) {
      _errorMessage = 'An error occurred: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Filter products based on selected category
  void filterProductsByCategory(int categoryId) {
    _filteredProducts = _allProducts
        .where((product) => product.categoryId == categoryId)
        .toList();
    notifyListeners();
  }

  // Clear filters
  void clearFilters() {
    _filteredProducts = _allProducts;
    notifyListeners();
  }

  // Search products by name
  List<ProductModel> searchProducts(String query) {
    if (query.isEmpty) return [];

    final searchQuery = query.toLowerCase();
    return _allProducts.where((product) {
      final name = product.productName.toLowerCase();
      final code = product.productCode.toLowerCase();
      return name.contains(searchQuery) || code.contains(searchQuery);
    }).toList();
  }
}
