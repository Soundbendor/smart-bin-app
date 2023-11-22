import 'package:flutter/material.dart';
import 'package:waste_watchers/database/models/detection.dart';
import 'package:waste_watchers/widgets/heading.dart';

class DetectionPage extends StatelessWidget {
  final Detection detection;

  const DetectionPage({super.key, required this.detection});

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
              onTap: () => Navigator.pop(context),
            ),
            const Heading(text: "Detection"),
            const SizedBox(height: 16),
            Center(
              child: Image.asset(
                detection.preDetectImgLink,
                width: 350,
                height: 350,
              ),
            ),
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
                          Text(detection.temperature.toString()),
                          Text(detection.humidity.toString()),
                          Text(detection.co2.toString()),
                          Text(detection.vo2.toString()),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
