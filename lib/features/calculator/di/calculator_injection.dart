import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

import 'package:crypto_calculator_challenge/core/config/app_config.dart';
import 'package:crypto_calculator_challenge/core/network/api_client.dart';
import 'package:crypto_calculator_challenge/data/repositories/calculator_repository_impl.dart';
import 'package:crypto_calculator_challenge/data/services/exchange_service.dart';
import 'package:crypto_calculator_challenge/data/services/mock_exchange_service.dart';
import 'package:crypto_calculator_challenge/data/services/real_exchange_service.dart';
import 'package:crypto_calculator_challenge/domain/repositories/calculator_repository.dart';
import 'package:crypto_calculator_challenge/features/calculator/cubit/calculator_cubit.dart';

final sl = GetIt.instance;

void initCalculator() {
  // Cubit
  sl.registerFactory(() => CalculatorCubit(repository: sl()));

  // Repository — delegates to whichever ExchangeService is active
  sl.registerLazySingleton<CalculatorRepository>(
    () => CalculatorRepositoryImpl(exchangeService: sl()),
  );

  // ExchangeService — swapped via AppConfig.useMockExchange
  // • true  → MockExchangeService (CoinGecko, no internal IDs required)
  // • false → RealExchangeService (official API, needs numeric asset IDs)
  sl.registerLazySingleton<ExchangeService>(
    () => AppConfig.useMockExchange
        ? MockExchangeService(client: sl())
        : RealExchangeService(apiClient: sl()),
  );

  // Core
  sl.registerLazySingleton(() => ApiClient(client: sl()));

  // External
  sl.registerLazySingleton(() => http.Client());
}
