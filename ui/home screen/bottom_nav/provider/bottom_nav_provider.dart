import 'package:flutter/material.dart';
import '../../../../models/categories_model.dart';
import '../../../../services/category_service.dart';
import '../../../../utils/constants/my_sharePrefs.dart';

class BottomNavigationProvider extends ChangeNotifier {
  final CategoryService _categoryService = CategoryService();
  final MySharedPrefs _sharedPrefs = MySharedPrefs();

  int _currentIndex = 0;
  List<CategoryModel> _categories = []; // ✅ Parent Categories
  Map<int, List<CategoryModel>> _childCategories = {}; // ✅ Parent ID -> Child Categories
  bool _isLoading = true;


  int get currentIndex => _currentIndex;
  List<CategoryModel> get categories => _categories;
  Map<int, List<CategoryModel>> get childCategories => _childCategories;
  bool get isLoading => _isLoading;

  BottomNavigationProvider() {
    _loadCategories();
  }

  void updateIndex(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  Future<void> _loadCategories() async {
    _isLoading = true;
    notifyListeners();

    final bool isExpired = await _sharedPrefs.isCategoryCacheExpired();
    if (!isExpired) {
      final cachedData = await _sharedPrefs.getCategories();
      if (cachedData.isNotEmpty) {
        _parseCategories(cachedData);
        return;
      }
    }

    await fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      final response = await _categoryService.getCategories();

      if (response != null && response['success'] == true) {
        final List<dynamic> categoryData = response['categories'] ?? [];
        _parseCategories(categoryData);

        await _sharedPrefs.setCategories(categoryData.cast<Map<String, dynamic>>());
      } else {
        print("❌ API Error: ${response?['message'] ?? 'Unknown error'}");
      }
    } catch (e) {
      print("❌ Exception while fetching categories: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  void _parseCategories(List<dynamic> categoryData) {
    _categories.clear();
    _childCategories.clear();

    for (var json in categoryData) {
      CategoryModel category = CategoryModel.fromJson(json);
      if (category.parentId == null) {
        _categories.add(category);
      } else {
        _childCategories.putIfAbsent(category.parentId!, () => []).add(category);
      }
    }
    print("📌 Parent Categories Loaded: ${_categories.map((e) => e.name).toList()}");
    print("📌 Child Categories Map: $_childCategories");

    _isLoading = false;
    notifyListeners();
  }
}