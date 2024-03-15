// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:binsight_ai/database/models/detection.dart';
import 'package:binsight_ai/pages/detection/detection.dart';
import '../shared.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testInit();

  testWidgets("Incomplete detection displays pending title",
      (widgetTester) async {
    final originalErrorHandler = FlutterError.onError;
    FlutterError.onError = ignoreOverflowErrors(originalErrorHandler);
    final detection = Detection.fromMap({
      "imageId": "bar",
      "preDetectImgLink": "assets/images/placeholder.png",
      "timestamp": DateTime.now().toIso8601String(),
      "deviceId": "bar",
      "depthMapImgLink": "assets/images/placeholder.png",
      "irImgLink": "assets/images/placeholder.png",
      "weight": 1.0,
      "humidity": 0.5,
      "temperature": 20.0,
      "co2": 0.5,
      "vo2": 0.5,
    });

    await widgetTester.pumpWidget(makeTestableWidget(
        size: const Size(800, 600),
        child: DetectionPage(detection: detection)));
    await widgetTester.pumpAndSettle();
    expect(find.text("Detection bar: pending analysis..."), findsOneWidget);
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
      "weight": 10.0,
      "humidity": 1.5,
      "temperature": 20.0,
      "co2": 0.5,
      "vo2": 0.5,
      "boxes": '[["pineapple", [11.4, 16.5]],["chicken", [10.0, 292.8]]]',
    });

    await widgetTester.pumpWidget(makeTestableWidget(
        size: const Size(800, 600),
        child: DetectionPage(detection: detection)));
    await widgetTester.pumpAndSettle();
    expect(find.text("Detection foo: pineapple, chicken"), findsOneWidget);
    FlutterError.onError = originalErrorHandler;
  });
}
