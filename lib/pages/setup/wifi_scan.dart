import 'dart:convert';
import 'package:binsight_ai/util/bluetooth_dialog_strings.dart';
import 'package:binsight_ai/util/print.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:binsight_ai/util/bluetooth.dart';
import 'package:binsight_ai/util/providers.dart';
import 'package:binsight_ai/util/bluetooth_bin_data.dart';
import 'package:binsight_ai/util/bluetooth_exception.dart';
import 'package:binsight_ai/util/wifi_scan.dart';
import 'package:binsight_ai/widgets/background.dart';
import 'package:binsight_ai/widgets/error_dialog.dart';

/// Displays the WiFi configuration page with background and padding.
class WifiScanPage extends StatefulWidget {
  const WifiScanPage({super.key, required this.device});

  /// The Bluetooth device to retrieve information from
  final BleDevice device;

  @override
  State<WifiScanPage> createState() => _WifiScanPageState();
}

class _WifiScanPageState extends State<WifiScanPage> {
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
    startScanning();
  }

  /// Begins the subscription for WiFi networks scan.
  void startScanning() async {
    try {
      await widget.device.subscribeToCharacteristic(
          serviceId: mainServiceId,
          characteristicId: wifiListCharacteristicId,
          onNotification: (data) {
            try {
              final List<dynamic> content = jsonDecode(utf8.decode(data));
              setState(() {
                wifiResults = content
                    .map((e) => WifiScanResult(e[0], e[1], e[2]))
                    .toList();
              });
            } catch (e) {
              // likely empty message
            }
          });
      setState(() {
        isScanning = true;
      });
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
    widget.device
        .unsubscribeFromCharacteristic(
            serviceId: mainServiceId,
            characteristicId: wifiListCharacteristicId)
        .ignore();
  }

  /// Navigates to the WiFi configuration page with the selected WiFi network.
  void goToWifiConfiguration(WifiScanResult wifiResult) {
    stopScanning();
    isScanning = false;
    GoRouter.of(context).goNamed('wifi', extra: wifiResult);
  }

  @override
  Widget build(BuildContext context) {
    const textSize = 20.0;

    return Consumer<DeviceNotifier>(
      builder: (context, value, child) {
        final device = value.device!;
        debug("Connected = ${device.isConnected}");
        if (!isModalOpen) {
          if (error != null) {
            isModalOpen = true;
            String text;
            String description;
            if (error is BleOperationFailureException) {
              text = "Scan Failure";
              description = """
Unable to scan for WiFi networks. If this error persists, please try restarting the bin, or try again later.
The error was: ${(error as BleOperationFailureException).message}.
""";
            } else {
              final strings = getStringsFromException(error);
              text = strings.title;
              description = strings.description;
            }
            Future.delayed(Duration.zero, () {
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
            Future.delayed(Duration.zero, () {
              showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) {
                    disconnectFuture =
                        Future.delayed(const Duration(seconds: 25), () => {});
                    return Consumer<DeviceNotifier>(
                      builder: (context, notifier, child) {
                        if (notifier.device!.isConnected) {
                          Future.delayed(Duration.zero, () {
                            Navigator.of(context).pop();
                            setState(() => isModalOpen = false);
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
          imageURL: "assets/images/FlowersBackground.png",
          child: Column(
            children: [
              SizedBox(
                height:
                    (MediaQuery.of(context).size.height / 2) - (200 + textSize),
              ),
              const Text("Select Your Network!",
                  style: TextStyle(
                    fontSize: textSize,
                  )),
              Container(
                color: const Color.fromRGBO(0, 0, 0, 0),
                height: MediaQuery.of(context).size.height / 2.5,
                child: ShaderMask(
                  shaderCallback: (Rect rect) {
                    return const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color.fromARGB(255, 0, 0, 0),
                        Colors.transparent,
                        Colors.transparent,
                        Color.fromARGB(255, 0, 0, 0)
                      ],
                      stops: [0.0, 0.2, 0.9, 1.0],
                    ).createShader(rect);
                  },
                  blendMode: BlendMode.dstOut,
                  child: ListView.builder(
                    itemCount: wifiResults.length,
                    itemBuilder: buildWifiItem,
                  ),
                ),
              ),
              isScanning
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () {
                        setState(() {
                          startScanning();
                        });
                      },
                      child: Text("Resume Scan",
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge!
                              .copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                              )),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a WiFi network list item.
  Widget? buildWifiItem(BuildContext context, int index) {
    final wifiResult = wifiResults[index];
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: ListTile(
          leading: const Icon(Icons.wifi),
          title: Text(wifiResult.ssid),
          trailing: const Icon(Icons.keyboard_arrow_right),
          onTap: () async {
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
          return AlertDialog(
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
