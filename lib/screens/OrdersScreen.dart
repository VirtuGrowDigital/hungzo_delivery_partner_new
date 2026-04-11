import 'package:flutter/material.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        /// 🌊 BACKGROUND WAVE
        Positioned(
          top: 120,
          left: -80,
          right: -80,
          child: Container(
            height: 500,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.teal.withOpacity(.35),
                  Colors.teal.withOpacity(.15),
                ],
              ),
              borderRadius: BorderRadius.circular(300),
            ),
          ),
        ),

        Column(
          children: [
            const SizedBox(height: 16),

            /// 🔝 APP BAR (FAKE)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Text(
                    "Orders",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  const CircleAvatar(
                    radius: 22,
                    backgroundImage: NetworkImage(
                      "https://i.pravatar.cc/150?img=12",
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView(
                padding:
                const EdgeInsets.symmetric(horizontal: 20),
                children: const [
                  OrderCard(orderId: "#11250", status: "Delivered"),
                  OrderCard(orderId: "#11251", status: "Skip"),
                  OrderCard(orderId: "#11252", status: "Delivered"),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
class OrderCard extends StatelessWidget {
  final String orderId;
  final String status;

  const OrderCard({
    super.key,
    required this.orderId,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final bool delivered = status.toLowerCase() == "delivered";

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            color: Colors.black.withOpacity(.05),
          )
        ],
      ),
      child: Row(
        children: [
          /// ORDER TEXT
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Order No.",
                style: TextStyle(fontSize: 18),
              ),
              Text(
                orderId,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const Spacer(),

          /// STATUS BADGE
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: delivered
                  ? Colors.green.withOpacity(.15)
                  : Colors.grey.withOpacity(.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: delivered ? Colors.green : Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}