/// Application-level feature flags and configuration.
///
/// ## Why [useMockExchange] exists
///
/// The official recommendations endpoint
/// (GET /orderbook/public/recommendations) requires **internal numeric IDs**
/// for both the crypto and fiat assets (e.g. `cryptoCurrencyId=1`).
/// However, the catalog routes that would expose these IDs
/// (`/assets`, `/orderbook/public`, etc.) currently return **404**.
///
/// Without a public ID catalog it is impossible to map user-facing symbols
/// (BTC, USDT, BRL …) to the backend's internal identifiers, so every call
/// to the real endpoint fails with:
///   "✖ invalid crypto currency id → at query.cryptoCurrencyId"
///
/// ## Solution
///
/// A [useMockExchange] flag switches the app between two implementations of
/// [ExchangeService]:
///
/// | Flag value | Service used             | Rate source                  |
/// |------------|--------------------------|------------------------------|
/// | `true`     | [MockExchangeService]    | CoinGecko public API (live)  |
/// | `false`    | [RealExchangeService]    | Official recommendations API |
///
/// The mock service uses a hardcoded symbol→CoinGecko-ID map and fetches
/// real-time market rates, so the app stays **fully functional** while the
/// backend gap is unresolved.
///
/// ## Migrating to real mode
///
/// 1. Obtain the internal numeric IDs from the backend team (or a catalog
///    endpoint once it is exposed).
/// 2. Populate [RealExchangeService._cryptoIdMap] and
///    [RealExchangeService._fiatIdMap] with the real values.
/// 3. Set [useMockExchange] = `false` here (or wire it up to a build-time
///    environment variable / `--dart-define`).
///
/// No other code needs to change — the [CalculatorRepository] interface and
/// all layers above it are completely unaffected by the switch.
class AppConfig {
  const AppConfig._();

  // ignore: do_not_use_environment
  static const bool useMockExchange = bool.fromEnvironment(
    'USE_MOCK_EXCHANGE',
    defaultValue: true, // safe default: mock until real IDs are available
  );
}
