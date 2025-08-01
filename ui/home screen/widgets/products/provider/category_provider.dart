import 'package:flutter/material.dart';
import 'package:point_of_sales/services/category_service.dart';
import 'package:point_of_sales/ui/home%20screen/widgets/products/provider/product_provider.dart';
import 'package:provider/provider.dart';
import '../../../../../models/categories_model.dart';
import '../../../../../utils/constants/my_sharePrefs.dart';
import '../../../../../models/product_model.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryService _apiService = CategoryService();
  final MySharedPrefs _prefs = MySharedPrefs();

  List<CategoryModel> _categories = [];
  List<CategoryModel> _childCategories = [];
  CategoryModel? _selectedCategory;
  CategoryModel? _selectedChildCategory;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<CategoryModel> get categories => _categories;
  List<CategoryModel> get childCategories => _childCategories;
  CategoryModel? get selectedCategory => _selectedCategory;
  CategoryModel? get selectedChildCategory => _selectedChildCategory;

  Future<void> fetchCategories() async {
    _isLoading = true;
    notifyListeners();

    // Ensure cache is only checked and API is called if cache is expired or empty
    // bool isCacheExpired = await _prefs.isCategoryCacheExpired();
    // List<Map<String, dynamic>> cachedData = await _prefs.getCategories();

    // if (cachedData.isNotEmpty && !isCacheExpired) {
    //   _categories = cachedData.map((e) => CategoryModel.fromJson(e)).toList();
    // } else {
    try {
      final response = await _apiService.getCategories();

      if (response != null && response['success']) {
        final rawList = response['categories'];

        if (rawList is List) {
          _categories = rawList.map((item) {
            if (item is Map<String, dynamic>) {
              return CategoryModel.fromJson(item);
            } else {
              throw Exception("Item in categories is not a Map: $item");
            }
          }).toList();

          // await _prefs.setCategories(List<Map<String, dynamic>>.from(rawList));
          // } else {
          //   throw Exception("Categories key is not a List");
        }
      }
    } catch (e) {
      print("Error loading categories: $e");
    }
    // }

    _selectedCategory = _categories.isNotEmpty ? _categories.first : null;
    _updateChildCategories();

    _isLoading = false;
    notifyListeners();
  }

  void selectCategory(CategoryModel category, BuildContext context) {
    if (_selectedCategory?.id == category.id) return;

    _selectedCategory = category;
    _updateChildCategories();

    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);
    productProvider.filterProductsByCategory(_selectedCategory!.id);

    if (_childCategories.isNotEmpty) {
      _selectedChildCategory = _childCategories.first;
      productProvider.filterProductsByCategory(_selectedChildCategory!.id);
    } else {
      _selectedChildCategory = null;
    }

    notifyListeners();
  }

  void selectChildCategory(CategoryModel childCategory, BuildContext context) {
    if (_selectedChildCategory?.id == childCategory.id) return;

    _selectedChildCategory = childCategory;
    notifyListeners();

    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);
    productProvider.filterProductsByCategory(_selectedChildCategory!.id);
  }

  void _updateChildCategories() {
    if (_selectedCategory != null) {
      _childCategories = _selectedCategory!.children;
      _selectedChildCategory =
          _childCategories.isNotEmpty ? _childCategories.first : null;
    } else {
      _childCategories = [];
      _selectedChildCategory = null;
    }
  }
}
