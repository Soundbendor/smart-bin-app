import 'package:flutter/material.dart';
// import 'package:waste_watchers/screens/main/detections_page.dart';
// import 'package:waste_watchers/screens/main/home_page.dart';
// import 'package:waste_watchers/screens/main/stats_page.dart';
// import 'package:waste_watchers/screens/splash/screen.dart';
// import 'package:waste_watchers/screens/splash/pages/wifi_page.dart';
import 'package:waste_watchers/screens/main/screen.dart';
import 'package:waste_watchers/screens/splash/screen.dart';

void main() {
  runApp(const WasteWatchersApp());
}

class WasteWatchersApp extends StatelessWidget {
  const WasteWatchersApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int index = 0;
  bool isWifiConnected = false;

  void _changeWifiConnected() {
    setState(() {
      isWifiConnected = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: isWifiConnected
            ? const MainScreen()
            : SplashPage(changeWifiConnected: _changeWifiConnected));
  }
}
