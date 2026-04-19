import 'package:crypto_calculator_challenge/common/config/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class Currency {
  final String id;

  /// ID used when calling the API (may differ from the short display [id]).
  final String apiId;
  final String name;
  final String symbol;
  final String flagAsset;

  const Currency({
    required this.id,
    String? apiId,
    required this.name,
    required this.symbol,
    required this.flagAsset,
  }) : apiId = apiId ?? id;
}

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
          Container(
            width: 60,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey[500],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(isFiat ? 'FIAT' : 'CRIPTO', style: AppTextStyles.titleTextStyle),
          SizedBox(height: 12),
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
                    Image.asset(
                      currency.flagAsset,
                      width: 40,
                      height: 40,
                      fit: BoxFit.contain,
                      errorBuilder: (_, e, _) => CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.amber.withValues(alpha: 0.15),
                        child: Text(
                          currency.id.substring(
                            0,
                            currency.id.length.clamp(0, 2),
                          ),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[800],
                          ),
                        ),
                      ),
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
