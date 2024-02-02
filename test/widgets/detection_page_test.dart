import 'package:binsight_ai/database/models/detection.dart';
import 'package:binsight_ai/screens/pages/detection_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../shared.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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
      "boxes": '[{"pineapple":0.6},{"chicken":0.8}]',
    });

    await widgetTester.pumpWidget(makeTestableWidget(
        size: const Size(800, 600),
        child: DetectionPage(detection: detection)));
    await widgetTester.pumpAndSettle();
    expect(find.text("Detection foo: pineapple, chicken"), findsOneWidget);
    FlutterError.onError = originalErrorHandler;
  });
}
