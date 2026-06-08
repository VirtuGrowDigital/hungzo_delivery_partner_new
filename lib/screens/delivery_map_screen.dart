import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
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
  final ImagePicker _imagePicker = ImagePicker();

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
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );

    await _pushDriverLocation(currentPosition);

    _positionSubscription =
        Geolocator.getPositionStream(
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

  Future<void> _openNavigation(DriverOrderModel order) async {
    if (order.lat == null || order.lng == null) {
      Get.snackbar(
        "Navigation unavailable",
        "Customer location is missing for this order.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final destinationLabel = [
      order.customerName.trim(),
      order.address.trim(),
    ].where((value) => value.isNotEmpty).join(", ");

    final encodedLabel = Uri.encodeComponent(destinationLabel);
    final lat = order.lat!;
    final lng = order.lng!;

    final uriCandidates = <Uri>[
      if (Platform.isIOS)
        Uri.parse(
          "http://maps.apple.com/?daddr=$lat,$lng&dirflg=d"
          "${encodedLabel.isEmpty ? "" : "&q=$encodedLabel"}",
        ),
      Uri.parse(
        "geo:$lat,$lng?q=$lat,$lng${encodedLabel.isEmpty ? "" : "($encodedLabel)"}",
      ),
      Uri.parse(
        "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving",
      ),
    ];

    for (final uri in uriCandidates) {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }
    }

    Get.snackbar(
      "Navigation unavailable",
      "No map app is available to open this destination.",
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> _handlePrimaryAction(DriverOrderModel order) async {
    if (order.driverStatus == "DRIVER_ACCEPTED") {
      final success = await controller.pickActiveOrder();
      if (success && mounted) {
        Get.snackbar("Picked Up", "Order is now out for delivery.");
      }
      return;
    }

    final deliveryPayload = await _showDeliveryConfirmationSheet(order);
    if (deliveryPayload == null) return;

    if (order.paymentStatus == "paid") {
      final success = await controller.completePaidActiveOrder(
        verificationMethod: deliveryPayload.verificationMethod,
        otp: deliveryPayload.otp,
        recipientName: deliveryPayload.recipientName,
        proofNote: deliveryPayload.proofNote,
        proofPhoto: deliveryPayload.proofPhoto,
      );
      if (success && mounted) {
        Navigator.pop(context);
      }
      return;
    }

    if (!mounted) return;

    final verified = await controller.verifyActiveOrderForPayment(
      verificationMethod: deliveryPayload.verificationMethod,
      otp: deliveryPayload.otp,
      recipientName: deliveryPayload.recipientName,
    );
    if (!verified || !mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _PaymentCollectionSheet(
        controller: controller,
        deliveryPayload: deliveryPayload,
        onCompleted: () {
          if (mounted) Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _handleRejectDueToUser() async {
    final failureDetails = await _showFailureSheet(
      title: "Reject delivery",
      presetReasonCode: "CUSTOMER_REJECTED",
      helperText:
          "Use this when the customer refuses to accept the order after pickup.",
      noteLabel: "Rejection comment",
      noteHint: "Write why the customer rejected the order",
      actionLabel: "Reject",
    );

    if (failureDetails == null) {
      return;
    }

    final success = await controller.reportFailedDelivery(
      reasonCode: failureDetails.reasonCode,
      reasonNote: failureDetails.reasonNote,
      proofPhoto: failureDetails.proofPhoto,
    );

    if (success && mounted) {
      Get.snackbar(
        "Delivery rejected",
        "The order was marked as customer rejected.",
      );
      Navigator.pop(context);
    }
  }

  Future<void> _handleReportFailedDelivery() async {
    final failureDetails = await _showFailureSheet(
      title: "Report failed delivery",
      helperText:
          "Record why the order could not be delivered so disputes and retries can be handled clearly.",
      noteLabel: "Failure details",
      noteHint: "Write what happened at the doorstep",
      actionLabel: "Submit",
    );

    if (failureDetails == null) {
      return;
    }

    final success = await controller.reportFailedDelivery(
      reasonCode: failureDetails.reasonCode,
      reasonNote: failureDetails.reasonNote,
      proofPhoto: failureDetails.proofPhoto,
    );

    if (success && mounted) {
      Get.snackbar(
        "Failed delivery recorded",
        "The failure reason has been saved for this order.",
      );
      Navigator.pop(context);
    }
  }

  Future<_DeliveryCompletionPayload?> _showDeliveryConfirmationSheet(
    DriverOrderModel order,
  ) {
    return showModalBottomSheet<_DeliveryCompletionPayload>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return _DeliveryConfirmationSheet(
          order: order,
          imagePicker: _imagePicker,
        );
      },
    );
  }

  Future<_FailurePayload?> _showFailureSheet({
    required String title,
    required String helperText,
    required String noteLabel,
    required String noteHint,
    required String actionLabel,
    String presetReasonCode = "OTHER",
  }) {
    return showModalBottomSheet<_FailurePayload>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _FailureReportSheet(
        title: title,
        helperText: helperText,
        noteLabel: noteLabel,
        noteHint: noteHint,
        actionLabel: actionLabel,
        presetReasonCode: presetReasonCode,
        imagePicker: _imagePicker,
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

        final currentDriver =
            _liveDriverLocation ??
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
            Positioned(top: 48, left: 20, right: 20, child: _headerCard(order)),
            Align(alignment: Alignment.bottomCenter, child: _bottomCard(order)),
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
            color: Colors.black.withValues(alpha: 0.08),
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
            color: Colors.black.withValues(alpha: 0.12),
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
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _openNavigation(order),
              icon: const Icon(Icons.navigation_outlined),
              label: const Text("Navigate to Customer"),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xffFF6B6B),
                side: const BorderSide(color: Color(0xffFF6B6B)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
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
          if (order.isPickedUp) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: controller.isActionLoading.value
                    ? null
                    : _handleReportFailedDelivery,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xff856404),
                  side: const BorderSide(color: Color(0xffE8D39B)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                icon: const Icon(Icons.report_gmailerrorred_outlined),
                label: const Text("Report Failed Delivery"),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: controller.isActionLoading.value
                    ? null
                    : _handleRejectDueToUser,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xffC84B31),
                  side: const BorderSide(color: Color(0xffF2B8AE)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                icon: const Icon(Icons.person_off_outlined),
                label: const Text("Customer Rejected Order"),
              ),
            ),
          ],
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
    if (order.paymentStatus == "paid") return "Verify & Complete Delivery";
    return "Verify Delivery & Collect Payment";
  }

  double _min(double a, double b) => a < b ? a : b;
  double _max(double a, double b) => a > b ? a : b;
}

class _PaymentCollectionSheet extends StatefulWidget {
  final OrderController controller;
  final _DeliveryCompletionPayload deliveryPayload;
  final VoidCallback onCompleted;

  const _PaymentCollectionSheet({
    required this.controller,
    required this.deliveryPayload,
    required this.onCompleted,
  });

  @override
  State<_PaymentCollectionSheet> createState() =>
      _PaymentCollectionSheetState();
}

class _PaymentCollectionSheetState extends State<_PaymentCollectionSheet> {
  String? qrUrl;
  Timer? timer;
  bool waitingForQrPayment = false;

  @override
  void initState() {
    super.initState();
    final activeOrder = widget.controller.activeOrder.value;
    if (activeOrder?.isQrPending == true &&
        activeOrder?.qrUrl != null &&
        activeOrder!.qrUrl!.isNotEmpty) {
      _resumeQrPaymentFlow(activeOrder.qrUrl!);
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _resumeQrPaymentFlow(String url) {
    qrUrl = url;
    waitingForQrPayment = true;

    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 5), (_) async {
      await widget.controller.fetchCurrentOrder();
      final current = widget.controller.activeOrder.value;
      if (current == null && mounted) {
        timer?.cancel();
        Navigator.pop(context);
        widget.onCompleted();
        return;
      }

      if (current?.paymentStatus == "paid" && mounted) {
        timer?.cancel();
        final success = await widget.controller.completePaidActiveOrder(
          verificationMethod: widget.deliveryPayload.verificationMethod,
          otp: widget.deliveryPayload.otp,
          recipientName: widget.deliveryPayload.recipientName,
          proofNote: widget.deliveryPayload.proofNote,
          proofPhoto: widget.deliveryPayload.proofPhoto,
        );
        if (!mounted) return;
        if (success) {
          Navigator.pop(context);
          widget.onCompleted();
        }
      }
    });
  }

  Future<void> _collectCash() async {
    final success = await widget.controller.deliverActiveOrderCash(
      verificationMethod: widget.deliveryPayload.verificationMethod,
      otp: widget.deliveryPayload.otp,
      recipientName: widget.deliveryPayload.recipientName,
      proofNote: widget.deliveryPayload.proofNote,
      proofPhoto: widget.deliveryPayload.proofPhoto,
    );
    if (success && mounted) {
      Navigator.pop(context);
      widget.onCompleted();
    }
  }

  Future<void> _startQrFlow() async {
    final url = await widget.controller.requestQrPayment(
      verificationMethod: widget.deliveryPayload.verificationMethod,
      otp: widget.deliveryPayload.otp,
      recipientName: widget.deliveryPayload.recipientName,
    );
    if (!mounted || url == null) return;

    setState(() {
      _resumeQrPaymentFlow(url);
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
                onPressed: widget.controller.isActionLoading.value
                    ? null
                    : _collectCash,
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
                onPressed: widget.controller.isActionLoading.value
                    ? null
                    : _startQrFlow,
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
                    child: Container(
                      width: 220,
                      height: 220,
                      color: Colors.white,
                      padding: const EdgeInsets.all(14),
                      child: QrImageView(
                        data: qrUrl!,
                        version: QrVersions.auto,
                        backgroundColor: Colors.white,
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: Color(0xff111827),
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: Color(0xff111827),
                        ),
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
                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
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

class _DeliveryConfirmationSheet extends StatefulWidget {
  final DriverOrderModel order;
  final ImagePicker imagePicker;

  const _DeliveryConfirmationSheet({
    required this.order,
    required this.imagePicker,
  });

  @override
  State<_DeliveryConfirmationSheet> createState() =>
      _DeliveryConfirmationSheetState();
}

class _DeliveryConfirmationSheetState
    extends State<_DeliveryConfirmationSheet> {
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _proofNoteController = TextEditingController();
  String _verificationMethod = "OTP";
  File? _proofPhoto;

  @override
  void dispose() {
    _otpController.dispose();
    _recipientController.dispose();
    _proofNoteController.dispose();
    super.dispose();
  }

  Future<void> _pickProofPhoto() async {
    final picked = await widget.imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );
    if (picked == null) return;

    setState(() {
      _proofPhoto = File(picked.path);
    });
  }

  void _submit() {
    final otp = _otpController.text.trim();
    final recipientName = _recipientController.text.trim();

    if (_verificationMethod == "OTP" && otp.isEmpty) {
      Get.snackbar("OTP required", "Enter the customer OTP to continue.");
      return;
    }

    if (_verificationMethod == "CUSTOMER_CONFIRMED" && recipientName.isEmpty) {
      Get.snackbar(
        "Recipient required",
        "Enter the name of the person who accepted the order.",
      );
      return;
    }

    Navigator.pop(
      context,
      _DeliveryCompletionPayload(
        verificationMethod: _verificationMethod,
        otp: otp.isEmpty ? null : otp,
        recipientName: recipientName.isEmpty ? null : recipientName,
        proofNote: _proofNoteController.text.trim().isEmpty
            ? null
            : _proofNoteController.text.trim(),
        proofPhoto: _proofPhoto,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            "Verify Delivery",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Text(
            "Confirm handoff before closing order #${widget.order.orderId}.",
          ),
          const SizedBox(height: 16),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment<String>(value: "OTP", label: Text("OTP")),
              ButtonSegment<String>(
                value: "CUSTOMER_CONFIRMED",
                label: Text("Customer Confirmed"),
              ),
            ],
            selected: {_verificationMethod},
            onSelectionChanged: (selection) {
              setState(() {
                _verificationMethod = selection.first;
              });
            },
          ),
          const SizedBox(height: 16),
          if (_verificationMethod == "OTP")
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Delivery OTP",
                hintText: "Enter OTP from customer",
                border: OutlineInputBorder(),
              ),
            )
          else
            TextField(
              controller: _recipientController,
              decoration: const InputDecoration(
                labelText: "Recipient name",
                hintText: "Who accepted the order?",
                border: OutlineInputBorder(),
              ),
            ),
          const SizedBox(height: 12),
          TextField(
            controller: _proofNoteController,
            maxLines: 3,
            maxLength: 300,
            decoration: const InputDecoration(
              labelText: "Proof note (optional)",
              hintText: "Add handoff details or landmark notes",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _pickProofPhoto,
            icon: const Icon(Icons.camera_alt_outlined),
            label: Text(
              _proofPhoto == null
                  ? "Capture Proof Photo"
                  : "Retake Proof Photo",
            ),
          ),
          if (_proofPhoto != null) ...[
            const SizedBox(height: 8),
            Text(
              "Proof photo attached",
              style: TextStyle(color: Colors.green.shade700),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffFF6B6B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text("Continue"),
            ),
          ),
        ],
      ),
    );
  }
}

class _FailureReportSheet extends StatefulWidget {
  final String title;
  final String helperText;
  final String noteLabel;
  final String noteHint;
  final String actionLabel;
  final String presetReasonCode;
  final ImagePicker imagePicker;

  const _FailureReportSheet({
    required this.title,
    required this.helperText,
    required this.noteLabel,
    required this.noteHint,
    required this.actionLabel,
    required this.presetReasonCode,
    required this.imagePicker,
  });

  @override
  State<_FailureReportSheet> createState() => _FailureReportSheetState();
}

class _FailureReportSheetState extends State<_FailureReportSheet> {
  final TextEditingController _noteController = TextEditingController();
  late String _reasonCode;
  File? _proofPhoto;

  static const List<MapEntry<String, String>> _reasonOptions = [
    MapEntry("CUSTOMER_REJECTED", "Customer rejected"),
    MapEntry("CUSTOMER_UNREACHABLE", "Customer unreachable"),
    MapEntry("ADDRESS_ISSUE", "Address issue"),
    MapEntry("PAYMENT_ISSUE", "Payment issue"),
    MapEntry("SAFETY_ISSUE", "Safety issue"),
    MapEntry("OTHER", "Other"),
  ];

  @override
  void initState() {
    super.initState();
    _reasonCode = widget.presetReasonCode;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickProofPhoto() async {
    final picked = await widget.imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );
    if (picked == null) return;

    setState(() {
      _proofPhoto = File(picked.path);
    });
  }

  void _submit() {
    if (_noteController.text.trim().isEmpty) {
      Get.snackbar("Reason required", "Please explain what happened.");
      return;
    }

    Navigator.pop(
      context,
      _FailurePayload(
        reasonCode: _reasonCode,
        reasonNote: _noteController.text.trim(),
        proofPhoto: _proofPhoto,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          Text(
            widget.title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Text(widget.helperText),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _reasonCode,
            decoration: const InputDecoration(
              labelText: "Reason",
              border: OutlineInputBorder(),
            ),
            items: _reasonOptions
                .map(
                  (option) => DropdownMenuItem<String>(
                    value: option.key,
                    child: Text(option.value),
                  ),
                )
                .toList(),
            onChanged: widget.presetReasonCode == "CUSTOMER_REJECTED"
                ? null
                : (value) {
                    if (value == null) return;
                    setState(() {
                      _reasonCode = value;
                    });
                  },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteController,
            maxLines: 3,
            maxLength: 300,
            decoration: InputDecoration(
              labelText: widget.noteLabel,
              hintText: widget.noteHint,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _pickProofPhoto,
            icon: const Icon(Icons.camera_alt_outlined),
            label: Text(
              _proofPhoto == null ? "Attach Proof Photo" : "Retake Proof Photo",
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffFF6B6B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: Text(widget.actionLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeliveryCompletionPayload {
  final String verificationMethod;
  final String? otp;
  final String? recipientName;
  final String? proofNote;
  final File? proofPhoto;

  const _DeliveryCompletionPayload({
    required this.verificationMethod,
    this.otp,
    this.recipientName,
    this.proofNote,
    this.proofPhoto,
  });
}

class _FailurePayload {
  final String reasonCode;
  final String reasonNote;
  final File? proofPhoto;

  const _FailurePayload({
    required this.reasonCode,
    required this.reasonNote,
    this.proofPhoto,
  });
}
