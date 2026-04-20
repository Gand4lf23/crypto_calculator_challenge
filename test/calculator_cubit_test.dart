import 'package:bloc_test/bloc_test.dart';
import 'package:crypto_calculator_challenge/core/error/failures.dart';
import 'package:crypto_calculator_challenge/domain/repositories/calculator_repository.dart';
import 'package:crypto_calculator_challenge/features/calculator/cubit/calculator_cubit.dart';
import 'package:crypto_calculator_challenge/features/calculator/cubit/calculator_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'calculator_cubit_test.mocks.dart';

@GenerateMocks([CalculatorRepository])
void main() {
  late MockCalculatorRepository mockRepository;
  late CalculatorCubit cubit;

  setUp(() {
    mockRepository = MockCalculatorRepository();
    cubit = CalculatorCubit(repository: mockRepository);
  });

  tearDown(() => cubit.close());

  group('calculateExchange (fiat → crypto, type 1)', () {
    const type = 1;
    const cryptoId = 'TATUM-TRON-USDT';
    const fiatId = 'BRL';
    const amount = 100.0;
    const amountCurrencyId = 'BRL';
    const exchangeRate = 0.176; // 1 BRL = 0.176 USDT

    blocTest<CalculatorCubit, CalculatorState>(
      'emits [CalculatorLoading, CalculatorLoaded] with correct convertedAmount '
      'when repository returns a successful rate',
      build: () {
        when(mockRepository.getExchangeRate(
          type: type,
          cryptoCurrencyId: cryptoId,
          fiatCurrencyId: fiatId,
          amount: amount,
          amountCurrencyId: amountCurrencyId,
        )).thenAnswer((_) async => const Right(exchangeRate));
        return cubit;
      },
      act: (cubit) => cubit.calculateExchange(
        type: type,
        cryptoCurrencyId: cryptoId,
        fiatCurrencyId: fiatId,
        amount: amount,
        amountCurrencyId: amountCurrencyId,
      ),
      expect: () => [
        isA<CalculatorLoading>(),
        isA<CalculatorLoaded>()
            .having((s) => s.exchangeRate, 'exchangeRate', exchangeRate)
            .having(
              (s) => s.convertedAmount,
              'convertedAmount',
              amount * exchangeRate, // fiat→crypto: amount * rate
            ),
      ],
      verify: (_) {
        verify(mockRepository.getExchangeRate(
          type: type,
          cryptoCurrencyId: cryptoId,
          fiatCurrencyId: fiatId,
          amount: amount,
          amountCurrencyId: amountCurrencyId,
        )).called(1);
      },
    );

    blocTest<CalculatorCubit, CalculatorState>(
      'emits [CalculatorLoading, CalculatorError] when repository fails',
      build: () {
        when(mockRepository.getExchangeRate(
          type: type,
          cryptoCurrencyId: cryptoId,
          fiatCurrencyId: fiatId,
          amount: amount,
          amountCurrencyId: amountCurrencyId,
        )).thenAnswer(
          (_) async =>
              const Left(ServerFailure(message: 'CoinGecko returned 429')),
        );
        return cubit;
      },
      act: (cubit) => cubit.calculateExchange(
        type: type,
        cryptoCurrencyId: cryptoId,
        fiatCurrencyId: fiatId,
        amount: amount,
        amountCurrencyId: amountCurrencyId,
      ),
      expect: () => [
        isA<CalculatorLoading>(),
        isA<CalculatorError>().having(
          (s) => s.message,
          'message',
          'CoinGecko returned 429',
        ),
      ],
    );
  });

  group('calculateExchange (crypto → fiat, type 0)', () {
    const type = 0;
    const cryptoId = 'TATUM-TRON-USDT';
    const fiatId = 'BRL';
    const amount = 50.0;
    const amountCurrencyId = 'TATUM-TRON-USDT';
    const exchangeRate = 0.176; // 1 BRL = 0.176 USDT

    blocTest<CalculatorCubit, CalculatorState>(
      'emits [CalculatorLoading, CalculatorLoaded] — crypto→fiat uses '
      'amount / exchangeRate',
      build: () {
        when(mockRepository.getExchangeRate(
          type: type,
          cryptoCurrencyId: cryptoId,
          fiatCurrencyId: fiatId,
          amount: amount,
          amountCurrencyId: amountCurrencyId,
        )).thenAnswer((_) async => const Right(exchangeRate));
        return cubit;
      },
      act: (cubit) => cubit.calculateExchange(
        type: type,
        cryptoCurrencyId: cryptoId,
        fiatCurrencyId: fiatId,
        amount: amount,
        amountCurrencyId: amountCurrencyId,
      ),
      expect: () => [
        isA<CalculatorLoading>(),
        isA<CalculatorLoaded>()
            .having((s) => s.exchangeRate, 'exchangeRate', exchangeRate)
            .having(
              (s) => s.convertedAmount,
              'convertedAmount',
              amount / exchangeRate, // crypto→fiat: amount / rate
            ),
      ],
    );
  });
}
