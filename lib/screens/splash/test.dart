import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: DriverOrdersScreen(),
    );
  }
}

/* ================= SOCKET SERVICE ================= */
class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  late IO.Socket socket;
  void Function(Map<String, dynamic>)? onNewOrder;

  void connect(String driverId, {required void Function(Map<String, dynamic>) onNewOrder}) {
    this.onNewOrder = onNewOrder;

    socket = IO.io(
      "https://api.hungzo.in/drivers",
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .enableReconnection()
          .build(),
    );

    socket.onConnect((_) {
      print("✅ Connected: ${socket.id}");
      print("✅ driver id: $driverId");
      socket.emit("joinDriverRoom", driverId);
    });

    socket.onDisconnect((_) => print("❌ Disconnected"));
    socket.onConnectError((err) => print("❌ Connect Error: $err"));
    socket.onError((err) => print("❌ Socket Error: $err"));

    // Listen for incoming orders
    socket.on("newOrder", (data) {
      print("🔥 New Order: $data");
      if (data is Map<String, dynamic>) {
        onNewOrder(data);
      } else if (data is Map) {
        onNewOrder(Map<String, dynamic>.from(data));
      }
    });

    socket.on("orderTaken", (data) => print("⚡ Order Taken: $data"));
    socket.on("orderAssigned", (data) => print("🎯 Order Assigned: $data"));

    socket.connect();
  }

  void dispose() {
    socket.dispose();
  }
}

/* ================= DRIVER ORDERS SCREEN ================= */
class DriverOrdersScreen extends StatefulWidget {
  const DriverOrdersScreen({super.key});

  @override
  State<DriverOrdersScreen> createState() => _DriverOrdersScreenState();
}

class _DriverOrdersScreenState extends State<DriverOrdersScreen> {
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
      // Fetch token from secure storage
      token = await _storage.read(key: 'accessToken');

      // Driver ID
      driverId = "69955e8cc67e65ab49ced5ff";
      // driverId = FirebaseAuth.instance.currentUser?.uid;

      if (token != null && driverId != null) {
        // Connect socket with callback to update UI
        socketService.connect(driverId!, onNewOrder: (order) {
          setState(() {
            incomingOrders.add(order);
          });
        });

        // Fetch current order from API
        await fetchCurrentOrder();
      } else {
        print("❌ Token or driver ID missing. Please login.");
      }
    } catch (e) {
      print("Initialization error: $e");
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  void dispose() {
    socketService.dispose();
    super.dispose();
  }
  /* ================= API CALLS ================= */
  Future<void> fetchCurrentOrder() async {
    if (token == null) return;

    try {
      final res = await http.get(
        Uri.parse("https://api.hungzo.in/driver/orders/current"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data["order"] != null) {
          setState(() => currentOrder = data["order"]);
        }
      } else {
        print("Server error fetching current order: ${res.statusCode}");
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
            // Remove the accepted order from incoming orders
            incomingOrders.removeWhere((o) => o["orderId"] == orderId);
          });
        }
      } else {
        print("Server error accepting order: ${res.statusCode}");
      }
    } catch (e) {
      print("Network error accepting order: $e");
    }
  }

  /* ================= UI ================= */
  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Driver Orders")),
      body: Column(
        children: [
          // CURRENT ORDER
          if (currentOrder != null)
            Container(
              color: Colors.green.shade100,
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "🚚 Current Order",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text("Order ID: ${currentOrder["_id"]}"),
                  Text("Status: ${currentOrder["driverStatus"] ?? 'N/A'}"),
                  Text("Address: ${currentOrder["address"] ?? 'N/A'}"),
                ],
              ),
            ),

          const SizedBox(height: 10),

          // INCOMING ORDERS
          Expanded(
            child: incomingOrders.isEmpty
                ? const Center(child: Text("No incoming orders"))
                : ListView.builder(
              itemCount: incomingOrders.length,
              itemBuilder: (context, index) {
                final order = incomingOrders[index];
                return Card(
                  child: ListTile(
                    title: Text("₹${order["amount"] ?? '0'}"),
                    subtitle: Text(order["address"] ?? 'No address'),
                    trailing: ElevatedButton(
                      onPressed: () => acceptOrder(order["orderId"]),
                      child: const Text("Accept"),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}