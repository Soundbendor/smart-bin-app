// Flutter imports:
import 'dart:convert';
import 'package:flutter/material.dart';

// Package imports:
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:binsight_ai/util/bluetooth_bin_data.dart';
import 'package:binsight_ai/util/print.dart';
import 'package:binsight_ai/util/shared_preferences.dart';
import 'package:binsight_ai/util/providers/device_notifier.dart';
import 'package:binsight_ai/util/providers/setup_key_notifier.dart';
import 'package:binsight_ai/util/providers/wifi_result_notifier.dart';
import 'package:binsight_ai/util/wifi_scan.dart';
import 'package:binsight_ai/widgets/background.dart';
import 'package:binsight_ai/widgets/bluetooth_alert_box.dart';
import 'package:binsight_ai/widgets/error_dialog.dart';

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
      wifiResult =
          Provider.of<WifiResultNotifier>(context, listen: false).wifiResult;
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
              onComplete: () async {
                // Take the user to main
                GoRouter.of(context).go("/main");
              });
        });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final provider = Provider.of<WifiResultNotifier>(context);
    if (provider.wifiResult != null) {
      ssidController.text = provider.wifiResult!.ssid;
    }
    return Scaffold(
      body: CustomBackground(
        imageURL: "assets/images/wifi_config_screen.png",
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child:
                  Text('Connect Bin to WiFi', style: textTheme.headlineSmall),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: TextField(
                controller: ssidController,
                decoration: const InputDecoration(labelText: 'Network Name'),
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
                // Send the values entered in ssid/password field to the bin
                sendCredentials(context);
              },
              child: Text('Connect',
                  style: textTheme.labelLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  )),
            ),
            ElevatedButton(
              onPressed: () {
                // Allows users to navigate back a page to modify their selected network
                Provider.of<SetupKeyNotifier>(context, listen: false)
                    .setupKey
                    .currentState
                    ?.previous();
              },
              child: Text("Back",
                  style: textTheme.labelLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  )),
            ),
          ],
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
      await Future.delayed(const Duration(seconds: 2));
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
    while (tries < 15) {
      // final now = DateTime.now();
      final statusData = await device.readCharacteristic(
          serviceId: mainServiceId,
          characteristicId: wifiCredentialCharacteristicId);
      debug("Status Data: $statusData");
      late Map<dynamic, dynamic> statusJson;
      try {
        statusJson = jsonDecode(utf8.decode(statusData));
      } catch (e) {
        debug(e);
        continue;
      }
      double timestamp = statusJson["timestamp"]; // in seconds
      debug("TIMESTAMP: $timestamp");
      String message = statusJson["message"];
      String? log = statusJson["log"];
      bool success = statusJson["success"];
      debug("Status: $statusJson");
      tries++;
      await Future.delayed(const Duration(seconds: 2));
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
    debug("INTERNET ACCESS: $internetAccess, SUCCESS: $success");
    if (internetAccess != null && internetAccess && success) {
      if (!mounted) return;
      await Future.delayed(const Duration(seconds: 2));
      fetchCredentials();
    } else {
      if (!mounted) return;
      setState(() {
        status = WifiConfigurationStatus.error;
        error = WifiConfigurationException("No internet access");
      });
    }
  }

  /// Fetches the compost bin credentials
  Future<void> fetchCredentials() async {
    if (!mounted) return;
    setState(() {
      status = WifiConfigurationStatus.fetchingCredentials;
    });
    final device = Provider.of<DeviceNotifier>(context, listen: false).device!;
    final credentialData = await device.readCharacteristic(
        serviceId: apiServiceId, characteristicId: apiKeyCharacteristicId);
    debug("API Data: $credentialData");
    final Map<dynamic, dynamic> credentialJson =
        jsonDecode(utf8.decode(credentialData));
    debug("Status: $credentialJson");
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    // Once the user has finalized their Bluetooth device choice, add it to preferences
    Provider.of<DeviceNotifier>(context, listen: false).resetDevice();
    sharedPreferences.setString(
        SharedPreferencesKeys.apiKey, credentialJson["apiKey"]);
    sharedPreferences.setString(SharedPreferencesKeys.deviceApiID,
        credentialJson["deviceID"].toString());
    sharedPreferences.setString(SharedPreferencesKeys.deviceID, device.id);
    widget.onComplete();
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
    } else if (status == WifiConfigurationStatus.fetchingCredentials) {
      return const WifiConfigurationAlert(text: "Fetching credentials...");
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

  /// Fetching bin credentials
  fetchingCredentials,

  /// An error occurred during the wifi configuration
  error,
}
