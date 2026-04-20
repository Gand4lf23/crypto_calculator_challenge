import 'package:flutter/material.dart';

/// Full-width elevated button used as the primary CTA across the app.
///
/// Styling is inherited from [ElevatedButtonThemeData] defined in
/// [AppTheme.lightTheme], so it automatically picks up the brand colors.
class MainButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const MainButton({super.key, required this.text, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(onPressed: onPressed, child: Text(text)),
    );
  }
}
