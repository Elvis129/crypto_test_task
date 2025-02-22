import 'package:auto_route/auto_route.dart';
import 'package:crypto_coins_list/features/widgets/animated_chart.dart';
import 'package:crypto_coins_list/repositories/crypto_coins/models/crypto_coin.dart';
import 'package:crypto_coins_list/router/router.dart';
import 'package:flutter/material.dart';

class CryotoCoinTile extends StatelessWidget {
  const CryotoCoinTile({
    Key? key,
    required this.coin,
  }) : super(key: key);

  final CryptoCoin coin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final coinDetails = coin.details;
    return ListTile(
      leading: Image.network(coinDetails.fullImageUrl),
      title: Text(
        coin.name,
        style: theme.textTheme.bodyMedium,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${coinDetails.priceInUSD} \$',
            style: theme.textTheme.labelSmall,
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 50,
            child: AnimatedChart(priceHistory: coin.history7Days),
          ),
        ],
      ),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () {
        AutoRouter.of(context).push(CryptoCoinRoute(coin: coin));
      },
    );
  }
}
