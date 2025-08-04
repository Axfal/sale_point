import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:point_of_sales/utils/constants/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:point_of_sales/ui/sales/provider/sales_provider.dart';
import 'package:intl/intl.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<SalesProvider>(context, listen: false);
      provider.fetchInvoices();
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void showDeleteDialog(BuildContext context, VoidCallback onDelete) {
    final screenWidth = MediaQuery.of(context).size.width;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SizedBox(
            width: screenWidth * 0.85, // 85% of screen width
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.delete_forever_rounded,
                      color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'Delete Invoice?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: MyAppColors.blackColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Are you sure you want to delete this invoice? This action cannot be undone.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: MyAppColors.greyColor,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                MyAppColors.greyColor.withValues(alpha: 0.2),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: MyAppColors.blackColor),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context); // Close dialog
                            onDelete(); // Execute delete logic
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: MyAppColors.redColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            'Delete',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _debounceSearch() {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer?.cancel();
    }
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      final searchQuery = _searchController.text;
      final provider = Provider.of<SalesProvider>(context, listen: false);
      provider.updateSearch(searchQuery);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sales Overview',
          style: TextStyle(color: MyAppColors.whiteColor),
        ),
        centerTitle: true,
        backgroundColor: MyAppColors.appBarColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: MyAppColors.whiteColor),
          // iOS style back button
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 4,
        actions: [
          Consumer<SalesProvider>(
            builder: (context, provider, _) {
              return IconButton(
                icon: provider.isLoading
                    ? const CupertinoActivityIndicator(
                        color: MyAppColors.whiteColor,
                        // strokeWidth: 2,
                      )
                    : const Icon(
                        Icons.refresh,
                        color: MyAppColors.whiteColor,
                      ),
                onPressed: () {
                  if (!provider.isLoading) {
                    FocusScope.of(context).unfocus();
                    provider.refreshInvoices();
                  }
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<SalesProvider>(
        builder: (context, provider, _) {
          return RefreshIndicator(
            onRefresh: provider.refreshInvoices,
            child: Column(
              children: [
                _buildFilterBar(provider),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    provider.lastUpdatedTime.isNotEmpty
                        ? 'Last Updated: ${_formatReadableDate(provider.lastUpdatedTime)}'
                        : '',
                    style: const TextStyle(
                        fontSize: 14, color: MyAppColors.greyColor),
                  ),
                ),
                Expanded(
                    child: provider.isLoading && provider.invoices.isEmpty
                        ? const Center(child: CupertinoActivityIndicator())
                        : provider.invoices.isEmpty
                            ? const Center(
                                child: Text('No invoices found.',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: MyAppColors.blackColor)))
                            : ListView.builder(
                                controller: _scrollController,
                                itemCount: provider.invoices.length + 1,
                                itemBuilder: (context, index) {
                                  // Show loader at the end
                                  if (index == provider.invoices.length) {
                                    return provider.isLoading
                                        ? const Padding(
                                            padding: EdgeInsets.all(12),
                                            child: Center(
                                                child:
                                                    CupertinoActivityIndicator()),
                                          )
                                        : const SizedBox.shrink();
                                  }

                                  // Reverse data manually
                                  final reversedInvoices =
                                      provider.invoices.reversed.toList();
                                  final invoice = reversedInvoices[index];

                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 10),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    elevation: 6,
                                    shadowColor: Colors.black12,
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  'Invoice #${invoice.invoiceNumber}',
                                                  style: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        MyAppColors.blackColor,
                                                  ),
                                                ),
                                              ),
                                              IconButton(
                                                icon: Icon(Icons.edit,
                                                    color: MyAppColors
                                                        .appBarColor),
                                                tooltip: 'Edit Invoice',
                                                onPressed: () {
                                                  // Handle edit
                                                },
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                    Icons.delete_outline,
                                                    color:
                                                        MyAppColors.redColor),
                                                tooltip: 'Delete Invoice',
                                                onPressed: () {
                                                  showDeleteDialog(context, () {
                                                    // Perform delete logic
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _formatReadableDate(
                                                invoice.datedToday),
                                            style: const TextStyle(
                                              color: MyAppColors.greyColor,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            '👤 ${invoice.customerName}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: MyAppColors.blackColor,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          const Text(
                                            '📦 Products:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: MyAppColors.blackColor,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          ...invoice.products.map((product) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 4.0),
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                      Icons
                                                          .check_circle_outline,
                                                      size: 16,
                                                      color: MyAppColors
                                                          .greenColor),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      product.productName,
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        color: MyAppColors
                                                            .blackColor,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                          const Divider(
                                              height: 24, thickness: 0.8),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text(
                                                '💰 Total:',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: MyAppColors.blackColor,
                                                ),
                                              ),
                                              Text(
                                                '\$${invoice.totalAmount}',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: MyAppColors.greenColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text(
                                                '📅 Due Date:',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: MyAppColors.blackColor,
                                                ),
                                              ),
                                              Text(
                                                _formatReadableDate(
                                                    invoice.dueToday),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      MyAppColors.lightRedColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              )),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatReadableDate(String date) {
    final dateTime = DateTime.parse(date);
    final formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(dateTime);
  }

  Widget _buildFilterBar(SalesProvider provider) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 200.w, vertical: 30.h),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              focusNode: _focusNode,
              controller: _searchController,
              onChanged: (value) {
                _debounceSearch();
              },
              decoration: InputDecoration(
                hintText: 'Search customer...',
                prefixIcon: const Icon(
                  Icons.search,
                  color: MyAppColors.appBarColor,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _focusNode.requestFocus(); // Maintain focus
                          provider.updateSearch('');
                        },
                      )
                    : null,
                border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12))),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
