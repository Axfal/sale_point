import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:point_of_sales/utils/constants/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:point_of_sales/ui/sales/provider/sales_provider.dart';
import '../../models/product_model.dart';
import 'package:intl/intl.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer; // Make the debounceTimer nullable
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
    _debounceTimer?.cancel(); // Cancel the timer if it's not null
    _scrollController.dispose();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _debounceSearch() {
    if (_debounceTimer?.isActive ?? false) {
      // Check if debounceTimer is active
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
            Navigator.pop(
                context); // Pop the current screen from the navigation stack
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
                    FocusScope.of(context).unfocus(); // 👈 This line is the fix
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

                      final invoice = provider.invoices[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 8,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Invoice #${invoice.invoiceNumber}',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color:
                                        MyAppColors.blackColor),
                                  ),
                                  Text(
                                    _formatReadableDate(
                                        invoice.datedToday),
                                    style: TextStyle(
                                        color: MyAppColors.greyColor,
                                        fontSize: 14),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '👤 ${invoice.customerName}',
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: MyAppColors.blackColor),
                              ),
                              const SizedBox(height: 12),
                              const Text('📦 Products:',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: MyAppColors.blackColor)),
                              const SizedBox(height: 6),
                              ...invoice.products.map((product) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 4.0),
                                  child: Row(
                                    children: [
                                      const Icon(
                                          Icons.check_circle_outline,
                                          size: 16,
                                          color:
                                          MyAppColors.greenColor),
                                      const SizedBox(width: 8),
                                      Expanded(
                                          child: Text(
                                              product.productName,
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: MyAppColors
                                                      .blackColor))),
                                    ],
                                  ),
                                );
                              }).toList(),
                              const Divider(height: 20),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('💰 Total:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: MyAppColors
                                              .blackColor)),
                                  Text(
                                    '\$${invoice.totalAmount}',
                                    style: const TextStyle(
                                        color: MyAppColors.greenColor,
                                        fontSize: 16),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('📅 Due Date:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: MyAppColors
                                              .blackColor)),
                                  Text(
                                      _formatReadableDate(
                                          invoice.dueToday),
                                      style: const TextStyle(
                                          color: MyAppColors
                                              .lightRedColor,
                                          fontWeight:
                                          FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatReadableDate(String date) {
    final dateTime = DateTime.parse(date);
    final formatter = DateFormat('dd/MM/yyyy hh:mm a'); // includes time in 12-hour format
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
