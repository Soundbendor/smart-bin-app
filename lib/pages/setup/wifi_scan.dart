// Flutter imports:
import 'dart:convert';
import 'package:binsight_ai/util/shared_preferences.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:binsight_ai/util/async_ops.dart';
import 'package:binsight_ai/util/bluetooth_bin_data.dart';
import 'package:binsight_ai/util/bluetooth.dart';
import 'package:binsight_ai/util/bluetooth_dialog_strings.dart';
import 'package:binsight_ai/util/bluetooth_exception.dart';
import 'package:binsight_ai/util/print.dart';
import 'package:binsight_ai/util/providers/device_notifier.dart';
import 'package:binsight_ai/util/providers/setup_key_notifier.dart';
import 'package:binsight_ai/util/providers/wifi_result_notifier.dart';
import 'package:binsight_ai/util/styles.dart';
import 'package:binsight_ai/util/wifi_scan.dart';
import 'package:binsight_ai/widgets/background.dart';
import 'package:binsight_ai/widgets/bluetooth_alert_box.dart';
import 'package:binsight_ai/widgets/error_dialog.dart';
import 'package:binsight_ai/widgets/scan_list.dart';

/// Displays the WiFi configuration page with background and padding.
class WifiScanPage extends StatefulWidget {
  const WifiScanPage({super.key});

  @override
  State<WifiScanPage> createState() => _WifiScanPageState();
}

class _WifiScanPageState extends State<WifiScanPage> {
  /// The Bluetooth device to retrieve information from
  BleDevice? device;

  /// The list of WiFi networks scanned.
  List<WifiScanResult> wifiResults = [];

  /// Whether the error modal is currently open.
  bool isModalOpen = false;

  /// Whether the device is currently scanning for WiFi networks.
  bool isScanning = false;

  /// The error that occurred.
  Exception? error;

  /// The future for checking disconnect status of device.
  Future? disconnectFuture;

  @override
  void initState() {
    super.initState();
    initDevice();
    startScanning();
  }

  void initDevice() {
    setState(() {
      device = Provider.of<DeviceNotifier>(context, listen: false).device;
    });
  }

  /// Begins the subscription for WiFi networks scan.
  void startScanning() async {
    try {
      setState(() {
        isScanning = true;
      });
      await device!.subscribeToCharacteristic(
          serviceId: mainServiceId,
          characteristicId: wifiListCharacteristicId,
          onNotification: (data) {
            try {
              final List<dynamic> content = jsonDecode(utf8.decode(data));
              debug("WiFi scan results: $content");
              setState(() {
                wifiResults = content
                    .map((e) => WifiScanResult(e[0], e[1], e[2]))
                    .toList();
              });
            } catch (e) {
              // likely empty message
            }
          });
      fetchWifiList();
    } on Exception catch (e) {
      stopScanning();
      setState(() {
        isScanning = false;
        error = e;
      });
    }
  }

  /// Stops scanning for WiFi networks.
  void stopScanning() {
    device!
        .unsubscribeFromCharacteristic(
            serviceId: mainServiceId,
            characteristicId: wifiListCharacteristicId)
        .ignore();
  }

  /// Fetches the WiFi network list manually.
  ///
  /// This may speed up when items appear in the list at the start.
  void fetchWifiList() async {
    try {
      if (wifiResults.isNotEmpty) return;
      final List<dynamic> parsed = jsonDecode(utf8.decode(await device!
          .readCharacteristic(
              serviceId: mainServiceId,
              characteristicId: wifiListCharacteristicId)));
      if (wifiResults.isNotEmpty) {
        setState(() {
          wifiResults =
              parsed.map((e) => WifiScanResult(e[0], e[1], e[2])).toList();
        });
      }
    } catch (e) {
      debug("Error manually fetching WiFi list: $e");
    }
  }

  /// Navigates to the WiFi configuration page with the selected WiFi network.
  void goToWifiConfiguration(WifiScanResult wifiResult) {
    stopScanning();
    isScanning = false;
    Provider.of<WifiResultNotifier>(context, listen: false)
        .setWifiResult(wifiResult);
    Provider.of<SetupKeyNotifier>(context, listen: false)
        .setupKey
        .currentState
        ?.next();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DeviceNotifier>(
      builder: (context, value, child) {
        final device = value.device;
        if (device == null) return const SizedBox();
        debug("Connected = ${device.isConnected}");
        if (!isModalOpen) {
          if (error != null) {
            isModalOpen = true;
            String text;
            String description;
            if (error is BleOperationFailureException) {
              text = "Scan Failure";
              description = """
Unable to scan for WiFi networks. If this error persists, please try resetting your bluetooth settings, restarting the bin, or try again later.
The error was: ${(error as BleOperationFailureException).message}.
""";
            } else {
              final strings = getStringsFromException(error);
              text = strings.title;
              description = strings.description;
            }
            runSoon(() {
              showDialog(
                  context: context,
                  builder: (context) {
                    return ErrorDialog(
                        text: text,
                        description: description,
                        callback: () {
                          setState(() {
                            isModalOpen = false;
                            error = null;
                          });
                          Navigator.of(context).pop();
                        });
                  });
            });
          } else if (!device.isConnected && isScanning) {
            isModalOpen = true;
            runSoon(() {
              showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) {
                    disconnectFuture =
                        Future.delayed(const Duration(seconds: 25), () => {});
                    return Consumer<DeviceNotifier>(
                      builder: (context, notifier, child) {
                        if (notifier.device!.isConnected) {
                          runSoon(() {
                            Navigator.of(context).pop();
                            setState(() {
                              isModalOpen = false;
                              error = null;
                            });
                          });
                          return const SizedBox();
                        }
                        return child!;
                      },
                      child: WifiScanDisconnectDialog(
                          callback: (context) {
                            Navigator.of(context).pop();
                            setState(() {
                              isModalOpen = false;
                              isScanning = false;
                              error = null;
                            });
                          },
                          disconnectFuture: disconnectFuture),
                    );
                  });
            });
          }
        }
        return child!;
      },
      child: Scaffold(
        body: CustomBackground(
          imageURL: "assets/images/wifi_scan_screen.png",
          child: Column(
            children: [
              ScanList(
                itemCount: wifiResults.length,
                listBuilder: buildWifiItem,
                onResume: () {
                  setState(() {
                    startScanning();
                  });
                },
                title: "Select Your Network!",
                inProgress: isScanning,
              ),
              // Only display back button for introduction sequence
              if (sharedPreferences.getString("deviceID") == null)
                ElevatedButton(
                  onPressed: () {
                    stopScanning();
                    Provider.of<DeviceNotifier>(context, listen: false)
                        .resetDevice();
                    Provider.of<SetupKeyNotifier>(context, listen: false)
                        .setupKey
                        .currentState
                        ?.previous();
                  },
                  child: Text(
                    "Back",
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a WiFi network list item.
  Widget buildWifiItem(BuildContext context, int index) {
    final wifiResult = wifiResults[index];
    IconData icon;
    if (wifiResult.security.startsWith("WPA")) {
      icon = Icons.lock_outline;
    } else {
      icon = Icons.lock_open;
    }
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      shape: bluetoothBorderRadius,
      child: ListTile(
          leading: const Icon(Icons.wifi),
          title:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(wifiResult.ssid, softWrap: true),
            Icon(icon),
          ]),
          trailing: const Icon(Icons.keyboard_arrow_right),
          onTap: () {
            goToWifiConfiguration(wifiResult);
          }),
    );
  }
}

class WifiScanDisconnectDialog extends StatelessWidget {
  const WifiScanDisconnectDialog({
    super.key,
    required this.callback,
    required this.disconnectFuture,
  });

  final Null Function(dynamic context) callback;
  final Future? disconnectFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: (context, future) {
        final textTheme = Theme.of(context).textTheme;
        if (future.connectionState == ConnectionState.done) {
          return ErrorDialog(
            text: "Device Disconnected",
            description:
                "Unable to connect to the device. Please make sure the bin is powered on and in range.",
            callback: () {
              callback(context);
            },
          );
        } else {
          return BluetoothAlertBox(
            title: Text("Device Disconnected", style: textTheme.headlineMedium),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "The device has disconnected. Reconnecting...",
                  style: textTheme.bodyMedium,
                  softWrap: true,
                ),
                const Center(
                  child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator()),
                ),
              ],
            ),
          );
        }
      },
      future: disconnectFuture,
    );
  }
}
