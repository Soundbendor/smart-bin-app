// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:go_router/go_router.dart';

// Project imports:
import 'package:binsight_ai/pages/detection/annotation.dart';
import 'package:binsight_ai/pages/detection/detection.dart';
import 'package:binsight_ai/pages/detection/index.dart';
import 'package:binsight_ai/pages/main/faq.dart';
import 'package:binsight_ai/pages/main/help.dart';
import 'package:binsight_ai/pages/main/user_guide.dart';
import 'package:binsight_ai/pages/main/home.dart';
import 'package:binsight_ai/pages/setup/intro_sequence.dart';
import 'package:binsight_ai/widgets/navigation_shell.dart';

// Used for testing
GoRouter? router;

/// The routes for the application.
///
/// The routes are defined like a tree. There are two top-level routes: 'main' and 'set-up'.
/// The 'main' route is wrapped in a [ShellRoute] to share the bottom navigation bar.
/// The ShellRoute returns an [NavigationShell] widget, which contains the top navigation bar.
List<RouteBase> routes = getRoutes();
List<RouteBase> getRoutes() {
  return [
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
                  }),
              // `/main/detection/:detectionId` - detection page with detailed information
              GoRoute(
                path: 'detection/:detectionId',
                builder: (BuildContext context, GoRouterState state) {
                  return DetectionPage.fromId(
                      detectionId: state.pathParameters['detectionId']!);
                },
                routes: [
                  // `/main/detection/:detectionId/annotation` - annotation page
                  GoRoute(
                    path: 'annotation',
                    builder: (BuildContext context, GoRouterState state) {
                      return AnnotationPage(
                          detectionId: state.pathParameters['detectionId']!);
                    },
                  ),
                ],
              ),
              // `/main/faq` - frequently asked questions
              GoRoute(
                name: 'faq',
                path: 'faq',
                builder: (BuildContext context, GoRouterState state) {
                  return const FAQ();
                },
              ),
              // `/main/user_guide` - user guide
              GoRoute(
                name: 'user_guide',
                path: 'user_guide',
                builder: (BuildContext context, GoRouterState state) {
                  return const UserGuide();
                },
              ),
              // `/main/help` - help page
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
        builder: (BuildContext context, GoRouterState state) {
          return const SetupScreen();
        },
        routes: [
          // `/set-up/bluetooth` - bluetooth set up page
          GoRoute(
            name: 'bluetooth',
            path: 'bluetooth',
            builder: (BuildContext context, GoRouterState state) {
              return const SetupScreen(startPageIndex: 2);
            },
          ),
          GoRoute(
              name: 'wifi-scan',
              path: 'wifi-scan',
              builder: (BuildContext context, GoRouterState state) {
                return const SetupScreen(startPageIndex: 3);
              }),
          // `/set-up/wifi` - selecting wifi page
          GoRoute(
              name: 'wifi',
              path: 'wifi',
              builder: (BuildContext context, GoRouterState state) {
                return const SetupScreen(startPageIndex: 4);
              }),
        ]),
  ];
}

/// Sets the routes to the given list of routes.
void setRoutes(List<RouteBase> newRoutes) {
  routes = newRoutes;
}
