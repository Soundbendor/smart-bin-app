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
import 'package:binsight_ai/database/models/device.dart';
import 'package:binsight_ai/database/models/detection.dart';
import 'package:binsight_ai/database/connection.dart';

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
            boxes:
                '[["Apple", [11.1, 16.4]], ["Orange", [10.0, 292.7]], ["Banana", [10.0, 292.7]]]'),
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
            boxes:
                '[["Apple", [11.1, 16.4]], ["Orange", [10.0, 292.7]], ["Banana", [10.0, 292.7]]]'),
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
            boxes:
                '[["Apple", [11.1, 16.4]], ["Orange", [10.0, 292.7]], ["Banana", [10.0, 292.7]]]'),
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
            boxes:
                '[["Apple", [11.1, 16.4]], ["Orange", [10.0, 292.7]], ["Banana", [10.0, 292.7]]]'),
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
            boxes:
                '[["Apple", [11.1, 16.4]], ["Orange", [10.0, 292.7]], ["Banana", [10.0, 292.7]]]'),
      ];
      for (final detection in fakeDetections) {
        await detection.save();
      }
    }
  }

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => DeviceNotifier()),
  ], child: BinsightAiApp(skipSetUp: devices.isNotEmpty)));
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

  // TODO: Execute this in main, but don't tie it to the UI
  // - it could modify data in a provider instead
  /// Initialize WebSocket channel and subscribe
  void initWebSocket() {
    channel = IOWebSocketChannel.connect('ws://10.0.2.2:8000/subscribe');
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
  }
}
