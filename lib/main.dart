import 'package:crypto_calculator_challenge/common/config/theme/app_theme.dart';
import 'package:crypto_calculator_challenge/features/calculator/di/calculator_injection.dart';
import 'package:crypto_calculator_challenge/features/calculator/presentation/calculator_screen.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  initCalculator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Crypto Calculator Challenge',
      theme: AppTheme.lightTheme,
      home: const CalculatorScreen(),
    );
  }
}
