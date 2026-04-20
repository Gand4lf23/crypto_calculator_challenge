# Crypto Calculator

A real-time cryptocurrency exchange calculator built with **Flutter**.
Convert between fiat currencies and popular
stablecoins (USDT, USDC) with live market rates.

---

## Features

| Feature | Description |
|---|---|
| **Live exchange rates** | Fetches up-to-date prices so every conversion reflects the current market. |
| **Swap direction** | Instantly reverse the conversion pair with a single tap — the previous result becomes the new input amount. |
| **Formatted input** | Thousand-separator formatting and decimal-limit validation as you type. |
| **Animated results** | Exchange rate, receivable amount, and estimated time slide in with a smooth transition after each calculation. |
| **Error handling** | A user-friendly dialog describes what went wrong without exposing raw technical details. |

---

## Architecture

The project follows a **Clean Architecture** approach split into four layers:

```
lib/
├── common/          ← Shared theme, widgets, and utilities
│   ├── config/theme/ (AppColors · AppTextStyles · AppTheme)
│   ├── widgets/      (MainButton · CurrencyIcon · InfoSection)
│   └── utils/        (CurrencyFormatter)
├── core/            ← Infrastructure (network client, error types, config)
│   ├── config/       (AppConfig — feature flags)
│   ├── error/        (ServerException · Failure)
│   └── network/      (ApiClient · ApiEndpoints)
├── data/            ← Data layer (models, services, repository impl)
│   ├── models/       (Currency · RecommendationResponse)
│   ├── services/     (ExchangeService interface + two implementations)
│   └── repositories/ (CalculatorRepositoryImpl)
├── domain/          ← Abstract contracts consumed by the UI
│   └── repositories/ (CalculatorRepository)
└── features/
    └── calculator/
        ├── cubit/        (CalculatorCubit · CalculatorState)
        ├── di/           (GetIt dependency injection setup)
        ├── presentation/ (CalculatorScreen — scaffold & background)
        └── widgets/      (CalculatorWidget · CurrencyConverter · ConvertionBottomSheet)
```

### State management — Cubit (flutter_bloc)

The **CalculatorCubit** manages a simple state machine:

```
CalculatorInitial  →  CalculatorLoading  →  CalculatorLoaded
                                         →  CalculatorError
```

When the user taps *Convertir*, the cubit calls the repository, computes the
converted amount, and emits a new state. The UI reacts declaratively via
`BlocBuilder` / `BlocListener` — no manual `setState` for results.

### Exchange-rate services

Two interchangeable implementations of `ExchangeService` exist:

| Service | Source | Status |
|---|---|---|
| **RealExchangeService** | Official recommendations API (`/orderbook/public/recommendations`) | ⚠ Blocked — the endpoint requires internal numeric asset IDs that are not publicly documented. Catalog routes (`/assets`, `/orderbook/public`) return **404**. |
| **MockExchangeService** | [CoinGecko](https://www.coingecko.com/) public API (free tier, no key) | ✅ Active — fetches real-time market prices and maps them to the same contract. |

A compile-time flag (`USE_MOCK_EXCHANGE`) controls which service is injected
via **GetIt**. When the official backend exposes a catalog of asset IDs, the
switch is a one-line change — no other layer is affected.

### Dependency injection

**GetIt** (`get_it`) provides a lightweight service locator:

```
main() → initCalculator() → registers ApiClient, ExchangeService,
                              CalculatorRepository, CalculatorCubit
```

Each dependency is registered once and resolved lazily, keeping the widget tree
free of manual wiring.

---

## Tech stack

| Category | Package |
|---|---|
| UI framework | Flutter (Material 3) |
| State management | `flutter_bloc` / Cubit |
| Dependency injection | `get_it` |
| Functional error handling | `dartz` (`Either<Failure, T>`) |
| HTTP client | `http` |
| Value equality | `equatable` |
| Testing | `flutter_test` · `mockito` · `bloc_test` |

---

## Testing

Unit tests live in `test/` and cover the cubit's `calculateExchange` — the
method called by the *Convertir* button.

```
test/
└── calculator_cubit_test.dart   ← CalculatorCubit unit tests (3 cases)
```

**What is tested:**

| Test case | Scenario | Expected states |
|---|---|---|
| Fiat → Crypto (type 1) — success | Repository returns a valid rate | `Loading` → `Loaded` with `amount × rate` |
| Fiat → Crypto (type 1) — failure | Repository returns a `ServerFailure` | `Loading` → `Error` with the failure message |
| Crypto → Fiat (type 0) — success | Repository returns a valid rate | `Loading` → `Loaded` with `amount ÷ rate` |

**Stack:** `mockito` generates a `MockCalculatorRepository` via
`@GenerateMocks`, `bloc_test`'s `blocTest` helper asserts the exact sequence
of emitted states.

Regenerate mocks after changing `CalculatorRepository`:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Run the tests:

```bash
flutter test test/calculator_cubit_test.dart
```

---
