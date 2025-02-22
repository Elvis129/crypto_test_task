import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AnimatedChart extends StatefulWidget {
  final List<double> priceHistory;

  const AnimatedChart({required this.priceHistory, Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _AnimatedChartState createState() => _AnimatedChartState();
}

class _AnimatedChartState extends State<AnimatedChart>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late List<double> _animatedPriceHistory;

  @override
  void initState() {
    super.initState();
    _animatedPriceHistory = List.filled(widget.priceHistory.length, 0.0);
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..addListener(() {
        setState(() {
          int animatedCount =
              (_animation.value * widget.priceHistory.length).toInt();
          for (int i = 0; i < animatedCount; i++) {
            _animatedPriceHistory[i] = widget.priceHistory[i];
          }
        });
      });

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedChart oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.priceHistory != oldWidget.priceHistory) {
      _controller.reset();
      _animatedPriceHistory = List.filled(widget.priceHistory.length, 0.0);
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              _animatedPriceHistory.length,
              (index) => FlSpot(index.toDouble(), _animatedPriceHistory[index]),
            ),
            isCurved: true,
            color: Colors.orange,
            barWidth: 2,
            belowBarData: BarAreaData(show: false),
          ),
        ],
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
