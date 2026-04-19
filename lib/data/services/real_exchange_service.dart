import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import 'package:crypto_calculator_challenge/core/error/exceptions.dart';
import 'package:crypto_calculator_challenge/core/error/failures.dart';
import 'package:crypto_calculator_challenge/core/network/api_client.dart';
import 'package:crypto_calculator_challenge/core/network/api_endpoints.dart';
import 'package:crypto_calculator_challenge/data/services/exchange_service.dart';

/// Production [ExchangeService] that calls the official recommendations API.
///
/// ## Current limitation — internal asset IDs
///
/// The endpoint requires **numeric** asset IDs (e.g. `cryptoCurrencyId=1`),
/// but no public catalog route exposes these IDs. The maps below contain
/// placeholder values that must be replaced once the backend team documents
/// the real IDs or exposes a `/assets` catalog endpoint.
///
/// Until then, keep [AppConfig.useMockExchange] = `true` and use
/// [MockExchangeService] instead.
///
/// ## Migration checklist
///
/// 1. Obtain real IDs from the backend (catalog endpoint or documentation).
/// 2. Update [_cryptoIdMap] and [_fiatIdMap] with the correct numeric values.
/// 3. Set `AppConfig.useMockExchange = false`.
class RealExchangeService implements ExchangeService {
  final ApiClient apiClient;

  RealExchangeService({required this.apiClient});

  // ── Internal asset ID maps ──────────────────────────────────────────────────
  //
  // TODO(backend): replace placeholder IDs with real values once the catalog
  //               endpoint (/assets or /orderbook/public) is available.
  //               Tracking issue: assign when known.

  /// Maps app-internal crypto identifiers to the backend's numeric IDs.
  static const Map<String, String> _cryptoIdMap = {
    'TATUM-TRON-USDT': '1', // ⚠ placeholder — replace with real ID
    'USDT': '1', //            ⚠ placeholder — replace with real ID
    'TATUM-TRON-USDC': '4', // ⚠ placeholder — replace with real ID
    'USDC': '4', //            ⚠ placeholder — replace with real ID
    'BTC': '2', //             ⚠ placeholder — replace with real ID
    'ETH': '3', //             ⚠ placeholder — replace with real ID
  };

  /// Maps app-internal fiat symbols to the backend's numeric IDs.
  static const Map<String, String> _fiatIdMap = {
    'BRL': '100', // ⚠ placeholder — replace with real ID
    'COP': '101', // ⚠ placeholder — replace with real ID
    'PEN': '102', // ⚠ placeholder — replace with real ID
    'VES': '103', // ⚠ placeholder — replace with real ID
    'USD': '104', // ⚠ placeholder — replace with real ID
    'EUR': '105', // ⚠ placeholder — replace with real ID
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
      final numericCryptoId = _cryptoIdMap[cryptoCurrencyId];
      if (numericCryptoId == null) {
        return Left(
          ServerFailure(
            message:
                'Unknown crypto asset "$cryptoCurrencyId". '
                'Update RealExchangeService._cryptoIdMap.',
          ),
        );
      }

      final numericFiatId = _fiatIdMap[fiatCurrencyId.toUpperCase()];
      if (numericFiatId == null) {
        return Left(
          ServerFailure(
            message:
                'Unknown fiat currency "$fiatCurrencyId". '
                'Update RealExchangeService._fiatIdMap.',
          ),
        );
      }

      final numericAmountId =
          _fiatIdMap[amountCurrencyId.toUpperCase()] ??
          _cryptoIdMap[amountCurrencyId] ??
          amountCurrencyId;

      final queryParams = {
        'type': type.toString(),
        'cryptoCurrencyId': numericCryptoId,
        'fiatCurrencyId': numericFiatId,
        'amount': amount == amount.truncateToDouble()
            ? amount.toInt().toString()
            : amount.toString(),
        'amountCurrencyId': numericAmountId,
      };

      debugPrint('[RealExchangeService] query: $queryParams');

      final response = await apiClient.get(
        ApiEndpoints.recommendations,
        queryParameters: queryParams,
      );

      debugPrint('[RealExchangeService] response: $response');

      final data = response['data'];
      if (data == null) {
        return Left(ServerFailure(message: 'Missing data in response'));
      }

      final byPrice = data['byPrice'];
      if (byPrice == null) {
        return Left(
          ServerFailure(message: 'No price available for this pair'),
        );
      }

      final rate = byPrice['fiatToCryptoExchangeRate'];
      if (rate == null) {
        return Left(ServerFailure(message: 'Missing exchange rate'));
      }

      return Right((rate as num).toDouble());
    } on ServerException catch (e) {
      final msg = e.body != null
          ? '[${e.statusCode}] ${e.body}'
          : 'Server error (${e.statusCode})';
      return Left(ServerFailure(message: msg));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
