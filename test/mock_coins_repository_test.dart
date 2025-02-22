import 'package:bloc_test/bloc_test.dart';
import 'package:crypto_coins_list/features/crypto_coin/bloc/crypto_coin_details/crypto_coin_details_bloc.dart';
import 'package:crypto_coins_list/features/crypto_list/bloc/crypto_list_bloc.dart';
import 'package:crypto_coins_list/repositories/crypto_coins/crypto_coins.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCoinsRepository extends Mock implements AbstractCoinsRepository {}

class MockCryptoCoin extends Mock implements CryptoCoin {}

void main() {
  late MockCoinsRepository coinsRepository;
  late CryptoCoinDetailsBloc cryptoCoinDetailsBloc;
  late CryptoListBloc cryptoListBloc;
  final mockCoin = MockCryptoCoin();
  final mockCoinList = [mockCoin, mockCoin];

  setUp(() {
    coinsRepository = MockCoinsRepository();
    cryptoCoinDetailsBloc = CryptoCoinDetailsBloc(coinsRepository);
    cryptoListBloc = CryptoListBloc(coinsRepository);
  });

  tearDown(() {
    cryptoCoinDetailsBloc.close();
    cryptoListBloc.close();
  });

  group('CryptoCoinDetailsBloc', () {
    test('initial state is CryptoCoinDetailsLoading', () {
      expect(cryptoCoinDetailsBloc.state,
          equals(const CryptoCoinDetailsLoading()));
    });

    blocTest<CryptoCoinDetailsBloc, CryptoCoinDetailsState>(
      'emits [CryptoCoinDetailsLoading, CryptoCoinDetailsLoaded] when LoadCryptoCoinDetails is added',
      build: () {
        when(() => coinsRepository.getCoinDetails(any()))
            .thenAnswer((_) async => mockCoin);
        return cryptoCoinDetailsBloc;
      },
      act: (bloc) => bloc.add(const LoadCryptoCoinDetails(currencyCode: 'BTC')),
      expect: () => [
        const CryptoCoinDetailsLoading(),
        CryptoCoinDetailsLoaded(coin: mockCoin, selectedPeriod: 0),
      ],
      verify: (_) {
        verify(() => coinsRepository.getCoinDetails('BTC')).called(1);
      },
    );

    blocTest<CryptoCoinDetailsBloc, CryptoCoinDetailsState>(
      'emits [CryptoCoinDetailsLoading, CryptoCoinDetailsLoadingFailure] when LoadCryptoCoinDetails fails',
      build: () {
        when(() => coinsRepository.getCoinDetails(any()))
            .thenThrow(Exception('Error fetching coin details'));
        return cryptoCoinDetailsBloc;
      },
      act: (bloc) => bloc.add(const LoadCryptoCoinDetails(currencyCode: 'BTC')),
      expect: () => [
        const CryptoCoinDetailsLoading(),
        isA<CryptoCoinDetailsLoadingFailure>(),
      ],
    );

    blocTest<CryptoCoinDetailsBloc, CryptoCoinDetailsState>(
      'emits new CryptoCoinDetailsLoaded state with updated period when ChangeHistoryPeriod is added',
      build: () => cryptoCoinDetailsBloc,
      seed: () => CryptoCoinDetailsLoaded(coin: mockCoin, selectedPeriod: 0),
      act: (bloc) => bloc.add(const ChangeHistoryPeriod(selectedPeriod: 1)),
      expect: () =>
          [CryptoCoinDetailsLoaded(coin: mockCoin, selectedPeriod: 1)],
    );
  });

  group('CryptoListBloc', () {
    test('initial state is CryptoListInitial', () {
      expect(cryptoListBloc.state, equals(CryptoListInitial()));
    });

    blocTest<CryptoListBloc, CryptoListState>(
      'emits [CryptoListLoading, CryptoListLoaded] when LoadCryptoList is added',
      build: () {
        when(() => coinsRepository.getCoinsList())
            .thenAnswer((_) async => mockCoinList);
        return cryptoListBloc;
      },
      act: (bloc) => bloc.add(LoadCryptoList()),
      expect: () =>
          [CryptoListLoading(), CryptoListLoaded(coinsList: mockCoinList)],
      verify: (_) {
        verify(() => coinsRepository.getCoinsList()).called(1);
      },
    );

    blocTest<CryptoListBloc, CryptoListState>(
      'emits [CryptoListLoading, CryptoListLoadingFailure] when LoadCryptoList fails',
      build: () {
        when(() => coinsRepository.getCoinsList())
            .thenThrow(Exception('Error fetching list'));
        return cryptoListBloc;
      },
      act: (bloc) => bloc.add(LoadCryptoList()),
      expect: () => [CryptoListLoading(), isA<CryptoListLoadingFailure>()],
    );
  });
}
