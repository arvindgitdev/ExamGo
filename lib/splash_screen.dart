import 'package:examgo/Login_page.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Animation Controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // Animation duration
    )..forward(); // Start animation

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    // Navigate to next page after splash screen
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => ResponsiveLayout(child: LoginPage()),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose animation controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo with Fade-in Effect
            FadeTransition(
              opacity: _fadeAnimation,
              child: Image.asset(
                'assets/icon/icon.png', // Replace with your actual icon
                width: 150,
              ),
            ),
            const SizedBox(height: 20),

            // Welcome Text with Fade-in
            FadeTransition(
              opacity: _fadeAnimation,
              child: const Text(
                'Welcome to \nExamGo',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Subtitle with Fade-in
            FadeTransition(
              opacity: _fadeAnimation,
              child: const Text(
                'Your Smart Exam Partner',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black54,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Loading Indicator
           /* FadeTransition(
              opacity: _fadeAnimation,
              child: const CircularProgressIndicator(
                color: Colors.blue, // Change color if needed
              ),
            ),*/
          ],
        ),
      ),
    );
  }
}
