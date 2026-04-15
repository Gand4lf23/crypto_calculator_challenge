import 'package:crypto_calculator_challenge/common/widgets/main_button.dart';
import 'package:crypto_calculator_challenge/features/calculator/widgets/currency_converter.dart';
import 'package:flutter/material.dart';

class CalculatorWidget extends StatelessWidget {
  const CalculatorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          CurrencyConverter(),
          TextField(),
          Text('Tasa estimada'),
          Text('Recibirás'),
          Text('Tiempo estimado'),
          MainButton(text: 'Cambiar', onPressed: () {}),
        ],
      ),
    );
  }
}
