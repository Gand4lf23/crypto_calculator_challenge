import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:crypto_calculator_challenge/core/error/failures.dart';
import 'package:crypto_calculator_challenge/core/network/api_endpoints.dart';
import 'package:crypto_calculator_challenge/data/services/exchange_service.dart';

/// Fallback [ExchangeService] that fetches live rates from the CoinGecko
/// public API instead of the official recommendations endpoint.
///
/// ## Why this exists
///
/// The official endpoint requires **internal numeric asset IDs**
/// (e.g. `cryptoCurrencyId=1`) that are not exposed by any public catalog
/// route. This service bridges that gap by:
///
/// 1. Mapping the app's string identifiers to CoinGecko asset slugs via
///    [_cryptoIdMap].
/// 2. Calling the free CoinGecko simple-price endpoint — no API key needed.
/// 3. Returning the `fiatToCryptoExchangeRate` in the same format the rest of
///    the app expects, so no other layer needs to change.
///
/// ## Extending support
///
/// To add a new crypto asset, add an entry to [_cryptoIdMap] where the key is
/// the string used by the app's [Currency.apiId] and the value is the
/// corresponding CoinGecko coin ID (find it at coingecko.com).
///
/// To add a new fiat currency, add an entry to [_fiatSymbolMap] where the key
/// is the app's symbol (uppercase) and the value is CoinGecko's lowercase
/// currency code (usually identical).
class MockExchangeService implements ExchangeService {
  final http.Client client;

  MockExchangeService({required this.client});

  // ── Symbol → CoinGecko ID mappings ─────────────────────────────────────────

  /// Maps app-internal crypto identifiers to CoinGecko coin IDs.
  ///
  /// The app uses [Currency.apiId] as the crypto identifier, which may differ
  /// from the user-facing symbol (e.g. "TATUM-TRON-USDT" vs "USDT").
  /// Extend this map when new crypto assets are added to the catalog.
  static const Map<String, String> _cryptoIdMap = {
    'TATUM-TRON-USDT': 'tether',
    'USDT': 'tether',
    'TATUM-TRON-USDC': 'usd-coin',
    'USDC': 'usd-coin',
    'BTC': 'bitcoin',
    'ETH': 'ethereum',
  };

  /// Maps app-internal fiat symbols (uppercase) to CoinGecko currency codes
  /// (lowercase). Usually a simple toLowerCase() suffices, but some exotic
  /// currencies may need an explicit mapping.
  static const Map<String, String> _fiatSymbolMap = {
    'BRL': 'brl',
    'COP': 'cop',
    'PEN': 'pen',
    'VES': 'ves',
    'USD': 'usd',
    'EUR': 'eur',
  };

  // ── ExchangeService ─────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, double>> getExchangeRate({
    required int type,
    required String cryptoCurrencyId,
    required String fiatCurrencyId,
    required double amount,
    required String amountCurrencyId,
  }) async {
    try {
      final coinGeckoId = _cryptoIdMap[cryptoCurrencyId];
      if (coinGeckoId == null) {
        return Left(
          ServerFailure(
            message:
                'Unsupported crypto asset "$cryptoCurrencyId". '
                'Add it to MockExchangeService._cryptoIdMap.',
          ),
        );
      }

      final vsCurrency =
          _fiatSymbolMap[fiatCurrencyId.toUpperCase()] ??
          fiatCurrencyId.toLowerCase();

      final uri = Uri.parse(ApiEndpoints.coinGeckoSimplePrice).replace(
        queryParameters: {
          'ids': coinGeckoId,
          'vs_currencies': vsCurrency,
        },
      );

      debugPrint('[MockExchangeService] GET $uri');

      final response = await client.get(uri);

      if (response.statusCode != 200) {
        return Left(
          ServerFailure(
            message:
                'CoinGecko returned ${response.statusCode}: ${response.body}',
          ),
        );
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      debugPrint('[MockExchangeService] response: $json');

      // Response shape: { "tether": { "brl": 5.68 } }
      final pricePerCrypto =
          (json[coinGeckoId]?[vsCurrency] as num?)?.toDouble();

      if (pricePerCrypto == null || pricePerCrypto == 0) {
        return Left(
          ServerFailure(
            message:
                'CoinGecko returned no price for $coinGeckoId/$vsCurrency',
          ),
        );
      }

      // CoinGecko gives: fiatPerCrypto (e.g. 5.68 BRL per 1 USDT).
      // The rest of the app expects fiatToCryptoExchangeRate = cryptoPerFiat.
      final fiatToCryptoExchangeRate = 1.0 / pricePerCrypto;
      debugPrint(
        '[MockExchangeService] rate: 1 $fiatCurrencyId = '
        '$fiatToCryptoExchangeRate $cryptoCurrencyId',
      );

      return Right(fiatToCryptoExchangeRate);
    } catch (e) {
      return Left(ServerFailure(message: 'MockExchangeService error: $e'));
    }
  }
}
