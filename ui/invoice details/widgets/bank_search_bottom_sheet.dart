import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../utils/constants/app_colors.dart';
import '../../home screen/widgets/invoice/providers/bank_provider.dart';

class BankSearchBottomSheet extends StatefulWidget {
  const BankSearchBottomSheet({super.key});

  @override
  State<BankSearchBottomSheet> createState() => _BankSearchBottomSheetState();
}

class _BankSearchBottomSheetState extends State<BankSearchBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // Ensure banks are loaded when sheet opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bankProvider = context.read<BankProvider>();
      if (bankProvider.bankAccounts.isEmpty && !bankProvider.isLoading) {
        bankProvider.fetchBankAccounts();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getFilteredBanks(
      BankProvider provider, String query) {
    print('🔍 Filtering banks...');
    print('📊 Total banks from provider: ${provider.bankAccounts.length}');

    // Debug: Print all banks to see their structure
    for (int i = 0; i < provider.bankAccounts.length; i++) {
      final bank = provider.bankAccounts[i];
      print(
          '🏦 Bank $i: ${bank['Name']} - EnablePayments: ${bank['EnablePaymentsToAccount']}');
    }

    // Start with all accounts, but prefer payment-enabled accounts
    List<Map<String, dynamic>> availableBanks = [];

    // First, try to get payment-enabled accounts
    final enabledBanks = provider.bankAccounts
        .where((bank) => bank['EnablePaymentsToAccount'] == true)
        .toList();

    print('✅ Payment-enabled banks: ${enabledBanks.length}');

    // If we have payment-enabled banks, use them
    if (enabledBanks.isNotEmpty) {
      availableBanks = enabledBanks;
    } else {
      // If no payment-enabled banks, use all banks
      print('⚠️ No payment-enabled banks found, using all banks');
      availableBanks = provider.bankAccounts;
    }

    if (query.isEmpty) {
      print('📋 Returning all available banks: ${availableBanks.length}');
      return availableBanks;
    }

    final searchQuery = query.toLowerCase();
    final filteredBanks = availableBanks.where((bank) {
      final name = bank['Name']?.toString().toLowerCase() ?? '';
      final accountNumber =
          bank['BankAccountNumber']?.toString().toLowerCase() ?? '';
      return name.contains(searchQuery) || accountNumber.contains(searchQuery);
    }).toList();

    print(
        '🔍 Search query: "$query" - Found ${filteredBanks.length} matching banks');
    return filteredBanks;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: MyAppColors.whiteColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.r),
          topRight: Radius.circular(16.r),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.symmetric(vertical: 12.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          // Search header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              children: [
                Text(
                  'Select Bank Account',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: MyAppColors.blackColor,
                  ),
                ),
                SizedBox(height: 8.h),
                Consumer<BankProvider>(
                  builder: (context, bankProvider, _) {
                    final paymentEnabledCount = bankProvider.bankAccounts
                        .where(
                            (bank) => bank['EnablePaymentsToAccount'] == true)
                        .length;
                    final totalCount = bankProvider.bankAccounts.length;

                    if (totalCount > 0) {
                      return Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6.r),
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16.sp,
                              color: Colors.blue[700],
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                paymentEnabledCount > 0
                                    ? '$paymentEnabledCount of $totalCount banks are payment-enabled'
                                    : 'All banks are available for selection',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                SizedBox(height: 16.h),
                Consumer<BankProvider>(
                  builder: (context, bankProvider, _) => TextField(
                    controller: _searchController,
                    onChanged: (query) =>
                        setState(() => _isSearching = query.isNotEmpty),
                    decoration: InputDecoration(
                      hintText: 'Search by bank name or account number',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _isSearching
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _isSearching = false);
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(
                          color: Colors.grey[300]!,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(
                          color: Colors.grey[300]!,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(
                          color: MyAppColors.appBarColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          // Bank list
          Expanded(
            child: Consumer<BankProvider>(
              builder: (context, bankProvider, _) {
                if (bankProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final filteredBanks =
                    _getFilteredBanks(bankProvider, _searchController.text);

                if (filteredBanks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.account_balance,
                          size: 48.sp,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          _isSearching
                              ? 'No matching banks found'
                              : bankProvider.bankAccounts.isEmpty
                                  ? 'No banks available'
                                  : 'No payment-enabled banks found',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (!_isSearching &&
                            bankProvider.bankAccounts.isNotEmpty) ...[
                          SizedBox(height: 8.h),
                          Text(
                            'Total banks: ${bankProvider.bankAccounts.length}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[500],
                            ),
                          ),
                          Text(
                            'Payment-enabled: ${bankProvider.bankAccounts.where((bank) => bank['EnablePaymentsToAccount'] == true).length}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: filteredBanks.length,
                  itemBuilder: (context, index) {
                    final bank = filteredBanks[index];
                    final isSelected =
                        bankProvider.selectedBank?['AccountID'] ==
                            bank['AccountID'];
                    final isPaymentEnabled =
                        bank['EnablePaymentsToAccount'] == true;

                    return Card(
                      elevation: 0,
                      margin: EdgeInsets.only(bottom: 8.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        side: BorderSide(
                          color: isSelected
                              ? MyAppColors.appBarColor
                              : Colors.grey[300]!,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: InkWell(
                        onTap: () {
                          print('🏦 Bank selected: \\${bank['Name']}');
                          // Return the selected bank to the parent screen
                          Navigator.pop(context, bank);
                        },
                        borderRadius: BorderRadius.circular(8.r),
                        child: Padding(
                          padding: EdgeInsets.all(16.r),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      bank['Name'] ?? 'Unknown Bank',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                        color: MyAppColors.blackColor,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      'Acc ${(bank['BankAccountNumber'] ?? 'N/A').toString()}',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      '${bank['BankAccountType'] ?? 'N/A'} • ${bank['CurrencyCode'] ?? 'N/A'}',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
