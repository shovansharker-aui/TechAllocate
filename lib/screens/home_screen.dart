import 'package:flutter/material.dart';
import 'login_screen.dart';

// Legacy compatibility screen. The app now enters through the single
// Employee ID + PIN login and automatically routes by the employee role.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoginScreen();
  }
}
