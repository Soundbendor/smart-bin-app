import 'package:flutter/material.dart';

class DetectionList extends StatelessWidget {
  final List detections;

  const DetectionList({
    super.key,
    required this.detections,
  });

  @override
  Widget build(BuildContext context) {
    if (detections.isEmpty) {
      return const SizedBox(
        width: double.infinity,
        child: Text("No detections yet", textAlign: TextAlign.left)
      );
    } else {
      return ListView.builder(
        itemCount: detections.length,
        prototypeItem: const ListTile(),
        itemBuilder: (context, index) {
          return null;
        },
      );
    }
  }
}
