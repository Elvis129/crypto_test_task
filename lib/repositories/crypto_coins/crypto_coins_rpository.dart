import 'package:dio/dio.dart';
import 'package:crypto_coins_list/repositories/crypto_coins/crypto_coins.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CryptoCoinsRepository implements AbstractCoinsRepository {
  CryptoCoinsRepository({
    required this.dio,
    required this.cryptoCoinsBox,
  });

  final Dio dio;
  final Box<CryptoCoin> cryptoCoinsBox;

  @override
  Future<List<CryptoCoin>> getCoinsList() async {
    var cryptoCoinsList = <CryptoCoin>[];
    try {
      cryptoCoinsList = await _fetchCoinsListFromApi();
      final cryptoCoinsMap = {for (var e in cryptoCoinsList) e.name: e};
      await cryptoCoinsBox.putAll(cryptoCoinsMap);
    } catch (e) {
      cryptoCoinsList = cryptoCoinsBox.values.toList();
    }

    cryptoCoinsList
        .sort((a, b) => b.details.priceInUSD.compareTo(a.details.priceInUSD));
    return cryptoCoinsList;
  }

  Future<List<CryptoCoin>> _fetchCoinsListFromApi() async {
    final response = await dio.get(
        'https://min-api.cryptocompare.com/data/pricemultifull?fsyms=BTC,ETH,BNB,SOL,AID,CAG,DOV&tsyms=USD');
    final data = response.data as Map<String, dynamic>;
    final dataRaw = data['RAW'] as Map<String, dynamic>;

    final cryptoCoinsList = await Future.wait(dataRaw.entries.map((e) async {
      final usdData =
          (e.value as Map<String, dynamic>)['USD'] as Map<String, dynamic>;
      final details = CryptoCoinDetail.fromJson(usdData);

      // final history24Hours = await getPriceHistory24Hours(e.key);
      final history7Days = await getPriceHistory7Days(e.key);
      // final history30Days = await getPriceHistory30Days(e.key);

      return CryptoCoin(
        name: e.key,
        details: details,
        history24Hours: const [],
        history7Days: history7Days,
        history30Days: const [],
      );
    }).toList());

    return cryptoCoinsList;
  }

  @override
  Future<CryptoCoin> getCoinDetails(String currencyCode) async {
    try {
      final coin = await _fetchCoinDetailsFromApi(currencyCode);

      coin.history24Hours = await getPriceHistory24Hours(currencyCode);
      coin.history7Days = await getPriceHistory7Days(currencyCode);
      coin.history30Days = await getPriceHistory30Days(currencyCode);

      cryptoCoinsBox.put(currencyCode, coin);
      return coin;
    } catch (e) {
      return cryptoCoinsBox.get(currencyCode)!;
    }
  }

  Future<CryptoCoin> _fetchCoinDetailsFromApi(String currencyCode) async {
    final response = await dio.get(
        'https://min-api.cryptocompare.com/data/pricemultifull?fsyms=$currencyCode&tsyms=USD');
    final data = response.data as Map<String, dynamic>;
    final dataRaw = data['RAW'] as Map<String, dynamic>;
    final coinData = dataRaw[currencyCode] as Map<String, dynamic>;
    final usdData = coinData['USD'] as Map<String, dynamic>;
    final details = CryptoCoinDetail.fromJson(usdData);
    final history24Hours = await getPriceHistory24Hours(currencyCode);
    final history7Days = await getPriceHistory7Days(currencyCode);
    final history30Days = await getPriceHistory30Days(currencyCode);
    return CryptoCoin(
        name: currencyCode,
        details: details,
        history24Hours: history24Hours,
        history7Days: history7Days,
        history30Days: history30Days);
  }

  Future<List<double>> getPriceHistory24Hours(String currencyCode) async {
    return await _getPriceHistory24Hours(currencyCode);
  }

  Future<List<double>> getPriceHistory7Days(String currencyCode) async {
    return await _getPriceHistory(currencyCode, limit: 6);
  }

  Future<List<double>> getPriceHistory30Days(String currencyCode) async {
    return await _getPriceHistory(currencyCode, limit: 29);
  }

  Future<List<double>> _getPriceHistory(String currencyCode,
      {required int limit}) async {
    try {
      final response = await dio.get(
          'https://min-api.cryptocompare.com/data/v2/histoday',
          queryParameters: {
            'fsym': currencyCode,
            'tsym': 'USD',
            'limit': limit,
            'toTs': DateTime.now().millisecondsSinceEpoch ~/ 1000,
          });

      final data = response.data as Map<String, dynamic>;
      if (data['Response'] == 'Error') {
        return [];
      }
      final dataRaw = data['Data']['Data'] as List<dynamic>;

      final priceHistory = dataRaw.map((e) {
        return e['close'] as double;
      }).toList();

      return priceHistory;
    } catch (e) {
      return [];
    }
  }

  Future<List<double>> _getPriceHistory24Hours(String currencyCode,
      {int limit = 23}) async {
    try {
      final response = await dio.get(
        'https://min-api.cryptocompare.com/data/v2/histohour',
        queryParameters: {
          'fsym': currencyCode,
          'tsym': 'USD',
          'limit': limit,
          'toTs': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        },
      );

      final data = response.data as Map<String, dynamic>;

      if (data['Response'] == 'Error') {
        return [];
      }

      final dataRaw = data['Data']['Data'] as List<dynamic>;

      final priceHistory = dataRaw.map((e) => e['close'] as double).toList();

      return priceHistory;
    } catch (e) {
      return [];
    }
  }
}
