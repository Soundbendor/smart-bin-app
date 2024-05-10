// This file tests the entry point.

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:binsight_ai/main.dart';
import 'package:binsight_ai/util/routes.dart';
import 'package:binsight_ai/util/providers/setup_key_notifier.dart';
import '../shared.dart';

/// Tests for main page
void main() {
  testInit();

  testWidgets("Initial location is at set-up when devices don't exist",
      (widgetTester) async {
    final originalErrorHandler = FlutterError.onError;
    FlutterError.onError = ignoreOverflowErrors(originalErrorHandler);
    router = null;
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

    await widgetTester.pumpWidget(makeTestableWidget(
        child: MultiProvider(providers: [Provider(create: (_) => SetupKeyNotifier())], child: const BinsightAiApp(skipSetUp: false)),
        size: const Size(800, 600)));
    await widgetTester.pumpAndSettle(const Duration(seconds: 10));
    expect(router!.routerDelegate.currentConfiguration.last.matchedLocation,
        equals("/set-up"));
    FlutterError.onError = originalErrorHandler;
  });

  testWidgets("Initial location is at main when devices exist",
      (widgetTester) async {
    final originalErrorHandler = FlutterError.onError;
    FlutterError.onError = ignoreOverflowErrors(originalErrorHandler);
    router = null;
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

    await widgetTester.pumpWidget(makeTestableWidget(
        child: const BinsightAiApp(skipSetUp: true),
        size: const Size(800, 600)));
    await widgetTester.pumpAndSettle();
    expect(router!.routerDelegate.currentConfiguration.last.matchedLocation,
        equals("/main"));
    FlutterError.onError = originalErrorHandler;
  });
}
