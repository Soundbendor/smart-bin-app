import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:binsight_ai/pages/setup/bluetooth.dart';

/// Widget for configuring the wifi credentials of the compost bin
class WifiConfiguration extends StatefulWidget {
  const WifiConfiguration({super.key, required this.device});

  final BluetoothDevice device;

  @override
  State<WifiConfiguration> createState() =>
      _WifiConfigurationState();
}

/// State class for WifiConfigurationWidget
class _WifiConfigurationState extends State<WifiConfiguration> {
  TextEditingController ssidController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  /// Function to send WiFi credentials to the Bluetooth connected Compost Bin
  Future<void> sendWifiCredentials() async {
    // Encode WiFi credentials as JSON and convert to bytes
    List<int> encodedJsonData = utf8.encode(jsonEncode(
        {"ssid": ssidController.text, "password": passwordController.text}));
    await writeCharacteristic(widget.device, Guid("2AB5"), encodedJsonData);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Text('Connect to Compost Bin', style: textTheme.headlineMedium),
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
          child: Text('Connect',
              style: textTheme.labelLarge!.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
              )),
        ),
      ], // Column children
    );
  }
}
