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

/// The home page of the application, displaying the user's latest image detection
/// and a visual summary of their detections.
class _HomePageState extends State<HomePage> {
  // All detections
  List<Detection> detections = [];
  // Map item names to total count of the item
  Map<String, int> labelCounts = {};
  // Map day to total compost weight
  Map<DateTime, double> weightCounts = {};
  late Future loadDetectionFuture;

  // Load all the detections upon building
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
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    
    populateCounts();
    
    Detection? latest;
    if (detections.isNotEmpty) {
      latest = detections[0];
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Review",
              style: Theme.of(context).textTheme.displayMedium,
            ),
          ),
                    SizedBox(height: 10),
          if (latest != null) ...[
            GestureDetector(
              onTap: () => GoRouter.of(context)
                  .push("/main/detection/${latest!.imageId}"),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Placeholder(
                        fallbackHeight: 200,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Tap to Annotate Latest Image",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Recap",
              style: Theme.of(context).textTheme.displayMedium,
            ),
          ),
          SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Detections by Food Category",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 10),
                  CircleChart(
                    data: labelCounts,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Trends",
              style: Theme.of(context).textTheme.displayMedium,
            ),
          ),
          SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Compost Over Time",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 10),
                  FractionallySizedBox(
                    widthFactor: 0.9,
                    child: LineChart(
                      data: weightCounts,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  /// Function to populate the weightCounts and labelCounts
  void populateCounts() {
    if (detections.isNotEmpty) {
      // Turn detections to a list of maps
      List<Map<String, dynamic>> detectionsMaps =
          detections.map((detection) => detection.toMap()).toList();
      // Loop over all detections and increment the counts accordingly
      for (Map<String, dynamic> detection in detectionsMaps) {
        DateTime timestamp = DateTime.parse(detection["timestamp"]);
        DateTime monthDay =
            DateTime(timestamp.year, timestamp.month, timestamp.day);
        // Extract month and day from each timestamp, and use that as the key
        weightCounts[monthDay] =
            (weightCounts[monthDay] ?? 0.0) + detection["weight"];
        if (detection["boxes"] != null) {
          String boxes = detection["boxes"];
          List<dynamic> boxesList = jsonDecode(boxes);
          // If the boxes field is populated, loop over the list and extract the name that's at index 0 of each item
          for (var label in boxesList) {
            String name = label[0];
            labelCounts[name] = (labelCounts[name] ?? 0) + 1;
          }
        }
      }
    }
  }
}

/// Button to navigate to the latest detection's page
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
