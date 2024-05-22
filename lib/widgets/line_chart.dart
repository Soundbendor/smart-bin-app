// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

/// Line chart to show total weight of compost by day
class BarChart extends StatelessWidget {
  // Map with the day as the key and total weight of compost as the value
  final Map<DateTime, double> data;

  const BarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // Create sorted chartdata for graph construction using the date and weights in data
    List<_ChartData> lineData = data.entries
        .map((entry) => _ChartData(entry.key, entry.value))
        .toList();
    lineData.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // If there is not a weeks worth of data, fill the rest of the week with zeros
    while (lineData.length < 7) {
      DateTime latestTimestamp = lineData.isNotEmpty
          ? lineData
              .map((data) => data.timestamp)
              .reduce((a, b) => a.isAfter(b) ? a : b)
          : DateTime.now();

      DateTime nextDay = latestTimestamp.add(const Duration(days: 1));
      lineData.add(_ChartData(nextDay, 0.0));
    }

    // Use the cartesian chart with the _ChartData, specifying the main axis as date time
    return SfCartesianChart(
      margin: const EdgeInsets.all(0.0),
      primaryXAxis: DateTimeAxis(
        isVisible: true,
        interval: 2,
        dateFormat: DateFormat('M/d'),
        labelRotation: 45, // Rotate labels for better readability
        edgeLabelPlacement: EdgeLabelPlacement.shift,
        labelIntersectAction: AxisLabelIntersectAction.rotate45,
      ),
      primaryYAxis: const NumericAxis(
        isVisible: true,
        title: AxisTitle(text: 'Weight'), // Label for Y axis
      ),
      series: <ColumnSeries<_ChartData, DateTime>>[
        ColumnSeries<_ChartData, DateTime>(
          dataSource: lineData,
          xValueMapper: (_ChartData detection, _) => detection.timestamp,
          yValueMapper: (_ChartData detection, _) => detection.weight,
        ),
      ],
    );
  }
}

/// Class to contain data to be used for for graphing
class _ChartData {
  _ChartData(this.timestamp, this.weight);

  final DateTime timestamp;
  final double weight;
}
