import 'package:crypto_calculator_challenge/features/calculator/cubit/calculator_cubit.dart';
import 'package:crypto_calculator_challenge/features/calculator/di/calculator_injection.dart';
import 'package:crypto_calculator_challenge/features/calculator/widgets/calculator_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CalculatorCubit>(),
      child: Scaffold(
        body: Stack(
          children: [
            // Dual-color background
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(color: Theme.of(context).primaryColor),
                ),
                Expanded(flex: 7, child: Container(color: Colors.grey[100])),
              ],
            ),
            // Calculator Card centered
            const SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: CalculatorWidget(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
