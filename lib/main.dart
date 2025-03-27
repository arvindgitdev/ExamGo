import 'package:examgo/Screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Provider/auth_provider.dart';
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
      ],
      child: Consumer< AuthProvider>(
          builder: (context,authProvider,child){
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Exam Go',
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
              ),
              home: const ResponsiveLayout(child: SplashScreen()), // Apply ResponsiveLayout globally
            );
          }
      ),
    );
  }
}

class ResponsiveLayout extends StatelessWidget {
  final Widget child;

  const ResponsiveLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double screenWidth = MediaQuery.of(context).size.width;
        double paddingValue = screenWidth * 0.005; // 5% padding for all screens

        if (screenWidth < 600) {
          // Mobile layout (adjust font size, padding dynamically)
          return Scaffold(
            body: Padding(
              padding: EdgeInsets.all(paddingValue),
              child: child,
            ),
          );
        } else {
          // Tablet/Web layout (restrict width for better layout)
          return Scaffold(
            body: Center(
              child: Container(
                width: screenWidth * 0.5, // 50% of screen width for larger screens
                constraints: const BoxConstraints(maxWidth: 450), // Max width limit
                padding: EdgeInsets.all(paddingValue),
                child: child,
              ),
            ),
          );
        }
      },
    );
  }
}