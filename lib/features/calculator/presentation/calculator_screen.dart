import 'package:crypto_calculator_challenge/features/calculator/widgets/calculator_widget.dart';
import 'package:flutter/material.dart';

class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: CalculatorWidget());
  }
}
