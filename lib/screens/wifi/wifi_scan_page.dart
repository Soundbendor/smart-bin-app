import 'package:binsight_ai/main.dart';
import 'package:flutter/material.dart';
import 'package:binsight_ai/widgets/wifi_scan_widget.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// Displays the WiFi configuration page with background and padding.
class WifiScanPage extends StatefulWidget {
  const WifiScanPage({super.key});


  @override
  State<WifiScanPage> createState() => 
  _WifiScanPageState();
}

class _WifiScanPageState extends State<WifiScanPage> {
  _WifiScanPageState();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/images/background2.JPG"),
              fit: BoxFit.cover),
        ),
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                WifiScanWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
