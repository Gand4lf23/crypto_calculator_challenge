import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';

abstract class CalculatorRepository {
  Future<Either<Failure, double>> getExchangeRate({
    required int type,
    required String cryptoCurrencyId,
    required String fiatCurrencyId,
    required double amount,
    required String amountCurrencyId,
  });
}
