// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:syncfusion_flutter_charts/charts.dart';

UniqueKey graphKey = UniqueKey();

/// Circle/doughnut graph to display names and ratios of items composted
class CircleChart extends StatefulWidget {
  // Map with the item name as the key and total count of that item as the value
  final Map data;

  const CircleChart({
    super.key,
    required this.data,
  });
  @override
  State<CircleChart> createState() => _CircleChartState();
}

class _CircleChartState extends State<CircleChart> {
  @override
  Widget build(BuildContext context) {
    // Create doughnut data for the doughnut chart construction using the name and counts in data
    List<_ChartData> doughnutData = widget.data.entries.map((entry) {
      return _ChartData(entry.value, entry.key);
    }).toList();

    // Creates a doughnut chart using the doughnutData
    return Center(
      child: SfCircularChart(
        key: graphKey,
        legend: const Legend(isVisible: true, position: LegendPosition.left),
        palette: const [
          Color.fromARGB(255, 33, 204, 231),
          Color.fromARGB(255, 252, 154, 154),
          Color.fromARGB(255, 115, 216, 194),
          Color.fromARGB(255, 243, 195, 124),
          Color.fromARGB(255, 108, 157, 235),
          Color.fromARGB(255, 156, 240, 155),
          Color.fromARGB(255, 237, 151, 71),
          Color.fromARGB(255, 202, 125, 200),
          Color.fromARGB(255, 212, 115, 185),
        ],
        series: <PieSeries<_ChartData, String>>[
          PieSeries<_ChartData, String>(
            radius: '65%',
            explode: true,
            explodeIndex: null,
            dataSource: doughnutData,
            xValueMapper: (_ChartData data, _) => data.text!,
            yValueMapper: (_ChartData data, _) => data.xData,
            dataLabelMapper: (_ChartData data, _) => data.text!,
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
              labelPosition: ChartDataLabelPosition.inside,
              overflowMode: OverflowMode.hide,
            ),
          ),
        ],
      ),
    );
  }
}

// Class to contain data to be used for for graphing
class _ChartData {
  _ChartData(this.xData, [this.text]);
  final num xData;
  String? text;
}
