import 'dart:convert';

import 'package:binsight_ai/database/models/detection.dart';
import 'package:binsight_ai/util/print.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Detection> detections = [];
  Map<String, int> labelCounts = {};
  late Future loadDetectionFuture;

  @override
  void initState() {
    loadDetectionFuture = Detection.all().then((value) async {
      setState(() {
        detections = value;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (detections.isNotEmpty) {
      List<Map<String, dynamic>> detectionsMaps =
          detections.map((detection) => detection.toMap()).toList();
      for (Map<String, dynamic> detection in detectionsMaps) {
        String boxes = detection["boxes"];
        List<dynamic> boxesList = jsonDecode(boxes);
        for (var label in boxesList) {
          String fruitName = label[0];
          labelCounts[fruitName] = (labelCounts[fruitName] ?? 0) + 1;
        }
      }
    }

    debug(labelCounts);
    List<_PieData> pieData = labelCounts.entries.map((entry) {
      return _PieData(entry.value, entry.key);
    }).toList();

    return Center(
      child: SfCircularChart(
        title: const ChartTitle(text: 'Detections by food category'),
        legend: const Legend(isVisible: true),
        series: <PieSeries<_PieData, String>>[
          PieSeries<_PieData, String>(
            explode: true,
            explodeIndex: 0,
            dataSource: pieData,
            xValueMapper: (_PieData data, _) => data.text!,
            yValueMapper: (_PieData data, _) => data.xData,
            dataLabelMapper: (_PieData data, _) => data.text!,
            dataLabelSettings: const DataLabelSettings(isVisible: true),
          ),
        ],
      ),
    );
  }
}

class _PieData {
  _PieData(this.xData, [this.text]);
  final num xData;
  String? text;
}
