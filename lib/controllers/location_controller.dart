import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationController extends GetxController {
  var area = 'Select location'.obs;
  var city = ''.obs;

  @override
  void onInit() {
    super.onInit();
    refreshLocation();
  }

  Future<void> refreshLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        area.value = 'Location off';
        city.value = 'Enable GPS to use current location';
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        area.value = 'Select location';
        city.value = 'Allow location when you need live tracking';
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      final place = placemarks.first;

      area.value = place.subLocality ?? place.locality ?? '';
      city.value = place.locality ?? '';
    } catch (e) {
      area.value = 'Location unavailable';
      city.value = 'Allow location when you need live tracking';
    }
  }
}
