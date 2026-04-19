import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:crypto_calculator_challenge/domain/repositories/calculator_repository.dart';
import 'calculator_state.dart';

class CalculatorCubit extends Cubit<CalculatorState> {
  final CalculatorRepository repository;

  CalculatorCubit({required this.repository}) : super(CalculatorInitial());

  Future<void> calculateExchange({
    required int type,
    required String cryptoCurrencyId,
    required String fiatCurrencyId,
    required double amount,
    required String amountCurrencyId,
  }) async {
    emit(CalculatorLoading());

    final result = await repository.getExchangeRate(
      type: type,
      cryptoCurrencyId: cryptoCurrencyId,
      fiatCurrencyId: fiatCurrencyId,
      amount: amount,
      amountCurrencyId: amountCurrencyId,
    );

    result.fold((failure) => emit(CalculatorError(message: failure.message)), (
      exchangeRate,
    ) {
      double convertedAmount;
      if (type == 0) {
        // Crypto to Fiat
        // 1 Fiat = 'exchangeRate' Crypto
        // cryptoAmount / exchangeRate = fiatAmount
        convertedAmount = amount / exchangeRate;
      } else {
        // Fiat to Crypto
        // 1 Fiat = 'exchangeRate' Crypto
        // fiatAmount * exchangeRate = cryptoAmount
        convertedAmount = amount * exchangeRate;
      }

      emit(
        CalculatorLoaded(
          exchangeRate: exchangeRate,
          convertedAmount: convertedAmount,
        ),
      );
    });
  }
}
