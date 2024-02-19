import 'package:binsight_ai/database/models/detection.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class LineChart extends StatelessWidget {
  final List<Detection> detections;
  const LineChart({super.key, required this.detections});

  @override
  Widget build(BuildContext context) {
    List<_ChartData> lineData = detections.map((detection) {
      return _ChartData(detection.timestamp, detection.weight);
    }).toList();
    return SfCartesianChart(
      title: const ChartTitle(text: "Compost over time"),
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
  final double? weight;
}
