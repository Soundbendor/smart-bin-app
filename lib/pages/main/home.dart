import 'dart:convert';

import 'package:binsight_ai/database/models/detection.dart';
import 'package:binsight_ai/widgets/circular_chart.dart';
import 'package:flutter/material.dart';

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
    populateCounts();

    return SingleChildScrollView(
      child: Column(
        children: [
          CircleChart(
            data: labelCounts,
            title: "Detections by food category",
          ),
        ],
      ),
    );
  }

  void populateCounts() {
    if (detections.isNotEmpty) {
      List<Map<String, dynamic>> detectionsMaps =
          detections.map((detection) => detection.toMap()).toList();
      for (Map<String, dynamic> detection in detectionsMaps) {
        String boxes = detection["boxes"];
        List<dynamic> boxesList = jsonDecode(boxes);
        for (var label in boxesList) {
          String name = label[0];
          labelCounts[name] = (labelCounts[name] ?? 0) + 1;
        }
      }
    }
  }
}
