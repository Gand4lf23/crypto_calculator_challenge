import 'package:crypto_calculator_challenge/common/config/theme/app_text_styles.dart';
import 'package:crypto_calculator_challenge/common/utils/currency_formatter.dart';
import 'package:crypto_calculator_challenge/common/widgets/main_button.dart';
import 'package:crypto_calculator_challenge/features/calculator/cubit/calculator_cubit.dart';
import 'package:crypto_calculator_challenge/features/calculator/cubit/calculator_state.dart';
import 'package:crypto_calculator_challenge/features/calculator/widgets/convertion_bottomsheet.dart';
import 'package:crypto_calculator_challenge/features/calculator/widgets/currency_converter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CalculatorWidget extends StatefulWidget {
  const CalculatorWidget({super.key});

  @override
  State<CalculatorWidget> createState() => _CalculatorWidgetState();
}

class _CalculatorWidgetState extends State<CalculatorWidget> {
  /// true  → Tengo = fiat,   Quiero = crypto  (API type 1: fiat→crypto)
  /// false → Tengo = crypto, Quiero = fiat    (API type 0: crypto→fiat)
  bool _isFiatFirst = true;

  Currency? _tengoSelected;
  Currency? _quieroSelected;

  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-select defaults so the amount field shows a prefix immediately.
    _tengoSelected = ConvertionBottomSheet.fiatCurrencies.first;
    _quieroSelected = ConvertionBottomSheet.cryptoCurrencies.first;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  // ── Sheet ──────────────────────────────────────────────────────────────────

  Future<void> _openSheet({required bool isTengo}) async {
    final isFiat = isTengo ? _isFiatFirst : !_isFiatFirst;
    final selected = await ConvertionBottomSheet.show(context, isFiat: isFiat);
    if (selected != null && mounted) {
      setState(() {
        if (isTengo) {
          _tengoSelected = selected;
        } else {
          _quieroSelected = selected;
        }
      });
    }
  }

  // ── Swap ───────────────────────────────────────────────────────────────────

  void _swap() {
    final currentState = context.read<CalculatorCubit>().state;

    setState(() {
      _isFiatFirst = !_isFiatFirst;
      final tmp = _tengoSelected;
      _tengoSelected = _quieroSelected;
      _quieroSelected = tmp;

      // If a result is already showing, seed the amount field with it so the
      // user immediately sees the inverse conversion on recalculate.
      if (currentState is CalculatorLoaded) {
        _amountController.text = CurrencyFormatter.formatValue(
          currentState.convertedAmount,
        );
      }
    });

    // Trigger an automatic recalculation with the swapped pair + new amount.
    if (currentState is CalculatorLoaded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _onCalculate();
      });
    }
  }

  // ── Calculate ──────────────────────────────────────────────────────────────

  void _onCalculate() {
    final amount = CurrencyFormatter.parse(_amountController.text);
    if (amount <= 0 || _tengoSelected == null || _quieroSelected == null)
      return;

    final fiatCurrency = _isFiatFirst ? _tengoSelected! : _quieroSelected!;
    final cryptoCurrency = _isFiatFirst ? _quieroSelected! : _tengoSelected!;

    context.read<CalculatorCubit>().calculateExchange(
      type: _isFiatFirst ? 1 : 0,
      cryptoCurrencyId: cryptoCurrency.apiId,
      fiatCurrencyId: fiatCurrency.apiId,
      amount: amount,
      amountCurrencyId: _isFiatFirst
          ? fiatCurrency.apiId
          : cryptoCurrency.apiId,
    );
  }

  // ── Error dialog ───────────────────────────────────────────────────────────

  void _showErrorDialog(BuildContext context, String message) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        contentPadding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Colors.amber,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Error de conversión',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
            ),
          ],
        ),
        content: Text(message, style: const TextStyle(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(
              'Entendido',
              style: TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final amberBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Colors.amber, width: 1.5),
    );

    // BlocListener wraps the entire card so it uses the widget's own
    // BuildContext (guaranteed to sit below a Navigator) rather than the
    // nested context inside BlocConsumer. addPostFrameCallback ensures the
    // dialog is shown after the current frame settles.
    return BlocListener<CalculatorCubit, CalculatorState>(
      listenWhen: (previous, current) =>
          current is CalculatorError && previous is! CalculatorError,
      listener: (_, state) {
        if (state is CalculatorError) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _showErrorDialog(context, state.message);
          });
        }
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Currency Converter ────────────────────────────────────
              CurrencyConverter(
                tengoSelected: _tengoSelected,
                quieroSelected: _quieroSelected,
                onTengoTap: () => _openSheet(isTengo: true),
                onQuieroTap: () => _openSheet(isTengo: false),
                onSwap: _swap,
              ),

              const SizedBox(height: 16),

              // ── Amount input ──────────────────────────────────────────
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  CurrencyFormatter(),
                ],
                decoration: InputDecoration(
                  // Label fijo arriba
                  labelText: 'Monto',
                  labelStyle: TextStyle(
                    color: Colors.amber[700],
                    fontWeight: FontWeight.w600,
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.always,

                  // Prefix siempre negro
                  prefixText: _tengoSelected != null
                      ? '${_tengoSelected!.id}  '
                      : null,
                  prefixStyle: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),

                  // Hint opcional (placeholder interno)
                  hintText: _tengoSelected == null ? '' : '0',
                  hintStyle: TextStyle(color: Colors.grey[400]),

                  border: amberBorder,
                  enabledBorder: amberBorder,
                  focusedBorder: amberBorder.copyWith(
                    borderSide: const BorderSide(color: Colors.amber, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── Info section — animated on new results ─────────────────
              BlocBuilder<CalculatorCubit, CalculatorState>(
                builder: (context, state) {
                  String rateValue = '—';
                  String receivesValue = '—';
                  const String timeValue = 'Inmediato';

                  if (state is CalculatorLoading) {
                    rateValue = 'Calculando...';
                    receivesValue = 'Calculando...';
                  } else if (state is CalculatorLoaded) {
                    final tengoId = _tengoSelected?.id ?? '';
                    final quieroId = _quieroSelected?.id ?? '';
                    final rate = state.exchangeRate; // cryptoPerFiat

                    // Show "1 Tengo = X Quiero" in the direction of the input.
                    if (_isFiatFirst) {
                      rateValue =
                          '1 $tengoId = ${CurrencyFormatter.formatValue(rate)} $quieroId';
                    } else {
                      rateValue =
                          '1 $tengoId = ${CurrencyFormatter.formatValue(1 / rate)} $quieroId';
                    }

                    receivesValue =
                        '${CurrencyFormatter.formatValue(state.convertedAmount)} $quieroId';
                  }

                  // AnimatedSwitcher animates each new result in with a
                  // fade + upward slide. The key changes whenever the
                  // calculated values change (or on loading/initial).
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    switchInCurve: Curves.easeOut,
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position:
                            Tween<Offset>(
                              begin: const Offset(0, 0.2),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOut,
                              ),
                            ),
                        child: child,
                      ),
                    ),
                    child: _InfoSection(
                      key: state is CalculatorLoaded
                          ? ValueKey(
                              '${state.exchangeRate}_${state.convertedAmount}',
                            )
                          : state is CalculatorLoading
                          ? const ValueKey('loading')
                          : const ValueKey('initial'),
                      rateValue: rateValue,
                      receivesValue: receivesValue,
                      timeValue: timeValue,
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // ── Convert button ────────────────────────────────────────
              Align(
                alignment: Alignment.center,
                child: FractionallySizedBox(
                  widthFactor: 0.9,
                  child: MainButton(text: 'Convertir', onPressed: _onCalculate),
                ),
              ),
            ],
          ),
        ),
      ), // Card
    ); // BlocListener
  }
}

// ── Info section ───────────────────────────────────────────────────────────────

class _InfoSection extends StatelessWidget {
  final String rateValue;
  final String receivesValue;
  final String timeValue;

  const _InfoSection({
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
