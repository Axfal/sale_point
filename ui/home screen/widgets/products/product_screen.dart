import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:point_of_sales/utils/helpers/show_toast_dialouge.dart';
import 'package:provider/provider.dart';
import 'package:point_of_sales/ui/home%20screen/widgets/products/provider/category_provider.dart';
import 'package:point_of_sales/ui/home%20screen/widgets/products/provider/product_provider.dart';
import 'package:point_of_sales/ui/home%20screen/widgets/products/widgets/product_card.dart';
import '../../../../utils/constants/app_colors.dart';
import '../invoice/providers/invoice_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final categoryProvider =
          Provider.of<CategoryProvider>(context, listen: false);
      final productProvider =
          Provider.of<ProductProvider>(context, listen: false);

      // Ensure categories are only fetched if not already loaded
      if (categoryProvider.categories.isEmpty && !categoryProvider.isLoading) {
        categoryProvider.fetchCategories();
      }
      productProvider.fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyAppColors.whiteColor,
      body: RefreshIndicator(
        onRefresh: () async {
          final categoryProvider =
              Provider.of<CategoryProvider>(context, listen: false);
          final productProvider =
              Provider.of<ProductProvider>(context, listen: false);

          await categoryProvider.fetchCategories();
          await productProvider.fetchProducts();
        },
        child: Column(
          children: [
            _buildChildCategoryTabs(),
            Expanded(child: _buildProductGrid()),
          ],
        ),
      ),
      bottomNavigationBar: _buildCategoryTabs(),
    );
  }

  /// Child Categories List with Enhanced Modern UI
  Widget _buildChildCategoryTabs() {
    return Consumer<CategoryProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: SizedBox(
            height: 85.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: provider.childCategories.length,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              separatorBuilder: (context, index) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final category = provider.childCategories[index];
                final isSelected = provider.selectedChildCategory == category;

                return GestureDetector(
                  onTap: () {
                    provider.selectChildCategory(category, context);
                    Provider.of<ProductProvider>(context, listen: false)
                        .filterProductsByCategory(category.id);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? MyAppColors.appBarColor.withValues(alpha: 0.1)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? MyAppColors.appBarColor
                            : MyAppColors.greyColor.withValues(alpha: 0.3),
                        width: isSelected ? 1.5 : 1.0,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: MyAppColors.appBarColor
                                    .withValues(alpha: 0.12),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : [],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          category.name,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected
                                ? MyAppColors.appBarColor
                                : MyAppColors.greyColor,
                          ),
                        ),
                        const SizedBox(height: 3),
                        if (isSelected)
                          Consumer<ProductProvider>(
                            builder: (context, productProvider, _) {
                              final count = productProvider.filteredProducts
                                  .where((p) => p.categoryId == category.id)
                                  .length;

                              return Text(
                                '$count products',
                                style: GoogleFonts.poppins(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  /// Product Grid
  Widget _buildProductGrid() {
    return Consumer<ProductProvider>(builder: (context, provider, _) {
      if (provider.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      if (provider.filteredProducts.isEmpty) {
        return const Center(child: Text('No products available.'));
      }

      final screenWidth = MediaQuery.of(context).size.width;

      /// Responsive breakpoints
      int crossAxisCount;
      double aspectRatio;

      if (screenWidth <= 600) {
        // Mobile
        crossAxisCount = 4;
        aspectRatio = 0.82;
      } else if (screenWidth <= 1621) {
        // Tablet
        crossAxisCount = 7;
        aspectRatio = 0.54;
      } else {
        // Desktop
        crossAxisCount = 8;
        aspectRatio = 0.71;
      }

      return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
          childAspectRatio: aspectRatio,
        ),
        padding: const EdgeInsets.all(12.0),
        itemCount: provider.filteredProducts.length,
        itemBuilder: (context, index) {
          final product = provider.filteredProducts[index];

          return ProductCard(
            title: product.productName,
            imageUrl: product.imageUrl ?? '',
            imageUrls: product.imageUrls,
            salesPrice: product.salesPrice.toString(),
            productCode: product.productCode,
            quantityOnHand: product.quantityOnHand,
            itemId: product.itemId,
            onTap: () {
              final invoiceProvider =
                  Provider.of<InvoiceProvider>(context, listen: false);
              if (product.quantityOnHand == '' ||
                  product.quantityOnHand == '0' ||
                  product.quantityOnHand == '0.0' ||
                  product.quantityOnHand == '0.00' ||
                  product.quantityOnHand == null) {
                ShowToastDialog.showToast("Out of Stock");
              } else {
                invoiceProvider.addProduct(product);
              }
            },
          );
        },
      );
    });
  }

  /// Category Tabs (Bottom Navigation)
  Widget _buildCategoryTabs() {
    return Consumer<CategoryProvider>(builder: (context, provider, _) {
      if (provider.categories.isEmpty) {
        return const SizedBox.shrink();
      }

      int currentIndex = provider.selectedCategory == null
          ? 0
          : provider.categories.indexOf(provider.selectedCategory!);

      if (currentIndex < 0 || currentIndex >= provider.categories.length) {
        currentIndex = 0;
      }

      return Container(
        height: 65,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey.shade100],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: MyAppColors.appBarColor.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: provider.categories.asMap().entries.map((entry) {
            int index = entry.key;
            final cat = entry.value;
            final isSelected = index == currentIndex;

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  if (index < provider.categories.length) {
                    provider.selectCategory(cat, context);
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? MyAppColors.appBarColor.withValues(alpha: 0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        height: 4,
                        width: isSelected ? 24 : 0,
                        decoration: BoxDecoration(
                          color: MyAppColors.appBarColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        cat.name,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected
                              ? MyAppColors.appBarColor
                              : MyAppColors.greyColor,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
    });
  }
}
