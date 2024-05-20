// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:binsight_ai/database/models/detection.dart';
import 'package:binsight_ai/widgets/detections.dart';
import '../shared.dart';

/// Tests for the detection list
void main() {
  testInit();

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
      "transcription": "pineapple, chicken",
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

  testWidgets("Detection list (complete) displays correct title",
      (widgetTester) async {
    final detection = Detection.fromMap({
      "imageId": "foo",
      "preDetectImgLink": "example.com/foo.jpg",
      "timestamp": DateTime.now().toIso8601String(),
      "deviceId": "foo",
      "postDetectImgLink": "example.com/foo-post.jpg",
      "depthMapImgLink": "example.com/foo-depth.jpg",
      "irImgLink": "example.com/foo-ir.jpg",
      "transcription": "pineapple, chicken",
      "weight": 10.0,
      "humidity": 1.5,
      "temperature": 20.0,
      "co2": 0.5,
      "vo2": 0.5,
      "boxes": '[["pineapple", [11.4, 16.5]],["chicken", [10.0, 292.8]]]',
    });
    await widgetTester.pumpWidget(makeTestableWidget(
      size: const Size(800, 600),
      child: DetectionSmallListItem(detection: detection),
    ));
    expect(find.text("Detection foo: pineapple, chicken"), findsOneWidget);

    await widgetTester.pumpWidget(makeTestableWidget(
      size: const Size(800, 600),
      child: DetectionLargeListItem(detection: detection),
    ));
    expect(find.text("Detection foo: pineapple, chicken"), findsOneWidget);
  });
}
