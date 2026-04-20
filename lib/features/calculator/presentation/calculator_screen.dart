import 'package:crypto_calculator_challenge/common/config/theme/app_colors.dart';
import 'package:crypto_calculator_challenge/features/calculator/cubit/calculator_cubit.dart';
import 'package:crypto_calculator_challenge/features/calculator/di/calculator_injection.dart';
import 'package:crypto_calculator_challenge/features/calculator/widgets/calculator_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    // Sphere diameter = 90 % of screen height.
    final sphereDiameter = screenHeight * 1.15;

    return BlocProvider(
      create: (_) => sl<CalculatorCubit>(),
      child: Scaffold(
        body: Stack(
          children: [
            // ── Plain background ──────────────────────────────────────
            Container(color: AppColors.backgroundColor),

            // ── Decorative sphere ─────────────────────────────────────
            // Positioned on the right, slightly above centre.
            // It shows slightly less than the left half (the right half
            // is off-screen).
            Positioned(
              right: -(sphereDiameter * 0.8),
              top: (screenHeight - sphereDiameter) / 2 - screenHeight * 0.1,
              child: Container(
                width: sphereDiameter,
                height: sphereDiameter,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryColor,
                ),
              ),
            ),

            // ── Calculator card — centred ─────────────────────────────
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
