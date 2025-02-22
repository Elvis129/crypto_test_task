part of 'crypto_coin_details_bloc.dart';

abstract class CryptoCoinDetailsEvent extends Equatable {
  const CryptoCoinDetailsEvent();

  @override
  List<Object> get props => [];
}

class LoadCryptoCoinDetails extends CryptoCoinDetailsEvent {
  const LoadCryptoCoinDetails({required this.currencyCode});

  final String currencyCode;

  @override
  List<Object> get props => [currencyCode];
}

class ChangeHistoryPeriod extends CryptoCoinDetailsEvent {
  const ChangeHistoryPeriod({required this.selectedPeriod});

  final int selectedPeriod;

  @override
  List<Object> get props => [selectedPeriod];
}
