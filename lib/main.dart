import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'pages/homepage.dart';
import 'pages/iot.dart';
import 'pages/login.dart';
import 'pages/profile.dart';
import 'pages/reminder.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // Initialize Firebase
    await Firebase.initializeApp(// Ensure correct options here
        );
    print("Firebase initialized successfully.");
  } catch (e) {
    print("Firebase initialization failed: $e");
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(), // Ensure you're calling the correct class
    );
  }
}
