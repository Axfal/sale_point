import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';
import '../../../utils/constants/my_sharePrefs.dart';
import '../../../utils/helpers/show_toast_dialouge.dart';

class LoginProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final MySharedPrefs _prefs = MySharedPrefs();

  bool _isPasswordVisible = false;
  bool _isSessionLoaded = false;
  bool _isLoading = false;
  UserModel? _user;

  bool get isPasswordVisible => _isPasswordVisible;
  bool get isSessionLoaded => _isSessionLoaded;
  bool get isLoading => _isLoading;
  UserModel? get user => _user;

  /// ✅ Toggle password visibility
  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  /// ✅ Load user session on app startup
  Future<void> loadUserSession() async {
    final isLoggedIn = await _prefs.isUserLoggedIn();
    if (isLoggedIn) {
      final userDataString = await _prefs.getUserData();
      if (userDataString != null) {
        try {
          final Map<String, dynamic> userData = jsonDecode(userDataString);
          _user = UserModel.fromJson(userData);
        } catch (e) {
          print("❌ Error loading session: $e");
        }
      }
    }
    _isSessionLoaded = true;
    notifyListeners();
  }

  /// ✅ Login user, store session, and update UI
  Future<String?> userLogin(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _authService.signIn(email, password);
      if (response?["success"] == true) {
        _user = UserModel.fromJson(response?["user"]);

        /// ✅ Store user session
        await _prefs.setUserData(jsonEncode(response?["user"]));

        print("✅ Login successful. User: ${_user?.name}");
        print("✅ Login successful. User: ${_user?.id}");
        return null; // No error
      } else {
        return response?["message"] ?? "Invalid credentials";
      }
    } catch (e) {
      return "Login failed: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ✅ Logout user and clear session data
  Future<bool> userLogout() async {
    try {
      print("🔄 Starting logout process...");
      ShowToastDialog.showLoader("Logging out...");

      // Clear user data from provider
      _user = null;

      // Clear session data from storage
      await _prefs.clearUserSession();

      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast("Logged out successfully! 👋");

      print("✅ Logout successful");
      notifyListeners();
      return true;
    } catch (e) {
      print("❌ Error during logout: $e");
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast("Error during logout: $e");
      return false;
    }
  }
}
