import 'package:crypto_coins_list/features/crypto_coin/widgets/widgets.dart';
import 'package:flutter/material.dart';

class PeriodSelector extends StatelessWidget {
  const PeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodSelected,
  });

  final int selectedPeriod;
  final ValueChanged<int> onPeriodSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        PeriodButton(
          label: '24-Hours',
          isSelected: selectedPeriod == 0,
          onTap: () => onPeriodSelected(0),
        ),
        const SizedBox(width: 8),
        PeriodButton(
          label: '7-Days',
          isSelected: selectedPeriod == 1,
          onTap: () => onPeriodSelected(1),
        ),
        const SizedBox(width: 8),
        PeriodButton(
          label: '30-Days',
          isSelected: selectedPeriod == 2,
          onTap: () => onPeriodSelected(2),
        ),
      ],
    );
  }
}
