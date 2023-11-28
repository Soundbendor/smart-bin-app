import 'package:flutter/material.dart';
import 'package:binsight_ai/database/models/detection.dart';
import 'package:binsight_ai/screens/main/detection_page.dart';

class DetectionLargeListItem extends StatelessWidget {
  final Detection detection;

  const DetectionLargeListItem({
    super.key,
    required this.detection,
  });

  DetectionLargeListItem.stub({super.key})
      : detection = Detection.createDefault();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DetectionPage(detection: detection)));
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade500,
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
            color: Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.all(9.0),
            child: FittedBox(
              child: Column(
                children: [
                  const Text("<Detection Food Names>", textScaleFactor: 1.75),
                  Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.shade700,
                          width: 2,
                        ),
                      ),
                      margin: const EdgeInsets.only(bottom: 12, top: 12),
                      child: Image.asset("assets/images/placeholder.png",
                          width: 200, height: 200)),
                  SizedBox(
                    width: 250,
                    child: Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Temperature"),
                              Text("Humidity"),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(detection.temperature.toString()),
                              Text(detection.humidity.toString()),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DetectionList extends StatelessWidget {
  final List<DetectionLargeListItem> detections;

  const DetectionList({
    super.key,
    required this.detections,
  });

  @override
  Widget build(BuildContext context) {
    if (detections.isEmpty) {
      return const SizedBox(
          width: double.infinity,
          child: Text("No detections yet", textAlign: TextAlign.left));
    } else {
      return Expanded(
        child: ListView.builder(
          itemCount: detections.length,
          prototypeItem: DetectionLargeListItem.stub(),
          scrollDirection: Axis.vertical,
          itemBuilder: (context, index) {
            return detections[index];
          },
        ),
      );
    }
  }
}
