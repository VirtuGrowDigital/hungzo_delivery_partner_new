import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../controllers/home_controller.dart';

class FilterBar extends StatefulWidget {
  const FilterBar({super.key});

  @override
  State<FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<FilterBar> {

  /// SORT
  int? selectedSortIndex;

  /// TOGGLES
  bool ratingSelected = false;
  bool priceSelected = false;

  final List<String> sortOptions = [
    "Relevance",
    "Low To High",
    "High To Low",
  ];

  // ================= CLEAR ALL =================

  void clearAllFilters() {
    setState(() {
      selectedSortIndex = null;
      ratingSelected = false;
      priceSelected = false;
    });
  }

  // ================= COMMON CHIP =================

  Widget chip(
      String text, {
        bool isSelected = false,
        VoidCallback? onTap,
      }) {
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xffFFF2E8)
              : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? Colors.brown : Colors.grey.shade300,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.brown : Colors.black,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // ================= UI =================

  @override
  @override
  Widget build(BuildContext context) {
    return Obx(() {

      final controller = Get.find<HomeController>();

      return Row(
        children: [

          /// SORT
          chip(
            controller.sortIndex.value == null
                ? "Sort by"
                : ["Relevance","Low To High","High To Low"]
            [controller.sortIndex.value!],
            isSelected: controller.sortIndex.value != null,
            onTap: () async {

              final result = await showSortBottomSheet(
                context,
                controller.sortIndex.value,
              );

              controller.sortIndex.value = result;

              /// 🔥 IMPORTANT
              controller.applyFilters();
            },
          ),

          const SizedBox(width: 8),

          /// RATING
          chip(
            "Rating 4.0+",
            isSelected: controller.ratingFilter.value,
            onTap: () {
              controller.ratingFilter.toggle();

              /// 🔥 IMPORTANT
              controller.applyFilters();
            },
          ),

          const SizedBox(width: 8),

          /// PRICE
          chip(
            "₹200-400",
            isSelected: controller.priceFilter.value,
            onTap: () {
              controller.priceFilter.toggle();

              /// 🔥 IMPORTANT
              controller.applyFilters();
            },
          ),

          const SizedBox(width: 8),

          /// CLEAR
          chip(
            "Clear",
            onTap: () {
              controller.clearFilters();

              /// 🔥 IMPORTANT
              controller.applyFilters();
            },
          ),
        ],
      );
    });
  }
}


Future<int?> showSortBottomSheet(
    BuildContext context,
    int? currentIndex,
    ) {
  return showModalBottomSheet<int?>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => SortBottomSheet(
      initialIndex: currentIndex,
    ),
  );
}

class SortBottomSheet extends StatefulWidget {
  final int? initialIndex;

  const SortBottomSheet({super.key, this.initialIndex});

  @override
  State<SortBottomSheet> createState() => _SortBottomSheetState();
}

class _SortBottomSheetState extends State<SortBottomSheet> {
  int? selectedIndex;

  final options = [
    "Relevance",
    "Low To High",
    "High To Low",
  ];

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      decoration: const BoxDecoration(
        color: Color(0xffF5F5F5),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            /// 🔥 TITLE
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Sort by",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// 🔥 OPTIONS CARD
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: List.generate(
                  options.length,
                      (index) => _buildTile(index),
                ),
              ),
            ),

            const SizedBox(height: 22),

            /// 🔥 BUTTONS
            Row(
              children: [

                /// CLOSE
                Expanded(
                  child: TextButton(
                    onPressed: () =>
                        Navigator.pop(context, widget.initialIndex),
                    child: const Text(
                      "Close",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),

                /// APPLY
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () =>
                          Navigator.pop(context, selectedIndex),
                      child: const Text(
                        "Show Results",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // 🔥 OPTION TILE (custom radio style like image)
  // =====================================================

  Widget _buildTile(int index) {
    final isSelected = selectedIndex == index;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => setState(() => selectedIndex = index),
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xffFFF2E8) // peach highlight
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            /// TEXT
            Text(
              options[index],
              style: const TextStyle(fontSize: 16),
            ),

            /// 🔥 CUSTOM RADIO
            Container(
              height: 22,
              width: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  width: 2,
                  color: isSelected
                      ? Colors.brown
                      : Colors.grey.shade400,
                ),
              ),
              child: isSelected
                  ? const Center(
                child: CircleAvatar(
                  radius: 5,
                  backgroundColor: Colors.brown,
                ),
              )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
