import 'dart:convert';
import 'package:binsight_ai/widgets/bluetooth_alert_box.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:binsight_ai/util/print.dart';
import 'package:binsight_ai/util/bluetooth_bin_data.dart';
import 'package:binsight_ai/util/providers.dart';
import 'package:binsight_ai/util/wifi_scan.dart';
import 'package:binsight_ai/database/models/device.dart';
import 'package:binsight_ai/widgets/error_dialog.dart';
import 'package:binsight_ai/widgets/background.dart';

// TODO: handle potential case where incoming JSON is invalid

/// Widget for configuring the wifi credentials of the compost bin
class WifiConfigurationPage extends StatefulWidget {
  const WifiConfigurationPage({super.key});

  @override
  State<WifiConfigurationPage> createState() => _WifiConfigurationPageState();
}

class _WifiConfigurationPageState extends State<WifiConfigurationPage> {
  /// The wifi scan result
  WifiScanResult? wifiResult;

  /// Controller for the SSID text field
  final TextEditingController ssidController = TextEditingController();

  /// Controller for the password text field
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    setState(() {
      wifiResult = Provider.of<WifiResultNotifier>(context, listen: false).wifiResult;
    });
  }

  /// Sends the wifi credentials to the compost bin
  void sendCredentials(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return WifiConfigurationDialog(
              ssid: ssidController.text,
              password: passwordController.text,
              onErrorClosed: () {},
              onComplete: () {
                GoRouter.of(context).go("/main");
              });
        });
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
              onPressed: () {
                sendCredentials(context);
              },
              child: Text('Connect',
                  style: textTheme.labelLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  )),
            ),
            ElevatedButton(
              onPressed: () {
                Provider.of<SetupKeyNotifier>(context).setupKey.currentState?.previous();
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

/// An alert for the wifi configuration
class WifiConfigurationAlert extends StatelessWidget {
  const WifiConfigurationAlert({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return BluetoothAlertBox(
      title: Text(text, style: Theme.of(context).textTheme.headlineMedium),
      content: const SizedBox(
        height: 50,
        child: Center(
          child: SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}

class WifiConfigurationDialog extends StatefulWidget {
  const WifiConfigurationDialog(
      {super.key,
      required this.onErrorClosed,
      required this.onComplete,
      required this.ssid,
      required this.password});

  final Function() onErrorClosed;
  final Function() onComplete;

  final String ssid;
  final String password;

  @override
  State<WifiConfigurationDialog> createState() =>
      _WifiConfigurationDialogState();
}

class _WifiConfigurationDialogState extends State<WifiConfigurationDialog> {
  WifiConfigurationStatus status = WifiConfigurationStatus.waiting;
  Exception? error;

  @override
  void initState() {
    super.initState();
    sendCredentials();
  }

  /// Sends the wifi credentials to the compost bin and monitors the status
  void sendCredentials() async {
    final ssid = widget.ssid;
    final password = widget.password;
    final device = Provider.of<DeviceNotifier>(context, listen: false).device!;
    try {
      setState(() {
        status = WifiConfigurationStatus.sending;
      });
      await device.writeCharacteristic(
          serviceId: mainServiceId,
          characteristicId: wifiCredentialCharacteristicId,
          value: jsonEncode({
            "ssid": ssid,
            "password": password,
          }));
      await verifyStatus();
    } on Exception catch (e) {
      debug(e);
      if (!mounted) return;
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
      debug("Status Data: $statusData");
      late Map<dynamic, dynamic> statusJson;
      try {
        statusJson = jsonDecode(utf8.decode(statusData));
      } catch (e) {
        continue;
      }
      double timestamp = statusJson["timestamp"]; // in seconds
      String message = statusJson["message"];
      String? log = statusJson["log"];
      bool success = statusJson["success"];
      debug("Status: $statusJson");
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
            error = WifiConfigurationException('$message, $log');
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
    debug("Status Data 2: $statusData");
    final Map<dynamic, dynamic> statusJson =
        jsonDecode(utf8.decode(statusData));
    debug("Status: $statusJson");
    bool success = statusJson["success"];
    bool? internetAccess = statusJson["internet_access"];
    if (internetAccess != null && internetAccess && success) {
      if (!mounted) return;
      saveBinData();
      Provider.of<DeviceNotifier>(context, listen: false).resetDevice();
      widget.onComplete();
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
  Widget build(BuildContext context) {
    if (status == WifiConfigurationStatus.sending) {
      return const WifiConfigurationAlert(text: "Sending WiFi credentials...");
    } else if (status == WifiConfigurationStatus.verifying) {
      return const WifiConfigurationAlert(
          text: "Verifying WiFi credentials...");
    } else if (status == WifiConfigurationStatus.verifyingConnection) {
      return const WifiConfigurationAlert(text: "Verifying internet access...");
    } else if (status == WifiConfigurationStatus.error) {
      return ErrorDialog(
        text: "Error",
        description: """
An error occurred while configuring the WiFi.
The error was: ${error.toString()}.
""",
        callback: () {
          status = WifiConfigurationStatus.waiting;
          error = null;
          widget.onErrorClosed();
          Navigator.of(context).pop();
        },
      );
    } else {
      return const SizedBox();
    }
  }
}

/// The status of the wifi configuration dialog
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
