import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:examgo/signup.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // Initialize Firebase

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Exam Go',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const ResponsiveLayout(),
    );
  }
}

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          // Mobile layout
          return const SignupPage();
        } else {
          // Web/Tablet layout with additional padding
          return Scaffold(
            body: Center(
              child: Container(
                width: 400, // Restrict width for a better web layout
                padding: const EdgeInsets.all(20),
                child: const SignupPage(),
              ),
            ),
          );
        }
      },
    );
  }
}
