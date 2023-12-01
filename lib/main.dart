import 'package:flutter/material.dart';
import 'package:waste_watchers/screens/bluetooth/bluetooth_page.dart';
import 'package:waste_watchers/screens/main/detections_page.dart';
import 'package:waste_watchers/screens/main/home_page.dart';
import 'package:waste_watchers/screens/main/stats_page.dart';
import 'package:waste_watchers/screens/splash/screen.dart';
import 'package:waste_watchers/screens/splash/wifi_page.dart';
import 'package:waste_watchers/screens/connection/connect_page.dart';
import 'package:waste_watchers/database/connection.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await getDatabaseConnection();
  runApp(const WasteWatchersApp());
}

class WasteWatchersApp extends StatelessWidget {
  const WasteWatchersApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
    );
  }
}

final routes = [
  ShellRoute(
    builder: (BuildContext context, GoRouterState state, Widget child) {
      return BottomNavBar(child: child);
    },
    routes: <GoRoute>[
      GoRoute(
          name: 'main',
          path: 'main',
          builder: (BuildContext context, GoRouterState state) {
            return const HomePage();
          },
          routes: [
            GoRoute(
              name: 'detections',
              path: 'detections',
              builder: (BuildContext context, GoRouterState state) {
                return const DetectionsPage();
              },
            ),
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
  GoRoute(
      name: 'set-up',
      path: '/set-up',
      builder: (BuildContext conext, GoRouterState state) {
        return const SplashPage();
      },
      routes: [
        GoRoute(
          name: 'bluetooth',
          path: 'bluetooth',
          builder: (BuildContext context, GoRouterState state) {
            return const WifiPage();
          }),
        GoRoute(
            name: 'wifi',
            path: 'wifi',
            builder: (BuildContext context, GoRouterState state) {
              return const WifiPage();
            }),
        GoRoute(
            name: 'bin_connect',
            path: 'bin_connect',
            builder: (BuildContext context, GoRouterState state) {
              return const ConnectPage();
            })
      ]),
];

final GoRouter _router = GoRouter(
  initialLocation: '/set-up',
  routes: [
    ShellRoute(
      builder: (BuildContext context, GoRouterState state, Widget child) {
        return BottomNavBar(child: child);
      },
      routes: <GoRoute>[
        GoRoute(
            name: 'main',
            path: '/main',
            builder: (BuildContext context, GoRouterState state) {
              return const HomePage();
            },
            routes: [
              GoRoute(
                name: 'detections',
                path: 'detections',
                builder: (BuildContext context, GoRouterState state) {
                  return const DetectionsPage();
                },
              ),
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
    GoRoute(
        name: 'set-up',
        path: '/set-up',
        builder: (BuildContext conext, GoRouterState state) {
          return const SplashPage();
        },
        routes: [
          GoRoute(
            name: 'bluetooth',
            path: 'bluetooth',
            builder: (BuildContext context, GoRouterState state) {
              return const BluetoothPage();
            }
            ),
          GoRoute(
              name: 'wifi',
              path: 'wifi',
              builder: (BuildContext context, GoRouterState state) {
                return const WifiPage();
              }),
          GoRoute(
              name: 'bin_connect',
              path: 'bin_connect',
              builder: (BuildContext context, GoRouterState state) {
                return const ConnectPage();
              })
        ]),
  ],
);

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    required this.child,
    Key? key,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Waste Watchers"),
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
