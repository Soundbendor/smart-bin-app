import 'package:binsight_ai/main.dart';
import 'package:binsight_ai/screens/bluetooth/bluetooth_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dart:convert';


/// Displays the WiFi configuration page with background and padding.
class WifiPage extends StatefulWidget {
  const WifiPage({super.key, required this.ssid});

  final String ssid;

  @override
  State<WifiPage> createState() => 
  _WifiPageState(ssid: ssid);
}

class _WifiPageState extends State<WifiPage> {
  _WifiPageState({required this.ssid});

  final String ssid;

  @override
  Widget build(BuildContext context) {
  final BluetoothDevice? bluetoothDevice = Provider.of<DeviceNotifier>(context, listen:false).getDevice();
  TextEditingController ssidController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  Future<void> sendWifiCredentials() async {
    // Encode WiFi credentials as JSON and convert to bytes
    List<int> encodedJsonData = utf8.encode(jsonEncode(
        {"ssid": ssidController.text, "password": passwordController.text}));
    await writeCharacteristic(bluetoothDevice!, Guid("2AB5"), encodedJsonData);
  }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/images/FlowersBackground.png"),
              fit: BoxFit.cover),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    const Text('Enter WiFi Details'),
                    TextField(
                      controller: ssidController..text = ssid,
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
