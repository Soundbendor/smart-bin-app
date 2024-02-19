import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

UniqueKey graphKey = UniqueKey();

class CircleChart extends StatefulWidget {
  final Map data;
  final String title;
  const CircleChart({super.key, required this.data, required this.title});
  @override
  State<CircleChart> createState() => _CircleChartState();
}

class _CircleChartState extends State<CircleChart> {
  @override
  Widget build(BuildContext context) {
    List<_ChartData> pieData = widget.data.entries.map((entry) {
      return _ChartData(entry.value, entry.key);
    }).toList();

    return Center(
      child: SfCircularChart(
        key: graphKey,
        title: ChartTitle(text: widget.title),
        legend: const Legend(isVisible: true),
        palette: const [
          Color(0xFF9FDEE7),
          Color(0xFFFF9E9E),
          Color(0xFF9CED9A),
          Color(0xFFF0C27C),
          Color(0xFFD0B4CF),
        ],
        series: <DoughnutSeries<_ChartData, String>>[
          DoughnutSeries<_ChartData, String>(
            radius: '65%',
            explode: true,
            explodeIndex: 0,
            dataSource: pieData,
            xValueMapper: (_ChartData data, _) => data.text!,
            yValueMapper: (_ChartData data, _) => data.xData,
            dataLabelMapper: (_ChartData data, _) => data.text!,
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
              labelPosition: ChartDataLabelPosition.outside,
              overflowMode: OverflowMode.shift,
              connectorLineSettings: ConnectorLineSettings(
                  type: ConnectorType.line, length: "50%"),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartData {
  _ChartData(this.xData, [this.text]);
  final num xData;
  String? text;
}
