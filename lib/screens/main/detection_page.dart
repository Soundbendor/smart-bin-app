import 'package:binsight_ai/screens/main/annotation.dart';
import 'package:binsight_ai/widgets/detections.dart';
import 'package:flutter/material.dart';
import 'package:binsight_ai/database/models/detection.dart';
import 'package:binsight_ai/widgets/heading.dart';
import 'package:go_router/go_router.dart';

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
        child: Column(
          children: [
            GestureDetector(
              child: const Row(
                children: [
                  Icon(Icons.arrow_back_ios),
                  Text("Back to list"),
                ],
              ),
              onTap: () => context.goNamed('detections'),
            ),
            FutureBuilder(
                future: detectionFuture,
                builder:
                    (BuildContext context, AsyncSnapshot<Detection?> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Heading(text: "Loading...");
                  } else {
                    return Heading(text: formatDetectionTitle(snapshot.data!));
                  }
                }),
            const SizedBox(height: 16),
            FutureBuilder(
              future: detectionFuture,
              builder:
                  (BuildContext context, AsyncSnapshot<Detection?> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else {
                  final detection = snapshot.data!;
                  return Column(children: [
                    GestureDetector(
                        child: Center(
                          child: detection!.preDetectImgLink.startsWith("http")
                              ? Image.network(
                                  detection!.preDetectImgLink,
                                  width: 350,
                                  height: 350,
                                )
                              : Image.asset(
                                  detection!.preDetectImgLink,
                                  width: 350,
                                  height: 350,
                                ),
                        ),
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AnnotationPage(
                                    imageLink: detection!.preDetectImgLink)))),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 400,
                      child: Row(
                        children: [
                          const Expanded(
                            child: Center(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Temperature:"),
                                  Text("Humidity:"),
                                  Text("eCO2:"),
                                  Text("tVOC:"),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(detection!.temperature.toString()),
                                  Text(detection!.humidity.toString()),
                                  Text(detection!.co2.toString()),
                                  Text(detection!.vo2.toString()),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ]);
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
