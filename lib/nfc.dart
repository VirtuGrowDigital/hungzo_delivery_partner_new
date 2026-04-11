import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Iso7816ReaderScreen(),
    );
  }
}

class Iso7816ReaderScreen extends StatefulWidget {
  const Iso7816ReaderScreen({super.key});

  @override
  State<Iso7816ReaderScreen> createState() => _Iso7816ReaderScreenState();
}

class _Iso7816ReaderScreenState extends State<Iso7816ReaderScreen> {
  static const platform = MethodChannel('iso7816_nfc');

  String result = "Tap card near phone to read ISO7816";

  @override
  void initState() {
    super.initState();

    platform.setMethodCallHandler((call) async {
      if (call.method == "readIso7816") {
        setState(() => result = call.arguments.toString());
      }
    });
  }

  Future<void> startReading() async {
    await platform.invokeMethod('startReader');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ISO7816 Full Reader")),
      floatingActionButton: FloatingActionButton(
        onPressed: startReading,
        child: const Icon(Icons.nfc),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SelectableText(result),
      ),
    );
  }
}
