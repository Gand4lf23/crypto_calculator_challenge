import 'package:crypto_calculator_challenge/common/config/theme/app_text_styles.dart';
import 'package:crypto_calculator_challenge/features/calculator/widgets/convertion_bottomsheet.dart';
import 'package:flutter/material.dart';

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
            Container(width: 1, color: Colors.grey.shade300),
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
        // Swap centrado sobre el divisor
        Positioned(child: _SwapButton(onSwap: onSwap)),
      ],
    );
  }
}

// ── Currency field ─────────────────────────────────────────────────────────────

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
    return TextField(
      controller: _controller,
      readOnly: true,
      onTap: widget.onTap,
      textAlign: widget.flagOnLeft ? TextAlign.start : TextAlign.end,
      style: AppTextStyles.currencyItemTitleTextStyle,
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: TextStyle(
          color: Colors.amber[700],
          fontWeight: FontWeight.w600,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        floatingLabelAlignment: widget.flagOnLeft
            ? FloatingLabelAlignment.center
            : FloatingLabelAlignment.center,
        hintText: 'Seleccionar',
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        prefixIcon: (widget.flagOnLeft && widget.selected != null)
            ? Padding(
                padding: const EdgeInsets.only(left: 12, right: 8),
                child: _CurrencyIcon(
                  flagAsset: widget.selected!.flagAsset,
                  id: widget.selected!.id,
                ),
              )
            : null,
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        suffixIcon: (!widget.flagOnLeft && widget.selected != null)
            ? Padding(
                padding: const EdgeInsets.only(left: 8, right: 12),
                child: _CurrencyIcon(
                  flagAsset: widget.selected!.flagAsset,
                  id: widget.selected!.id,
                ),
              )
            : null,
        suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.amber, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.amber, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.amber, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),
      ),
    );
  }
}

// ── Swap button ────────────────────────────────────────────────────────────────

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
          color: Colors.amber,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withValues(alpha: 0.35),
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

// ── Currency icon with graceful fallback ───────────────────────────────────────

class _CurrencyIcon extends StatelessWidget {
  final String flagAsset;
  final String id;

  const _CurrencyIcon({required this.flagAsset, required this.id});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      flagAsset,
      width: 36,
      height: 36,
      fit: BoxFit.contain,
      errorBuilder: (_, e, _) => CircleAvatar(
        radius: 18,
        backgroundColor: Colors.amber.withValues(alpha: 0.15),
        child: Text(
          id.substring(0, id.length.clamp(0, 2)),
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: Colors.amber[800],
          ),
        ),
      ),
    );
  }
}
