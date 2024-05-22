// Flutter imports:
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

// Project imports:
import 'package:binsight_ai/database/models/detection.dart';
import 'package:binsight_ai/util/print.dart';
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
    "object_name": "Beef",
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
  },
  {
    "object_name": "Pea",
    "xy_coord_list": [
      [11.1, 16.4],
      [11.3, 16.5]
    ]
  },
  {
    "object_name": "Lettuce",
    "xy_coord_list": [
      [11.1, 16.4],
      [11.3, 16.5]
    ]
  },
  {
    "object_name": "Tomato",
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
            dotenv.env['DEVICE_ID'] ?? "",
        timestamp);
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
    // Defines the router to be used for the app, with set-up as the initial route
    setRoutes(getRoutes());
    router ??= GoRouter(
        // initialLocation: widget.skipSetUp ? '/main' : '/main',
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

  /// Hits the api to retrieve all detections for a certain device after a date
  Future<void> fetchImageData(
      String deviceID, Future<DateTime> afterDate) async {
    DateTime timestamp = await afterDate;
    debug("LATEST TIME STAMP $timestamp");
    String formattedDate = DateFormat('yyyy-MM-dd').format(timestamp);
    String formattedTime = DateFormat('HH:mm:ss').format(timestamp);
    const String url =
        'http://sb-binsight.dri.oregonstate.edu:30080/api/get_image_info';
    Map<String, String> queryParams = {
      'deviceID': deviceID,
      'after_date': formattedDate,
      'after_time': formattedTime,
      'page': '1',
      'size': '50',
    };

    final Uri uri = Uri.parse(url).replace(queryParameters: queryParams);
    String apiKey = dotenv.env['API_KEY'] ??
        sharedPreferences.getString(SharedPreferencesKeys.apiKey) ??
        "";
    Map<String, String> headers = {
      'accept': 'application/json',
      'token': apiKey,
    };
    try {
      final http.Response response = await http.get(uri, headers: headers);
      List<String> imageList = [];
      debug(response);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        // API RETURNS ITEMS SORTED BY DATE IN ASCENDING ORDER, REVERSE FOR NEWEST FIRST
        List<dynamic> itemList = data['items'].reversed.toList();
        if (itemList.isNotEmpty && timestamp != DateTime(2022, 1, 1)) {
          itemList.removeAt(0);
        }
        debug(
            "IMAGES QUERIED FOR AND RECIEVED: $itemList and length ${itemList.length}");
        for (var item in itemList) {
          Map<String, dynamic> adjustedMap = transformMap(item);
          imageList.add(adjustedMap["postDetectImgLink"]);
          Detection detection = Detection.fromMap(adjustedMap);
          await detection.save();
        }
        if (mounted) {
          Provider.of<DetectionNotifier>(context, listen: false).getAll();
        }
        try {
          retrieveImages(deviceID, imageList);
        } catch (e) {
          debug(e);
        }
      } else {
        debug('Failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      debug('Error: $e');
    }
  }

  Future<void> retrieveImages(String deviceID, List<String> imageList) async {
    String url =
        'http://sb-binsight.dri.oregonstate.edu:30080/api/get_images?deviceID=$deviceID';
    String apiKey = dotenv.env['API_KEY'] ??
        sharedPreferences.getString(SharedPreferencesKeys.apiKey) ??
        "";

    var requestBody = imageList;
    debug("Image List $imageList");
    Map<String, String> headers = {
      'accept': 'application/json',
      'token': apiKey,
      'Content-Type': 'application/json',
    };
    try {
      final http.Response response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        debug('POST request successful');
        debug(response.body);
        if (!mounted) return;
        Provider.of<ImageNotifier>(context, listen: false)
            .saveAndExtract(response.body);
      } else {
        debug('Failed to make POST request.');
      }
    } catch (e) {
      debug('Error: $e');
    }
  }

  /// Adjust new json map recieved from api to match existing schema
  Map<String, dynamic> transformMap(Map<String, dynamic> map) {
    //colorImage_2024-05-11--20-36-25.jpg, substrings to get the date section and time section
    String dateString = map["colorImage"].substring(11, 21);
    String timeString = map["colorImage"].substring(23, 31);
    String combinedDateTimeString = "${dateString}T$timeString";
    String formattedDateTimeString = combinedDateTimeString.replaceAll('-', '');
    //Remove dashes and put a T between the date and time parts so it can be parsed as DateTime, and later, an Iso String
    return {
      'imageId': map['colorImage'],
      'timestamp': DateTime.parse(formattedDateTimeString).toIso8601String(),
      'deviceId': map['deviceID'].toString(),
      'postDetectImgLink': map['colorImage'],
      'weight': map['weight_delta']?.toDouble(),
      'humidity': map['humidity']?.toDouble(),
      'temperature': map['temperature']?.toDouble(),
      'co2': map['co2_eq']?.toDouble(),
      'iaq': map['iaq']?.toDouble(),
      'pressure': map['pressure']?.toDouble(),
      'tvoc': map['tvoc']?.toDouble(),
      'transcription': map['transcription'],
    };
  }
}
