import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../provider/product_provider.dart';
import '../../invoice/providers/invoice_provider.dart';
import '../../../../../models/product_model.dart';
import '../../../../../utils/constants/app_colors.dart';
import 'product_card.dart';

class ProductSearchDelegate extends SearchDelegate<ProductModel?> {
  @override
  String get searchFieldLabel => 'Search products by name or code...';

  @override
  TextStyle get searchFieldStyle => TextStyle(
        fontSize: 16.sp,
        color: MyAppColors.blackColor,
        fontWeight: FontWeight.w500,
      );

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: MyAppColors.appBarColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: MyAppColors.whiteColor),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(
          fontSize: 16.sp,
          color: MyAppColors.whiteColor.withOpacity(0.7),
        ),
        border: InputBorder.none,
      ),
      textTheme: TextTheme(
        titleLarge: TextStyle(
          color: MyAppColors.whiteColor,
          fontSize: 16.sp,
        ),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: MyAppColors.whiteColor,
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        AnimatedOpacity(
          opacity: query.isEmpty ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: IconButton(
            icon: const Icon(
              Icons.clear,
              color: MyAppColors.whiteColor,
            ),
            onPressed: () {
              query = '';
              showSuggestions(context);
            },
          ),
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
        color: MyAppColors.whiteColor,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, _) {
        if (query.isEmpty) {
          return Container(
            color: MyAppColors.scaffoldBgColor,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search,
                    size: 100.sp,
                    color: MyAppColors.appBarColor.withOpacity(0.2),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Start typing to search products',
                    style: TextStyle(
                      fontSize: 18.sp,
                      color: MyAppColors.appBarColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Search by product name or code',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: MyAppColors.greyColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final searchResults = productProvider.searchProducts(query);

        if (searchResults.isEmpty) {
          return Container(
            color: MyAppColors.scaffoldBgColor,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off_rounded,
                    size: 100.sp,
                    color: MyAppColors.appBarColor.withOpacity(0.2),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'No products found',
                    style: TextStyle(
                      fontSize: 18.sp,
                      color: MyAppColors.appBarColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Try a different search term',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: MyAppColors.greyColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Container(
          color: MyAppColors.scaffoldBgColor,
          child: GridView.builder(
            padding: EdgeInsets.all(16.r),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16.r,
              mainAxisSpacing: 16.r,
            ),
            itemCount: searchResults.length,
            itemBuilder: (context, index) {
              final product = searchResults[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: AnimatedOpacity(
                duration: Duration(milliseconds: 300),
                opacity: 1.0,
                child: _buildProductCard(context, product),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildProductCard(BuildContext context, ProductModel product) {
    return Hero(
      tag: 'product_${product.itemId}',
      child: Material(
        type: MaterialType.transparency,
      child: ProductCard(
        title: product.productName,
        imageUrl: product.imageUrl ?? '',
        imageUrls: product.imageUrls,
        quantityOnHand: product.quantityOnHand ?? '0.00',
        salesPrice: product.salesPrice.toString(),
        productCode: product.productCode,
          itemId: product.itemId,
        onTap: () {
            final invoiceProvider =
                Provider.of<InvoiceProvider>(context, listen: false);
          invoiceProvider.addProduct(product);
        },
        ),
      ),
    );
  }
}
