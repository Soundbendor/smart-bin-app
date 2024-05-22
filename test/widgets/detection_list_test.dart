// Flutter imports:
import 'dart:io';

import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:binsight_ai/database/models/detection.dart';
import 'package:binsight_ai/widgets/detections.dart';
import 'package:path_provider/path_provider.dart';
import '../shared.dart';

/// Tests for the detection list
void main() {
  testInit();

  testWidgets("Detection list (incomplete) displays correct title",
      (widgetTester) async {
    Directory dir = await getApplicationDocumentsDirectory();
    final detection = Detection.fromMap(
      {
        "imageId": "foo-2",
        "timestamp":
            DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        "deviceId": "bar",
        "postDetectImgLink": "https://placehold.co/512x512",
        "depthMapImgLink": "https://placehold.co/512x512",
        "irImgLink": "https://placehold.co/512x512",
        "transcription": "orange peels",
        "weight": 10.0,
        "humidity": 1.5,
        "temperature": 20.0,
        "co2": 0.5,
        "vo2": 0.5,
        "pressure": 10.0,
        "iaq": 10.0,
        "boxes": "[]"
      },
    );

    await widgetTester.pumpWidget(makeTestableWidget(
      size: const Size(800, 600),
      child: DetectionSmallListItem(detection: detection, baseDir: null),
    ));
    expect(
        find.text(
            "Detection ${detection.deviceId}-${detection.timestamp.toIso8601String()}"),
        findsOneWidget);

    await widgetTester.pumpWidget(makeTestableWidget(
      size: const Size(800, 600),
      child: DetectionLargeListItem(
        detection: detection,
<<<<<<< HEAD
        baseDir: dir,
=======
        baseDir: Directory("/test"),
>>>>>>> dev
      ),
    ));
    expect(
        find.text(
            "Detection ${detection.deviceId}-${detection.timestamp.toIso8601String()}"),
        findsOneWidget);
  });

  testWidgets("Detection list (complete) displays correct title",
      (widgetTester) async {
<<<<<<< HEAD
    Directory dir = await getApplicationDocumentsDirectory();
=======
    Directory dir = Directory("/test");
>>>>>>> dev
    final detection = Detection.fromMap(
      {
        "imageId": "foo",
        "timestamp":
            DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        "deviceId": "bar",
        "postDetectImgLink": "https://placehold.co/512x512",
        "depthMapImgLink": "https://placehold.co/512x512",
        "irImgLink": "https://placehold.co/512x512",
        "transcription": "orange peels",
        "weight": 10.0,
        "humidity": 1.5,
        "temperature": 20.0,
        "co2": 0.5,
        "vo2": 0.5,
        "pressure": 10.0,
        "iaq": 10.0,
        "boxes": "[]"
      },
    );

    await widgetTester.pumpWidget(makeTestableWidget(
      size: const Size(800, 600),
      child: DetectionSmallListItem(detection: detection, baseDir: dir),
    ));
    expect(find.text("Detection ${detection.imageId}"), findsOneWidget);

    await widgetTester.pumpWidget(makeTestableWidget(
      size: const Size(800, 600),
      child: DetectionLargeListItem(detection: detection, baseDir: dir),
    ));
    expect(find.text("Detection ${detection.imageId}"), findsOneWidget);
  });
}
