// Flutter imports:
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:go_router/go_router.dart';
import 'package:web_socket_channel/io.dart';

// Project imports:
import 'package:binsight_ai/database/models/device.dart';
import 'package:binsight_ai/screens/pages/detections_page.dart';
import 'package:binsight_ai/screens/pages/bluetooth_page.dart';
import 'package:binsight_ai/screens/pages/annotation.dart';
import 'package:binsight_ai/database/models/detection.dart';
import 'package:binsight_ai/screens/pages/detection_page.dart';
import 'package:binsight_ai/screens/pages/home_page.dart';
import 'package:binsight_ai/screens/pages/stats_page.dart';
import 'package:binsight_ai/screens/pages/help_page.dart';
import 'package:binsight_ai/screens/splash/screen.dart';
import 'package:binsight_ai/screens/splash/wifi_page.dart';
import 'package:binsight_ai/widgets/navigation_shell.dart';
import 'package:binsight_ai/database/connection.dart';
import 'package:binsight_ai/pub_sub/subscriber.dart';

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

  if (kDebugMode) {
    final db = await getDatabaseConnection();
    // development code to add fake data
    if (devices.isEmpty) {
      await db.insert("devices", {"id": "test"});
    }

    final detections = await Detection.all();
    if (detections.isEmpty) {
      final fakeDetections = [
        Detection(
          imageId: "test-1",
          preDetectImgLink: "https://placehold.co/512x512.png",
          timestamp: DateTime.now(),
          deviceId: "test",
          postDetectImgLink: "https://placehold.co/513x513.png",
          depthMapImgLink: "https://placehold.co/514x514.png",
          irImgLink: "https://placehold.co/515x515.png",
          weight: 12.0,
          humidity: 0.5,
          temperature: 20.0,
          co2: 0.5,
          vo2: 0.5,
          boxes: "[]",
        ),
        Detection(
          imageId: "test-2",
          preDetectImgLink: "https://placehold.co/512x512.png",
          timestamp: DateTime.now(),
          deviceId: "test",
          depthMapImgLink: "https://placehold.co/514x514.png",
          irImgLink: "https://placehold.co/515x515.png",
          weight: 12.0,
          humidity: 0.5,
          temperature: 20.0,
          co2: 0.5,
          vo2: 0.5,
        ),
      ];
      for (final detection in fakeDetections) {
        await detection.save();
      }
    }
  }

  // Run the app without the bluetooth set up
  // runApp(BinsightAiApp(skipSetUp: true));

  // Run the app with the bluetooth set up
  runApp(BinsightAiApp(skipSetUp: devices.isNotEmpty));
}

// Also used for testing
late GoRouter router;

/// The root of the application. Contains the GoRouter and MaterialApp wrappers.
class BinsightAiApp extends StatefulWidget {
  final bool skipSetUp;

  const BinsightAiApp({super.key, this.skipSetUp = false});

  @override
  State<BinsightAiApp> createState() => _BinsightAiAppState();
}

class _BinsightAiAppState extends State<BinsightAiApp>
    with WidgetsBindingObserver {
  late IOWebSocketChannel channel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initWebSocket();
  }

  void initWebSocket() {
    // Initialize WebSocket channel and subscribe
    channel = IOWebSocketChannel.connect('ws://10.0.2.2:8000/subscribe');
    final subscriptionMessage = {"type": "subscribe", "channel": "1"};
    channel.sink.add(jsonEncode(subscriptionMessage));

    handleMessages(channel);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    //Minimized
    if (state == AppLifecycleState.paused) {
      print("closed");
    }
    //Reopened
    else if (state == AppLifecycleState.resumed) {
      print("Opened");
      if (channel.closeCode != null) {
        initWebSocket();
      }
    }
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //Defines the router to be used for the app, with set-up as the initial route
    router = GoRouter(
        initialLocation: widget.skipSetUp ? '/main' : '/set-up',
        routes: routes);

    return MaterialApp.router(
      routerConfig: router,
    );
  }
}

/// The routes for the application.
///
/// The routes are defined like a tree. There are two top-level routes: 'main' and 'set-up'.
/// The 'main' route is wrapped in a [ShellRoute] to share the bottom navigation bar.
/// The ShellRoute returns an [AppShell] widget, which contains the top navigation bar.
var routes = [
  ShellRoute(
    builder: (BuildContext context, GoRouterState state, Widget child) {
      return NavigationShell(child: child);
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
            // `/main/detection/:detectionId` - detection page with detailed information
            GoRoute(
                path: 'detection/:detectionId',
                builder: (BuildContext context, GoRouterState state) {
                  return DetectionPage.fromId(
                      detectionId: state.pathParameters['detectionId']!);
                }),
            // `/main/stats` - usage and statistics page
            GoRoute(
              name: 'stats',
              path: 'stats',
              builder: (BuildContext context, GoRouterState state) {
                return const StatsPage();
              },
            ),
            GoRoute(
              name: 'help',
              path: 'help',
              builder: (BuildContext context, GoRouterState state) {
                return const HelpPage();
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
