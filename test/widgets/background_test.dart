import 'dart:io';

import 'package:binsight_ai/widgets/background.dart';
import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';

import '../shared.dart';

void main() {
  testWidgets("Background is properly initialized when provided valid values.",
      (widgetTester) async {
    final originalErrorHandler = FlutterError.onError;
    FlutterError.onError = ignoreOverflowErrors(originalErrorHandler);

    await widgetTester.pumpWidget(
      makeTestableWidget(
        size: const Size(800, 600),
        child: const CustomBackground(
          imageURL: "assets/images/load_screen.png",
          child: Text("Custom background test"),
        ),
      ),
    );

    expect(find.byWidgetPredicate(
    (Widget widget) => widget is Container &&
                      widget.decoration is BoxDecoration &&
                      (widget.decoration as BoxDecoration).image is DecorationImage &&
                      ((widget.decoration as BoxDecoration).image as DecorationImage).image is AssetImage,
  ), findsOneWidget);
    expect(find.text('Custom background test'), findsOneWidget);
    FlutterError.onError = originalErrorHandler;
  });
}
