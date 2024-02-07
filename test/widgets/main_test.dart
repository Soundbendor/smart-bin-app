// This file tests the entry point.
import 'package:binsight_ai/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {

  testWidgets("Initial location is at set-up when devices don't exist", (widgetTester) async {
    setRoutes([
      GoRoute(
        name: 'set-up',
        path: '/set-up',
        builder: (BuildContext context, GoRouterState state) {
          return const Text("Set up");
        },
      ),
      GoRoute(
        name: 'main',
        path: '/main',
        builder: (BuildContext context, GoRouterState state) {
          return const Text("Main");
        },
      ),
    ]);

    await widgetTester.pumpWidget(BinsightAiApp(skipSetUp: false));
    expect(
      router.routerDelegate.currentConfiguration.last.matchedLocation,
      equals("/set-up")
    );
  });

  testWidgets("Initial location is at main when devices exist", (widgetTester) async {
    setRoutes([
      GoRoute(
        name: 'set-up',
        path: '/set-up',
        builder: (BuildContext context, GoRouterState state) {
          return const Text("Set up");
        },
      ),
      GoRoute(
        name: 'main',
        path: '/main',
        builder: (BuildContext context, GoRouterState state) {
          return const Text("Main");
        },
      ),
    ]);

    await widgetTester.pumpWidget(BinsightAiApp(skipSetUp: true));
    expect(
      router.routerDelegate.currentConfiguration.last.matchedLocation,
      equals("/main")
    );
  });

}
