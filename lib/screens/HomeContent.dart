import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:hungzo_delivery_partner/screens/splash/test.dart';

import '../services/Api/clint.dart';
import 'delivery_map_screen.dart';
import 'delivery_home_screen.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final SocketService socketService = SocketService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String? token;
  String? driverId;
  List<dynamic> incomingOrders = [];
  dynamic currentOrder;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _initializeDriver();
  }

  Future<void> _initializeDriver() async {
    try {
      token = await _storage.read(key: 'accessToken');
      driverId = "69b7aa78dee89d0387362590"; // replace with FirebaseAuth if needed

      if (token != null && driverId != null) {
        // Connect socket with callback
        socketService.connect(driverId!, onNewOrder: (order) {
          setState(() {
            incomingOrders.add(order);
          });
        });

        // Fetch current order
        await fetchCurrentOrder();
      } else {
        print("❌ Token or driver ID missing.");
      }
    } catch (e) {
      print("Initialization error: $e");
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> fetchCurrentOrder() async {
    if (token == null) return;
    try {
      final res = await http.get(
        Uri.parse("https://api.hungzo.in/driver/orders/current"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        print("fetching current order: ${res.body}");

        if (data["order"] != null) {
          setState(() => currentOrder = data["order"]);
        }
      } else {
        print("Server error fetching current order: ${res.statusCode}");
        print("Server error fetching current order: ${res.body}");
      }
    } catch (e) {
      print("Network error fetching current order: $e");
    }
  }

  Future<void> acceptOrder(String orderId) async {
    if (token == null) return;
    try {
      final res = await http.post(
        Uri.parse("https://api.hungzo.in/driver/orders/$orderId/accept"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data["success"]) {
          setState(() {
            currentOrder = data["order"];
            incomingOrders.removeWhere((o) => o["orderId"] == orderId);
          });
        }
      } else {
        print("Server error accepting order: ${res.statusCode}");
        print("Server error accepting order: ${res.body}");
      }
    } catch (e) {
      print("Network error accepting order: $e");
    }
  }

  @override
  void dispose() {
    socketService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          /// 🔹 HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.location_on, size: 20, color: Colors.black54),
                  SizedBox(width: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Lalbag",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        "Lucknow",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  )
                ],
              ),
              Column(
                children: const [
                  CircleAvatar(
                    radius: 22,
                    backgroundImage: NetworkImage(
                        "https://i.pravatar.cc/150?img=12"),
                  ),
                  SizedBox(height: 4),
                  Text("Lucknow", style: TextStyle(fontSize: 12))
                ],
              )
            ],
          ),

          const SizedBox(height: 25),

          /// 🔹 ORDER CARDS (Dynamic)
          SizedBox(
            height: incomingOrders.isEmpty?80:170,
            child: incomingOrders.isEmpty
                ? const Center(child: Text("No incoming orders"))
                : ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: incomingOrders.length,
              separatorBuilder: (_, __) =>
              const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final order = incomingOrders[index];
                return Container(
                  width: 270,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Order #${order["orderId"] ?? ""}"),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(order["address"] ??
                          "Address not available"),
                      const Spacer(),
                      SizedBox(
                        height: 35,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xffFF6B6B),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          onPressed: () =>
                              acceptOrder(order["orderId"]),
                          child: const Text(
                            "Accept",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 40),

          /// 🔹 STATS SECTION
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // const ProgressSection(),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Row(
                      children: [
                        Icon(Icons.check_box, color: Color(0xff1EB980)),
                        SizedBox(width: 6),
                        Text(
                          "60%",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    Text(
                      "Delivered Order increased by",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    SizedBox(height: 15),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber),
                        SizedBox(width: 6),
                        Text(
                          "4.9",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 6),
                        Text(
                          "Rating",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Image.asset(
                "assets/images/money_man.png",
                height: 140,
              ),
            ],
          ),

          const SizedBox(height: 40),

          /// 🔹 PREVIOUS ORDER
          const Text(
            "Previous Order",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        currentOrder == null
            ? const Text("No order available")
            : InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DeliveryMapScreen(
                 currentOrder: currentOrder,
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xffFFF6F6), Color(0xffFFFFFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 🔹 Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Order #${(currentOrder["orderId"]?.toString() ?? "--").substring(
                        0,
                        (currentOrder["orderId"]?.toString().length ?? 0).clamp(0, 8),
                      )}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            currentOrder["orderStatus"] ?? "Unknown",
                            style: const TextStyle(
                              color: Colors.orange,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.location_on, color: Colors.red),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DeliveryMapScreen(
                                currentOrder: currentOrder,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                /// 🔹 Address
                Row(
                  children: [
                    const Icon(Icons.home, size: 18, color: Colors.grey),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        currentOrder["address"]?["full"] ?? "No address",
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                /// 🔹 Items Card
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: List.generate(
                      currentOrder["items"]?.length ?? 0,
                          (index) {
                        final item = currentOrder["items"][index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item["name"] ?? "",
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                              Text(
                                "x${item["quantity"] ?? 0}",
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(width: 8),
                              Text("₹${item["total"] ?? 0}"),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                /// 🔹 Driver Status + Amount
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Amount: ₹${currentOrder["amount"] ?? 0}",
                      style: const TextStyle(fontSize: 12),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        currentOrder["driverStatus"] ?? "Unknown",
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
          const SizedBox(height: 16),


        ],
      ),
    );
  }

  Widget _priceRow(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          Text("₹$value"),
        ],
      ),
    );
  }}