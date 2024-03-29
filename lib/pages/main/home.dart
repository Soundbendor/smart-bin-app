// Flutter imports:
import 'dart:convert';
import 'package:flutter/material.dart';

// Package imports:
import 'package:go_router/go_router.dart';

// Project imports:
import 'package:binsight_ai/database/models/detection.dart';
import 'package:binsight_ai/widgets/circular_chart.dart';
import 'package:binsight_ai/widgets/line_chart.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

/// The home page of the application
///
/// Contains an invitation to the user to annotate the latest detection
/// and a visual summary of all detections so far, as a circular chart and a bar graph.
class _HomePageState extends State<HomePage> {
  // All detections
  List<Detection> detections = [];
  // Map item names to total count of the item
  Map<String, int> labelCounts = {};
  // Map day to total compost weight
  Map<DateTime, double> weightCounts = {};
  late Future loadDetectionFuture;

  // Load all detections from the database
  @override
  void initState() {
    loadDetectionFuture = Detection.all().then((value) async {
      setState(() {
        detections = value;
      });
    });
    super.initState();
  }

  // Build the home page
  @override
  Widget build(BuildContext context) {
    // Populate the counts for the circular chart and bar graph
    populateCounts();

    // Get the latest image detection from the compost bin
    Detection? latest;
    if (detections.isNotEmpty) {
      latest = detections[0];
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "Review",
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                ),
                Expanded(
                  child: Image.asset(
                    'assets/images/transparent_bee.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Tap to Annotate Latest Image",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  latest != null
                      ? GestureDetector(
                          onTap: () => GoRouter.of(context)
                              .push("/main/detection/${latest!.imageId}"),
                          child: Image.asset(
                            'assets/images/header_compost.png',
                            fit: BoxFit.cover,
                            height: 200,
                          ),
                        )
                      : Container(), // Container to handle the case when latest is null
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Recap",
              style: Theme.of(context).textTheme.displayMedium,
            ),
          ),
          const SizedBox(height: 10),
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
                  const SizedBox(height: 10),
                  CircleChart(
                    data: labelCounts,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Trends",
              style: Theme.of(context).textTheme.displayMedium,
            ),
          ),
          const SizedBox(height: 10),
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
                  const SizedBox(height: 10),
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
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// Function to populate the weightCounts and labelCounts for the circular chart and bar graph
  void populateCounts() {
    // If there are detections
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
