import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MonthlyBarChart extends StatefulWidget {
  final void Function(int monthIndex, String monthName)? onBarTap;
  const MonthlyBarChart({super.key, this.onBarTap});

  @override
  State<MonthlyBarChart> createState() => _MonthlyBarChartState();
}

class _MonthlyBarChartState extends State<MonthlyBarChart> {
  final List<String> months = [
    "Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"
  ];
  Map<int, double> monthlyData = {};
  bool isLoading = true;
  int currentMonth = DateTime.now().month;

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

    Map<int, double> tempData = {};
    for (var doc in snapshot.docs) {
      final data = doc.data();
      DateTime? txnDate;
      if (data['timestamp'] is Timestamp) {
        txnDate = (data['timestamp'] as Timestamp).toDate();
      } else if (data['parsedDate'] is DateTime) {
        txnDate = data['parsedDate'];
      } else {
        final dateStr = data['date'] ?? '';
        final timeStr = data['time'] ?? '00:00';
        txnDate = DateTime.tryParse('$dateStr $timeStr');
      }

      // Here's the real fix! Only sum when you are the sender:
      if (txnDate != null &&
          txnDate.year == DateTime.now().year &&
          txnDate.month <= currentMonth &&
          data['from'] == currentUid) {
        final month = txnDate.month;
        final amount = (data['amount'] ?? 0).toDouble();
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
    final filteredMonths = List.generate(currentMonth, (index) => index + 1)
        .where((m) => monthlyData[m] != null && monthlyData[m]! > 0)
        .toList();

    final maxAmount = filteredMonths.isEmpty
        ? 10
        : filteredMonths.map((m) => monthlyData[m]!).reduce((a, b) => a > b ? a : b);

    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : SizedBox(
            height: 260,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: 60.0 * filteredMonths.length,
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
                          if (index >= 0 && index < filteredMonths.length) {
                            final monthNum = filteredMonths[index];
                            widget.onBarTap!(monthNum, months[monthNum - 1]);
                          }
                        }
                      },
                    ),
                    titlesData: FlTitlesData(
                      // ...title code omitted for brevity (keep yours)...
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, _) {
                        final index = value.toInt();
                        if (index >= 0 && index < filteredMonths.length) {
                          final amount = monthlyData[filteredMonths[index]];
                          if (amount != null && amount > 0) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text('₹${amount.toStringAsFixed(0)}',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            );
                          }
                        }
                        return const SizedBox.shrink();
                      })),
                      bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, _) {
                        final index = value.toInt();
                        if (index >= 0 && index < filteredMonths.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(months[filteredMonths[index] - 1],
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                          );
                        }
                        return const SizedBox.shrink();
                      })),
                    ),
                    minY: 0,
                    maxY: maxAmount + maxAmount * 0.2,
                    barGroups: List.generate(filteredMonths.length, (index) {
                      final month = filteredMonths[index];
                      final value = monthlyData[month] ?? 0;
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: value,
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
