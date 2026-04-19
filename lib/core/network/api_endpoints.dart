class ApiEndpoints {
  // ── Official backend ────────────────────────────────────────────────────────
  static const String baseUrl =
      'https://74j6q7lg6a.execute-api.eu-west-1.amazonaws.com/stage';

  /// Requires internal numeric asset IDs.
  /// See [AppConfig.useMockExchange] for context.
  static const String recommendations =
      '$baseUrl/orderbook/public/recommendations';

  // ── Public fallback ──────────────────────────────────────────────────────────
  /// CoinGecko simple-price endpoint used by [MockExchangeService].
  /// No API key required for the free tier.
  /// Docs: https://docs.coingecko.com/reference/simple-price
  static const String coinGeckoSimplePrice =
      'https://api.coingecko.com/api/v3/simple/price';
}
