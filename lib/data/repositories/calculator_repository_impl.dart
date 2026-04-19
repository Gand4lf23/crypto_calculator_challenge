import 'package:dartz/dartz.dart';
import 'package:crypto_calculator_challenge/core/error/failures.dart';
import 'package:crypto_calculator_challenge/data/services/exchange_service.dart';
import 'package:crypto_calculator_challenge/domain/repositories/calculator_repository.dart';

class CalculatorRepositoryImpl implements CalculatorRepository {
  final ExchangeService exchangeService;

  CalculatorRepositoryImpl({required this.exchangeService});

  @override
  Future<Either<Failure, double>> getExchangeRate({
    required int type,
    required String cryptoCurrencyId,
    required String fiatCurrencyId,
    required double amount,
    required String amountCurrencyId,
  }) {
    return exchangeService.getExchangeRate(
      type: type,
      cryptoCurrencyId: cryptoCurrencyId,
      fiatCurrencyId: fiatCurrencyId,
      amount: amount,
      amountCurrencyId: amountCurrencyId,
    );
  }
}
