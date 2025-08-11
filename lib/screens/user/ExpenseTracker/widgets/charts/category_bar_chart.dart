import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class CategoryBarChart extends StatefulWidget {
  final Map<String, double> data;
  final bool showValuesOnTop;
  final bool hideYAxisLabels;

  const CategoryBarChart({
    super.key,
    required this.data,
    this.showValuesOnTop = true,
    this.hideYAxisLabels = false,
  });

  @override
  State<CategoryBarChart> createState() => _CategoryBarChartState();
}

class _CategoryBarChartState extends State<CategoryBarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = widget.data.keys.toList();
    final values = widget.data.values.toList();
    final maxY = (values.isEmpty
            ? 1
            : values.reduce((a, b) => a > b ? a : b) * 1.3)
        .ceilToDouble();

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return BarChart(
          BarChartData(
            maxY: maxY,
            alignment: BarChartAlignment.spaceAround,
            barTouchData: BarTouchData(enabled: true),
            titlesData: FlTitlesData(
              show: true,
              leftTitles: AxisTitles(
                sideTitles: widget.hideYAxisLabels
                    ? SideTitles(showTitles: false)
                    : SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, _) => Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 10),
                        ),
                      ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 60,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= categories.length) {
                      return const SizedBox.shrink();
                    }
                    final label = categories[index];
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Transform.rotate(
                        angle: -0.5, // Tilt the label
                        child: Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
                ),
              ),
              topTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: widget.showValuesOnTop,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    final index = value.toInt();
                    if (index < 0 ||
                        index >= values.length ||
                        values[index] == 0) {
                      return const SizedBox.shrink();
                    }
                    return Text(
                      values[index].toStringAsFixed(0),
                      style: const TextStyle(
                        color: Colors.orangeAccent,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            gridData: FlGridData(show: false),
            borderData: FlBorderData(show: false),
            barGroups: List.generate(categories.length, (index) {
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: values[index] * _animation.value,
                    width: 14,
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.lightBlueAccent,
                  ),
                ],
              );
            }),
          ),
        );
      },
    );
  }
}
