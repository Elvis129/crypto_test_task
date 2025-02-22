part of 'crypto_coin_details_bloc.dart';

class CryptoCoinDetailsState extends Equatable {
  const CryptoCoinDetailsState();

  @override
  List<Object?> get props => [];
}

class CryptoCoinDetailsLoading extends CryptoCoinDetailsState {
  const CryptoCoinDetailsLoading();
}

class CryptoCoinDetailsLoaded extends CryptoCoinDetailsState {
  const CryptoCoinDetailsLoaded({
    required this.coin,
    this.selectedPeriod = 0,
  });

  final CryptoCoin coin;
  final int selectedPeriod;

  @override
  List<Object?> get props => [coin, selectedPeriod];

  CryptoCoinDetailsLoaded copyWith({int? selectedPeriod}) {
    return CryptoCoinDetailsLoaded(
      coin: coin,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
    );
  }
}

class CryptoCoinDetailsLoadingFailure extends CryptoCoinDetailsState {
  const CryptoCoinDetailsLoadingFailure(this.exception);

  final Object exception;

  @override
  List<Object?> get props => [exception];
}
