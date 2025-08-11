import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class CategoryPieChart extends StatefulWidget {
  final Map<String, double> data;

  const CategoryPieChart({super.key, required this.data});

  @override
  State<CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<CategoryPieChart> {
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
    final data = widget.data;

    if (data.isEmpty) {
      return const Center(
        child: Text(
          "No transactions available for this month.",
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    final entriesList = data.entries.toList();
    final total = data.values.fold(0.0, (a, b) => a + b);
    final colors = _generateColors(entriesList.length);

    const double finalRadius = 42.0;
    const double finalCenterSpace = 24.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 140,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, progress, child) {
              return PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: finalCenterSpace * (progress * 0.6),
                  startDegreeOffset: 270 * (1 - progress),
                  sections: List.generate(entriesList.length, (index) {
                    final entry = entriesList[index];
                    final value = entry.value;
                    final radius = finalRadius * progress;
                    final color = colors[index].withOpacity(0.2 + 0.8 * progress);

                    final displayLabel = progress >= 0.98
                        ? (total == 0 ? '0%' : '${(entry.value / total * 100).toStringAsFixed(1)}%')
                        : '';

                    return PieChartSectionData(
                      color: color,
                      value: value, 
                      radius: radius,
                      title: displayLabel,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 6,
          alignment: WrapAlignment.center,
          children: List.generate(entriesList.length, (index) {
            final category = entriesList[index].key;
            final color = _generateColors(entriesList.length)[index];
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  color: color,
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
