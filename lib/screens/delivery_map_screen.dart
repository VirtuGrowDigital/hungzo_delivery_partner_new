import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controllers/order_controller.dart';
import '../model/driver_order_model.dart';

class DeliveryMapScreen extends StatefulWidget {
  final String orderId;

  const DeliveryMapScreen({super.key, required this.orderId});

  @override
  State<DeliveryMapScreen> createState() => _DeliveryMapScreenState();
}

class _DeliveryMapScreenState extends State<DeliveryMapScreen> {
  final OrderController controller = Get.find<OrderController>();

  GoogleMapController? _mapController;
  StreamSubscription<Position>? _positionSubscription;
  Timer? _paymentPollingTimer;
  LatLng? _liveDriverLocation;

  @override
  void initState() {
    super.initState();
    _setupTracking();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _paymentPollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _setupTracking() async {
    await controller.fetchCurrentOrder();
    final order = controller.activeOrder.value;

    if (order == null || order.orderId != widget.orderId) {
      return;
    }

    if (order.driverLat != null && order.driverLng != null) {
      _liveDriverLocation = LatLng(order.driverLat!, order.driverLng!);
    }

    await _startLocationStream();
  }

  Future<void> _startLocationStream() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    final currentPosition = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );

    await _pushDriverLocation(currentPosition);

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 15,
      ),
    ).listen((position) {
      _pushDriverLocation(position);
    });
  }

  Future<void> _pushDriverLocation(Position position) async {
    final next = LatLng(position.latitude, position.longitude);
    setState(() => _liveDriverLocation = next);
    await controller.syncActiveOrderLocation(
      lat: position.latitude,
      lng: position.longitude,
    );
    _fitBounds();
  }

  void _fitBounds() {
    final order = controller.activeOrder.value;
    if (_mapController == null ||
        order == null ||
        _liveDriverLocation == null ||
        order.lat == null ||
        order.lng == null) {
      return;
    }

    final destination = LatLng(order.lat!, order.lng!);
    final bounds = LatLngBounds(
      southwest: LatLng(
        _min(_liveDriverLocation!.latitude, destination.latitude),
        _min(_liveDriverLocation!.longitude, destination.longitude),
      ),
      northeast: LatLng(
        _max(_liveDriverLocation!.latitude, destination.latitude),
        _max(_liveDriverLocation!.longitude, destination.longitude),
      ),
    );

    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    if (phoneNumber.isEmpty) return;

    final uri = Uri(scheme: "tel", path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _handlePrimaryAction(DriverOrderModel order) async {
    if (order.driverStatus == "DRIVER_ACCEPTED") {
      final success = await controller.pickActiveOrder();
      if (success && mounted) {
        Get.snackbar("Picked Up", "Order is now out for delivery.");
      }
      return;
    }

    if (order.paymentStatus == "paid") {
      final success = await controller.completePaidActiveOrder();
      if (success && mounted) {
        Navigator.pop(context);
      }
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _PaymentCollectionSheet(
        controller: controller,
        onCompleted: () {
          if (mounted) Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        final order = controller.activeOrder.value;

        if (order == null || order.orderId != widget.orderId) {
          return const Center(child: Text("No active order found."));
        }

        final destination = order.lat != null && order.lng != null
            ? LatLng(order.lat!, order.lng!)
            : null;

        final currentDriver = _liveDriverLocation ??
            (order.driverLat != null && order.driverLng != null
                ? LatLng(order.driverLat!, order.driverLng!)
                : destination);

        final markers = <Marker>{
          if (destination != null)
            Marker(
              markerId: const MarkerId("destination"),
              position: destination,
              infoWindow: const InfoWindow(title: "Delivery location"),
            ),
          if (currentDriver != null)
            Marker(
              markerId: const MarkerId("driver"),
              position: currentDriver,
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueAzure,
              ),
              infoWindow: const InfoWindow(title: "Your live location"),
            ),
        };

        final polylines = <Polyline>{
          if (destination != null && currentDriver != null)
            Polyline(
              polylineId: const PolylineId("delivery_route"),
              points: [currentDriver, destination],
              color: const Color(0xffFF6B6B),
              width: 5,
            ),
        };

        return Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: currentDriver ?? const LatLng(20.5937, 78.9629),
                zoom: 14,
              ),
              onMapCreated: (mapController) {
                _mapController = mapController;
                _fitBounds();
              },
              markers: markers,
              polylines: polylines,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: false,
            ),
            Positioned(
              top: 48,
              left: 20,
              right: 20,
              child: _headerCard(order),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: _bottomCard(order),
            ),
          ],
        );
      }),
    );
  }

  Widget _headerCard(DriverOrderModel order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.local_shipping_outlined, color: Color(0xffFF6B6B)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.customerName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  order.orderStatus,
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _makePhoneCall(order.customerPhone),
            icon: const Icon(Icons.call_outlined),
          ),
        ],
      ),
    );
  }

  Widget _bottomCard(DriverOrderModel order) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 24,
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
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            "Order #${order.orderId}",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Text(order.address),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _detailChip(
                  Icons.currency_rupee,
                  "Rs ${order.amount.toStringAsFixed(0)}",
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _detailChip(
                  Icons.payments_outlined,
                  order.paymentStatus == "paid"
                      ? "Paid"
                      : order.isQrPending
                          ? "QR Pending"
                          : "Collect payment",
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (controller.isActionLoading.value)
            Text(
              controller.actionLabel.value,
              style: const TextStyle(color: Colors.black54),
            ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: controller.isActionLoading.value
                  ? null
                  : () => _handlePrimaryAction(order),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffFF6B6B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(_primaryButtonLabel(order)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xffF5F6FB),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.black54),
          const SizedBox(width: 8),
          Expanded(child: Text(label)),
        ],
      ),
    );
  }

  String _primaryButtonLabel(DriverOrderModel order) {
    if (order.driverStatus == "DRIVER_ACCEPTED") return "Mark Picked Up";
    if (order.paymentStatus == "paid") return "Complete Delivery";
    return "Collect Payment";
  }

  double _min(double a, double b) => a < b ? a : b;
  double _max(double a, double b) => a > b ? a : b;
}

class _PaymentCollectionSheet extends StatefulWidget {
  final OrderController controller;
  final VoidCallback onCompleted;

  const _PaymentCollectionSheet({
    required this.controller,
    required this.onCompleted,
  });

  @override
  State<_PaymentCollectionSheet> createState() => _PaymentCollectionSheetState();
}

class _PaymentCollectionSheetState extends State<_PaymentCollectionSheet> {
  String? qrUrl;
  Timer? timer;
  bool waitingForQrPayment = false;

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> _collectCash() async {
    final success = await widget.controller.deliverActiveOrderCash();
    if (success && mounted) {
      Navigator.pop(context);
      widget.onCompleted();
    }
  }

  Future<void> _startQrFlow() async {
    final url = await widget.controller.requestQrPayment();
    if (!mounted || url == null) return;

    setState(() {
      qrUrl = url;
      waitingForQrPayment = true;
    });

    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 5), (_) async {
      await widget.controller.fetchCurrentOrder();
      if (widget.controller.activeOrder.value == null && mounted) {
        timer?.cancel();
        Navigator.pop(context);
        widget.onCompleted();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.controller.activeOrder.value;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Collect Payment",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Text(
            order == null
                ? ""
                : "Rs ${order.amount.toStringAsFixed(0)} from ${order.customerName}",
          ),
          const SizedBox(height: 20),
          if (!waitingForQrPayment) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: widget.controller.isActionLoading.value ? null : _collectCash,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff1EB980),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                icon: const Icon(Icons.money_outlined),
                label: const Text("Cash Collected"),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: widget.controller.isActionLoading.value ? null : _startQrFlow,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                icon: const Icon(Icons.qr_code_2_outlined),
                label: const Text("Generate QR Payment"),
              ),
            ),
          ] else ...[
            Center(
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.network(
                      "https://api.qrserver.com/v1/create-qr-code/?size=260x260&data=${Uri.encodeComponent(qrUrl!)}",
                      width: 220,
                      height: 220,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 220,
                        height: 220,
                        color: Colors.grey.shade200,
                        alignment: Alignment.center,
                        child: const Text("QR preview unavailable"),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    "Ask the customer to scan and complete payment.",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () async {
                      final uri = Uri.parse(qrUrl!);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    },
                    child: const Text("Open payment link"),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
