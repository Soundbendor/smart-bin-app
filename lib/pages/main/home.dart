import 'dart:convert';

import 'package:binsight_ai/database/models/detection.dart';
import 'package:binsight_ai/widgets/circular_chart.dart';
import 'package:binsight_ai/widgets/line_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
    Detection? latest;
    if (detections.isNotEmpty) {
      latest = detections[0];
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          if (latest != null)
            LabelButton(
                detection: latest, text: "Label Your Latest Annotation!"),
          CircleChart(
            data: labelCounts,
            title: "Detections by food category",
          ),
          LineChart(detections: detections)
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

class LabelButton extends StatelessWidget {
  const LabelButton({
    super.key,
    required this.detection,
    required this.text,
  });

  final String text;
  final Detection? detection;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: .75,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextButton.icon(
          icon: const Icon(Icons.edit_outlined),
          onPressed: () => GoRouter.of(context)
              .push("/main/detection/${detection!.imageId}"),
          label: Text(text),
        ),
      ),
    );
  }
}
