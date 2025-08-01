import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:point_of_sales/utils/constants/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:point_of_sales/ui/home%20screen/widgets/invoice/providers/invoice_provider.dart';

class ProductCard extends StatefulWidget {
  final String title;
  final String imageUrl;
  final List<String> imageUrls;
  final String salesPrice;
  final String productCode;
  final VoidCallback onTap;
  final String itemId;
  final String? quantityOnHand;

  const ProductCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.imageUrls,
    required this.salesPrice,
    required this.productCode,
    required this.onTap,
    required this.itemId,
    required this.quantityOnHand,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  List<String> get _allImages {
    final List<String> images = [];

    if (widget.imageUrl.startsWith('http')) {
      images.add(widget.imageUrl);
    }

    for (String url in widget.imageUrls) {
      if (url.startsWith('http') && !images.contains(url)) {
        images.add(url);
      }
    }

    return images;
  }

  Widget _buildImageCarousel() {
    final images = _allImages;

    if (images.isEmpty) {
      return Container(
        height: 110.h,
        decoration: BoxDecoration(
          color: MyAppColors.scaffoldBgColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
        ),
        child: Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            size: 30.sp,
            color: MyAppColors.lightGreyColor,
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(14.r)),
      child: Stack(
        children: [
          SizedBox(
            height: 110.h,
            child: PageView.builder(
              controller: _pageController,
              itemCount: images.length,
              onPageChanged: (index) {
                setState(() {
                  _currentImageIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return CachedNetworkImage(
                  imageUrl: images[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (_, __) =>
                  const Center(child: CupertinoActivityIndicator()),
                  errorWidget: (_, __, ___) =>
                  const Center(child: Icon(Icons.broken_image)),
                );
              },
            ),
          ),
          if (images.length > 1)
            Positioned(
              bottom: 6,
              left: 0,
              right: 0,
              child: Center(
                child: DotsIndicator(
                  dotsCount: images.length,
                  position: _currentImageIndex,
                  decorator: DotsDecorator(
                    size: Size(5.w, 5.w),
                    activeSize: Size(14.w, 5.w),
                    activeShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.r),
                    ),
                    activeColor: MyAppColors.appBarColor,
                    spacing: EdgeInsets.all(2.w),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<InvoiceProvider>(
      builder: (context, invoiceProvider, _) {
        final invoiceProduct = invoiceProvider.invoiceProducts
            .where((p) => p.itemId == widget.itemId)
            .firstOrNull;
        final isInInvoice = invoiceProduct != null;
        final quantity = isInInvoice ? invoiceProduct.quantity : 0;

        final isOutOfStock = widget.quantityOnHand == null ||
            widget.quantityOnHand == "0.00" ||
            widget.quantityOnHand == "0" ||
            widget.quantityOnHand == "0.0";

        return GestureDetector(
          onTap: widget.onTap,
          child: Stack(
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
                margin: EdgeInsets.all(3.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImageCarousel(),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: GoogleFonts.poppins(
                              fontSize: 8.sp,
                              fontWeight: FontWeight.w500,
                              color: MyAppColors.blackColor.withValues(alpha: 0.8),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Price: \$${widget.salesPrice}',
                            style: GoogleFonts.poppins(
                              fontSize: 7.sp,
                              fontWeight: FontWeight.w500,
                              color: MyAppColors.redColor,
                            ),
                          ),
                          // Text(
                          //   'Code: ${widget.productCode}',
                          //   style: GoogleFonts.poppins(
                          //     fontSize: 6.sp,
                          //     fontWeight: FontWeight.w400,
                          //     color: MyAppColors.greyColor,
                          //   ),
                          // ),
                          Text(
                            isOutOfStock
                                ? 'Out of Stock'
                                : 'Stock: ${widget.quantityOnHand}',
                            style: GoogleFonts.poppins(
                              fontSize: 7.sp,
                              fontWeight: FontWeight.w600,
                              color: isOutOfStock
                                  ? Colors.black54
                                  : MyAppColors.greenColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (isInInvoice)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: MyAppColors.appBarColor,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Text(
                      'x$quantity',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 7.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
