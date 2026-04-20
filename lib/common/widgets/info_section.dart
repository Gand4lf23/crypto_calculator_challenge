import 'package:flutter/material.dart';
import 'package:crypto_calculator_challenge/common/config/theme/app_text_styles.dart';

class InfoSection extends StatelessWidget {
  final String rateValue;
  final String receivesValue;
  final String timeValue;

  const InfoSection({
    super.key,
    required this.rateValue,
    required this.receivesValue,
    required this.timeValue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _InfoRow(label: 'Tasa estimada', value: rateValue),
        const SizedBox(height: 8),
        _InfoRow(label: 'Recibirás', value: receivesValue),
        const SizedBox(height: 8),
        _InfoRow(label: 'Tiempo estimado', value: timeValue),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.infoLabelTextStyle),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            style: AppTextStyles.infoValueTextStyle,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
