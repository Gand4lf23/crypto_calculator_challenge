import 'package:crypto_calculator_challenge/common/config/theme/app_colors.dart';
import 'package:crypto_calculator_challenge/common/config/theme/app_text_styles.dart';
import 'package:crypto_calculator_challenge/common/widgets/currency_icon.dart';
import 'package:crypto_calculator_challenge/data/models/currency.dart';
import 'package:flutter/material.dart';

/// Displays two tappable currency selector fields ("Tengo" / "Quiero")
/// with a central animated swap button.
class CurrencyConverter extends StatelessWidget {
  final Currency? tengoSelected;
  final Currency? quieroSelected;
  final VoidCallback onTengoTap;
  final VoidCallback onQuieroTap;
  final VoidCallback onSwap;

  const CurrencyConverter({
    super.key,
    this.tengoSelected,
    this.quieroSelected,
    required this.onTengoTap,
    required this.onQuieroTap,
    required this.onSwap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Row(
          children: [
            Expanded(
              child: _CurrencyField(
                label: 'Tengo',
                selected: tengoSelected,
                onTap: onTengoTap,
                flagOnLeft: true,
              ),
            ),
            Container(width: 1, color: AppColors.divider),
            Expanded(
              child: _CurrencyField(
                label: 'Quiero',
                selected: quieroSelected,
                onTap: onQuieroTap,
                flagOnLeft: false,
              ),
            ),
          ],
        ),
        // Swap button centred on the divider
        Positioned(child: _SwapButton(onSwap: onSwap)),
      ],
    );
  }
}

// ── Currency selector field ──────────────────────────────────────────────────

class _CurrencyField extends StatefulWidget {
  final String label;
  final Currency? selected;
  final VoidCallback onTap;

  /// true  → [flag][ticker]  (Tengo side)
  /// false → [ticker][flag]  (Quiero side — mirror layout)
  final bool flagOnLeft;

  const _CurrencyField({
    required this.label,
    required this.onTap,
    required this.flagOnLeft,
    this.selected,
  });

  @override
  State<_CurrencyField> createState() => _CurrencyFieldState();
}

class _CurrencyFieldState extends State<_CurrencyField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.selected?.id ?? '');
  }

  @override
  void didUpdateWidget(covariant _CurrencyField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected != oldWidget.selected) {
      _controller.text = widget.selected?.id ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(24),
      borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.5),
    );

    // Build prefix: flag (left field) or chevron (right field)
    Widget? prefixIcon;
    if (widget.flagOnLeft && widget.selected != null) {
      prefixIcon = Padding(
        padding: const EdgeInsets.only(left: 16, right: 8),
        child: CurrencyIcon(
          flagAsset: widget.selected!.flagAsset,
          id: widget.selected!.id,
        ),
      );
    } else if (!widget.flagOnLeft) {
      prefixIcon = const Padding(
        padding: EdgeInsets.only(left: 4),
        child: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: AppColors.primaryColor,
          size: 22,
        ),
      );
    }

    // Build suffix: chevron (left field) or flag (right field)
    Widget? suffixIcon;
    if (widget.flagOnLeft) {
      suffixIcon = const Padding(
        padding: EdgeInsets.only(right: 4),
        child: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: AppColors.primaryColor,
          size: 22,
        ),
      );
    } else if (!widget.flagOnLeft && widget.selected != null) {
      suffixIcon = Padding(
        padding: const EdgeInsets.only(left: 8, right: 16),
        child: CurrencyIcon(
          flagAsset: widget.selected!.flagAsset,
          id: widget.selected!.id,
        ),
      );
    }

    return TextField(
      controller: _controller,
      readOnly: true,
      onTap: widget.onTap,
      textAlign: widget.flagOnLeft ? TextAlign.start : TextAlign.end,
      style: AppTextStyles.currencyItemTitleTextStyle,
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: AppTextStyles.fieldLabelTextStyle,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        floatingLabelAlignment: FloatingLabelAlignment.center,
        hintStyle: AppTextStyles.fieldHintTextStyle,
        prefixIcon: prefixIcon,
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        suffixIcon: suffixIcon,
        suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        border: primaryBorder,
        enabledBorder: primaryBorder,
        focusedBorder: primaryBorder,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
    );
  }
}

// ── Swap button ──────────────────────────────────────────────────────────────

class _SwapButton extends StatefulWidget {
  final VoidCallback onSwap;

  const _SwapButton({required this.onSwap});

  @override
  State<_SwapButton> createState() => _SwapButtonState();
}

class _SwapButtonState extends State<_SwapButton> {
  double _turns = 0;

  void _handleTap() {
    widget.onSwap();
    setState(() => _turns += 0.5); // 180° per tap
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withValues(alpha: 0.35),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: AnimatedRotation(
          turns: _turns,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          child: const Icon(
            Icons.swap_horiz_rounded,
            color: Colors.white,
            size: 36,
          ),
        ),
      ),
    );
  }
}
