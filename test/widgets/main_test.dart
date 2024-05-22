// This file tests the entry point.

// Flutter imports:
import 'package:binsight_ai/util/shared_preferences.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:binsight_ai/main.dart';
import 'package:binsight_ai/util/routes.dart';
import 'package:binsight_ai/util/providers/detection_notifier.dart';
import 'package:binsight_ai/util/providers/setup_key_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../shared.dart';

class FakeSharedPreferences implements SharedPreferences {
  @override
  String? getString(String key) {
    return "";
  }

  @override
  Future<bool> clear() {
    throw UnimplementedError();
  }

  @override
  Future<bool> commit() {
    throw UnimplementedError();
  }

  @override
  bool containsKey(String key) {
    throw UnimplementedError();
  }

  @override
  Object? get(String key) {
    throw UnimplementedError();
  }

  @override
  bool? getBool(String key) {
    throw UnimplementedError();
  }

  @override
  double? getDouble(String key) {
    throw UnimplementedError();
  }

  @override
  int? getInt(String key) {
    throw UnimplementedError();
  }

  @override
  Set<String> getKeys() {
    throw UnimplementedError();
  }

  @override
  List<String>? getStringList(String key) {
    throw UnimplementedError();
  }

  @override
  Future<void> reload() {
    throw UnimplementedError();
  }

  @override
  Future<bool> remove(String key) {
    throw UnimplementedError();
  }

  @override
  Future<bool> setBool(String key, bool value) {
    throw UnimplementedError();
  }

  @override
  Future<bool> setDouble(String key, double value) {
    throw UnimplementedError();
  }

  @override
  Future<bool> setInt(String key, int value) {
    throw UnimplementedError();
  }

  @override
  Future<bool> setString(String key, String value) {
    throw UnimplementedError();
  }

  @override
  Future<bool> setStringList(String key, List<String> value) {
    throw UnimplementedError();
  }
}

/// Tests for main page
void main() {
  testInit();
  sharedPreferences = FakeSharedPreferences();

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
        child: MultiProvider(
            providers: [Provider(create: (_) => SetupKeyNotifier())],
            child: const BinsightAiApp(skipSetUp: false)),
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
        child: MultiProvider(providers: [
          ChangeNotifierProvider(create: (_) => DetectionNotifier()),
        ], child: const BinsightAiApp(skipSetUp: true)),
        size: const Size(800, 600)));
    await widgetTester.pumpAndSettle();
    expect(router!.routerDelegate.currentConfiguration.last.matchedLocation,
        equals("/main"));
    FlutterError.onError = originalErrorHandler;
  });
}
