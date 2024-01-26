import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:binsight_ai/screens/bluetooth/bluetooth_page.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:convert';

/// Widget for configuring the wifi credentials of the compost bin
class WifiConfigurationWidget extends StatefulWidget {
  const WifiConfigurationWidget({super.key, required this.device});

  final BluetoothDevice device;

  @override
  State<WifiConfigurationWidget> createState() =>
      _WifiConfigurationWidgetState(device: device);
}

/// State class for WifiConfigurationWidget
class _WifiConfigurationWidgetState extends State<WifiConfigurationWidget> {
  _WifiConfigurationWidgetState({required this.device});

  TextEditingController ssidController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final BluetoothDevice device;

  /// Function to send WiFi credentials to the Bluetooth connected Compost Bin
  Future<void> sendWifiCredentials() async {
    // Encode WiFi credentials as JSON and convert to bytes
    List<int> encodedJsonData = utf8.encode(jsonEncode(
        {"ssid": ssidController.text, "password": passwordController.text}));
    await writeCharacteristic(device, Guid("2AB5"), encodedJsonData);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Connect to Compost Bin'),
        TextField(
          controller: ssidController,
          decoration: const InputDecoration(labelText: 'SSID'),
        ),
        TextField(
          controller: passwordController,
          decoration: const InputDecoration(labelText: 'Password'),
        ),
        ElevatedButton(
          onPressed: () {
            // Call function to send WiFi credentials to the Compost Bin
            sendWifiCredentials();
            // Navigate to the 'main' route using GoRouter
            context.goNamed('main');
          },
          child: const Text('Connect'),
        ),
      ], // Column children
    );
  }
}
