// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

// Package imports:
import 'package:go_router/go_router.dart';
// import 'package:sqflite/sqflite.dart';

// Project imports:
import 'package:binsight_ai/database/models/device.dart';
import 'package:binsight_ai/screens/bluetooth/bluetooth_page.dart';
import 'package:binsight_ai/screens/main/annotation.dart';
import 'package:binsight_ai/screens/main/detections_page.dart';
import 'package:binsight_ai/screens/main/home_page.dart';
import 'package:binsight_ai/screens/main/stats_page.dart';
import 'package:binsight_ai/screens/splash/screen.dart';
import 'package:binsight_ai/screens/splash/wifi_page.dart';
import 'package:binsight_ai/ui_components/bottom_nav_bar.dart';
// import 'package:binsight_ai/database/connection.dart';

/// Entry point of the application
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // final channel =
  //     IOWebSocketChannel.connect('http://54.214.80.15/api/model/subscribe');
  // final subscriptionMessage = {
  //   "type": "subscribe",
  //   "channel": "1",
  // };
  // channel.sink.add(jsonEncode(subscriptionMessage));
  // handleMessages(channel);
  // Determine if there are devices in the database.
  final devices = await Device.all();
  runApp(BinsightAiApp(skipSetUp: devices.isNotEmpty));
}

/// The root of the application.
/// Contains the GoRouter and MaterialApp wrappers.
class BinsightAiApp extends StatelessWidget {
  final bool skipSetUp;

  const BinsightAiApp({super.key, this.skipSetUp = false});

  @override
  Widget build(BuildContext context) {
    router = GoRouter(
        initialLocation: skipSetUp ? '/main' : '/set-up', routes: routes);

    return MaterialApp.router(
      routerConfig: router,
    );
  }
}

// Also used for testing
late GoRouter router;

/// The routes for the application.
///
/// The routes are defined like a tree. There are two top-level routes: 'main' and 'set-up'.
/// The 'main' route is wrapped in a [ShellRoute] to share the bottom navigation bar.
var routes = [
  ShellRoute(
    builder: (BuildContext context, GoRouterState state, Widget child) {
      return BottomNavBar(child: child);
    },
    routes: <GoRoute>[
      // `/main` - home page
      GoRoute(
          name: 'main',
          path: '/main',
          builder: (BuildContext context, GoRouterState state) {
            return const HomePage();
          },
          routes: [
            // `/main/detections` - list of detections
            GoRoute(
                name: 'detections',
                path: 'detections',
                builder: (BuildContext context, GoRouterState state) {
                  return const DetectionsPage();
                },
                routes: [
                  // `/main/detections/annotation` - annotation page
                  // [imagePath] is the id of the detection to annotate.
                  GoRoute(
                      name: 'annotation',
                      path: 'annotation:imagePath',
                      builder: (BuildContext context, GoRouterState state) {
                        return AnnotationPage(
                            imageLink: state.pathParameters['imagePath']!);
                      }),
                ]),
            // `/main/stats` - usage and statistics page
            GoRoute(
              name: 'stats',
              path: 'stats',
              builder: (BuildContext context, GoRouterState state) {
                return const StatsPage();
              },
            ),
          ]),
    ],
  ),

  // `/set-up` - set up / welcome page
  GoRoute(
      name: 'set-up',
      path: '/set-up',
      builder: (BuildContext conext, GoRouterState state) {
        return const SplashPage();
      },
      routes: [
        // `/set-up/bluetooth` - bluetooth set up page
        GoRoute(
            name: 'bluetooth',
            path: 'bluetooth',
            builder: (BuildContext context, GoRouterState state) {
              return const BluetoothPage();
            }),
        // `/set-up/wifi` - selecting wifi page
        GoRoute(
            name: 'wifi',
            path: 'wifi',
            builder: (BuildContext context, GoRouterState state) {
              return WifiPage(device: state.extra as BluetoothDevice);
            }),
      ]),
];

/// Wrapper containing the title app bar and bottom navigation bar.
/// Used for testing
void setRoutes(List<RouteBase> newRoutes) {
  routes = newRoutes;
}

