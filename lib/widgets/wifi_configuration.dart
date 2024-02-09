import 'dart:convert';
import 'package:binsight_ai/main.dart';
import 'package:binsight_ai/util/print.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:binsight_ai/pages/setup/bluetooth.dart';
import 'package:provider/provider.dart';
import 'package:binsight_ai/widgets/loading_popup.dart';

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

  final String ssid;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final BluetoothDevice? bluetoothDevice =
        Provider.of<DeviceNotifier>(context, listen: false).getDevice();
    TextEditingController ssidController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    /// Function to send WiFi credentials to the Bluetooth connected Compost Bin
    Future<void> sendWifiCredentials() async {
      // Encode WiFi credentials as JSON and convert to bytes
      setState(() {
        isLoading = true;
      });
      debug(ssidController.text);
      debug(passwordController.text);
      List<int> encodedJsonData = utf8.encode(jsonEncode(
          {"ssid": ssidController.text, "password": passwordController.text}));
      // await writeCharacteristic(
      //     bluetoothDevice!, Guid("2AB5"), encodedJsonData);
      // setState(() {
        // isLoading = true;
      // });
    }

    final textTheme = Theme.of(context).textTheme;
    // if (isLoading) {
    //   showDialog(
    //       context: context,
    //       builder: (context) {
    //         return const LoadingPopup();
    //       });
    // }
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
              // isLoading, ? displayLoading : null
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
      ),
    ));
  }
}
