import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import 'package:binsight_ai/screens/bluetooth/bluetooth_page.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:convert';

/// Sends WiFi credentials to the compost bin.
class WifiConfigurationWidget extends StatefulWidget {
  const WifiConfigurationWidget({super.key, required this.device});

  final BluetoothDevice device;

  @override
  State<WifiConfigurationWidget> createState() =>
      _WifiConfigurationWidgetState(device: device);
}

class _WifiConfigurationWidgetState extends State<WifiConfigurationWidget> {
  _WifiConfigurationWidgetState({required this.device});

  TextEditingController ssidController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final BluetoothDevice device;


  Future<void> sendWifiCredentials() async {
      List<int> encodedJsonData = utf8.encode(jsonEncode({"ssid": ssidController.text, "password": passwordController.text}));
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
            sendWifiCredentials();
            context.goNamed('main');
          },
          child: const Text('Connect'),
        ),
      ], // Column children
    );
  }
}
