// Flutter imports:
import 'dart:convert';
import 'package:binsight_ai/util/print.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:binsight_ai/database/models/detection.dart';
import 'package:binsight_ai/util/providers/detection_notifier.dart';
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
  // Map item names to total count of the item
  Map<String, int> labelCounts = {};
  // Map day to total compost weight
  Map<DateTime, double> weightCounts = {};
  //Label data

  Map categories = {};
  // Load all detections from the database
  @override
  void initState() {
    loadDetections();
    super.initState();
  }

  void loadDetections() {
    Provider.of<DetectionNotifier>(context, listen: false).getAll();
    loadCategories();
  }

  Future<void> loadCategories() async {
    final String response =
        await rootBundle.loadString('assets/data/categories.json');
    final data = await json.decode(response);
    setState(() {
      categories = data;
    });
  }

  void updateDetection(DetectionNotifier notifier) async {
    await notifier.getAll();
  }

  // Build the home page
  @override
  Widget build(BuildContext context) {
    // Listen for changes to the detections
    return Consumer<DetectionNotifier>(
      builder: (context, notifier, child) {
        final detections = notifier.detections;

        // Populate the counts for the circular chart and bar graph
        populateCounts(detections);

        // Get the latest image detection from the compost bin
        Detection? latest;
        if (detections.isNotEmpty) {
          latest = detections.first;
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
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
                          child: BarChart(
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
          ),
        );
      },
    );
  }

  /// Populate the weightCounts and labelCounts for the circular chart and bar graph
  void populateCounts(List<Detection> detections) {
    labelCounts = {};
    // If there are detections
    if (detections.isNotEmpty) {
      // Turn detections to a list of maps
      List<Map<String, dynamic>> detectionsMaps =
          detections.map((detection) => detection.toMap()).toList();
      debug('NUMBER OF DETECTIONS: ${detectionsMaps.length}');
      // Loop over all detections and increment the counts accordingly
      for (Map<String, dynamic> detection in detectionsMaps) {
        DateTime timestamp = DateTime.parse(detection["timestamp"]);
        DateTime monthDay =
            DateTime(timestamp.year, timestamp.month, timestamp.day);
        // Extract month and day from each timestamp, and use that as the key
        weightCounts[monthDay] =
            (weightCounts[monthDay] ?? 0.0) + detection["weight"];

        if (detection["boxes"] != null) {
          List<dynamic> boxesList = jsonDecode(detection["boxes"]);
          for (var label in boxesList) {
            String name = label['object_name'];
            name = name.toLowerCase();
            //Check singular and plural version of item
            String? category = categories[name];
            category ??= categories['${name}s'];
            category ??= "Undefined";
            labelCounts[category] = (labelCounts[category] ?? 0) + 1;
          }
          debug(labelCounts);
        }
      }
    }
  }
}
