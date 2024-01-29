import 'dart:convert';

import 'package:binsight_ai/database/models/device.dart';
import 'package:binsight_ai/pub_sub/subscriber.dart';
import 'package:binsight_ai/screens/bluetooth/bluetooth_page.dart';
import 'package:binsight_ai/screens/main/annotation.dart';
import 'package:flutter/material.dart';
import 'package:binsight_ai/screens/main/detections_page.dart';
import 'package:binsight_ai/screens/main/home_page.dart';
import 'package:binsight_ai/screens/main/stats_page.dart';
import 'package:binsight_ai/screens/splash/screen.dart';
import 'package:binsight_ai/screens/splash/wifi_page.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:web_socket_channel/io.dart';

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

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("binsight.ai"),
        centerTitle: true,
      ),
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Detections',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Stats',
          ),
        ],
        currentIndex: _calculateSelectedIndex(context),
        onTap: (int idx) => _onItemTapped(idx, context),
      ),
    );
  }

  // Calculate the index of the bottom navigation bar based on the current route
  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location == '/main') {
      return 0;
    }
    if (location == '/main/detections') {
      return 1;
    }
    if (location == '/main/stats') {
      return 2;
    }
    return 0;
  }

  // Function to handle navigation when an item is tapped
  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        GoRouter.of(context).go('/main');
        break;
      case 1:
        GoRouter.of(context).go('/main/detections');
        break;
      case 2:
        GoRouter.of(context).go('/main/stats');
    }
  }
}
