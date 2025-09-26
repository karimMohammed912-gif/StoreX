import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store_x/app/data/models/home_model/product.dart';
import 'package:store_x/app/modules/details/view/components/porduct_app_bar.dart';
import 'package:store_x/app/services/sqlite_favorites_service.dart';
import 'package:store_x/app/services/stripe_payment_service.dart';
import 'components/product_image_slider.dart';
import 'components/product_header.dart';
import 'components/product_rating.dart';
import 'components/product_price.dart';

import 'components/quantity_selector.dart';
import 'components/product_description.dart';
import 'components/reviews_section.dart';
import 'components/payment_ui.dart';

class DetailsScreen extends StatefulWidget {
  DetailsScreen({super.key});
  final Product? product = Get.arguments;
  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  late final SqliteFavoritesService favoritesService;
  late final StripePaymentService stripeService;
  int currentImageIndex = 0;
  bool isFavorite = false;
  int selectedSize = 0;
  int selectedColor = 0;

  @override
  void initState() {
    super.initState();
    favoritesService = Get.find<SqliteFavoritesService>();
    stripeService = Get.find<StripePaymentService>();
    final product = widget.product;
    isFavorite = favoritesService.favoriteProducts.any(
      (p) => p.id == product?.id,
    );
  }

  int quantity = 1;

  // Sample product data

  final List<String> sizes = ['S', 'M', 'L', 'XL'];
  final List<Color> colors = [
    Colors.black,
    Colors.red,
    Colors.blue,
    Colors.green,
  ];

  final int reviewCount = 128;

  @override
  Widget build(BuildContext context) {
    List<String> productImages =
        widget.product?.images ??
        [
          'https://i.dummyjson.com/data/products/1/1.jpg',
          'https://i.dummyjson.com/data/products/1/2.jpg',
          'https://i.dummyjson.com/data/products/1/3.jpg',
          'https://i.dummyjson.com/data/products/1/4.jpg',
        ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            PorductAppBar(),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Slider
                    ProductImageSlider(
                      images: productImages,
                      currentIndex: currentImageIndex,
                      onPageChanged: (index) {
                        setState(() {
                          currentImageIndex = index;
                        });
                      },
                    ),

                    // Product Info
                    Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title and Favorite
                          ProductHeader(
                            title: widget.product?.title ?? 'Product Name',
                            isFavorite: isFavorite,
                            onFavoriteTap: () async {
                              // Toggle via service then reflect latest state
                              final service =
                                  Get.find<SqliteFavoritesService>();
                              await service.toggleFavorite(widget.product);
                              final nowFav = service.favoriteProducts.any(
                                (p) => p.id == widget.product?.id,
                              );
                              setState(() {
                                isFavorite = nowFav;
                              });
                            },
                          ),
                          SizedBox(height: 8.h),

                          // Rating and Reviews
                          ProductRating(
                            rating: widget.product?.rating?.toDouble() ?? 0.0,
                          ),
                          SizedBox(height: 12.h),

                          // Price and Discount
                          ProductPrice(
                            originalPrice:
                                widget.product?.price?.toDouble() ?? 0.0,
                            discountPercentage:
                                widget.product?.discountPercentage
                                    ?.toDouble() ??
                                0.0,
                          ),
                          SizedBox(height: 16.h),

                          // Quantity Selector
                          QuantitySelector(
                            quantity: quantity,
                            onQuantityChanged: (newQuantity) {
                              setState(() {
                                quantity = newQuantity;
                              });
                            },
                          ),
                          SizedBox(height: 20.h),

                          // Description
                          ProductDescription(
                            description:
                                widget.product?.description ??
                                'No description available.',
                          ),
                          SizedBox(height: 20.h),

                          // Reviews Section
                          ReviewsSection(
                            reviewCount: widget.product!.reviews!.length,
                            reviews: widget.product!.reviews,
                          ),
                          SizedBox(height: 20.h),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Payment UI
            PaymentUI(
              totalPrice: (widget.product?.price ?? 0) * quantity,
              onAddToCart: () {
                Get.snackbar(
                  'Added to Cart',
                  'Product added to cart successfully!',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              },
              onBuyNow: () async {
                final price = (widget.product?.price ?? 0).toDouble();
                final double amount = price * quantity;
                if (amount <= 0) {
                  Get.snackbar(
                    'Invalid amount',
                    'Total must be greater than 0',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                  return;
                }
                Get.snackbar(
                  'Processing',
                  'Creating payment... Please wait',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.blue,
                  colorText: Colors.white,
                  duration: Duration(milliseconds: 800),
                );
                PaymentResult result;
                try {
                  // Debug: log amount and product id
                  // ignore: avoid_print
                  print(
                    'BuyNow tapped: amount=' +
                        amount.toString() +
                        ', productId=' +
                        (widget.product?.id?.toString() ?? ''),
                  );
                  result = await stripeService.processPayment(
                    amount: amount,
                    currency: 'usd',
                    metadata: {
                      'product_id': (widget.product?.id ?? '').toString(),
                      'product_title': widget.product?.title ?? '',
                      'qty': quantity.toString(),
                    },
                  );
                } catch (e) {
                  Get.snackbar(
                    'Payment Error',
                    e.toString(),
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                  return;
                }

                if (result.isSuccess) {
                  Get.snackbar(
                    'Payment Successful',
                    'Paid \$${amount.toStringAsFixed(2)}',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                  );
                } else {
                  Get.snackbar(
                    'Payment Failed',
                    result.errorMessage ?? 'Unknown error',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
