// Flutter imports:
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/io.dart';

// Project imports:
import 'package:binsight_ai/util/print.dart';
import 'package:binsight_ai/util/providers.dart';
import 'package:binsight_ai/util/routes.dart';
import 'package:binsight_ai/util/styles.dart';
import 'package:binsight_ai/util/subscriber.dart';
import 'package:binsight_ai/database/connection.dart';
import 'package:binsight_ai/database/models/device.dart';
import 'package:binsight_ai/database/models/detection.dart';

const String exampleBoxes = '''
[ 
  {
    "category_name": "Apple",
    "xy_coord_list": [
      [11.1, 16.4],
      [11.3, 16.5]
    ]
  },
  {
    "category_name": "Orange",
    "xy_coord_list": [
      [11.1, 16.4],
      [11.3, 16.5]
    ]
  },
  {
    "category_name": "Banana",
    "xy_coord_list": [
      [11.1, 16.4],
      [11.3, 16.5]
    ]
  }
]''';

/// Entry point of the application
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Determine if there are devices in the database.
  var devices = await Device.all();

  if (kDebugMode) {
    final db = await getDatabaseConnection();
    // development code to add fake data

    if (devices.isEmpty) {
      await db.insert("devices", {"id": "test"});
      devices = await Device.all();
    }

    final detections = await Detection.all();
    if (detections.isEmpty) {
      var fakeDetections = [
        Detection(
          imageId: "test-10",
          preDetectImgLink: "https://placehold.co/512x512.png",
          timestamp: DateTime.now().subtract(const Duration(days: 6)),
          deviceId: "test",
          postDetectImgLink: "https://placehold.co/513x513.png",
          depthMapImgLink: "https://placehold.co/514x514.png",
          irImgLink: "https://placehold.co/515x515.png",
          weight: 27.0,
          humidity: 0.5,
          temperature: 20.0,
          co2: 0.5,
          vo2: 0.5,
          boxes: exampleBoxes,
        ),
        Detection(
          imageId: "test-9",
          preDetectImgLink: "https://placehold.co/512x512.png",
          timestamp: DateTime.now().subtract(const Duration(days: 5)),
          deviceId: "test",
          postDetectImgLink: "https://placehold.co/513x513.png",
          depthMapImgLink: "https://placehold.co/514x514.png",
          irImgLink: "https://placehold.co/515x515.png",
          weight: 10.0,
          humidity: 0.5,
          temperature: 20.0,
          co2: 0.5,
          vo2: 0.5,
          boxes: exampleBoxes,
        ),
        Detection(
          imageId: "test-8",
          preDetectImgLink: "https://placehold.co/512x512.png",
          timestamp: DateTime.now().subtract(const Duration(days: 4)),
          deviceId: "test",
          postDetectImgLink: "https://placehold.co/513x513.png",
          depthMapImgLink: "https://placehold.co/514x514.png",
          irImgLink: "https://placehold.co/515x515.png",
          weight: 40.0,
          humidity: 0.5,
          temperature: 20.0,
          co2: 0.5,
          vo2: 0.5,
          boxes: exampleBoxes,
        ),
        Detection(
          imageId: "test-7",
          preDetectImgLink: "https://placehold.co/512x512.png",
          timestamp: DateTime.now().subtract(const Duration(days: 3)),
          deviceId: "test",
          postDetectImgLink: "https://placehold.co/513x513.png",
          depthMapImgLink: "https://placehold.co/514x514.png",
          irImgLink: "https://placehold.co/515x515.png",
          weight: 16.0,
          humidity: 0.5,
          temperature: 20.0,
          co2: 0.5,
          vo2: 0.5,
          boxes: exampleBoxes,
        ),
        Detection(
          imageId: "test-6",
          preDetectImgLink: "https://placehold.co/512x512.png",
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
          deviceId: "test",
          postDetectImgLink: "https://placehold.co/513x513.png",
          depthMapImgLink: "https://placehold.co/514x514.png",
          irImgLink: "https://placehold.co/515x515.png",
          weight: 30.0,
          humidity: 0.5,
          temperature: 20.0,
          co2: 0.5,
          vo2: 0.5,
          boxes: exampleBoxes,
        ),
      ];
      for (final detection in fakeDetections) {
        await detection.save();
      }
    }
  }

  runApp(
    MultiProvider(
      providers: [
        // Notifies listeners of the status of the Bluetooth-connected compost bin.
        ChangeNotifierProvider(create: (_) => DeviceNotifier()),
        // Notifies listeners of the selected WiFi network.
        ChangeNotifierProvider(create: (_) => WifiResultNotifier()),
        // Provides a global key used for controlling page animation.
        Provider(create: (_) => SetupKeyNotifier()),
        // Notifies listeners of changes to the current annotation's state.
        ChangeNotifierProvider(create: (_) => AnnotationNotifier()),
      ],
      child: BinsightAiApp(skipSetUp: devices.isNotEmpty),
    ),
  );
}

/// The root of the application. Contains the GoRouter and MaterialApp wrappers.
class BinsightAiApp extends StatefulWidget {
  final bool skipSetUp;

  const BinsightAiApp({super.key, this.skipSetUp = true});

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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Minimized
    if (state == AppLifecycleState.paused) {
      debug("Closed");
    }
    // Reopened
    else if (state == AppLifecycleState.resumed) {
      debug("Opened");
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
    setRoutes(getRoutes());
    router ??= GoRouter(
        initialLocation: widget.skipSetUp ? '/main' : '/set-up',
        routes: routes);

    return ChangeNotifierProvider(
      create: (_) => DeviceNotifier(),
      child: MaterialApp.router(
        routerConfig: router,
        theme: mainTheme,
      ),
    );
  }

  /// Get last detection in local database
  Future<DateTime> getLatestTimestamp() async {
    final latestDetection = await Detection.latest();
    final timeStamp = latestDetection.timestamp;
    return timeStamp;
  }

  /// Initialize WebSocket channel and subscribe
  void initWebSocket() async {
    channel =
        IOWebSocketChannel.connect('ws://10.0.2.2:8000/api/model/subscribe');
    try {
      await channel
          .ready; // https://github.com/dart-lang/web_socket_channel/issues/38
      final subscriptionMessage = {"type": "subscribe", "channel": "1"};
      channel.sink.add(jsonEncode(subscriptionMessage));
      final timeStamp = getLatestTimestamp();
      final requestMessage = {
        "type": "request_data",
        "after": timeStamp.toString(),
        "channel": "1"
      };
      channel.sink.add(jsonEncode(requestMessage));
      handleMessages(channel);
    } catch (e) {
      debug("Connect Error: $e");
    }
  }
}
