import 'package:binsight_ai/screens/main/annotation.dart';
import 'package:binsight_ai/widgets/detections.dart';
import 'package:flutter/material.dart';
import 'package:binsight_ai/database/models/detection.dart';
import 'package:binsight_ai/widgets/heading.dart';
import 'package:go_router/go_router.dart';

/// Displays information about a single detection.
class DetectionPage extends StatefulWidget {
  final Detection? detection;
  final String? detectionId;

  const DetectionPage({super.key, required this.detection})
      : detectionId = null;
  const DetectionPage.fromId({super.key, required String this.detectionId})
      : detection = null;

  @override
  State<DetectionPage> createState() {
    return _DetectionPageState();
  }
}

class _DetectionPageState extends State<DetectionPage> {
  Detection? detection;
  Future? detectionFuture;

  @override
  void initState() {
    if (widget.detection != null) {
      detection = widget.detection;
    } else if (widget.detectionId != null) {
      detectionFuture = Detection.find(widget.detectionId!).then((value) {
        setState(() {
          detection = value;
        });
      });
    }
    super.initState();
  }

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
            Heading(text: formatDetectionTitle(detection!)),
            const SizedBox(height: 16),
            FutureBuilder(
              future: detectionFuture,
              builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else {
                  return Column(children: [
                    GestureDetector(
                        child: Center(
                          child: Image.asset(
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
