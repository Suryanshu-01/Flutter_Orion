import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class CategoryPieChart extends StatelessWidget {
  final Map<String, double> data;

  const CategoryPieChart({super.key, required this.data});

  List<Color> _generateColors(int count) {
    final random = Random(42);
    return List.generate(
      count,
      (index) => Color.fromARGB(
        255,
        random.nextInt(180) + 40,
        random.nextInt(180) + 40,
        random.nextInt(180) + 40,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text("No transactions available for this month."));
    }

    final entriesList = data.entries.toList();
    final total = data.values.fold(0.0, (a, b) => a + b);
    final colors = _generateColors(entriesList.length);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 140, // Reduced from 200 to 140 (60px smaller)
          child: PieChart(
            PieChartData(
              sections: List.generate(entriesList.length, (index) {
                final entry = entriesList[index];
                final value = entry.value;
                final percentage = total == 0 ? 0 : (value / total) * 100;
                return PieChartSectionData(
                  color: colors[index],
                  value: value,
                  title: "${percentage.toStringAsFixed(1)}%",
                  radius: 42, // You may also reduce this slightly for best fit (optional)
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }),
              sectionsSpace: 2,
              centerSpaceRadius: 24, // Also reduced slightly for proportional scaling
            ),
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 6,
          alignment: WrapAlignment.center,
          children: List.generate(entriesList.length, (index) {
            final category = entriesList[index].key;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  color: colors[index],
                ),
                const SizedBox(width: 4),
                Text(
                  category,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }
}
