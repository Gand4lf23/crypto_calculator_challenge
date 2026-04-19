class RecommendationResponse {
  final double fiatToCryptoExchangeRate;

  RecommendationResponse({required this.fiatToCryptoExchangeRate});

  factory RecommendationResponse.fromJson(Map<String, dynamic> json) {
    final byPrice = json['data']?['byPrice'];
    if (byPrice == null) {
      throw const FormatException('No exchange rate available for this currency pair');
    }
    try {
      final raw = byPrice['fiatToCryptoExchangeRate'];
      final rate = raw is num ? raw.toDouble() : double.parse(raw.toString());
      return RecommendationResponse(fiatToCryptoExchangeRate: rate);
    } catch (e) {
      throw FormatException('Failed to parse response: $e');
    }
  }
}
