import 'package:flutter/material.dart';
import 'package:waste_watchers/screens/detections_page.dart';
import 'package:waste_watchers/screens/home_page.dart';
import 'package:waste_watchers/screens/stats_page.dart';
import 'package:waste_watchers/screens/splash_page.dart';

void main() {
  runApp(const MainPage());
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Waste Watchers"),
          centerTitle: true,
        ),
        body: IndexedStack(
          index: index,
          children: const [
            SplashPage(),
            HomePage(),
            DetectionsPage(),
            StatsPage(),
          ],
        ),
        bottomNavigationBar: NavigationBarTheme(
          data: const NavigationBarThemeData(
            labelTextStyle: MaterialStatePropertyAll(
              TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          child: NavigationBar(
            height: 60,
            selectedIndex: index,
            onDestinationSelected: (index) => setState(() {
              this.index = index;
            }),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.batch_prediction),
                label: 'Detections',
              ),
              NavigationDestination(
                icon: Icon(Icons.analytics),
                label: 'Stats',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
