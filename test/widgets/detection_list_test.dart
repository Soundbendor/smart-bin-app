import 'package:binsight_ai/database/models/detection.dart';
import 'package:binsight_ai/widgets/detections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../shared.dart';

void main() {
  testWidgets("Detection list (incomplete) displays correct title",
      (widgetTester) async {
    final detection = Detection.fromMap({
      "imageId": "bar",
      "preDetectImgLink": "example.com/bar.jpg",
      "timestamp": DateTime.now().toIso8601String(),
      "deviceId": "bar",
      // "postDetectImgLink": "http://example.com/bar-post.jpg",
      "depthMapImgLink": "example.com/bar-depth.jpg",
      "irImgLink": "example.com/bar-ir.jpg",
      "weight": 1.0,
      "humidity": 0.5,
      "temperature": 20.0,
      "co2": 0.5,
      "vo2": 0.5,
      // "boxes": "[]",
    });

    await widgetTester.pumpWidget(makeTestableWidget(
      size: const Size(800, 600),
      child: DetectionSmallListItem(detection: detection),
    ));
    expect(find.text("Detection bar: pending analysis..."), findsOneWidget);

    await widgetTester.pumpWidget(makeTestableWidget(
      size: const Size(800, 600),
      child: DetectionLargeListItem(detection: detection),
    ));
    expect(find.text("Detection bar: pending analysis..."), findsOneWidget);
  });
}
