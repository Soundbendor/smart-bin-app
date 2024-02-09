import 'package:binsight_ai/database/models/detection.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Detection> detections = [];
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
    //TODO: Map detections to _PieData(category count, category)

    List<_PieData> pieData = [
      _PieData(10, 'Orange'),
      _PieData(20, 'Apple'),
      _PieData(15, 'Banana'),
    ];

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
