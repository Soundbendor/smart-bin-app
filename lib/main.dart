import 'package:flutter/material.dart';
import 'package:waste_watchers/screens/main/screen.dart';
import 'package:waste_watchers/screens/splash/screen.dart';
import 'package:waste_watchers/screens/splash/wifi_page.dart';

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

  void _changeScreen(int newIndex) {
    setState(() {
      index = newIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: IndexedStack(
        index: index,
        children: [
          SplashPage(changeScreen: _changeScreen),
          WifiPage(changeScreen: _changeScreen),
          const MainScreen(),
        ],
      ),
    );
  }
}
