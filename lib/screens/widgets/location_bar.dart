import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/ColorConstants.dart';
import '../../utils/ImageConstant.dart';
import '../../controllers/location_controller.dart';

class LocationBar extends StatelessWidget {
  LocationBar({super.key});

  final LocationController locationController =
  Get.put(LocationController());

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.location_on, color: ColorConstants.textHint),
            const SizedBox(width: 8),

            Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  locationController.area.value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  locationController.city.value,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
              ],
            )),
          ],
        ),

        Image.asset(
          ImageConstant.logoHungZo,
          width: 45,
          height: 45,
          fit: BoxFit.contain,
        ),
      ],
    );
  }
}
