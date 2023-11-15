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
            Center(
              child: Image.asset(
                detection.preDetectImgLink,
                width: 400,
                height: 400,
              ),
            ),
            const SizedBox(height: 16),
            const Column(
              children: [
                Row(
                  children: [
                    Expanded(child: Center(child: Text("Temp: 100°C"))),
                    Expanded(child: Center(child: Text("Humidity: 50%"))),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: Center(child: Text("eCO2: 500ppm"))),
                    Expanded(child: Center(child: Text("tVOC: 500ppm"))),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
