import 'package:flutter/material.dart';
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

final GoRouter _router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const SplashPage();
      },
      routes: <RouteBase>[
        GoRoute(
            path: 'wifi',
            builder: (BuildContext context, GoRouterState state) {
              return const WifiPage();
            }),
        GoRoute(
            path: 'bin_connect',
            builder: (BuildContext context, GoRouterState state) {
              return const ConnectPage();
            }),
        ShellRoute(
          builder: (BuildContext context, GoRouterState state, Widget child) {
            return BottomNavBar(child: child);
          },
          navigatorKey: _shellNavigatorKey,
          routes: <RouteBase>[
            GoRoute(
              path: 'home',
              builder: (BuildContext context, GoRouterState state) {
                return const HomePage();
              },
            ),
            GoRoute(
              path: 'detections',
              parentNavigatorKey: _shellNavigatorKey,
              builder: (BuildContext context, GoRouterState state) {
                return const DetectionsPage();
              },
            ),
            GoRoute(
              path: 'stats',
              builder: (BuildContext context, GoRouterState state) {
                return const StatsPage();
              },
            ),
          ],
        )
      ],
    ),
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
    if (location.startsWith('/home')) {
      return 0;
    }
    if (location.startsWith('/detections')) {
      return 1;
    }
    if (location.startsWith('/stats')) {
      return 2;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        GoRouter.of(context).go('/home');
        break;
      case 1:
        GoRouter.of(context).go('/detections');
        break;
      case 2:
        GoRouter.of(context).go('/stats');
    }
  }
}
