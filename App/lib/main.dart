import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Test Firestore connection
  try {
    await FirebaseFirestore.instance.collection('test').add({
      'connected': true,
      'timestamp': DateTime.now(),
    });
    print("✅ Firestore write SUCCESS");
  } catch (e) {
    print("❌ Firestore write FAILED: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter + Firebase + Python Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Mentra App Backend Test'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String backendMessage = "No connection yet.";
  String sumResult = "";

  // ⚙️ Adjust this URL — use your computer's local IP if testing on emulator/phone
  final String backendUrl =
      "http://127.0.0.1:5000"; // or "http://192.168.x.x:5000"

  // 🔹 GET request — simple test
  Future<void> fetchHello() async {
    try {
      final response = await http.get(Uri.parse("$backendUrl/api/hello"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          backendMessage = data["message"];
        });
      } else {
        setState(() {
          backendMessage = "Backend error: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        backendMessage = "Connection failed: $e";
      });
    }
  }

  // 🔹 POST request — send data to backend
  Future<void> sendNumbers(int a, int b) async {
    try {
      final response = await http.post(
        Uri.parse("$backendUrl/api/sum"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"a": a, "b": b}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          sumResult = "Sum result: ${data['result']}";
        });
      } else {
        setState(() {
          sumResult = "Backend error: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        sumResult = "Failed to connect: $e";
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchHello(); // connect to backend when app starts
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Firebase + Python Backend Connection Test",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text(
                backendMessage,
                style: const TextStyle(fontSize: 16, color: Colors.blueAccent),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => sendNumbers(5, 7),
                child: const Text("Send Numbers to Backend"),
              ),
              const SizedBox(height: 20),
              Text(sumResult, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
