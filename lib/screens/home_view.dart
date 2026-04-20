import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hungzo_delivery_partner/screens/widgets/banner_card.dart';
import 'package:hungzo_delivery_partner/screens/widgets/category_card.dart';
import 'package:hungzo_delivery_partner/screens/widgets/filter_bar.dart';
import 'package:hungzo_delivery_partner/screens/widgets/location_bar.dart';
import 'package:hungzo_delivery_partner/screens/widgets/product_card.dart';
import 'package:hungzo_delivery_partner/screens/widgets/search_bar.dart';
import 'package:shimmer/shimmer.dart';

import '../controllers/home_controller.dart';
import '../services/firbase/permission_service.dart';
import '../utils/color_constants.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.mintCream,
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () => controller.changeTab(0),
        child: const CircleAvatar(
          backgroundColor: Colors.white,
          backgroundImage: AssetImage("assets/logo/hunzo_main_logo.png"),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: Obx(() => controller.screens[controller.bottomIndex.value]),
      bottomNavigationBar: Obx(
            () => AnimatedBottomNavigationBar(
          icons: controller.iconList,
          activeIndex: controller.bottomIndex.value,
          gapLocation: GapLocation.none,
          activeColor: ColorConstants.primary,
          inactiveColor: Colors.grey,
          iconSize: 30,
          leftCornerRadius: 30,
          rightCornerRadius: 30,
          onTap: controller.changeTab,
        ),
      ),
    );
  }
}



class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: ColorConstants.screenBackgroundGradient2,
          ),
          child: CustomScrollView(
            slivers: [

              /// 🔥 FIXED HEADER
              SliverPersistentHeader(
                pinned: true,
                delegate: HomeHeaderDelegate(),
              ),

              /// 🔥 BODY CONTENT
              SliverPadding(
                padding: const EdgeInsets.all(10),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([

                    const BannerCard(),
                    const SizedBox(height: 10),

                    const Text(
                      "Category",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    /// ---------- CATEGORY ----------
                    Obx(() {
                      if (controller.isLoading.value &&
                          controller.products.isEmpty) {
                        return _categoryShimmer();
                      }

                      final cats = controller.categories;

                      return SizedBox(
                        height: 140,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: cats.length,
                          separatorBuilder: (_, __) =>
                          const SizedBox(width: 12),
                          itemBuilder: (_, index) {
                            final category = cats[index];

                            String imageUrl = '';
                            final products =
                            category['products'] as List<dynamic>?;

                            if (products != null && products.isNotEmpty) {
                              final firstProduct =
                              products.first as Map<String, dynamic>;
                              final images =
                              firstProduct['images'] as List<dynamic>?;

                              if (images != null && images.isNotEmpty) {
                                imageUrl = images.first.toString();
                              }
                            }

                            return GestureDetector(
                              onTap: () => controller.changeCategory(
                                category["category"],
                              ),
                              child: CategoryCard(
                                title: category["category"] ?? 'Unknown',
                                subtitle:
                                "${products?.length ?? 0} items",
                                image: imageUrl.isNotEmpty
                                    ? imageUrl
                                    : 'assets/permission/location.png',
                              ),
                            );
                          },
                        ),
                      );
                    }),

                    const SizedBox(height: 15),
                     FilterBar(),
                    const SizedBox(height: 15),

                    /// ---------- PRODUCTS ----------
                    Obx(() {
                      if (controller.isLoading.value &&
                          controller.products.isEmpty) {
                        return _productGridShimmer();
                      }
                      final products = controller.products;

                      if (products.isEmpty) {
                        return const Center(
                          child: Text("No products available"),
                        );
                      }

                      return ProductGrid(products: products);
                    }),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _productGridShimmer() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.65,
      ),
      itemCount: 6,
      itemBuilder: (_, __) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade200,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        );
      },
    );
  }
  Widget _categoryShimmer() {
    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, __) {
          return Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade200,
            child: Container(
              width: 130,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          );
        },
      ),
    );
  }


}

class HomeHeaderDelegate extends SliverPersistentHeaderDelegate {
  @override
  double get minExtent => 70; // Height for SearchDishBar

  @override
  double get maxExtent => 130; // LocationBar + SearchDishBar

  @override
  Widget build(
      BuildContext context,
      double shrinkOffset,
      bool overlapsContent,
      ) {
    final double progress =
    (shrinkOffset / (maxExtent - minExtent))
        .clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: ColorConstants.cardBackground, // 🔥 PINK APPBAR
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [

          /// 🔥 LOCATION BAR (hide on scroll)
          Positioned(
            top: 12 - (progress * 40),
            left: 0,
            right: 0,
            child: Opacity(
              opacity: 1 - progress,
              child: LocationBar(),
            ),
          ),

          /// 🔥 SEARCH BAR (always visible)
          const Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: SearchDishBar(),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
