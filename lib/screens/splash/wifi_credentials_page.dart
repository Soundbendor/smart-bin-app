import 'package:flutter/material.dart';
import 'package:binsight_ai/widgets/wifi_credentials_widget.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// Displays the WiFi configuration page with background and padding.
class WifiPage extends StatefulWidget {
  const WifiPage({super.key, required this.device, required this.ssid});

  final BluetoothDevice device;
  final String ssid;

  @override
  State<WifiPage> createState() => 
  _WifiPageState(device: device, ssid: ssid);
}

class _WifiPageState extends State<WifiPage> {
  _WifiPageState({required this.device, required this.ssid});

  final BluetoothDevice device;
  final String ssid;


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
                WifiConfigurationWidget(device: device, ssid: ssid),
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text("Wifi Page Content"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
