import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class DeliveryTrackingScreen extends StatefulWidget {
  const DeliveryTrackingScreen({super.key});

  @override
  State<DeliveryTrackingScreen> createState() => _DeliveryTrackingScreenState();
}

class _DeliveryTrackingScreenState extends State<DeliveryTrackingScreen> {
  GoogleMapController? _controller;

  // ⚠️ REPLACE WITH YOUR API KEY
  static const String apiKey = "AIzaSyBn_OzZp3TW5dO6JN52edTyTQ_XcuhDvQo";

  // Locations based on your image
  // Restaurant at top, Scooter very close to restaurant, Delivery at bottom
  final LatLng restaurantLocation = const LatLng(19.1196, 72.8465); // Blue marker (top)
  final LatLng scooterLocation = const LatLng(19.1196, 72.8465); // Scooter near restaurant
  final LatLng deliveryLocation = const LatLng(19.0990, 72.8582); // Green marker (bottom)

  Set<Polyline> polylines = {};
  Set<Marker> markers = {};
  bool isLoading = true;

  BitmapDescriptor? scooterIcon;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    await _createCustomScooterIcon();
    await _fetchRoutes();
    _addMarkers();
    setState(() => isLoading = false);
  }

  Future<void> _createCustomScooterIcon() async {
    // Create custom yellow scooter icon
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Yellow circle background
    final paint = Paint()
      ..color = const Color(0xffFFC107)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(40, 40), 35, paint);

    // Border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(const Offset(40, 40), 35, borderPaint);

    // Draw scooter emoji
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '🛵',
        style: TextStyle(fontSize: 45),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, const Offset(8, 5));

    final picture = recorder.endRecording();
    final img = await picture.toImage(80, 80);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final buffer = byteData!.buffer.asUint8List();

    scooterIcon = BitmapDescriptor.fromBytes(buffer);
  }

  void _addMarkers() {
    setState(() {
      markers.clear();

      // Restaurant/Pickup Location (Blue marker - top)
      markers.add(
        Marker(
          markerId: const MarkerId("restaurant"),
          position: restaurantLocation,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: "1522 Bar & Kitchen Mumbai"),
        ),
      );

      // Delivery Location (Green marker - bottom)
      markers.add(
        Marker(
          markerId: const MarkerId("delivery"),
          position: deliveryLocation,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: const InfoWindow(title: "Delivery Location"),
        ),
      );

      // Scooter (Yellow icon - near restaurant)
      markers.add(
        Marker(
          markerId: const MarkerId("scooter"),
          position: scooterLocation,
          icon: scooterIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          anchor: const Offset(0.5, 0.5),
          infoWindow: const InfoWindow(title: "Delivery Partner"),
        ),
      );
    });
  }

  Future<void> _fetchRoutes() async {
    // First get the full route from restaurant to delivery
    final fullRoute = await _getRoutePoints(restaurantLocation, deliveryLocation);

    if (fullRoute.isEmpty) {
      debugPrint("❌ Failed to get route");
      return;
    }

    // Find the closest point on route to scooter location (simulate scooter just started)
    int scooterRouteIndex = _findClosestPointIndex(fullRoute, scooterLocation);

    // If scooter is very close to start, use first 5-10% of route
    if (scooterRouteIndex < fullRoute.length * 0.1) {
      scooterRouteIndex = (fullRoute.length * 0.08).toInt();
    }

    // Route 1: Restaurant to Scooter position (RED LINE - short, just started)
    List<LatLng> completedRoute = fullRoute.sublist(0, scooterRouteIndex + 1);

    setState(() {
      polylines.add(
        Polyline(
          polylineId: const PolylineId("completed_route"),
          points: completedRoute,
          color: const Color(0xffFF5252), // Red/Pink
          width: 5,
          geodesic: true,
        ),
      );
    });

    // Route 2: Scooter to Delivery (BLUE LINE - long remaining route)
    List<LatLng> remainingRoute = fullRoute.sublist(scooterRouteIndex);

    setState(() {
      polylines.add(
        Polyline(
          polylineId: const PolylineId("remaining_route"),
          points: remainingRoute,
          color: const Color(0xffFF5252), // Red/Pink
          width: 5,
          geodesic: true,
        ),
      );
    });

    debugPrint("✅ Routes drawn - Completed: ${completedRoute.length}, Remaining: ${remainingRoute.length}");
  }

  Future<List<LatLng>> _getRoutePoints(LatLng start, LatLng end) async {
    final String url = 'https://maps.googleapis.com/maps/api/directions/json?'
        'origin=${start.latitude},${start.longitude}'
        '&destination=${end.latitude},${end.longitude}'
        '&mode=driving'
        '&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          final String encodedPolyline =
          data['routes'][0]['overview_polyline']['points'];
          return _decodePolyline(encodedPolyline);
        } else {
          debugPrint("❌ API Error: ${data['status']}");
          if (data['error_message'] != null) {
            debugPrint("Error: ${data['error_message']}");
          }
        }
      }
    } catch (e) {
      debugPrint("❌ Exception: $e");
    }

    return [];
  }

  int _findClosestPointIndex(List<LatLng> points, LatLng target) {
    int closestIndex = 0;
    double minDistance = double.infinity;

    for (int i = 0; i < points.length; i++) {
      double distance = _calculateDistance(points[i], target);
      if (distance < minDistance) {
        minDistance = distance;
        closestIndex = i;
      }
    }

    return closestIndex;
  }

  double _calculateDistance(LatLng point1, LatLng point2) {
    double latDiff = point1.latitude - point2.latitude;
    double lngDiff = point1.longitude - point2.longitude;
    return latDiff * latDiff + lngDiff * lngDiff; // Squared distance is fine for comparison
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polyline = [];
    int index = 0;
    int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      polyline.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return polyline;
  }

  void _fitMapToAllPoints() {
    if (_controller == null) return;

    List<LatLng> allPoints = [
      restaurantLocation,
      scooterLocation,
      deliveryLocation,
    ];

    double minLat = allPoints[0].latitude;
    double maxLat = allPoints[0].latitude;
    double minLng = allPoints[0].longitude;
    double maxLng = allPoints[0].longitude;

    for (var point in allPoints) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    Future.delayed(const Duration(milliseconds: 1000), () {
      _controller?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: scooterLocation,
              zoom: 13,
            ),
            onMapCreated: (controller) {
              _controller = controller;
              _setMapStyle();
              _fitMapToAllPoints();
            },
            markers: markers,
            polylines: polylines,
            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
            mapType: MapType.normal,
            compassEnabled: false,
            mapToolbarEnabled: false,
            rotateGesturesEnabled: false,
            scrollGesturesEnabled: true,
            tiltGesturesEnabled: false,
            zoomGesturesEnabled: true,
          ),

          if (isLoading)
            Container(
              color: Colors.black87,
              child: const Center(
                child: CircularProgressIndicator(
                  color: Color(0xffFF5252),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _setMapStyle() {
    // Dark brownish theme matching your image
    _controller?.setMapStyle('''
[
  {
    "elementType": "geometry",
    "stylers": [{"color": "#2d1f1a"}]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#9ca5b3"}]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [{"color": "#1a1410"}]
  },
  {
    "featureType": "administrative",
    "elementType": "geometry",
    "stylers": [{"color": "#4a3a30"}]
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [{"color": "#3d2f27"}]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#7c8796"}]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [{"color": "#2a1f1a"}]
  },
  {
    "featureType": "road",
    "elementType": "geometry.fill",
    "stylers": [{"color": "#3d3027"}]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#9ca5b3"}]
  },
  {
    "featureType": "road.arterial",
    "elementType": "geometry",
    "stylers": [{"color": "#4a3a30"}]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [{"color": "#5a4a40"}]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [{"color": "#1a0f0a"}]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#4d5d6f"}]
  }
]
    ''');
  }
}