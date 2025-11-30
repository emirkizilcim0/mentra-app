import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mentra_app/splash_page.dart';
import 'firebase_options.dart';
import 'routes_manager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'mbti/result_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          print(
            'Building MyApp with dark mode: ${themeProvider.isDarkMode}',
          ); // Debug

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Mentra App',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.deepPurple,
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              scaffoldBackgroundColor: Colors.white,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.deepPurple,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
              scaffoldBackgroundColor: Colors.grey[900],
            ),
            themeMode: themeProvider.isDarkMode
                ? ThemeMode.dark
                : ThemeMode.light,
            initialRoute: '/',
            routes: AppRoutes.routes,
          );
        },
      ),
    );
  }
}

// MyHomePage class'ınız aynı kalacak...
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String backendResponse = "No data yet.";

  Future<void> sendToBackend() async {
    const backendUrl = "https://mentra-app.onrender.com";
    try {
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': 'Mentra User'}),
      );

      final data = jsonDecode(response.body);
      setState(() {
        backendResponse = data["message"];
      });
    } catch (e) {
      setState(() {
        backendResponse = "Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(backendResponse),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: sendToBackend,
              child: const Text("Test Backend"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/document-processor');
              },
              child: const Text("Open Document Processor"),
            ),
          ],
        ),
      ),
    );
  }
}
