// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:binsight_ai/database/models/detection.dart';
import 'package:binsight_ai/pages/detection/detection.dart';
import '../shared.dart';

/// Tests for the detection page
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testInit();

  testWidgets("Incomplete detection displays pending title",
      (widgetTester) async {
    final originalErrorHandler = FlutterError.onError;
    FlutterError.onError = ignoreOverflowErrors(originalErrorHandler);
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
        child: DetectionPage(detection: detection)));
    await widgetTester.pumpAndSettle();
    expect(find.text("Detection ${detection.imageId}"), findsOneWidget);
    FlutterError.onError = originalErrorHandler;
  });

  testWidgets("Complete detection displays correct title",
      (widgetTester) async {
    final originalErrorHandler = FlutterError.onError;
    FlutterError.onError = ignoreOverflowErrors(originalErrorHandler);
    final detection = Detection.fromMap({
      "imageId": "foo",
      "preDetectImgLink": "assets/images/placeholder.png",
      "timestamp": DateTime.now().toIso8601String(),
      "deviceId": "foo",
      "postDetectImgLink": "assets/images/placeholder.png",
      "depthMapImgLink": "assets/images/placeholder.png",
      "irImgLink": "assets/images/placeholder.png",
      "transcription": "pineapple, chicken",
      "weight": 10.0,
      "pressure": 0.5,
      "iaq": 0.5,
      "humidity": 1.5,
      "temperature": 20.0,
      "co2": 0.5,
      "vo2": 0.5,
      "boxes": '''
        [
          {
            "object_name": "Pineapple",
            "xy_coord_list": [
              [11.1, 16.4],
              [11.3, 16.5]
            ]
          },
          {
            "object_name": "Chicken",
            "xy_coord_list": [
              [11.1, 16.4],
              [11.3, 16.5]
            ]
          }
        ]''',
    });

    await widgetTester.pumpWidget(makeTestableWidget(
        size: const Size(800, 600),
        child: DetectionPage(detection: detection)));
    await widgetTester.pumpAndSettle();
    expect(find.text("Detection ${detection.imageId}"), findsOneWidget);
    FlutterError.onError = originalErrorHandler;
  });
}
