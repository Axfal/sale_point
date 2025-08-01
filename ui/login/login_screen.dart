import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'provider/login_provider.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/helpers/show_toast_dialouge.dart';
import '../../utils/helpers/CustomTextField.dart';
import '../home screen/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _navigating = false;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadSession() async {
    ShowToastDialog.showLoader("Loading session...");
    await Provider.of<LoginProvider>(context, listen: false).loadUserSession();
    ShowToastDialog.closeLoader();

    /// 🔹 Debugging Statement
    print(
        "✅ Session Loaded - User: ${Provider.of<LoginProvider>(context, listen: false).user}");
  }

  void _navigateToHome() {
    if (!mounted || _navigating) return;
    _navigating = true;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomeScreen(scaffoldKey: GlobalKey<ScaffoldState>()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginProvider>(
      builder: (context, loginProvider, child) {
        if (!loginProvider.isSessionLoaded) {
          print("⚠️ Waiting for session to load...");
          return const Scaffold(body: SizedBox.shrink());
        }

        if (loginProvider.user != null && !_navigating) {
          print("✅ User logged in. Navigating to HomeScreen...");
          WidgetsBinding.instance
              .addPostFrameCallback((_) => _navigateToHome());
          return const Scaffold(body: SizedBox.shrink());
        }

        return _buildLoginScreen(loginProvider);
      },
    );
  }

  Widget _buildLoginScreen(LoginProvider loginProvider) {
    return Scaffold(
      backgroundColor: MyAppColors.appBarColor,
      // appBar: AppBar(
      //   backgroundColor: MyAppColors.whiteColor,
      //   centerTitle: true,
      //   title: Image.asset(
      //     'assets/app_logo/bonope-logo.png',
      //     height: 40,
      //   ),
      // ),
      // backgroundColor: MyAppColors.whiteColor,
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 400.w,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Add logo at the top of the form
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 40.h),
                      child: Image.asset(
                        'assets/app_logo/bonope-logo.png',
                        height: 120.h,
                      ),
                    ),

                    /// Email Field
                    CustomTextField(
                      controller: _emailController,
                      hintText: "Enter your email",
                      label: "Email",
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.emailAddress,
                      obscureText: false,
                      prefixIcon:
                          const Icon(Icons.email, color: MyAppColors.greyColor),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Email cannot be empty";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    /// Password Field
                    CustomTextField(
                      controller: _passwordController,
                      hintText: "Enter your password",
                      label: "Password",
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.text,
                      obscureText: !loginProvider.isPasswordVisible,
                      prefixIcon:
                          const Icon(Icons.lock, color: MyAppColors.greyColor),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Password cannot be empty";
                        }
                        return null;
                      },

                      /// ✅ Eye Icon Button to Toggle Password Visibility
                      suffixIcon: Consumer<LoginProvider>(
                        builder: (context, loginProvider, child) {
                          return IconButton(
                            icon: Icon(
                              loginProvider.isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: loginProvider.isPasswordVisible
                                  ? MyAppColors.appBarColor
                                  : MyAppColors.greyColor,
                            ),
                            onPressed: loginProvider.togglePasswordVisibility,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    /// Login button
                    SizedBox(
                      width: 150.w,
                      height: 70.h,
                      child: ElevatedButton(
                        onPressed: loginProvider.isLoading
                            ? null
                            : () => _handleLogin(context, loginProvider),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MyAppColors.whiteColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: loginProvider.isLoading
                            ? CupertinoActivityIndicator(
                                color: MyAppColors.whiteColor)
                            : Text("Login",
                                style:
                                    TextStyle(color: MyAppColors.appBarColor, fontWeight: FontWeight.bold, fontSize: 15.sp)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 🔹 Handles login action with validation
  Future<void> _handleLogin(
      BuildContext context, LoginProvider loginProvider) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    ShowToastDialog.showLoader('Authenticating... 🔒');
    print("🔍 Logging in...");

    try {
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();

      print("📧 Email: $email");
      print("🔑 Password: ${password.replaceAll(RegExp(r'.'), '*')}");

      String? errorMessage = await loginProvider.userLogin(email, password);

      if (!mounted) return;
      ShowToastDialog.closeLoader();

      if (errorMessage == null) {
        print("✅ Login successful. User: ${loginProvider.user}");
        ShowToastDialog.showToast("Welcome! 🎉",
            position: EasyLoadingToastPosition.top);

        // Navigate immediately after successful login
        _navigateToHome();
      } else {
        print("❌ Login failed: $errorMessage");
        ShowToastDialog.showToast(errorMessage,
            position: EasyLoadingToastPosition.top);
      }
    } catch (e) {
      if (!mounted) return;
      ShowToastDialog.closeLoader();
      print("🚨 Unexpected Error: $e");
      ShowToastDialog.showToast("Unexpected Error: $e",
          position: EasyLoadingToastPosition.top);
    }
  }
}
