import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:binsight_ai/util/bluetooth.dart';
import 'package:binsight_ai/util/providers.dart';
import 'package:binsight_ai/util/wifi_scan.dart';

/// Widget for configuring the wifi credentials of the compost bin
class WifiConfigurationPage extends StatefulWidget {
  const WifiConfigurationPage({super.key, required this.wifiResult});

  final WifiScanResult wifiResult;

  @override
  State<WifiConfigurationPage> createState() => _WifiConfigurationPageState();
}

/// State class for WifiConfigurationWidget
class _WifiConfigurationPageState extends State<WifiConfigurationPage> {

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final BleDevice? bluetoothDevice =
        Provider.of<DeviceNotifier>(context, listen: false).device;
    TextEditingController ssidController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    void sendData(String deviceId) async {
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
              controller: ssidController..text = widget.wifiResult.ssid,
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
