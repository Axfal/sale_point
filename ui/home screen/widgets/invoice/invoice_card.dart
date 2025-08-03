import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:point_of_sales/models/tax_model.dart';
import 'package:point_of_sales/ui/home%20screen/widgets/invoice/providers/invoice_provider.dart';
import 'package:provider/provider.dart';
import '../../../../models/invoice_model.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/helpers/show_toast_dialouge.dart';
import '../../../invoice details/invoice_details.dart';

class InvoiceCard extends StatefulWidget {
  const InvoiceCard({super.key});

  @override
  _InvoiceCardState createState() => _InvoiceCardState();
}

class _InvoiceCardState extends State<InvoiceCard> {
  late TextEditingController customerNameController;
  late TextEditingController datedTodayController;
  late TextEditingController dueTodayController;
  late TextEditingController invoiceNumberController;

  @override
  void initState() {
    super.initState();
    final invoiceProvider =
        Provider.of<InvoiceProvider>(context, listen: false);

    // Initialize controllers with values from the provider
    customerNameController =
        TextEditingController(text: invoiceProvider.customerName);
    datedTodayController =
        TextEditingController(text: _formatDate(invoiceProvider.datedToday));
    dueTodayController =
        TextEditingController(text: _formatDate(invoiceProvider.dueToday));

    // Initialize invoice number controller and generate the invoice number if not already set
    invoiceNumberController = TextEditingController();
    _initializeInvoiceNumber(invoiceProvider);
  }

  @override
  void dispose() {
    // Dispose of the controllers properly
    customerNameController.dispose();
    datedTodayController.dispose();
    dueTodayController.dispose();
    invoiceNumberController.dispose();
    super.dispose();
  }

  // Initialize or update the invoice number
  void _initializeInvoiceNumber(InvoiceProvider invoiceProvider) {
    final invoiceNumber = invoiceProvider.invoiceNumber;
    if (invoiceNumber == null || invoiceNumber.isEmpty) {
      // If there's no invoice number, generate it
      invoiceProvider
          .generateInvoiceNumber(); // Make sure this triggers the generation
    } else {
      invoiceNumberController.text =
          invoiceNumber; // If it exists, set it in the controller
    }
  }

  String _formatDate(DateTime? date) {
    return date != null ? DateFormat('dd-MMM-yyyy').format(date) : '';
  }

  // Check if all required fields are filled
  bool _isFormValid() {
    final invoiceProvider =
        Provider.of<InvoiceProvider>(context, listen: false);
    return customerNameController.text.isNotEmpty &&
        dueTodayController.text.isNotEmpty &&
        invoiceProvider.invoiceProducts.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final invoiceProvider = Provider.of<InvoiceProvider>(context);

    return Consumer<InvoiceProvider>(
      builder: (context, invoiceProvider, child) {
        return Column(
          children: [
            _buildInvoiceDetailsExpansion(invoiceProvider),
            Divider(
              height: 0.1.h,
              color: MyAppColors.lightGreyColor,
            ),
            Expanded(child: _buildAddProductToInvoice(invoiceProvider)),
            _buildTotalAmount(invoiceProvider),
            _buildChargeButton(context),
          ],
        );
      },
    );
  }

  Widget _buildInvoiceDetailsExpansion(InvoiceProvider invoiceProvider) {
    return Container(
      color: MyAppColors.whiteColor,
      child: ExpansionTile(
        collapsedIconColor: MyAppColors.appBarColor,
        initiallyExpanded: invoiceProvider.isDetailsExpanded,
        onExpansionChanged: (expanded) {
          invoiceProvider.setDetailsExpanded(expanded);
        },
        title: !invoiceProvider.isDetailsExpanded
            ? Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customerNameController.text.isEmpty
                              ? 'Invoice Details'
                              : customerNameController.text,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: customerNameController.text.isEmpty
                                ? MyAppColors.lightGreyColor
                                : MyAppColors.blackColor,
                          ),
                        ),
                        if (invoiceNumberController.text.isNotEmpty)
                          Text(
                            invoiceNumberController.text,
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: MyAppColors.greyColor,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              )
            : Text(
                'Invoice Details',
                style: TextStyle(fontSize: 12.sp),
              ),
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Column(
              children: [
                _buildCustomerField(invoiceProvider),
                _buildTextField(
                  controller: datedTodayController,
                  label: "Dated Today *",
                  hintText: "Dated today",
                  onChanged: (val) {
                    final date = _tryParseDate(val);
                    if (date != null) invoiceProvider.setDatedToday(date);
                  },
                  isDateField: true,
                ),
                _buildTextField(
                  controller: dueTodayController,
                  label: "Due Date *",
                  hintText: "Due today",
                  onChanged: (val) {
                    final date = _tryParseDate(val);
                    if (date != null) invoiceProvider.setDueToday(date);
                  },
                  isDateField: true,
                ),
                _buildTextField(
                  controller: invoiceNumberController,
                  hintText: "Invoice Number",
                  isEditable: false,
                  onChanged: null,
                  isDateField: false,
                ),
                _buildTaxOptions(invoiceProvider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  DateTime? _tryParseDate(String input) {
    try {
      return DateFormat('dd-MMM-yyyy').parse(input);
    } catch (_) {
      return null;
    }
  }

  Widget _buildCustomerField(InvoiceProvider invoiceProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: TextField(
            // autofocus: false,
            controller: customerNameController,
            onChanged: (value) async {
              await invoiceProvider.fetchContactSuggestions(value);
            },
            style: TextStyle(
              fontSize: 10.sp,
              color: MyAppColors.blackColor,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: "Who is it for?",
              hintStyle: TextStyle(
                color: MyAppColors.lightGreyColor,
                fontSize: 12.sp,
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide(color: MyAppColors.lightGreyColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide:
                    BorderSide(color: MyAppColors.appBarColor, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide(color: MyAppColors.lightGreyColor),
              ),
            ),
          ),
        ),

        /// Contact Suggestions (Only show if any)
        if (invoiceProvider.contactSuggestions.isNotEmpty) ...[
          SizedBox(height: 8.h),
          Divider(
            height: 0.5.h,
            color: MyAppColors.lightGreyColor,
          ),
          SizedBox(height: 6.h),
          _buildContactSuggestions(invoiceProvider),
        ]
      ],
    );
  }

  Widget _buildContactSuggestions(InvoiceProvider invoiceProvider) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: 150.h,
        minHeight: 0,
      ),
      color: MyAppColors.whiteColor,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: invoiceProvider.contactSuggestions.length,
        itemBuilder: (context, index) {
          final suggestion = invoiceProvider.contactSuggestions[index];
          return ListTile(
            dense: true,
            title: Text(
              suggestion.name ?? "Unknown",
              style: TextStyle(fontSize: 12.sp),
            ),
            onTap: () {
              final name = suggestion.name ?? "Unknown";
              customerNameController.text = name;
              invoiceProvider.setCustomerName(name);
              if (suggestion.contactId.isNotEmpty) {
                invoiceProvider.setContactId(suggestion.contactId);
              }
              invoiceProvider.fetchContactSuggestions('');
            },
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required Function(String)? onChanged,
    bool isEditable = false,
    bool isDateField = false,
    String? label,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: TextFormField(
        readOnly: !isEditable || isDateField,
        controller: controller,
        onChanged: onChanged,
        onTap: () async {
          if (isDateField && !isEditable) {
            final selectedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (selectedDate != null) {
              controller.text = DateFormat('dd-MMM-yyyy').format(selectedDate);
              if (onChanged != null) onChanged(controller.text);
            }
          }
        },
        style: TextStyle(
          fontSize: 10.sp,
          color: MyAppColors.blackColor,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          labelText: label,
          labelStyle: TextStyle(
            fontSize: 10.sp,
            color: Colors.red,
            fontWeight: FontWeight.w500,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: 12.sp,
            color: MyAppColors.lightGreyColor,
          ),
          prefixIcon: isDateField
              ? Icon(
                  Icons.calendar_today_outlined,
                  size: 16.sp,
                  color: MyAppColors.appBarColor,
                )
              : null,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide(color: MyAppColors.lightGreyColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide(color: MyAppColors.appBarColor),
          ),
        ),
      ),
    );
  }

  Widget _buildTaxOptions(InvoiceProvider invoiceProvider) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Consumer<InvoiceProvider>(
            builder: (context, provider, child) {
              if (provider.availableTaxes.isEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  provider.fetchTaxes();
                });
                return const Center(child: CircularProgressIndicator());
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Dropdown Field
                  DropdownButtonFormField<Data>(
                    value: provider.selectedTaxItem,
                    isExpanded: true,
                    icon: Icon(Icons.arrow_drop_down, size: 20.sp),
                    style: TextStyle(
                        fontSize: 12.sp, color: MyAppColors.blackColor),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      labelText: 'Select Tax Rate',
                      labelStyle: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.w, vertical: 14.h),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide:
                            BorderSide(color: MyAppColors.lightGreyColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide: BorderSide(color: MyAppColors.appBarColor),
                      ),
                    ),
                    items: provider.taxModel?.data?.map((tax) {
                      final rate = tax.components?.isNotEmpty == true
                          ? tax.components!.first.rate
                          : 0;
                      return DropdownMenuItem<Data>(
                        value: tax,
                        child: Text(
                          '${tax.name} (${rate?.toString() ?? '0'}%)',
                          style: TextStyle(fontSize: 10.sp),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      provider.setSelectedTaxItem(value);
                    },
                  ),

                  /// Default Tax Notice
                  if (provider.isUsingDefaultTaxes)
                    Padding(
                      padding: EdgeInsets.only(top: 6.h, left: 4.w),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline,
                              size: 14.sp, color: Colors.orange),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              'Using default tax rates (offline mode)',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.orange,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAddProductToInvoice(InvoiceProvider invoiceProvider) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      itemCount: invoiceProvider.invoiceProducts.length,
      itemBuilder: (context, index) {
        final product = invoiceProvider.invoiceProducts[index];

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
          child: Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: MyAppColors.whiteColor,
              borderRadius: BorderRadius.circular(10.r),
              boxShadow: [
                BoxShadow(
                  color: MyAppColors.lightGreyColor.withValues(alpha: 0.4),
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product title & delete
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        product.productName,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 9.sp,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        Icons.delete_outline,
                        color: MyAppColors.lightRedColor,
                        size: 14.sp,
                      ),
                      onPressed: () {
                        invoiceProvider.removeAllProduct(product);
                      },
                    ),
                  ],
                ),

                SizedBox(height: 6.h),

                // Quantity controls & total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Quantity Controls
                    Row(
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            Icons.remove_circle_outline,
                            color: MyAppColors.lightRedColor,
                            size: 15.sp,
                          ),
                          onPressed: () {
                            if (product.quantity > 0) {
                              invoiceProvider.updateProductQuantity(
                                  product, -1);
                            }
                          },
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: Container(
                            width: 28.w,
                            height: 28.h,
                            decoration: BoxDecoration(
                              color: MyAppColors.scaffoldBgColor,
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Center(
                              child: TextField(
                                controller: TextEditingController(
                                    text: product.quantity.toString()),
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(fontSize: 9.sp),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6.r),
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade300),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6.r),
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade400),
                                  ),
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onSubmitted: (value) {
                                  int newQuantity = int.tryParse(value) ?? 1;
                                  invoiceProvider.updateProductQuantity(
                                      product, newQuantity - product.quantity);
                                },
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            Icons.add_circle_outline,
                            color: MyAppColors.greenColor,
                            size: 15.sp,
                          ),
                          onPressed: () =>
                              invoiceProvider.updateProductQuantity(product, 1),
                        ),
                      ],
                    ),
                    // Price
                    Text(
                      '\$${(product.salesPrice * product.quantity).toStringAsFixed(2)}',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 9.5.sp,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTotalAmount(InvoiceProvider invoiceProvider) {
    final subtotal = invoiceProvider.totalAmount;
    final taxAmount = invoiceProvider.calculateTaxAmount(subtotal);
    final total = invoiceProvider.totalWithTax;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      color: MyAppColors.whiteColor,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal', style: TextStyle(fontSize: 13.sp)),
              Text('\$${subtotal.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 13.sp)),
            ],
          ),
          if (invoiceProvider.taxStatus == "Tax Exclusive" || taxAmount > 0)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tax', style: TextStyle(fontSize: 13.sp)),
                Text('\$${taxAmount.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 13.sp)),
              ],
            ),
          Divider(height: 0.1.h, color: MyAppColors.lightGreyColor),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                  )),
              Text('\$${total.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                  )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChargeButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(12.r),
      child: ElevatedButton(
        onPressed: _isFormValid()
            ? () async {
                final invoiceProvider =
                    Provider.of<InvoiceProvider>(context, listen: false);

                final int userId = await invoiceProvider.getUserId();
                if (userId == 0) {
                  ShowToastDialog.showToast("User is not logged in.",
                      position: EasyLoadingToastPosition.top);
                  return;
                }

                // Set invoice number before navigation
                final invoiceNumber = invoiceProvider.invoiceNumber ?? '';
                invoiceProvider.setInvoiceNumber(
                    invoiceNumber); // Ensure invoice number is set

                final subtotal = invoiceProvider.totalAmount;
                final taxAmount = invoiceProvider.calculateTaxAmount(subtotal);

                final invoiceDetails = InvoiceModel(
                  customerName: customerNameController.text,
                  datedToday: invoiceProvider.datedToday ?? DateTime.now(),
                  dueToday: invoiceProvider.dueToday ?? DateTime.now(),
                  invoiceNumber: invoiceNumber,
                  products: invoiceProvider.invoiceProducts,
                  userId: userId,
                  taxStatus: invoiceProvider.selectedTaxItem?.taxType ??
                      'invoice card',
                  selectedTax: invoiceProvider.selectedTaxItem,
                  taxAmount: taxAmount,
                  subtotal: subtotal,
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        InvoiceDetailScreen(invoiceDetails: invoiceDetails),
                  ),
                );
              }
            : () {
                ShowToastDialog.showToast(
                  "Please fill all required fields and add products to proceed.",
                  position: EasyLoadingToastPosition.top,
                );
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: MyAppColors.appBarColor,
          minimumSize: Size(double.infinity, 44.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        child: Text(
          'CHARGE',
          style: TextStyle(
            color: MyAppColors.whiteColor,
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
