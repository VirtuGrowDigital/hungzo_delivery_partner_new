import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/home_controller.dart';

class BannerCard extends StatefulWidget {
  const BannerCard({super.key});

  @override
  State<BannerCard> createState() => _BannerCardState();
}

class _BannerCardState extends State<BannerCard> {
  final controller = Get.find<HomeController>();

  final PageController _pageController = PageController();
  Timer? _timer;

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();

    /// 🔥 Auto slide every 3 seconds
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (controller.bannerImages.isEmpty) return;

      currentIndex++;

      if (currentIndex >= controller.bannerImages.length) {
        currentIndex = 0;
      }

      _pageController.animateToPage(
        currentIndex,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.bannerImages.isEmpty) {
        return const SizedBox(height: 200);
      }

      return Column(
        children: [
          /// ================= SLIDER =================
          SizedBox(
            width: double.infinity,
            height: 160,
            child: PageView.builder(
              controller: _pageController,
              itemCount: controller.bannerImages.length,
              onPageChanged: (index) {
                setState(() => currentIndex = index);
              },
              itemBuilder: (_, index) {
                final image = controller.bannerImages[index];

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: NetworkImage(image),
                      fit: BoxFit.fill,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          /// ================= DOT INDICATOR =================
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              controller.bannerImages.length,
                  (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 8,
                width: currentIndex == index ? 18 : 8,
                decoration: BoxDecoration(
                  color: currentIndex == index
                      ? Colors.indigo
                      : Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}
