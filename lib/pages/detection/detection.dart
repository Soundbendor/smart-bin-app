// Flutter imports:
import 'dart:io';

import 'package:binsight_ai/util/image.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:go_router/go_router.dart';

// Project imports:
import 'package:binsight_ai/database/models/detection.dart';
import 'package:binsight_ai/widgets/detections.dart';
import 'package:binsight_ai/widgets/heading.dart';
import 'package:path_provider/path_provider.dart';

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
class _DetectionCard extends StatefulWidget {
  final Detection detection;
  const _DetectionCard({required this.detection});

  @override
  State<_DetectionCard> createState() => _DetectionCardState();
}

class _DetectionCardState extends State<_DetectionCard> {
  Directory? appDocDir;

  @override
  void initState() {
    getDirectory();
    super.initState();
  }

  Future<void> getDirectory() async {
    Directory dir = await getApplicationDocumentsDirectory();
    setState(() {
      appDocDir = dir;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    File? image = getImage(widget.detection.postDetectImgLink!, appDocDir);
    final textTheme = Theme.of(context).textTheme;

    return Card(
      color: colorScheme.onPrimary,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        child: Column(
          children: [
            SizedBox(
              width: 350,
              height: 350,
              child: Stack(
                children: [
                  Container(
                      margin: const EdgeInsets.only(bottom: 10, top: 10),
                      child: Center(
                        child: image != null
                            ? Image.file(image, width: 350, height: 350)
                            : Container(),
                      )),
                  // Annotate Image Button
                  Positioned(
                    bottom: 16,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(Icons.edit),
                      iconSize: 30,
                      tooltip: "Annotate Image",
                      onPressed: () {
                        GoRouter.of(context).push(
                            "/main/detection/${widget.detection.imageId}/annotation");
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                          colorScheme.primary.withAlpha(200),
                        ),
                        shape: WidgetStateProperty.all(const CircleBorder()),
                      ),
                      color: colorScheme.onPrimary,
                      splashColor: colorScheme.onSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDataField("Transcription: ",
                    widget.detection.transcription.toString(), textTheme),
                _buildDataField("Temperature: ",
                    widget.detection.temperature.toString(), textTheme),
                _buildDataField("Weight: ", 
                    widget.detection.weight.toString(), textTheme),
                _buildDataField("Total Weight: ",
                    widget.detection.totalWeight.toString(), textTheme),
                _buildDataField("Humidity: ",
                    widget.detection.humidity.toString(), textTheme),
                _buildDataField("CO2 Equivalent: ",
                    widget.detection.co2.toString(), textTheme),
                _buildDataField("Pressure: ",
                    widget.detection.pressure.toString(), textTheme),
                _buildDataField("Indoor Air Quality: ",
                    widget.detection.iaq.toString(), textTheme),
                _buildDataField("Total VOCs: ",
                    widget.detection.vo2.toString(), textTheme),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Creates a row with a title and a value to build the sensor data fields.
  Widget _buildDataField(String title, String value, TextTheme textStyle) {
    return Row(
      children: [
        Text(title, style: textStyle.titleMedium),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            value,
            style: textStyle.labelMedium,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
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
          const Icon(Icons.arrow_back_ios, size: 30),
          Text("Back to list", 
          style: textTheme.headlineSmall),
        ],
      ),
      onTap: () => GoRouter.of(context).pop(),
    );
  }
}
