import 'package:crypto_coins_list/features/crypto_list/view/view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:crypto_coins_list/features/crypto_list/bloc/crypto_list_bloc.dart';
import 'package:crypto_coins_list/repositories/crypto_coins/crypto_coins.dart';

class MockCoinsRepository extends Mock implements AbstractCoinsRepository {}

void main() {
  late MockCoinsRepository mockRepository;

  setUp(() {
    // Очистка GetIt перед кожним тестом
    GetIt.I.reset();

    // Створення мокованого репозиторію та реєстрація в GetIt
    mockRepository = MockCoinsRepository();
    GetIt.I.registerSingleton<AbstractCoinsRepository>(mockRepository);
  });

  group('CryptoListScreen', () {
    testWidgets('displays loading indicator when the state is loading',
        (tester) async {
      // Arrange
      when(() => mockRepository.getCoinsList()).thenAnswer((_) async => []);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider(
            create: (context) => CryptoListBloc(mockRepository),
            child: const CryptoListScreen(),
          ),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays list of coins when the state is loaded',
        (tester) async {
      // Arrange
      final mockCoinsList = [
        CryptoCoin(
            name: 'Bitcoin',
            details: CryptoCoinDetail(
                priceInUSD: 50000,
                imageUrl: '',
                toSymbol: '',
                lastUpdate: DateTime(1),
                hight24Hour: 1,
                low24Hours: 2)),
        CryptoCoin(
            name: 'Ethereum',
            details: CryptoCoinDetail(
                priceInUSD: 30000,
                imageUrl: '',
                toSymbol: '',
                lastUpdate: DateTime(1),
                hight24Hour: 1,
                low24Hours: 2)),
      ];

      when(() => mockRepository.getCoinsList())
          .thenAnswer((_) async => mockCoinsList);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider(
            create: (context) => CryptoListBloc(mockRepository),
            child: const CryptoListScreen(),
          ),
        ),
      );

      // Trigger the LoadCryptoList event to load the data
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Bitcoin'), findsOneWidget);
      expect(find.text('Ethereum'), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('displays error message when the state is loading failure',
        (tester) async {
      // Arrange
      when(() => mockRepository.getCoinsList())
          .thenThrow(Exception('Failed to load coins'));

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider(
            create: (context) => CryptoListBloc(mockRepository),
            child: const CryptoListScreen(),
          ),
        ),
      );

      // Trigger the LoadCryptoList event
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Please try again later'), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets(
        'retries loading the list when the "Try again" button is pressed',
        (tester) async {
      // Arrange
      when(() => mockRepository.getCoinsList()).thenAnswer((_) async => []);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider(
            create: (context) => CryptoListBloc(mockRepository),
            child: const CryptoListScreen(),
          ),
        ),
      );

      // Trigger the LoadCryptoList event and simulate a failure
      await tester.pumpAndSettle();

      // Press the "Try again" button
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();

      // Assert
      verify(() => mockRepository.getCoinsList())
          .called(2); // Ensure retry occurs
    });
  });
}
