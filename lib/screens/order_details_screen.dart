import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:hungzo_delivery_partner/services/Api/api_constants.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'my_orders_screen.dart';

class OrderDetailsScreen extends StatefulWidget {
  final OrderModel order;
  final OrderItem selectedItem;

  const OrderDetailsScreen({
    super.key,
    required this.order,
    required this.selectedItem,
  });

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen>
    with TickerProviderStateMixin {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  late List<AnimationController> _controllers;

  final List<String> statusFlow = [
    "Pending",
    "Accepted",
    "Packed",
    "Out for Delivery",
    "Delivered",
    "Returned",
    "Refunded",
  ];

  late int currentIndex;

  // ================= RETURN BUTTON CONDITION =================

  bool get _canShowReturn {
    return false;
  }

  @override
  void initState() {
    super.initState();

    final item = widget.selectedItem;
    String effectiveStatus = widget.order.orderStatus;

    if (item.returned && !item.refunded) {
      effectiveStatus = "Returned";
    }

    if (item.refunded) {
      effectiveStatus = "Refunded";
    }

    currentIndex = statusFlow.indexOf(effectiveStatus);

    _controllers = List.generate(
      statusFlow.length,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      ),
    );

    if (currentIndex >= 0) {
      _playSequential(currentIndex);
    }
  }

  Future<void> _playSequential(int endIndex) async {
    for (int i = 0; i <= endIndex; i++) {
      await _controllers[i].forward();
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCancelled = widget.order.orderStatus == "Cancelled";

    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Order Details",
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        actions: [
          if (_canShowReturn)
            TextButton(
              onPressed: _showReturnDialog,
              child: const Text(
                "Return",
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _downloadInvoice,
          ),
        ],
      ),
      body: ListView(
        children: [
          _productHeader(),
          if (widget.selectedItem.refunded) _refundCard(),
          const SizedBox(height: 10),
          if (isCancelled) _cancelledCard() else _timelineCard(),
        ],
      ),
    );
  }

  // ================= DOWNLOAD INVOICE =================

  Future<void> _downloadInvoice() async {
    try {
      final order = widget.order;

      final pdf = pw.Document();

      // Load logo
      final logoBytes = await rootBundle.load(
        'assets/logo/hunzo_main_logo.png',
      );
      final logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());

      // Download product image (first item)
      pw.MemoryImage? productImage;

      if (order.items.isNotEmpty && order.items.first.image.isNotEmpty) {
        final response = await http.get(Uri.parse(order.items.first.image));
        productImage = pw.MemoryImage(response.bodyBytes);
      }

      double subTotal = 0;
      for (var item in order.items) {
        subTotal += item.total;
      }

      double deliveryFee = 50; // 👈 You can make dynamic
      double platformFee = 12; // 👈 You can make dynamic

      double grandTotal = subTotal + deliveryFee + platformFee;

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                /// HEADER
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Image(logoImage, height: 60),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          "INVOICE",
                          style: pw.TextStyle(
                            fontSize: 26,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue900,
                          ),
                        ),
                        pw.SizedBox(height: 5),
                        pw.Text(
                          "Date: ${DateFormat('dd MMM yyyy').format(DateTime.parse(order.createdAt).toLocal())}",
                        ),
                        pw.Text("Order ID: ${order.id}"),
                      ],
                    ),
                  ],
                ),

                pw.SizedBox(height: 30),
                pw.Divider(),
                pw.SizedBox(height: 20),

                /// PRODUCT TABLE
                pw.Text(
                  "Order Items",
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),

                pw.SizedBox(height: 10),

                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(3),
                    1: const pw.FlexColumnWidth(2),
                    2: const pw.FlexColumnWidth(2),
                    3: const pw.FlexColumnWidth(2),
                  },
                  children: [
                    /// TABLE HEADER
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.blue50,
                      ),
                      children: [
                        _tableCell("Product"),
                        _tableCell("Qty"),
                        _tableCell("Price"),
                        _tableCell("Total"),
                      ],
                    ),

                    /// TABLE ROWS
                    ...order.items.map(
                      (item) => pw.TableRow(
                        children: [
                          _tableCell(item.name),
                          _tableCell(item.qty.toString()),
                          _tableCell("₹${item.price}"),
                          _tableCell("₹${item.total}"),
                        ],
                      ),
                    ),
                  ],
                ),

                pw.SizedBox(height: 25),

                /// PRODUCT IMAGE
                if (productImage != null) ...[
                  pw.Text(
                    "Product Image",
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Image(productImage, height: 100),
                  pw.SizedBox(height: 20),
                ],

                pw.Divider(),

                pw.SizedBox(height: 15),

                /// SUMMARY
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      _summaryRow("Subtotal", subTotal),
                      _summaryRow("Delivery Fee", deliveryFee),
                      _summaryRow("Platform Fee", platformFee),

                      pw.SizedBox(height: 8),

                      pw.Container(
                        padding: const pw.EdgeInsets.all(10),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.grey200,
                          borderRadius: pw.BorderRadius.circular(6),
                        ),
                        child: pw.Text(
                          "Grand Total: ₹$grandTotal",
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                pw.Spacer(),
                pw.Divider(),

                pw.Center(
                  child: pw.Text(
                    "Thank you for shopping with us!",
                    style: const pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.grey700,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );

      final dir = await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/invoice_${order.id}.pdf");

      await file.writeAsBytes(await pdf.save());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invoice saved successfully")),
      );

      await OpenFile.open(file.path);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  /// ================= TABLE CELL HELPER =================
  pw.Widget _tableCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(text, style: const pw.TextStyle(fontSize: 12)),
    );
  }

  pw.Widget _summaryRow(String title, double value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [pw.Text(title), pw.Text("₹$value")],
      ),
    );
  }

  // ================= RETURN API =================

  Future<void> _submitReturnRequest({
    required String reason,
    required String description,
  }) async {
    final token = await _storage.read(key: 'accessToken');

    if (token == null) return;

    await http.post(
      Uri.parse("${ApiConstants.baseURL}returns/request"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "orderId": widget.order.id,
        "productId": widget.selectedItem.productId,
        "quantity": widget.selectedItem.qty,
        "reason": reason,
        "description": description,
        "images": [],
      }),
    );

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Return request submitted")));
  }

  // ================= RETURN DIALOG =================

  void _showReturnDialog() {
    final reasonController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Request Return"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(labelText: "Reason"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: "Description"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.isEmpty) return;

              Navigator.pop(context);

              _submitReturnRequest(
                reason: reasonController.text,
                description: descriptionController.text,
              );
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }

  // ================= UI CARDS & STEPPER =================

  Widget _productHeader() {
    final item = widget.selectedItem;

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: item.image.isNotEmpty
                ? Image.network(
                    item.image,
                    height: 70,
                    width: 70,
                    fit: BoxFit.cover,
                  )
                : _placeholderImage(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Qty: ${item.qty}",
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 6),
                Text(
                  "Order #${widget.order.id}",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cancelledCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Icon(Icons.cancel, color: Colors.red),
          SizedBox(width: 10),
          Text(
            "Order Cancelled",
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _refundCard() {
    final item = widget.selectedItem;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Refund Processed",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Text("Refund Amount - ₹${item.refundAmount.toInt()}"),
        ],
      ),
    );
  }

  Widget _timelineCard() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Order Status",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Column(
            children: List.generate(statusFlow.length, (index) {
              final isActive = index <= currentIndex;
              final isLast = index == statusFlow.length - 1;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      AnimatedBuilder(
                        animation: _controllers[index],
                        builder: (_, __) {
                          return Container(
                            height: 14,
                            width: 14,
                            decoration: BoxDecoration(
                              color: _controllers[index].value > 0
                                  ? Colors.green
                                  : Colors.grey.shade400,
                              shape: BoxShape.circle,
                            ),
                          );
                        },
                      ),
                      if (!isLast)
                        SizedBox(
                          height: 50,
                          width: 2,
                          child: Stack(
                            children: [
                              Container(
                                height: 50,
                                width: 2,
                                color: Colors.grey.shade300,
                              ),
                              Container(
                                height: 50 * _controllers[index].value,
                                width: 2,
                                color: Colors.green,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            statusFlow[index],
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isActive ? Colors.black : Colors.grey,
                            ),
                          ),
                          if (isActive) const SizedBox(height: 4),
                          if (isActive)
                            Text(
                              DateFormat('dd MMM yyyy, hh:mm a').format(
                                DateTime.parse(
                                  widget.order.createdAt,
                                ).toLocal(),
                              ),
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

Widget _placeholderImage() {
  return Container(
    height: 70,
    width: 70,
    color: Colors.grey.shade200,
    child: const Icon(Icons.image_not_supported, color: Colors.grey),
  );
}
