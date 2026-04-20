/// Data class representing a selectable currency (fiat or crypto).
///
/// [id] is the short user-facing symbol (e.g. "BRL", "USDT").
/// [apiId] is the identifier sent to the exchange API — it defaults to [id]
/// but may differ for crypto assets (e.g. "TATUM-TRON-USDT").
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
