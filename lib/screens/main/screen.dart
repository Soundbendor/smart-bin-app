import 'package:flutter/material.dart';
import 'package:waste_watchers/screens/main/detections_page.dart';
import 'package:waste_watchers/screens/main/home_page.dart';
import 'package:waste_watchers/screens/main/stats_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("BiNSIGHT"),
        centerTitle: true,
      ),
      body: IndexedStack(
        index: index,
        children: const [
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
    );
  }
}
