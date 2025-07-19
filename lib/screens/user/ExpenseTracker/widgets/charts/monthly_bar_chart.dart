import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MonthlyBarChart extends StatefulWidget {
  final Function(int monthIndex, String monthName)? onBarTap; // optional

  const MonthlyBarChart({super.key, this.onBarTap});

  @override
  State<MonthlyBarChart> createState() => _MonthlyBarChartState();
}

class _MonthlyBarChartState extends State<MonthlyBarChart> {
  final List<String> months = [
    "Jan", "Feb", "Mar", "Apr", "May", "Jun",
    "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
  ];

  Map<int, double> monthlyData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMonthlyData();
  }

  Future<void> fetchMonthlyData() async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection("transactions")
        .where("participants", arrayContains: currentUid)
        .where("status", isEqualTo: "success")
        .get();

    final currentYear = DateTime.now().year;
    Map<int, double> tempData = {};
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final dateStr = data['date'];
      final timeStr = data['time'] ?? '00:00';
      final amount = (data['amount'] ?? 0).toDouble();
      final txnDate = DateTime.tryParse('$dateStr $timeStr');
      if (txnDate != null && txnDate.year == currentYear) {
        final month = txnDate.month;
        tempData[month] = (tempData[month] ?? 0) + amount;
      }
    }

    setState(() {
      monthlyData = tempData;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final currentMonth = DateTime.now().month;
    final maxAmount = monthlyData.values.isEmpty
        ? 10
        : monthlyData.values.reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 260,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: 60.0 * currentMonth,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              gridData: FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barTouchData: BarTouchData(
                enabled: widget.onBarTap != null,
                touchCallback: (event, response) {
                  if (widget.onBarTap != null &&
                      response != null &&
                      response.spot != null &&
                      event.isInterestedForInteractions) {
                    final index = response.spot!.touchedBarGroupIndex;
                    widget.onBarTap!(index + 1, months[index]);
                  }
                },
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, _) {
                      final index = value.toInt();
                      if (index >= 0 && index < currentMonth) {
                        final amount = monthlyData[index + 1];
                        if (amount != null && amount > 0) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              '₹${amount.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          );
                        }
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, _) {
                      final index = value.toInt();
                      if (index >= 0 && index < currentMonth) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            months[index],
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white, 
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
              minY: 0,
              maxY: maxAmount + maxAmount * 0.2,
              barGroups: List.generate(currentMonth, (index) {
                final value = monthlyData[index + 1] ?? 0;
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: value == 0 ? 1 : value,
                      width: 20,
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
