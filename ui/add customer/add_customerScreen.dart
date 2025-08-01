import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:point_of_sales/utils/constants/app_colors.dart';
import 'package:point_of_sales/utils/extensions/sized_box_extension.dart';
import 'package:point_of_sales/utils/helpers/CustomTextField.dart';
import '../../utils/helpers/show_toast_dialouge.dart';
import '../all customer/provider/contacts_provider.dart';

class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({super.key});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _phoneAreaCodeController = TextEditingController();
  final _phoneCountryCodeController = TextEditingController();
  final _addressLine1Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _regionController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _countryController = TextEditingController();
  final _taxNumberController = TextEditingController();
  final _companyNumberController = TextEditingController();
  final _currencyController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _phoneAreaCodeController.dispose();
    _phoneCountryCodeController.dispose();
    _addressLine1Controller.dispose();
    _cityController.dispose();
    _regionController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    _taxNumberController.dispose();
    _companyNumberController.dispose();
    _currencyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: MyAppColors.scaffoldBgColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Card(
                  elevation: 2,
                  color: MyAppColors.whiteColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle("Contact Info"),
                          _buildFormRow([
                            _buildTextField(_nameController, "Contact Name",
                                hint: "A business or person's name",
                                validator: (value) =>
                                value == null || value.isEmpty
                                    ? "Contact Name can't be empty"
                                    : null)]),
                          _buildSectionTitle("Basic Info"),
                          _buildFormRow([
                            _buildTextField(_firstNameController, "First Name",
                                hint: "Enter First Name"),
                            _buildTextField(_lastNameController, "Last Name",
                                hint: "Enter Last Name"),
                          ]),

                          _buildFormRow([
                            _buildTextField(_emailController, "Email",
                                hint: "Enter Email",
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) =>
                                value == null || value.isEmpty
                                    ? "Email can't be empty"
                                    : null),
                            _buildTextField(_phoneController, "Phone",
                                hint: "Enter Phone Number",
                                validator: (value) =>
                                value == null || value.isEmpty
                                    ? "Phone can't be empty"
                                    : null),
                            _buildTextField(
                                _phoneAreaCodeController, "Phone Area Code",
                                hint: "Enter Phone Area Code"),
                            _buildTextField(_phoneCountryCodeController,
                                "Phone Country Code",
                                hint: "Enter Phone Country Code",
                                validator: (value) =>
                                    value == null || value.isEmpty
                                        ? "Country Code can't be empty"
                                        : null),
                          ]),
                          _buildSectionTitle("Address"),
                          _buildTextField(
                              hint: "Enter Address",
                              _addressLine1Controller,
                              "Address Line 1"),
                          _buildFormRow([
                            _buildTextField(_cityController, "City",
                                hint: "Enter City"),
                            _buildTextField(_regionController, "Region",
                                hint: "Enter Region"),
                          ]),
                          _buildFormRow([
                            _buildTextField(
                                hint: "Enter Postal Code",
                                _postalCodeController,
                                "Postal Code"),
                            _buildTextField(_countryController, "Country",
                                hint: "Enter Country"),

                          ]),
                          _buildSectionTitle("Other Details"),
                          _buildFormRow([
                            _buildTextField(_taxNumberController, "Tax Number",
                                hint: "Enter Tax Number"),
                            _buildTextField(
                                _companyNumberController, "Company Number",
                                hint: "Enter Company Number"),
                          ]),
                          _buildTextField(
                              _currencyController, "Default Currency",
                              hint: "Enter Default Currency"),
                          SizedBoxExtensions.withHeight(32.h),
                          Center(child: _buildAddButton()),
                          SizedBoxExtensions.withHeight(12.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: MyAppColors.appBarColor,
      iconTheme: const IconThemeData(color: MyAppColors.whiteColor),
      title: Text(
        "Add New Customer",
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(CupertinoIcons.back),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.grey.shade600, size: 18.sp),
          SizedBoxExtensions.withWidth(8.w),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 12.sp,
              color: MyAppColors.appBarColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 6.h),
          CustomTextField(
            controller: controller,
            label: hint,
            hintText: hint,
            textInputAction: TextInputAction.next,
            keyboardType: keyboardType,
            validator: validator,
            obscureText: false,
            style: GoogleFonts.poppins(
              fontSize: 10.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormRow(List<Widget> children) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWide = constraints.maxWidth > 600;
        if (isWide && children.length == 2) {
          return Row(
            children: [
              Expanded(child: children[0]),
              SizedBoxExtensions.withWidth(12.w),
              Expanded(child: children[1]),
            ],
          );
        }
        return Column(children: children);
      },
    );
  }

  Widget _buildAddButton() {
    return SizedBox(
      height: 65.h,
      width: 160.w,
      child: ElevatedButton.icon(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            final contactsProvider =
                Provider.of<ContactsProvider>(context, listen: false);
            contactsProvider
                .createNewContact(
              name: _nameController.text,
              firstName: _firstNameController.text,
              lastName: _lastNameController.text,
              email: _emailController.text,
              phone: _phoneController.text,
              phoneAreaCode: _phoneAreaCodeController.text,
              phoneCountryCode: _phoneCountryCodeController.text,
              addressLine1: _addressLine1Controller.text,
              city: _cityController.text,
              region: _regionController.text,
              postalCode: _postalCodeController.text,
              country: _countryController.text,
              taxNumber: _taxNumberController.text,
              companyNumber: _companyNumberController.text,
              defaultCurrency: _currencyController.text,
            )
                .then((success) {
              ShowToastDialog.showToast(
                success
                    ? "New contact added to list"
                    : "Name, email, and phone are required",
                position: EasyLoadingToastPosition.top,
              );
            });
          }
        },
        icon: Icon(
          Icons.person_add_alt_1_rounded,
          size: 18.sp,
          color: MyAppColors.whiteColor,
        ),
        label: Text(
          'Add Customer',
          style: GoogleFonts.poppins(
            fontSize: 11.5.sp,
            fontWeight: FontWeight.w600,
            color: MyAppColors.whiteColor,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: MyAppColors.appBarColor,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 3,
          shadowColor: Colors.black26,
        ),
      ),
    );
  }
}
