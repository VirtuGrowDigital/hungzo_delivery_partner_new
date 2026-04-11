import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../../services/Api/api_constants.dart';
import '../../utils/ColorConstants.dart';
import '../../utils/snack_bar.dart';

class ProductBottomSheet extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductBottomSheet({super.key, required this.product});

  @override
  State<ProductBottomSheet> createState() =>
      _ProductBottomSheetState();
}

class _ProductBottomSheetState
    extends State<ProductBottomSheet> {
  int selectedSize = 0;
  int quantity = 1;
  bool isLoading = false;

  final FlutterSecureStorage secureStorage =
  const FlutterSecureStorage();

  late PageController _pageController;
  int currentImage = 0;

  /// 🔹 VARIETIES
  List<Map<String, dynamic>> get sizes {
    final List<dynamic>? varieties =
    widget.product['varieties'];
    if (varieties == null || varieties.isEmpty) {
      return [];
    }
    return varieties.cast<Map<String, dynamic>>();
  }

  /// 🔹 IMAGES (FOR SLIDER)
  List<String> get images {
    final List<dynamic>? imgs =
    widget.product['images'];
    if (imgs == null || imgs.isEmpty) {
      return ["https://via.placeholder.com/150"];
    }
    return imgs.cast<String>();
  }

  /// 🔹 TOTAL PRICE
  int get totalPrice {
    if (sizes.isEmpty) return 0;
    return (sizes[selectedSize]['price'] as int) *
        quantity;
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    if (images.length > 1) {
      Future.delayed(
          const Duration(seconds: 3), autoSlide);
    }
  }

  void autoSlide() {
    if (!mounted || images.length <= 1) return;

    currentImage = (currentImage + 1) % images.length;

    _pageController.animateToPage(
      currentImage,
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOut,
    );

    Future.delayed(
        const Duration(seconds: 3), autoSlide);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    final productName =
        product["name"] ?? "Unknown product";

    final double rating =
    (product["rating"] is num)
        ? (product["rating"] as num).toDouble()
        : 0.0;

    return Container(
      decoration: const BoxDecoration(
        color: ColorConstants.textHint,
        borderRadius:
        BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                /// 🔥 PRODUCT IMAGE (AUTO SLIDER)
                Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius:
                    BorderRadius.circular(16),
                    color: Colors.white,
                  ),
                  child: ClipRRect(
                    borderRadius:
                    BorderRadius.circular(16),
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: images.length,
                      itemBuilder: (context, index) {
                        return Image.network(
                          images[index],
                          fit: BoxFit.fill,
                          errorBuilder:
                              (_, __, ___) =>
                              Image.asset(
                                'assets/logo/img.png',
                                fit: BoxFit.contain,
                              ),
                        );
                      },
                    ),
                  ),
                ),


                Padding(padding: const EdgeInsets.all(5),child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [

                        /// TITLE & RATING
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                productName,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight:
                                  FontWeight.w700,
                                ),
                                overflow:
                                TextOverflow.ellipsis,
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.star,
                                    color: ColorConstants
                                        .warning,
                                    size: 22),
                                const SizedBox(width: 4),
                                Text(
                                  rating.toStringAsFixed(1),
                                  style:
                                  const TextStyle(
                                    fontWeight:
                                    FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),

                        const SizedBox(height: 5),

                        /// VARIETY LIST
                        if (sizes.isEmpty)
                          const Padding(
                            padding:
                            EdgeInsets.all(8.0),
                            child: Text(
                              "No sizes available",
                              style:
                              TextStyle(fontSize: 16),
                            ),
                          )
                        else
                          SizedBox(
                            height: sizes.length > 3
                                ? 170
                                : null,
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: sizes.length > 3
                                  ? const BouncingScrollPhysics()
                                  : const NeverScrollableScrollPhysics(),
                              itemCount: sizes.length,
                              itemBuilder:
                                  (context, index) {
                                final isSelected =
                                    selectedSize == index;
                                final label =
                                sizes[index]['name'];
                                final price =
                                sizes[index]['price'];

                                return GestureDetector(
                                  onTap: () =>
                                      setState(() =>
                                      selectedSize =
                                          index),
                                  child: Container(
                                    margin:
                                    const EdgeInsets
                                        .only(bottom: 6),
                                    padding:
                                    const EdgeInsets
                                        .symmetric(
                                      horizontal: 20,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius:
                                      BorderRadius
                                          .circular(12),
                                      color: Colors.white,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment
                                          .spaceBetween,
                                      children: [
                                        Text(
                                          label.toString(),
                                          style:
                                          const TextStyle(
                                            fontWeight:
                                            FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "₹$price",
                                              style:
                                              const TextStyle(
                                                fontWeight:
                                                FontWeight.w700,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(
                                                width: 12),
                                            Container(
                                              width: 24,
                                              height: 24,
                                              decoration:
                                              BoxDecoration(
                                                shape:
                                                BoxShape.circle,
                                                border:
                                                Border.all(
                                                  color: isSelected
                                                      ? ColorConstants
                                                      .orangeRed
                                                      : Colors
                                                      .grey
                                                      .shade400,
                                                  width: 2,
                                                ),
                                              ),
                                              child: isSelected
                                                  ? Center(
                                                child:
                                                Container(
                                                  width:
                                                  12,
                                                  height:
                                                  12,
                                                  decoration:
                                                  const BoxDecoration(
                                                    shape:
                                                    BoxShape.circle,
                                                    color:
                                                    ColorConstants
                                                        .orangeRed,
                                                  ),
                                                ),
                                              )
                                                  : null,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                        const SizedBox(height: 5),

                        /// QUANTITY + ADD BUTTON
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,
                          children: [

                            /// QUANTITY
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: ColorConstants
                                      .orangeRed,
                                  width: 1.5,
                                ),
                                borderRadius:
                                BorderRadius.circular(
                                    20),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.remove,
                                      color:
                                      ColorConstants
                                          .orangeRed,
                                      size: 20,
                                    ),
                                    onPressed: quantity > 1
                                        ? () => setState(
                                            () =>
                                        quantity--)
                                        : null,
                                  ),
                                  Text(
                                    "$quantity",
                                    style:
                                    const TextStyle(
                                      fontSize: 18,
                                      fontWeight:
                                      FontWeight.w700,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.add,
                                      color:
                                      ColorConstants
                                          .orangeRed,
                                      size: 20,
                                    ),
                                    onPressed: () =>
                                        setState(() =>
                                        quantity++),
                                  ),
                                ],
                              ),
                            ),

                            /// ADD TO CART
                            ElevatedButton(
                              onPressed: isLoading
                                  ? null
                                  : () => addToCartApi(
                                productId:
                                product["_id"],
                                varietyId:
                                sizes[selectedSize]
                                ["_id"],
                              ),
                              style:
                              ElevatedButton.styleFrom(
                                backgroundColor:
                                ColorConstants.orangeRed,
                              ),
                              child: isLoading
                                  ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                                  : Text(
                                "Add ₹$totalPrice",
                                style:
                                const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 🔥 ADD TO CART API
  Future<void> addToCartApi({
             required String productId,
    required String varietyId,
  }) async {
    setState(() => isLoading = true);

    const String url =
        "${ApiConstants.baseURL}cart/add";

    try {
      final String? accessToken =
      await secureStorage.read(
          key: 'accessToken');

      if (accessToken == null) {
        CustomSnackBar("User not logged in", "E");

        return;
      }

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization":
          "Bearer $accessToken",
        },
        body: jsonEncode({
          "productId": productId,
          "varietyId": varietyId,
          "quantity": quantity,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        CustomSnackBar("Item added to cart", "S");

        Navigator.pop(context);
      } else {
        CustomSnackBar(
          data["message"] ?? "Failed",
          "E",
        );

      }
    } catch (e) {
      CustomSnackBar(e.toString(), "E");

    } finally {
      setState(() => isLoading = false);
    }
  }
}
