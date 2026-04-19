import 'package:flutter/services.dart';

class CurrencyFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final stripped = newValue.text.replaceAll(RegExp(r'[^0-9.]'), '');

    final dotCount = '.'.allMatches(stripped).length;
    if (dotCount > 1) return oldValue;

    final parts = stripped.split('.');
    String intPart = parts[0];
    final String? decPart = parts.length > 1
        ? parts[1].substring(0, parts[1].length.clamp(0, 2))
        : null;

    final formattedInt = _formatIntPart(intPart);
    final formatted =
        decPart != null ? '$formattedInt.$decPart' : formattedInt;

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  static String _formatIntPart(String s) {
    if (s.isEmpty) return '';
    s = s.replaceAll(RegExp(r'^0+'), '');
    if (s.isEmpty) s = '0';

    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  static double parse(String formatted) {
    return double.tryParse(formatted.replaceAll(',', '')) ?? 0.0;
  }

  static String formatValue(double value) {
    if (value == 0) return '0';
    if (value < 1) {
      final s = value.toStringAsFixed(8);
      return s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    }
    final parts = value.toStringAsFixed(2).split('.');
    return '${_formatIntPart(parts[0])}.${parts[1]}';
  }
}
