import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:hungzo_delivery_partner/screens/tracking_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

class DeliveryMapScreen extends StatefulWidget {
  final dynamic currentOrder;

  DeliveryMapScreen({super.key, required this.currentOrder});

  @override
  State<DeliveryMapScreen> createState() => _DeliveryMapScreenState();
}

class _DeliveryMapScreenState extends State<DeliveryMapScreen> {
  late GoogleMapController _controller;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  LatLng? start;
  late final LatLng end = widget.currentOrder?["location"] != null
      ? LatLng(
          (widget.currentOrder["location"]["latitude"] ?? 19.1136).toDouble(),
          (widget.currentOrder["location"]["longitude"] ?? 72.8697).toDouble(),
        )
      : const LatLng(19.1136, 72.8697);

  Set<Polyline> polylines = {};
  Set<Marker> markers = {};
  bool isLoading = true;
  String statusMessage = "Loading route...";

  // Track order pick status
  bool orderPicked = false;
  bool isButtonLoading = false;

  String? token;
  dynamic currentOrder;

  @override
  void initState() {
    super.initState();
    currentOrder = widget.currentOrder;
    _addEndMarker();
    _getCurrentLocation();
    _getRoute();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        statusMessage = "Location services are disabled.";
        isLoading = false;
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          statusMessage = "Location permission denied.";
          isLoading = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        statusMessage = "Location permissions are permanently denied.";
        isLoading = false;
      });
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      start = LatLng(position.latitude, position.longitude);
      _updateStartMarker();
    });
  }

  void _addEndMarker() {
    markers.add(
      Marker(
        markerId: const MarkerId("end"),
        position: end,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: "End"),
      ),
    );
  }

  void _updateStartMarker() {
    if (start == null) return;
    markers.removeWhere((m) => m.markerId.value == "start");
    markers.add(
      Marker(
        markerId: const MarkerId("start"),
        position: start!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(title: "Start"),
      ),
    );

    if (_controller != null) {
      _fitMapToRoute([start!, end]);
    }
  }

  Future<void> _getRoute() async {
    const String apiKey = "AIzaSyBn_OzZp3TW5dO6JN52edTyTQ_XcuhDvQo";

    if (start == null) {
      await Future.delayed(const Duration(milliseconds: 500));
      _getRoute();
      return;
    }

    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${start!.latitude},${start!.longitude}&destination=${end.latitude},${end.longitude}&mode=driving&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final String encodedPolyline =
              data['routes'][0]['overview_polyline']['points'];

          List<LatLng> routePoints = _decodePolyline(encodedPolyline);

          if (routePoints.isNotEmpty) {
            setState(() {
              polylines.clear();
              polylines.add(
                Polyline(
                  polylineId: const PolylineId("route"),
                  points: routePoints,
                  color: const Color(0xffFF5A5F),
                  width: 6,
                  geodesic: true,
                ),
              );
              statusMessage = "✅ Route loaded successfully!";
              isLoading = false;
            });

            Future.delayed(const Duration(milliseconds: 500), () {
              _fitMapToRoute(routePoints);
            });
          }
        } else {
          setState(() {
            statusMessage = "❌ API Error: ${data['status']}";
            isLoading = false;
          });
        }
      } else {
        setState(() {
          statusMessage = "❌ HTTP Error: ${response.statusCode}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        statusMessage = "❌ Exception: $e";
        isLoading = false;
      });
    }
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

  void _fitMapToRoute(List<LatLng> routePoints) {
    if (routePoints.isEmpty) return;

    double minLat = routePoints.first.latitude;
    double maxLat = routePoints.first.latitude;
    double minLng = routePoints.first.longitude;
    double maxLng = routePoints.first.longitude;

    for (var point in routePoints) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    try {
      _controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
    } catch (e) {
      print("⚠️ Could not adjust camera: $e");
    }
  }

  Future<void> makePhoneCall(String phoneNumber) async {
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      print("Could not launch $url");
    }
  }

  Future<void> pickOrder(String orderId) async {
    token = await _storage.read(key: 'accessToken');
    if (token == null) return;

    try {
      final res = await http.post(
        Uri.parse("https://api.hungzo.in/driver/orders/$orderId/pick"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          currentOrder = data["order"];
        });
      } else {
        print("Server error picking order: ${res.statusCode}");
        print("Server error picking order: ${res.body}");
      }
    } catch (e) {
      print("Network error picking order: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: start ?? const LatLng(19.1075, 72.8746),
              zoom: 14,
            ),
            onMapCreated: (controller) {
              _controller = controller;
            },
            markers: markers,
            polylines: polylines,
            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
            mapType: MapType.normal,
          ),
          if (isLoading || statusMessage.contains('❌'))
            Positioned(
              top: 50,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusMessage.contains('✅')
                      ? Colors.green.shade100
                      : statusMessage.contains('❌')
                      ? Colors.red.shade100
                      : Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    if (isButtonLoading)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        statusMessage,
                        style: TextStyle(
                          fontSize: 12,
                          color: statusMessage.contains('❌')
                              ? Colors.red.shade900
                              : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 25),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 25,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      height: 5,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person, color: Colors.redAccent),
                          SizedBox(width: 8),
                          Text(
                            widget.currentOrder?["customer"]?["name"] ??
                                "Unknown",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: () {
                          makePhoneCall(
                            widget.currentOrder?["customer"]?["phone"] ??
                                "No phone",
                          );
                        },
                        child: Container(
                          height: 45,
                          width: 45,
                          decoration: const BoxDecoration(
                            color: Color(0xffFFE6E6),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.call, color: Color(0xffFF5A5F)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on, color: Colors.redAccent),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Delivery",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            SizedBox(height: 4),
                            Text(
                              widget.currentOrder?["address"]?["full"] ??
                                  "No address",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffFF5A5F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: isButtonLoading
                          ? null
                          : () async {
                              if (!orderPicked) {
                                // Pick the order first
                                if (widget.currentOrder?["orderId"] != null) {
                                  setState(() {
                                    isButtonLoading = true;
                                    statusMessage = "Picking order...";
                                  });

                                  await pickOrder(
                                    widget.currentOrder!["orderId"],
                                  );

                                  setState(() {
                                    isButtonLoading = false;
                                    orderPicked = true;
                                    statusMessage =
                                        "✅ Order picked! Ready to deliver";
                                  });
                                } else {
                                  setState(() {
                                    statusMessage = "❌ Order ID not found!";
                                  });
                                }
                              } else {
                                // Order picked → check payment
                                final paymentStatus =
                                    currentOrder?["paymentStatus"] ?? "pending";

                                if (paymentStatus == "completed") {
                                  // Payment done → deliver order
                                  setState(() {
                                    isButtonLoading = true;
                                    statusMessage = "Delivering order...";
                                  });

                                  await deleverOrder(currentOrder["orderId"]);

                                  setState(() {
                                    isButtonLoading = false;
                                  });

                                  // Show success screen
                                  if (mounted) {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            SuccessScreen(order: currentOrder),
                                      ),
                                    );
                                  }
                                } else {
                                  // Payment pending → open PaymentScreen
                                  if (mounted) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => PaymentScreen(
                                          order: currentOrder,
                                          onPaymentSuccess: (updatedOrder) async {
                                            setState(() {
                                              currentOrder = updatedOrder;
                                            });

                                            // After payment, call deliver API
                                            setState(() {
                                              isButtonLoading = true;
                                              statusMessage =
                                                  "Delivering order...";
                                            });

                                            await deleverOrder(
                                              currentOrder["orderId"],
                                            );

                                            setState(() {
                                              isButtonLoading = false;
                                            });

                                            // Show success screen
                                            if (mounted) {
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => SuccessScreen(
                                                    order: currentOrder,
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                      icon: isButtonLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.send, color: Colors.white),
                      label: Text(
                        orderPicked ? "Deliver" : "Start",
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> deleverOrder(String orderId) async {
    token = await _storage.read(key: 'accessToken');
    if (token == null) return;
    try {
      final res = await http.post(
        Uri.parse("https://api.hungzo.in/driver/orders/$orderId/deliver"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          currentOrder = data["order"];
        });
      } else {
        print("  ${res.statusCode}");
        print("Server error picking order: ${res.body}");
      }
    } catch (e) {
      print("Network error picking order: $e");
    }
  }
}

class SuccessScreen extends StatelessWidget {
  final dynamic order;

  const SuccessScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 120,
                  color: Colors.green,
                ),
                const SizedBox(height: 24),
                Text(
                  "Delivery Completed!",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  "Order ID: ${order["orderId"]}\nAmount: ₹${order["amount"]}",
                  style: const TextStyle(fontSize: 18, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Back to Home",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PaymentScreen extends StatelessWidget {
  final dynamic order;
  final Function(dynamic updatedOrder) onPaymentSuccess;

  const PaymentScreen({
    super.key,
    required this.order,
    required this.onPaymentSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      appBar: AppBar(
        backgroundColor: Colors.orange.shade700,
        title: const Text("Collect Payment"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              "Order ID: ${order["orderId"]}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Text(
              "Amount: ₹${order["amount"]}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            Text(
              "Choose Payment Method",
              style: TextStyle(
                fontSize: 16,
                color: Colors.orange.shade900,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),

            // Cash Payment Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade600,
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                dynamic updatedOrder = {...order, "paymentStatus": "completed"};
                onPaymentSuccess(updatedOrder);
                Navigator.pop(context);
              },
              icon: const Icon(Icons.money, color: Colors.white),
              label: const Text(
                "Cash Payment",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 16),

            // Online Payment Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange.shade400,
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                // Mock online payment success
                dynamic updatedOrder = {...order, "paymentStatus": "completed"};
                onPaymentSuccess(updatedOrder);
                Navigator.pop(context);
              },
              icon: const Icon(Icons.credit_card, color: Colors.white),
              label: const Text(
                "Online Payment",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
