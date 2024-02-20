import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:binsight_ai/util/print.dart';
import 'package:binsight_ai/util/bluetooth_bin_data.dart';
import 'package:binsight_ai/util/providers.dart';
import 'package:binsight_ai/util/wifi_scan.dart';
import 'package:binsight_ai/database/models/device.dart';
import 'package:binsight_ai/widgets/background.dart';

/// Widget for configuring the wifi credentials of the compost bin
class WifiConfigurationPage extends StatefulWidget {
  const WifiConfigurationPage({super.key, required this.wifiResult});

  /// The wifi scan result
  final WifiScanResult wifiResult;

  @override
  State<WifiConfigurationPage> createState() => _WifiConfigurationPageState();
}

/// State class for WifiConfigurationWidget
class _WifiConfigurationPageState extends State<WifiConfigurationPage> {
  /// Whether the modal is currently open
  bool isModalOpen = false;

  /// The status of the wifi configuration
  WifiConfigurationStatus status = WifiConfigurationStatus.waiting;

  /// The error that occurred
  Exception? error;

  /// Controller for the SSID text field
  final TextEditingController ssidController = TextEditingController();

  /// Controller for the password text field
  final TextEditingController passwordController = TextEditingController();

  /// Sends the wifi credentials to the compost bin and monitors the status
  void sendCredentials() async {
    final ssid = ssidController.text;
    final password = passwordController.text;
    final device = Provider.of<DeviceNotifier>(context, listen: false).device!;
    try {
      setState(() {
        status = WifiConfigurationStatus.sending;
      });
      await device.writeCharacteristic(
          serviceId: mainServiceId,
          characteristicId: wifiCredentialCharacteristicId,
          value: jsonEncode({
            ssid: ssid,
            password: password,
          }));
      await verifyStatus();
    } on Exception catch (e) {
      debug(e);
      setState(() {
        status = WifiConfigurationStatus.error;
        error = e;
      });
    }
  }

  /// Verifies the status of the wifi configuration
  Future<void> verifyStatus() async {
    if (!mounted) return;
    final device = Provider.of<DeviceNotifier>(context, listen: false).device!;
    setState(() {
      status = WifiConfigurationStatus.verifying;
    });
    int tries = 0;
    while (tries < 5) {
      final now = DateTime.now();
      final statusData = await device.readCharacteristic(
          serviceId: mainServiceId,
          characteristicId: wifiCredentialCharacteristicId);
      final Map<dynamic, dynamic> statusJson =
          jsonDecode(utf8.decode(statusData));
      double timestamp = statusJson["timestamp"]; // in seconds
      String message = statusJson["message"];
      bool success = statusJson["success"];
      // check if timestamp is within ~5 seconds of now
      if (now
              .difference(DateTime.fromMillisecondsSinceEpoch(
                  (timestamp * 1000).floor()))
              .inSeconds <
          5) {
        if (success) {
          return await verifyConnection();
        } else {
          if (!mounted) return;
          setState(() {
            status = WifiConfigurationStatus.error;
            error = WifiConfigurationException(message);
          });
          return;
        }
      } else {
        tries++;
        await Future.delayed(const Duration(seconds: 1));
      }
    }
    // if we reach here, the operation has timed out
    if (!mounted) return;
    setState(() {
      status = WifiConfigurationStatus.error;
      error = WifiConfigurationException("Operation timed out");
    });
  }

  /// Verifies the internet connection of the compost bin
  Future<void> verifyConnection() async {
    if (!mounted) return;
    setState(() {
      status = WifiConfigurationStatus.verifyingConnection;
    });
    final device = Provider.of<DeviceNotifier>(context, listen: false).device!;
    final statusData = await device.readCharacteristic(
        serviceId: mainServiceId, characteristicId: wifiStatusCharacteristicId);
    final Map<dynamic, dynamic> statusJson =
        jsonDecode(utf8.decode(statusData));
    bool internetAccess = statusJson["internet_access"];
    bool success = statusJson["success"];
    if (internetAccess && success) {
      if (!mounted) return;
      saveBinData();
      Provider.of<DeviceNotifier>(context, listen: false).resetDevice();
      GoRouter.of(context).go("/main");
    } else {
      if (!mounted) return;
      setState(() {
        status = WifiConfigurationStatus.error;
        error = WifiConfigurationException("No internet access");
      });
    }
  }

  /// Saves the bin data to the database
  void saveBinData() {
    final device = Provider.of<DeviceNotifier>(context, listen: false).device!;
    final databaseDevice = Device(
        id: device.id); // TODO: Add more fields, confirm what id is stored
    databaseDevice.save();
  }

  @override
  void initState() {
    super.initState();
    ssidController.text = widget.wifiResult.ssid;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: CustomBackground(
        imageURL: "assets/images/FlowersBackground.png",
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Connect Bin to WiFi', style: textTheme.headlineMedium),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: TextField(
                controller: ssidController,
                decoration: const InputDecoration(labelText: 'SSID'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
            ),
            ElevatedButton(
              onPressed: sendCredentials,
              child: Text('Connect',
                  style: textTheme.labelLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  )),
            ),
            ElevatedButton(
              onPressed: () {
                GoRouter.of(context).goNamed("wifi-scan");
              },
              child: Text("Back",
                  style: textTheme.labelLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  )),
            ),
          ], // Column children
        ),
      ),
    );
  }
}

class WifiConfigurationException implements Exception {
  WifiConfigurationException(this.message);

  final String message;

  @override
  String toString() => "WifiConfigurationException: $message";
}

/// A status of the wifi configuration
enum WifiConfigurationStatus {
  /// The wifi configuration is waiting for input
  waiting,

  /// The wifi credentials are being sent to the compost bin
  sending,

  /// The compost bin is verifying the wifi credentials
  verifying,

  /// The compost bin is verifying internet connectivity
  verifyingConnection,

  /// An error occurred during the wifi configuration
  error,
}
