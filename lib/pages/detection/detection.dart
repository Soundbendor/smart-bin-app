import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:binsight_ai/database/models/detection.dart';
import 'package:binsight_ai/widgets/detections.dart';
import 'package:binsight_ai/widgets/heading.dart';
import 'package:binsight_ai/widgets/image.dart';

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
              _DetectionHeader(detectionFuture: detectionFuture),
              const SizedBox(height: 16),
              FutureBuilder(
                future: detectionFuture,
                builder:
                    (BuildContext context, AsyncSnapshot<Detection?> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else {
                    final detection = snapshot.data;
                    return _DetectionCard(detection: detection!);
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
    final textTheme = Theme.of(context).textTheme;
    return Column(children: [
      GestureDetector(
          child: Center(
            child: DynamicImage(detection.preDetectImgLink,
                width: 350, height: 350),
          ),
          onTap: () => GoRouter.of(context)
              .push("/main/detection/${detection.imageId}/annotation")),
      const SizedBox(height: 16),
      SizedBox(
        width: 400,
        child: Row(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Temperature:", style: textTheme.labelLarge),
                    Text(
                      "Humidity:",
                      style: textTheme.labelLarge,
                    ),
                    Text(
                      "eCO2:",
                      style: textTheme.labelLarge,
                    ),
                    Text(
                      "tVOC:",
                      style: textTheme.labelLarge,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(detection.temperature.toString(),
                        style: textTheme.labelLarge),
                    Text(detection.humidity.toString(),
                        style: textTheme.labelLarge),
                    Text(detection.co2.toString(), 
                        style: textTheme.labelLarge),
                    Text(detection.vo2.toString(), 
                        style: textTheme.labelLarge),
                  ],
                ),
              ),
            ),
          ],
        ),
      )
    ]);
  }
}

/// The header for the detection page, which displays the title.
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
            return Heading(text: formatDetectionTitle(snapshot.data!));
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
