import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:point_of_sales/utils/constants/app_colors.dart';
import 'package:point_of_sales/utils/extensions/sized_box_extension.dart';
import 'package:point_of_sales/utils/helpers/show_toast_dialouge.dart';
import '../../models/invoice_model.dart';
import '../../models/product_model.dart';
import '../home screen/widgets/invoice/providers/invoice_provider.dart';
import '../home screen/widgets/invoice/providers/bank_provider.dart';
import 'providers/payment_provider.dart';
import 'widgets/bank_search_bottom_sheet.dart';
import '../../services/sales.dart';

class InvoiceDetailScreen extends StatefulWidget {
  final InvoiceModel invoiceDetails;

  const InvoiceDetailScreen({super.key, required this.invoiceDetails});

  @override
  State<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends State<InvoiceDetailScreen> {
  // Map to store controllers for each product
  final Map<String, TextEditingController> _priceControllers = {};
  final Map<String, FocusNode> _priceFocusNodes = {};

  @override
  void initState() {
    super.initState();
    // Initialize controllers and focus nodes for each product
    for (var product in widget.invoiceDetails.products) {
      _priceControllers[product.itemId] =
          TextEditingController(text: product.salesPrice.toStringAsFixed(2));
      _priceFocusNodes[product.itemId] = FocusNode();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final invoiceProvider = context.read<InvoiceProvider>();
      invoiceProvider.setInvoiceProducts(widget.invoiceDetails.products);
      context.read<PaymentProvider>().reset();
      context.read<BankProvider>().fetchBankAccounts();
    });
  }

  @override
  void dispose() {
    // Clean up controllers and focus nodes
    for (var controller in _priceControllers.values) {
      controller.dispose();
    }
    for (var focusNode in _priceFocusNodes.values) {
      focusNode.dispose();
    }
    super.dispose();
  }

  // Helper method to handle price updates
  void _handlePriceUpdate(
      String value, ProductModel product, InvoiceProvider invoiceProvider) {
    if (value.isEmpty) {
      print('Empty price value');
      return;
    }

    final newPrice = double.tryParse(value);
    if (newPrice != null && newPrice >= 0) {
      print('💲 Valid price entered: $newPrice');
      invoiceProvider.updateProductPrice(product, newPrice);
    } else {
      print('❌ Invalid price value: $value');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyAppColors.scaffoldBgColor,
      appBar: _buildAppBar(context),
      body: Row(
        children: [
          _buildInvoiceSummary(),
          VerticalDivider(
              width: 1, thickness: 1, color: MyAppColors.whiteColor),
          _buildPaymentSection(context),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Invoice Details',
          style: TextStyle(color: MyAppColors.whiteColor)),
      centerTitle: true,
      backgroundColor: MyAppColors.appBarColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: MyAppColors.whiteColor),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildInvoiceSummary() {
    return Consumer<InvoiceProvider>(
      builder: (context, invoiceProvider, _) {
        return Expanded(
          flex: 2,
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r)),
              elevation: 2,
              shadowColor: MyAppColors.blackColor.withValues(alpha: 0.2),
              color: MyAppColors.whiteColor,
              child: Padding(
                padding: EdgeInsets.all(16.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInvoiceHeader(),
                    const Divider(
                        thickness: 1, color: MyAppColors.scaffoldBgColor),
                    _buildItemList(),
                    const Divider(
                        thickness: 1, color: MyAppColors.scaffoldBgColor),
                    _buildAmountBreakdown(),
                    SizedBoxExtensions.withHeight(8.h),
                    _buildInvoiceTotal(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInvoiceHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildInfoRow(
                  'Invoice # ', widget.invoiceDetails.invoiceNumber),
            ),
            Expanded(
              child: _buildInfoRow(
                  'Customer ', widget.invoiceDetails.customerName),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: _buildInfoRow(
                  'Date ', _formatDate(widget.invoiceDetails.datedToday)),
            ),
            Expanded(
              child: _buildInfoRow(
                  'Due Date ', _formatDate(widget.invoiceDetails.dueToday)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: MyAppColors.blackColor,
              fontSize: 10.sp,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: MyAppColors.greyColor,
                fontSize: 10.sp,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemList() {
    return Expanded(
      child: Consumer<InvoiceProvider>(
        builder: (context, invoiceProvider, _) {
          final products = invoiceProvider.invoiceProducts;

          if (products.isEmpty) {
            return Center(
              child: Text(
                'No products added to invoice',
                style: TextStyle(
                  color: MyAppColors.greyColor,
                  fontSize: 12.sp,
                ),
              ),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            itemCount: products.length,
            separatorBuilder: (_, __) => SizedBox(height: 8.h),
            itemBuilder: (context, index) {
              final product = products[index];
              final controller = _priceControllers[product.itemId]!;
              final focusNode = _priceFocusNodes[product.itemId]!;

              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Top Row: Delete Icon & Product Name
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                          icon: Icon(Icons.delete,
                              color: MyAppColors.lightRedColor, size: 18.sp),
                          onPressed: () {
                            invoiceProvider.removeAllProduct(product);
                            _priceControllers[product.itemId]?.dispose();
                            _priceFocusNodes[product.itemId]?.dispose();
                            _priceControllers.remove(product.itemId);
                            _priceFocusNodes.remove(product.itemId);
                          },
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                        ),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Text(
                            product.productName,
                            style: TextStyle(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w500,
                              color: MyAppColors.blackColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 10.h),

                    /// Middle Row: Quantity Controls
                    Row(
                      children: [
                        Text(
                          'Qty:',
                          style: TextStyle(
                            fontSize: 9.sp,
                            color: MyAppColors.greyColor,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        _qtyButton(
                            icon: Icons.remove_circle_outline,
                            onTap: () {
                              if (product.quantity > 1) {
                                invoiceProvider.updateProductQuantity(
                                    product, -1);
                              }
                            },
                            color: MyAppColors.lightRedColor),
                        SizedBox(
                          width: 30.w,
                          child: Center(
                            child: Text(
                              '${product.quantity}',
                              style: TextStyle(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        _qtyButton(
                          icon: Icons.add_circle_outline,
                          onTap: () =>
                              invoiceProvider.updateProductQuantity(product, 1),
                          color: MyAppColors.greenColor,
                        ),
                      ],
                    ),

                    SizedBox(height: 10.h),

                    /// Bottom Row: Price Input and Total
                    Row(
                      children: [
                        Text(
                          'Price:',
                          style: TextStyle(
                            fontSize: 9.sp,
                            color: MyAppColors.greyColor,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        SizedBox(
                          width: 70.w,
                          child: TextFormField(
                            controller: controller,
                            focusNode: focusNode,
                            textAlign: TextAlign.center,
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            style: TextStyle(
                              fontSize: 9.sp,
                              color: MyAppColors.blackColor,
                            ),
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 6.w, vertical: 8.h),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6.r),
                                borderSide: BorderSide(
                                  color: MyAppColors.greyColor
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                            ),
                            onChanged: (value) => _handlePriceUpdate(
                                value, product, invoiceProvider),
                          ),
                        ),
                        Spacer(),
                        Text(
                          'Total: \$${(product.salesPrice * product.quantity).toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w600,
                            color: MyAppColors.blackColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// Quantity button
  Widget _qtyButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Icon(
          icon,
          size: 18.sp,
          color: color,
        ),
      ),
    );
  }

  Widget _buildAmountBreakdown() {
    return Consumer<InvoiceProvider>(builder: (context, invoiceProvider, _) {
      final subtotal = invoiceProvider.totalAmount;
      final taxAmount = invoiceProvider.calculateTaxAmount(subtotal);
      final taxPercentage =
          widget.invoiceDetails.selectedTax?.displayRate ?? 0.0;
      final taxName = widget.invoiceDetails.selectedTax?.name ?? 'Tax';

      return Column(
        children: [
          _buildAmountRow('Subtotal', subtotal),
          if (widget.invoiceDetails.taxStatus == "Tax Exclusive" ||
              taxAmount > 0)
            _buildAmountRow('$taxName ($taxPercentage%)', taxAmount),
        ],
      );
    });
  }

  Widget _buildAmountRow(String label, double value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: MyAppColors.greyColor,
              fontWeight: FontWeight.w500,
              fontSize: 10.sp,
            ),
          ),
          Text(
            '\$${value.toStringAsFixed(2)}',
            style: TextStyle(
              color: MyAppColors.greyColor,
              fontSize: 10.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceTotal() {
    return Consumer<InvoiceProvider>(builder: (context, invoiceProvider, _) {
      final total = invoiceProvider.totalWithTax;
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 11.sp,
            ),
          ),
          Text(
            '\$${total.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: MyAppColors.blackColor,
              fontSize: 11.sp,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildPaymentSection(BuildContext context) {
    return Expanded(
      flex: 2,
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Card(
          color: MyAppColors.whiteColor,
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          shadowColor: MyAppColors.blackColor.withValues(alpha: 0.2),
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          _buildTotalDue(),
                          SizedBox(height: 24.h),
                          _buildPaymentMethodSelector(context),
                          SizedBox(height: 24.h),
                          _buildPaymentDetails(context),
                          const Spacer(),
                          _buildSubmitButton(context),
                          SizedBox(height: 16.h),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTotalDue() {
    return Consumer<InvoiceProvider>(builder: (context, invoiceProvider, _) {
      final total = invoiceProvider.totalWithTax;
      return Column(
        children: [
          Text('\$${total.toStringAsFixed(2)}',
              style: TextStyle(
                  fontSize: 30.sp,
                  fontWeight: FontWeight.bold,
                  color: MyAppColors.appBarColor)),
          SizedBoxExtensions.withHeight(6.h),
          Text('Total Due',
              style: TextStyle(fontSize: 13.sp, color: MyAppColors.greyColor)),
        ],
      );
    });
  }

  Widget _buildPaymentMethodSelector(BuildContext context) {
    return Consumer<PaymentProvider>(
      builder: (context, paymentProvider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Payment Method',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: MyAppColors.blackColor,
              ),
            ),
            SizedBox(height: 12.h),
            ...PaymentMethod.values.map((method) => _buildPaymentMethodTile(
                  context,
                  method,
                  paymentProvider,
                )),
          ],
        );
      },
    );
  }

  Widget _buildPaymentMethodTile(
    BuildContext context,
    PaymentMethod method,
    PaymentProvider provider,
  ) {
    final isSelected = provider.selectedPaymentMethod == method;
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Material(
        color: isSelected
            ? MyAppColors.appBarColor.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12.r),
        child: InkWell(
          onTap: () => provider.setPaymentMethod(method),
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected
                    ? MyAppColors.appBarColor
                    : Colors.grey.withValues(alpha: 0.3),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(
                  method.icon,
                  color: isSelected
                      ? MyAppColors.appBarColor
                      : MyAppColors.greyColor,
                  size: 24.sp,
                ),
                SizedBox(width: 12.w),
                Text(
                  method.displayName,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? MyAppColors.appBarColor
                        : MyAppColors.blackColor,
                  ),
                ),
                const Spacer(),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: MyAppColors.appBarColor,
                    size: 24.sp,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentDetails(BuildContext context) {
    return Consumer2<PaymentProvider, BankProvider>(
      builder: (context, paymentProvider, bankProvider, _) {
        if (paymentProvider.selectedPaymentMethod == null) {
          return const SizedBox.shrink();
        }

        // For Pay Later, show a message instead of bank details
        if (paymentProvider.selectedPaymentMethod == PaymentMethod.pay_later) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Text(
              'Payment will be collected later',
              style: TextStyle(
                fontSize: 16.sp,
                color: MyAppColors.greyColor,
                fontStyle: FontStyle.italic,
              ),
            ),
          );
        }

        // For Partial Payment, show amount input field
        if (paymentProvider.selectedPaymentMethod ==
            PaymentMethod.partial_payment) {
          return Consumer<InvoiceProvider>(
            builder: (context, invoiceProvider, _) {
              final totalDue = invoiceProvider.totalWithTax;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enter Partial Payment Amount',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: MyAppColors.blackColor,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  TextField(
                    controller: paymentProvider.partialAmountController,
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final amount = double.tryParse(value) ?? 0.0;
                      if (amount > totalDue) {
                        paymentProvider.partialAmountController.text =
                            totalDue.toStringAsFixed(2);
                      }
                    },
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.attach_money),
                      hintText:
                          'Enter amount (max: \$${totalDue.toStringAsFixed(2)})',
                      filled: true,
                      fillColor: MyAppColors.scaffoldBgColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  if (paymentProvider.receivedAmount > 0)
                    Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: MyAppColors.scaffoldBgColor,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPaymentInfoRow(
                            'Total Amount:',
                            '\$${totalDue.toStringAsFixed(2)}',
                          ),
                          SizedBox(height: 8.h),
                          _buildPaymentInfoRow(
                            'Partial Payment:',
                            '\$${paymentProvider.receivedAmount.toStringAsFixed(2)}',
                            valueColor: MyAppColors.appBarColor,
                          ),
                          SizedBox(height: 8.h),
                          _buildPaymentInfoRow(
                            'Remaining Balance:',
                            '\$${(totalDue - paymentProvider.receivedAmount).toStringAsFixed(2)}',
                            valueColor: MyAppColors.redColor,
                          ),
                        ],
                      ),
                    ),

                  /// Bank lists for partial payment
                  SizedBox(height: 12.h),
                  InkWell(
                    onTap: () => _handleBankSelection(context),
                    child: Container(
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey[300]!,
                        ),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: bankProvider.isLoading
                                ? Row(
                                    children: [
                                      SizedBox(
                                        width: 16.w,
                                        height: 16.w,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                      SizedBox(width: 12.w),
                                      Text(
                                        'Loading banks...',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  )
                                : Text(
                                    bankProvider.selectedBank?['Name'] ??
                                        'Select Bank Account',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: bankProvider.selectedBank != null
                                          ? MyAppColors.blackColor
                                          : Colors.grey[600],
                                    ),
                                  ),
                          ),
                          Icon(
                            Icons.arrow_drop_down,
                            color: Colors.grey[600],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Debug button to refresh banks
                  if (bankProvider.bankAccounts.isEmpty &&
                      !bankProvider.isLoading)
                    Padding(
                      padding: EdgeInsets.only(top: 8.h),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            print('🔄 Manually refreshing bank accounts...');
                            bankProvider.fetchBankAccounts();
                          },
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('Refresh Banks'),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        }

        return Column(
          children: [
            _buildBankAccountsSection(context),
            if (paymentProvider.selectedPaymentMethod == PaymentMethod.cod)
              Column(
                children: [
                  SizedBox(height: 24.h),
                  _buildCashPaymentSection(context),
                ],
              ),
          ],
        );
      },
    );
  }

  Widget _buildPaymentInfoRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: MyAppColors.greyColor,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: valueColor ?? MyAppColors.blackColor,
          ),
        ),
      ],
    );
  }

  Widget _buildBankAccountsSection(BuildContext context) {
    return Consumer2<PaymentProvider, BankProvider>(
      builder: (context, paymentProvider, bankProvider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              paymentProvider.selectedPaymentMethod == PaymentMethod.bank
                  ? 'Bank Account'
                  : 'Deposit Bank Account',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: MyAppColors.blackColor,
              ),
            ),
            SizedBox(height: 12.h),
            InkWell(
              onTap: () => _handleBankSelection(context),
              child: Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey[300]!,
                  ),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: bankProvider.isLoading
                          ? Row(
                              children: [
                                SizedBox(
                                  width: 16.w,
                                  height: 16.w,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Text(
                                  'Loading banks...',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              bankProvider.selectedBank?['Name'] ??
                                  'Select Bank Account',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: bankProvider.selectedBank != null
                                    ? MyAppColors.blackColor
                                    : Colors.grey[600],
                              ),
                            ),
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      color: Colors.grey[600],
                    ),
                  ],
                ),
              ),
            ),
            // Debug button to refresh banks
            if (bankProvider.bankAccounts.isEmpty && !bankProvider.isLoading)
              Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      print('🔄 Manually refreshing bank accounts...');
                      bankProvider.fetchBankAccounts();
                    },
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Refresh Banks'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildBankInfoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 120.w,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[600],
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12.sp,
              color: MyAppColors.blackColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCashPaymentSection(BuildContext context) {
    return Consumer2<PaymentProvider, InvoiceProvider>(
      builder: (context, paymentProvider, invoiceProvider, _) {
        // Automatically update cash received when total changes and COD is selected
        if (paymentProvider.isCashOnDelivery) {
          final totalDue = invoiceProvider.totalWithTax;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            paymentProvider.updateCashReceived(totalDue);
          });
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cash Received',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: MyAppColors.blackColor,
              ),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: paymentProvider.cashReceivedController,
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final amount = double.tryParse(value) ?? 0.0;
                paymentProvider
                    .validateReceivedAmount(invoiceProvider.totalWithTax);
              },
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.attach_money),
                hintText: 'Enter amount',
                errorText: paymentProvider.receivedAmountError.isNotEmpty
                    ? paymentProvider.receivedAmountError
                    : null,
                filled: true,
                fillColor: MyAppColors.scaffoldBgColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            if (paymentProvider.receivedAmount > 0 &&
                paymentProvider.receivedAmountError.isEmpty)
              Padding(
                padding: EdgeInsets.only(top: 12.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Change:',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: MyAppColors.blackColor,
                      ),
                    ),
                    Text(
                      '\$${paymentProvider.getChange(invoiceProvider.totalWithTax).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: MyAppColors.appBarColor,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return Consumer<PaymentProvider>(
      builder: (context, paymentProvider, _) {
        final isValid = paymentProvider.isValidPaymentConfig;
        final isProcessing = paymentProvider.isProcessing;

        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: !isValid || isProcessing
                ? null
                : () => _handlePayment(context, paymentProvider),
            style: ElevatedButton.styleFrom(
              backgroundColor: MyAppColors.appBarColor,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 2,
            ),
            child: isProcessing
                ? SizedBox(
                    height: 20.h,
                    width: 20.h,
                    child: CupertinoActivityIndicator(),
                  )
                : Text(
                    'Complete Payment',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        );
      },
    );
  }

  void _handleBankSelection(BuildContext context) async {
    print('🔄 Starting bank selection process...');
    final bankProvider = Provider.of<BankProvider>(context, listen: false);
    final invoiceProvider =
        Provider.of<InvoiceProvider>(context, listen: false);
    final paymentProvider =
        Provider.of<PaymentProvider>(context, listen: false);

    final selectedBank = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const BankSearchBottomSheet(),
    );

    print('📝 Selected bank from modal: ${selectedBank?.toString()}');

    if (selectedBank != null) {
      print('✓ Setting bank in providers...');
      // Set the bank in both providers
      bankProvider.setSelectedBank(selectedBank);
      paymentProvider.setSelectedBank(selectedBank);
      invoiceProvider.setAccountId(selectedBank['AccountID']);

      print(
          '✓ Bank set in BankProvider: ${bankProvider.selectedBank?['Name']}');
      print(
          '✓ Bank set in PaymentProvider: ${paymentProvider.selectedBank?['Name']}');
      print('✓ AccountID set in InvoiceProvider: ${selectedBank['AccountID']}');
    } else {
      print('❌ No bank was selected from modal');
    }
  }

  Future<void> _handlePayment(
    BuildContext context,
    PaymentProvider paymentProvider,
  ) async {
    print('🚀 Starting payment process...');
    try {
      paymentProvider.setProcessing(true);
      print(
          '💳 Payment method: ${paymentProvider.selectedPaymentMethod?.displayName}');

      final invoiceProvider =
          Provider.of<InvoiceProvider>(context, listen: false);
      final bankProvider = Provider.of<BankProvider>(context, listen: false);
      final salesService = SalesService();

      // Validate bank account selection (except for Pay Later)
      if (paymentProvider.selectedPaymentMethod != PaymentMethod.pay_later &&
          bankProvider.selectedBank == null) {
        print('❌ Error: No bank account selected');
        ShowToastDialog.showToast('Please select a bank account');
        return;
      }

      // Handle bank information based on payment method
      String? accountId;
      String? accountCode;

      if (paymentProvider.selectedPaymentMethod != PaymentMethod.pay_later) {
        print('🏦 Selected bank: ${bankProvider.selectedBank!['Name']}');
        accountId = bankProvider.selectedBank!['AccountID'];
        accountCode =
            bankProvider.selectedBank!['Code'] ?? "yar bank ka code null hy";
      } else {
        print('⏰ Pay Later payment - no bank account required');
        accountId = null; // For Pay Later, we don't need an account ID
        accountCode = null;
      }

      print(
          '💰 Total amount: \$${widget.invoiceDetails.totalAmount.toStringAsFixed(2)}');

      // Create a copy of the invoice with the payment method and bank account
      final invoice = InvoiceModel(
        userId: widget.invoiceDetails.userId,
        accountId: accountId,
        contactId: widget.invoiceDetails.contactId,
        customerName: widget.invoiceDetails.customerName,
        datedToday: widget.invoiceDetails.datedToday,
        dueToday: widget.invoiceDetails.dueToday,
        invoiceNumber: widget.invoiceDetails.invoiceNumber,
        products: widget.invoiceDetails.products,
        taxStatus: widget.invoiceDetails.taxStatus,
        selectedTax: widget.invoiceDetails.selectedTax,
        taxAmount: widget.invoiceDetails.taxAmount,
        subtotal: widget.invoiceDetails.subtotal,
        paymentMethod: paymentProvider.selectedPaymentMethod?.displayName,
        notes: _getPaymentNotes(paymentProvider),
      );

      // For Pay Later, we need to set the accountId to null in the provider as well
      if (paymentProvider.selectedPaymentMethod == PaymentMethod.pay_later) {
        invoiceProvider.setAccountId(null);
      }

      print('📝 Posting sale to API (add_sale)...');
      final saleResult = await invoiceProvider.chargeUserSale(invoice);
// final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
      if (saleResult['success'] == true) {
        print('✅ Invoice created. Proceeding to payment API...');
        // Prepare payment payload
        final invoiceNumber = invoice.invoiceNumber;
        final amount = paymentProvider.selectedPaymentMethod ==
                PaymentMethod.partial_payment
            ? paymentProvider.partialAmountController.text
            : invoiceProvider.totalWithTax;
        final paymentDate = DateTime.now();

        // For Pay Later, we don't need to make a payment API call
        if (paymentProvider.selectedPaymentMethod == PaymentMethod.pay_later) {
          print('⏰ Pay Later payment - skipping payment API call');
          print('✅ Invoice created successfully for Pay Later!');
          print('🧹 Clearing invoice data and navigating to home...');

          // Clear invoice fields while preserving tax settings
          invoiceProvider.clearInvoiceFields();
          bankProvider.setSelectedBank(null);
          // Show success message
          ShowToastDialog.showToast(
              'Invoice created successfully! Payment pending.');

          // Navigate back to home screen
          Navigator.of(context).popUntil((route) => route.isFirst);

          print('✨ Invoice cleared and returned to home screen');
          return;
        }

        if (kDebugMode) {
          print('invoiceNumber: ====> $invoiceNumber');
          print('amount: ====> $amount');
          print('paymentDate: ====> $paymentDate');
          print('accountCode: ====> $accountCode');
        }
        final parsedAmount = double.tryParse(amount.toString()) ?? 0.0;
        final paymentResult = await salesService.invoicePayment(
          invoiceNumber: invoiceNumber,
          amount: parsedAmount,
          paymentDate: paymentDate.toIso8601String().split('T').first,
          accountCode: accountCode!,
        );

        if (paymentResult['success'] == true) {
          print('✅ Payment completed successfully!');
          print('🧹 Clearing invoice data and navigating to home...');

          // Clear invoice fields while preserving tax settings
          invoiceProvider.clearInvoiceFields();
          bankProvider.setSelectedBank(null);
          // Show success message
          ShowToastDialog.showToast('Payment completed successfully!');

          // Navigate back to home screen
          Navigator.of(context).popUntil((route) => route.isFirst);

          print('✨ Invoice cleared and returned to home screen');
        } else {
          invoiceProvider.clearInvoiceFields();
          print('❌ Payment failed: ${paymentResult['message']}');
          ShowToastDialog.showToast(
              paymentResult['message'] ?? 'Payment failed');
        }
      } else {
        print('❌ Invoice creation failed: ${saleResult['message']}');
        print("error: ${saleResult['message']}");
      }
    } catch (e) {
      print('❌ Error during payment process: $e');
      ShowToastDialog.showToast('An error occurred: $e');
    } finally {
      paymentProvider.setProcessing(false);
      print('🏁 Payment process completed');
    }
  }

  String _getPaymentNotes(PaymentProvider paymentProvider) {
    if (paymentProvider.selectedPaymentMethod == PaymentMethod.bank &&
        paymentProvider.selectedBank != null) {
      return 'Bank: ${paymentProvider.selectedBank!['Name']}\nAcc #: ${paymentProvider.selectedBank!['BankAccountNumber']}';
    } else if (paymentProvider.selectedPaymentMethod == PaymentMethod.cod) {
      final totalDue =
          Provider.of<InvoiceProvider>(context, listen: false).totalWithTax;
      return 'Amount Received: \$${paymentProvider.receivedAmount.toStringAsFixed(2)}\nChange: \$${paymentProvider.getChange(totalDue).toStringAsFixed(2)}';
    } else if (paymentProvider.selectedPaymentMethod ==
        PaymentMethod.pay_later) {
      return 'Payment Status: Pending\nPayment Method: Pay Later';
    } else if (paymentProvider.selectedPaymentMethod ==
        PaymentMethod.partial_payment) {
      final totalDue =
          Provider.of<InvoiceProvider>(context, listen: false).totalWithTax;
      final remainingBalance = totalDue - paymentProvider.receivedAmount;
      return 'Payment Status: Partial\nAmount Paid: \$${paymentProvider.receivedAmount.toStringAsFixed(2)}\nRemaining Balance: \$${remainingBalance.toStringAsFixed(2)}';
    }
    return '';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
