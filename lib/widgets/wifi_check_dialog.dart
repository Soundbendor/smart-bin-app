// Flutter imports:
import 'dart:convert';
import 'package:flutter/material.dart';

// Package imports:
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:binsight_ai/pages/detection/index.dart';
import 'package:binsight_ai/util/bluetooth_bin_data.dart';
import 'package:binsight_ai/util/providers/device_notifier.dart';

/// Widget for building out different dialogs as a user completes the WiFi status
/// check sequence. Handles Bluetooth connection, characteristic reading, and displays
/// results.
class WifiCheckDialog extends StatefulWidget {
  const WifiCheckDialog({super.key});

  @override
  State<WifiCheckDialog> createState() => _WifiCheckDialogState();
}

class _WifiCheckDialogState extends State<WifiCheckDialog> {
  // Initialize wifiConnectedToInternet enum state to "waiting"
  WifiConnectedToInternet wifiConnectedToInternet =
      WifiConnectedToInternet.waiting;

  @override
  Widget build(BuildContext context) {
    // Uses consumer pattern to conditionally display different steps in the
    // WiFi status check process
    return Consumer<DeviceNotifier>(builder: (context, deviceNotifier, child) {
      if (deviceNotifier.device == null) {
        return const SizedBox();
      }
      // Case when device has not connected to Bluetooth yet
      if (!(deviceNotifier.device!.isBonded &&
          deviceNotifier.device!.isConnected)) {
        return AlertDialog(
          title: Text(
            "Connecting to Bluetooth",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
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
      // Case when device has connected to Bluetooth but not read status
      if (deviceNotifier.device!.isBonded &&
          deviceNotifier.device!.isConnected &&
          wifiConnectedToInternet == WifiConnectedToInternet.waiting) {
        // Begin reading the WiFi status characteristic until it returns
        getWifiStatusCharacteristic();
        return AlertDialog(
          title: Text(
            "Checking Wi-Fi Status",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
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
      // Case when device has connected to Bluetooth and has read status
      if (deviceNotifier.device!.isBonded &&
          deviceNotifier.device!.isConnected &&
          wifiConnectedToInternet != WifiConnectedToInternet.waiting) {
        return AlertDialog(
          title: Text(
            "Wi-Fi Connection Status",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          // Depending on the status of the WiFi connection, display different text
          content: Text(
              wifiConnectedToInternet == WifiConnectedToInternet.connected
                  ? "All good! You were already connected, did you want to select a new network?"
                  : "Oops! Your bin was disconnected from the internet. Reconnect now?",
              style: Theme.of(context).textTheme.bodyLarge),
          actions: <Widget>[
            TextButton(
              style: Theme.of(context).elevatedButtonTheme.style!.copyWith(
                    backgroundColor: WidgetStateProperty.all(
                      Theme.of(context).colorScheme.surface,
                    ),
                  ),
              onPressed: () {
                // Removes the dialog
                Navigator.of(context).pop();
              },
              child: Text(
                "No",
                style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withAlpha(250),
                    ),
              ),
            ),
            TextButton(
              onPressed: () {
                // Take the user back to the Wi-Fi scan setup sequence.
                Navigator.of(context).pop();
                GoRouter.of(context).pushReplacementNamed("wifi-scan");
              },
              style: TextButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 116, 193, 164)),
              child: const Text("Yes"),
            ),
          ],
        );
      }
      // Catch-all case, should NEVER happen
      return const Text(
          "If you reach this screen, please contact the developers via the email found in the Help menu.");
    });
  }

  /// Reads and decodes the Wi-Fi status characteristic, then updates wifiConnectedToInternet
  /// state based on the characteristic's value.
  void getWifiStatusCharacteristic() async {
    DeviceNotifier notifierProvider =
        Provider.of<DeviceNotifier>(context, listen: false);
    await Future.delayed(const Duration(seconds: 2));

    final statusCharacteristic = await notifierProvider.device
        ?.readCharacteristic(
            serviceId: mainServiceId,
            characteristicId: wifiStatusCharacteristicId);
    final Map<String, dynamic> statusJson =
        jsonDecode(utf8.decode(statusCharacteristic!));

    setState(() {
      // If the device was connected to Wi-Fi at all
      if (statusJson["success"]) {
        // Set it to either connected or notConnected based on internet access
        wifiConnectedToInternet = (statusJson["internet_access"])
            ? WifiConnectedToInternet.connected
            : WifiConnectedToInternet.notConnected;
      } else {
        // If the device was not connected to Wi-Fi, it had no internet
        wifiConnectedToInternet = WifiConnectedToInternet.notConnected;
      }
    });
  }
}
