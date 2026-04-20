import 'package:flutter/material.dart';
import 'package:crypto_calculator_challenge/common/config/theme/app_colors.dart';

class CurrencyIcon extends StatelessWidget {
  final String flagAsset;
  final String id;
  final double size;

  const CurrencyIcon({
    super.key,
    required this.flagAsset,
    required this.id,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      flagAsset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => CircleAvatar(
        radius: size / 2,
        backgroundColor: AppColors.primaryColor.withValues(alpha: 0.15),
        child: Text(
          id.substring(0, id.length.clamp(0, 2)),
          style: TextStyle(
            fontSize: size * 0.25,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryColor,
          ),
        ),
      ),
    );
  }
}
