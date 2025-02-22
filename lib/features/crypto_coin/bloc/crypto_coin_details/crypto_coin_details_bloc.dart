import 'package:crypto_coins_list/repositories/crypto_coins/crypto_coins.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'crypto_coin_details_event.dart';
part 'crypto_coin_details_state.dart';

class CryptoCoinDetailsBloc
    extends Bloc<CryptoCoinDetailsEvent, CryptoCoinDetailsState> {
  CryptoCoinDetailsBloc(this.coinsRepository)
      : super(const CryptoCoinDetailsLoading()) {
    on<LoadCryptoCoinDetails>(_load);
    on<ChangeHistoryPeriod>(_changePeriod);
  }

  final AbstractCoinsRepository coinsRepository;

  Future<void> _load(
    LoadCryptoCoinDetails event,
    Emitter<CryptoCoinDetailsState> emit,
  ) async {
    try {
      emit(const CryptoCoinDetailsLoading());
      final coinDetails =
          await coinsRepository.getCoinDetails(event.currencyCode);
      emit(CryptoCoinDetailsLoaded(coin: coinDetails, selectedPeriod: 0));
    } catch (e) {
      emit(CryptoCoinDetailsLoadingFailure(e));
    }
  }

  void _changePeriod(
    ChangeHistoryPeriod event,
    Emitter<CryptoCoinDetailsState> emit,
  ) {
    final currentState = state;
    if (currentState is CryptoCoinDetailsLoaded) {
      emit(currentState.copyWith(selectedPeriod: event.selectedPeriod));
    }
  }
}
