import 'package:crypto_calculator_challenge/common/config/theme/app_text_styles.dart';
import 'package:crypto_calculator_challenge/common/widgets/currency_icon.dart';
import 'package:crypto_calculator_challenge/data/models/currency.dart';
import 'package:flutter/material.dart';

/// Modal bottom sheet that displays a list of selectable currencies.
///
/// The static currency catalogs ([fiatCurrencies] and [cryptoCurrencies]) live
/// here so they're co-located with the UI that presents them.
class ConvertionBottomSheet extends StatelessWidget {
  final bool isFiat;
  final ValueChanged<Currency> onSelected;

  static const List<Currency> fiatCurrencies = [
    Currency(
      id: 'BRL',
      name: 'Real Brasileño',
      symbol: 'R\$',
      flagAsset: 'assets/icons/BRL.png',
    ),
    Currency(
      id: 'COP',
      name: 'Peso Colombiano',
      symbol: '\$',
      flagAsset: 'assets/icons/COP.png',
    ),
    Currency(
      id: 'PEN',
      name: 'Sol Peruano',
      symbol: 'S/',
      flagAsset: 'assets/icons/PEN.png',
    ),
    Currency(
      id: 'VES',
      name: 'Bolívar Venezolano',
      symbol: 'Bs.',
      flagAsset: 'assets/icons/VES.png',
    ),
  ];

  static const List<Currency> cryptoCurrencies = [
    Currency(
      id: 'USDT',
      apiId: 'TATUM-TRON-USDT',
      name: 'Tether',
      symbol: 'USDT',
      flagAsset: 'assets/icons/TATUM-TRON-USDT.png',
    ),
    Currency(
      id: 'USDC',
      apiId: 'TATUM-TRON-USDC',
      name: 'USD Coin',
      symbol: 'USDC',
      flagAsset: 'assets/icons/USDC.png',
    ),
  ];

  const ConvertionBottomSheet({
    super.key,
    required this.isFiat,
    required this.onSelected,
  });

  /// Convenience factory that opens the sheet and returns the selection.
  static Future<Currency?> show(BuildContext context, {required bool isFiat}) {
    return showModalBottomSheet<Currency>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ConvertionBottomSheet(
        isFiat: isFiat,
        onSelected: (currency) => Navigator.pop(context, currency),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencies = isFiat ? fiatCurrencies : cryptoCurrencies;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Drag handle ────────────────────────────────────────────
          Container(
            width: 60,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey[500],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // ── Section title ──────────────────────────────────────────
          Text(isFiat ? 'FIAT' : 'CRIPTO', style: AppTextStyles.titleTextStyle),
          const SizedBox(height: 12),

          // ── Currency list ──────────────────────────────────────────
          ...currencies.map(
            (currency) => InkWell(
              onTap: () => onSelected(currency),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    CurrencyIcon(
                      flagAsset: currency.flagAsset,
                      id: currency.id,
                      size: 40,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currency.id,
                          style: AppTextStyles.currencyItemTitleTextStyle,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${currency.name} (${currency.symbol})',
                          style: AppTextStyles.currencyItemSubtitleTextStyle,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
