// ignore_for_file: must_be_immutable

import 'package:crypto_coins_list/repositories/crypto_coins/models/crypto_coin_details.dart';
import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'crypto_coin.g.dart';

@HiveType(typeId: 2)
class CryptoCoin extends Equatable {
  CryptoCoin({
    required this.name,
    required this.details,
    this.history24Hours = const [],
    this.history7Days = const [],
    this.history30Days = const [],
  });

  @HiveField(0)
  final String name;

  @HiveField(1)
  final CryptoCoinDetail details;

  @HiveField(2)
  List<double> history24Hours;

  @HiveField(3)
  List<double> history7Days;

  @HiveField(4)
  List<double> history30Days;

  @override
  List<Object> get props => [name, details];
}
