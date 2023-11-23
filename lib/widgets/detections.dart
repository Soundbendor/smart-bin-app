import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DetectionListItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String image;

  const DetectionListItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.image,
  });

  const DetectionListItem.stub({super.key})
      : title = "Stub Title",
        subtitle = "Stub Subtitle",
        image = "assets/images/placeholder.png";

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.asset(image),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: () => {
        context.goNamed('annotation', pathParameters: {'imagePath': image})
      },
    );
  }
}

class DetectionList extends StatelessWidget {
  final List<DetectionListItem> detections;

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
          prototypeItem: const DetectionListItem.stub(),
          scrollDirection: Axis.vertical,
          itemBuilder: (context, index) {
            return detections[index];
          },
        ),
      );
    }
  }
}
