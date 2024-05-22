// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Project imports:
import 'package:binsight_ai/util/print.dart';
import 'package:binsight_ai/util/api.dart';
import 'package:binsight_ai/util/providers/image_provider.dart';
import 'package:binsight_ai/util/providers/detection_notifier.dart';
import 'package:binsight_ai/util/providers/annotation_notifier.dart';
import 'package:binsight_ai/util/providers/device_notifier.dart';
import 'package:binsight_ai/util/providers/setup_key_notifier.dart';
import 'package:binsight_ai/util/providers/wifi_result_notifier.dart';
import 'package:binsight_ai/util/routes.dart';
import 'package:binsight_ai/util/shared_preferences.dart';
import 'package:binsight_ai/util/styles.dart';

const String exampleBoxes = '''
[
  {
    "object_name": "Apple",
    "xy_coord_list": [
      [11.1, 16.4],
      [11.3, 16.5]
    ]
  },
  {
    "object_name": "Orange",
    "xy_coord_list": [
      [11.1, 16.4],
      [11.3, 16.5]
    ]
  },
  {
    "object_name": "Banana",
    "xy_coord_list": [
      [11.1, 16.4],
      [11.3, 16.5]
    ]
  },
  {
    "object_name": "Milk",
    "xy_coord_list": [
      [11.1, 16.4],
      [11.3, 16.5]
    ]
  }
]''';

/// Entry point of the application
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize shared preferences
  await initPreferences();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  try {
    await dotenv.load(fileName: "assets/data/.env");
  } catch (e) {
    debug("Error loading .env file");
    // Ensure that `dotenv` is initialized and prevents crashes
    dotenv.testLoad();
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
        // Notifies listeners of changes to the current detection's state.
        ChangeNotifierProvider(create: (_) => DetectionNotifier()),
        // Notifies listeners of changes to the current image's state. Used on the home page.
        ChangeNotifierProvider(create: (_) => ImageNotifier())
      ],
      // Skip initial set up if user has already set up a device
      child: BinsightAiApp(
          skipSetUp:
              sharedPreferences.getString(SharedPreferencesKeys.deviceID) !=
                  null),
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future<DateTime> timestamp = getLatestTimestamp();
    fetchImageData(
      sharedPreferences.getString(SharedPreferencesKeys.deviceApiID) ??
          dotenv.env['DEVICE_ID'] ??
          "",
      timestamp,
      context,
    );
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
    }
  }

  @override
  void dispose() {
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
}
