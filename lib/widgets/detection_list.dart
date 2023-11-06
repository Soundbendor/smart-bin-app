import 'package:flutter/material.dart';

class DetectionList extends StatelessWidget {

  final List detections;

  const DetectionList({
    super.key,
    required this.detections,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: detections.length,
      prototypeItem: const ListTile(),
      itemBuilder: (context, index) {
        return null;
      },
    );
  }
}
