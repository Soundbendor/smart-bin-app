import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class LineChart extends StatelessWidget {
  final Map<DateTime, double> data;
  final String title;
  const LineChart({super.key, required this.data, required this.title});

  @override
  Widget build(BuildContext context) {
    List<_ChartData> lineData = data.entries
        .map((entry) => _ChartData(entry.key, entry.value))
        .toList();

    lineData.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    while (lineData.length < 7) {
      DateTime latestTimestamp = lineData.isNotEmpty
          ? lineData
              .map((data) => data.timestamp)
              .reduce((a, b) => a.isAfter(b) ? a : b)
          : DateTime.now();

      DateTime nextDay = latestTimestamp.add(const Duration(days: 1));
      lineData.add(_ChartData(nextDay, 0.0));
    }

    return SfCartesianChart(
      title: ChartTitle(text: title),
      primaryXAxis: DateTimeAxis(
        isVisible: true,
        dateFormat: DateFormat('M/d'),
      ),
      series: <LineSeries<_ChartData, DateTime>>[
        LineSeries<_ChartData, DateTime>(
          dataSource: lineData,
          xValueMapper: (_ChartData detection, _) => detection.timestamp,
          yValueMapper: (_ChartData detection, _) => detection.weight!,
        ),
      ],
    );
  }
}

class _ChartData {
  _ChartData(this.timestamp, this.weight);

  final DateTime timestamp;
  final double weight;
}
