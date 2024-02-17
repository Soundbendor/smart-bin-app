import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:binsight_ai/util/bluetooth.dart';
import 'package:binsight_ai/util/providers.dart';

/// Widget for configuring the wifi credentials of the compost bin
class WifiConfiguration extends StatefulWidget {
  const WifiConfiguration({super.key, required this.ssid});

  final String ssid;

  @override
  State<WifiConfiguration> createState() => _WifiConfigurationState(ssid: ssid);
}

/// State class for WifiConfigurationWidget
class _WifiConfigurationState extends State<WifiConfiguration> {
  _WifiConfigurationState({required this.ssid});
  final flutterReactiveBle = FlutterReactiveBle();
  final Uuid _binServiceID = Uuid.parse("31415924535897932384626433832790");
  final Uuid _wifiCredID = Uuid.parse("31415924535897932384626433832793");

  final String ssid;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final BleDevice? bluetoothDevice =
        Provider.of<DeviceNotifier>(context, listen: false).device;
    TextEditingController ssidController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    void sendData(String deviceId) async {
      // await flutterReactiveBle.writeCharacteristicWithResponse(_rxCharacteristic!, value: _dataToSendText!.text.codeUnits);
      List<int> encodedJsonData = utf8.encode(jsonEncode(
          {"ssid": ssidController.text, "password": passwordController.text}));
      Uuid wifiCharacteristic = Uuid.parse("31415924535897932384626433832792");
      final characteristic = QualifiedCharacteristic(
          serviceId: _binServiceID,
          characteristicId: wifiCharacteristic,
          deviceId: deviceId);
      await flutterReactiveBle.writeCharacteristicWithResponse(characteristic,
          value: encodedJsonData);
    }

    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
        body: Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage("assets/images/FlowersBackground.png"),
            fit: BoxFit.cover),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Connect to Compost Bin', style: textTheme.headlineMedium),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: TextField(
              controller: ssidController..text = ssid,
              decoration: const InputDecoration(labelText: 'SSID'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Call function to send WiFi credentials to the Compost Bin
              // await the sending
              if (bluetoothDevice != null) {
                sendData(bluetoothDevice.id);
              }
              // Navigate to the 'main' route using GoRouter
              context.goNamed('main');
            },
            child: Text('Connect',
                style: textTheme.labelLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                )),
          ),
        ], // Column children
      ),
    ));
  }
}
