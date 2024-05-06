// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:go_router/go_router.dart';

// Project imports:
import 'package:binsight_ai/database/models/detection.dart';
import 'package:binsight_ai/widgets/detections.dart';
import 'package:binsight_ai/widgets/heading.dart';
import 'package:binsight_ai/widgets/image.dart';
import 'package:binsight_ai/widgets/statistic_card.dart';

/// Displays information about a single detection.
class DetectionPage extends StatelessWidget {
  final Future<Detection?> detectionFuture;

  DetectionPage({super.key, required Detection detection})
      : detectionFuture = Future.value(detection);
  DetectionPage.fromId({super.key, required String detectionId})
      : detectionFuture = Detection.find(detectionId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _BackToListButton(),
              const SizedBox(height: 16),
              _DetectionHeader(detectionFuture: detectionFuture),
              const SizedBox(height: 16),
              FutureBuilder(
                future: detectionFuture,
                builder:
                    (BuildContext context, AsyncSnapshot<Detection?> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else {
                    final detection = snapshot.data!;
                    return _DetectionCard(detection: detection);
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

/// The card that displays the detection information, including the image and sensor data.
class _DetectionCard extends StatelessWidget {
  final Detection detection;
  const _DetectionCard({required this.detection});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      color: colorScheme.onPrimary,
      child: Padding(
        padding: const EdgeInsets.only(
          top: 20,
          left: 5,
          right: 5,
          bottom: 5,
        ),
        child: SingleChildScrollView(
          child: Column(children: [
            SizedBox(
              width: 350,
              height: 350,
              child: Stack(
                children: [
                  Center(
                    child: DynamicImage(detection.postDetectImgLink!,
                        width: 350, height: 350),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: IconButton(
                      onPressed: () {
                        GoRouter.of(context).push(
                            "/main/detection/${detection.imageId}/annotation");
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                          Theme.of(context).colorScheme.primary.withAlpha(200),
                        ),
                        shape: MaterialStateProperty.all(const CircleBorder()),
                      ),
                      color: Theme.of(context).colorScheme.onPrimary,
                      icon: const Icon(Icons.edit, size: 30),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 400,
              child: Wrap(
                children: [
                  StatisticCard(
                      title: "Temperature",
                      value: detection.temperature.toString()),
                  StatisticCard(
                      title: "Weight", value: detection.weight.toString()),
                  StatisticCard(
                      title: "Humidity", value: detection.humidity.toString()),
                  StatisticCard(
                      title: "CO2 Equivalent", value: detection.co2.toString()),
                  StatisticCard(
                      title: "Total Volatile Organic Compounds",
                      value: detection.vo2.toString()),
                  StatisticCard(
                      title: "Pressure", value: detection.pressure.toString()),
                  StatisticCard(
                      title: "Indoor Air Quality",
                      value: detection.iaq.toString()),
                ],
              ),
            )
          ]),
        ),
      ),
    );
  }
}

/// The header for the detection page, which displays the title and timestamp.
class _DetectionHeader extends StatelessWidget {
  const _DetectionHeader({
    required this.detectionFuture,
  });

  final Future<Detection?> detectionFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: detectionFuture,
        builder: (BuildContext context, AsyncSnapshot<Detection?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Heading(text: "Loading...");
          } else {
            final detection = snapshot.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Heading(text: formatDetectionTitle(detection)),
                Text(
                  "Timestamp: ${detection.timestamp}",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            );
          }
        });
  }
}

/// A button that navigates back to the list of detections.
class _BackToListButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      child: Row(
        children: [
          const Icon(Icons.arrow_back_ios),
          Text("Back to list", style: textTheme.labelLarge),
        ],
      ),
      onTap: () => GoRouter.of(context).pop(),
    );
  }
}
