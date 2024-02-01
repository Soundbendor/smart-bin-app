import 'package:flutter/material.dart';
import 'package:binsight_ai/widgets/wifi_scan_widget.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// Displays the WiFi configuration page with background and padding.
class WifiScanPage extends StatefulWidget {
  const WifiScanPage({super.key, required this.device});

  final BluetoothDevice device;

  @override
  State<WifiScanPage> createState() => 
  _WifiScanPageState(device: device);
}

class _WifiScanPageState extends State<WifiScanPage> {
  _WifiScanPageState({required this.device});

  final BluetoothDevice device;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/images/background2.JPG"),
              fit: BoxFit.cover),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                WifiScanWidget(device: device),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
