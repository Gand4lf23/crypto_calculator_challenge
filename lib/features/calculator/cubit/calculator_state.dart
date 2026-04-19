import 'package:equatable/equatable.dart';

abstract class CalculatorState extends Equatable {
  const CalculatorState();

  @override
  List<Object?> get props => [];
}

class CalculatorInitial extends CalculatorState {}

class CalculatorLoading extends CalculatorState {}

class CalculatorLoaded extends CalculatorState {
  final double exchangeRate;
  final double convertedAmount;

  const CalculatorLoaded({
    required this.exchangeRate,
    required this.convertedAmount,
  });

  @override
  List<Object?> get props => [exchangeRate, convertedAmount];
}

class CalculatorError extends CalculatorState {
  final String message;

  const CalculatorError({required this.message});

  @override
  List<Object?> get props => [message];
}
