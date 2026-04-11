import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FirebaseLoginScreen extends StatefulWidget {
  const FirebaseLoginScreen({super.key});

  @override
  State<FirebaseLoginScreen> createState() => _FirebaseLoginScreenState();
}

class _FirebaseLoginScreenState extends State<FirebaseLoginScreen> {
  String responseText = "";
  bool loading = false;

  Future<void> callApi() async {
    setState(() {
      loading = true;
      responseText = "";
    });

    try {
      final url = Uri.parse(
        "http://10.0.2.2:4000/auth/firebase-login",
      );
      // 👆 Use 10.0.2.2 for Android Emulator
      // Use http://localhost:4000 for iOS simulator

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer MOCK_FIREBASE_TOKEN",
        },
        body: jsonEncode({
          // "phone": "+91 9876543210",
          "role": "DRIVER",
        }),
      );

      setState(() {
        responseText =
        "Status: ${response.statusCode}\n\n${response.body}";
      });
    } catch (e) {
      setState(() {
        responseText = "Error: $e";
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Firebase Login API Test"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: loading ? null : callApi,
              child: const Text("Call API"),
            ),
            const SizedBox(height: 16),
            loading
                ? const CircularProgressIndicator()
                : Expanded(
              child: SingleChildScrollView(
                child: Text(
                  responseText,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
