import 'package:dartz/dartz.dart';
import 'package:crypto_calculator_challenge/core/error/failures.dart';

/// Data-layer abstraction for fetching an exchange rate between a crypto asset
/// and a fiat currency.
///
/// Two concrete implementations exist:
/// - [RealExchangeService] — calls the official recommendations endpoint.
/// - [MockExchangeService] — falls back to CoinGecko when the official
///   endpoint is unavailable or its internal asset IDs are unknown.
///
/// The active implementation is chosen at startup based on
/// [AppConfig.useMockExchange] and injected via [GetIt].
/// All layers above the repository are unaware of which service is in use.
abstract class ExchangeService {
  /// Returns the **fiat-to-crypto exchange rate** (crypto units per 1 fiat
  /// unit) for the requested currency pair.
  ///
  /// Parameters mirror the official recommendations API:
  /// - [type] — conversion direction: `0` = crypto→fiat input,
  ///   `1` = fiat→crypto input.
  /// - [cryptoCurrencyId] — string identifier for the crypto asset
  ///   (e.g. `"TATUM-TRON-USDT"`).
  /// - [fiatCurrencyId] — ISO-style symbol for the fiat currency
  ///   (e.g. `"BRL"`).
  /// - [amount] — quantity being converted.
  /// - [amountCurrencyId] — identifier of the currency [amount] is expressed
  ///   in.
  ///
  /// Returns `Right(rate)` on success, or `Left(Failure)` on any error.
  Future<Either<Failure, double>> getExchangeRate({
    required int type,
    required String cryptoCurrencyId,
    required String fiatCurrencyId,
    required double amount,
    required String amountCurrencyId,
  });
}
