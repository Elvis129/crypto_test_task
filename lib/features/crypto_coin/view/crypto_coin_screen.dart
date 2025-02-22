import 'package:auto_route/auto_route.dart';
import 'package:crypto_coins_list/features/crypto_coin/bloc/crypto_coin_details/crypto_coin_details_bloc.dart';
import 'package:crypto_coins_list/features/crypto_coin/widgets/widgets.dart';
import 'package:crypto_coins_list/features/widgets/animated_chart.dart';
import 'package:crypto_coins_list/repositories/crypto_coins/crypto_coins.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

@RoutePage()
class CryptoCoinScreen extends StatelessWidget {
  const CryptoCoinScreen({super.key, required this.coin});

  final CryptoCoin coin;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CryptoCoinDetailsBloc(GetIt.I<AbstractCoinsRepository>())
        ..add(LoadCryptoCoinDetails(currencyCode: coin.name)),
      child: Scaffold(
        appBar: AppBar(),
        body: BlocBuilder<CryptoCoinDetailsBloc, CryptoCoinDetailsState>(
          builder: (context, state) {
            if (state is CryptoCoinDetailsLoaded) {
              final coin = state.coin;

              return Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 160,
                      width: 160,
                      child: Image.network(coin.details.fullImageUrl),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      coin.name,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    BaseCard(
                      child: Center(
                        child: Text(
                          '${coin.details.priceInUSD} \$',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    BaseCard(
                      child: Column(
                        children: [
                          DataRowWidget(
                            title: 'High 24 Hour',
                            value: '${coin.details.hight24Hour} \$',
                          ),
                          const SizedBox(height: 6),
                          DataRowWidget(
                            title: 'Low 24 Hour',
                            value: '${coin.details.low24Hours} \$',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    PeriodSelector(
                      selectedPeriod: state.selectedPeriod,
                      onPeriodSelected: (index) {
                        context
                            .read<CryptoCoinDetailsBloc>()
                            .add(ChangeHistoryPeriod(selectedPeriod: index));
                      },
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: SizedBox(
                        height: 50,
                        child: AnimatedChart(
                            priceHistory: state.selectedPeriod == 0
                                ? coin.history24Hours
                                : state.selectedPeriod == 1
                                    ? coin.history7Days
                                    : coin.history30Days),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const Center(
                child: CircularProgressIndicator(
              color: Colors.orange,
            ));
          },
        ),
      ),
    );
  }
}
