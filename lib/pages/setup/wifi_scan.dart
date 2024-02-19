import 'dart:convert';
import 'package:binsight_ai/util/bluetooth_bin_data.dart';
import 'package:binsight_ai/widgets/background.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:binsight_ai/util/bluetooth.dart';
import 'package:binsight_ai/util/providers.dart';

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
  }

  void scanForWifi() async {
    try {
      isScanning = true;
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
    } on Exception catch (e) {
      widget.device
          .unsubscribeFromCharacteristic(
              serviceId: mainServiceId,
              characteristicId: wifiListCharacteristicId)
          .ignore();
      setState(() {
        error = e;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const textSize = 20.0;

    return Consumer<DeviceNotifier>(
      builder: (context, value, child) {
        final device = value.device!;
        if (!isModalOpen) {
          if (error != null) {
            // TODO: show error modal
          } else if (!device.isConnected) {
            // TODO: show disconnect modal
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
                          scanForWifi();
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
            GoRouter.of(context).goNamed('wifi', extra: wifiResult);
          }),
    );
  }
}

class WifiScanResult {
  final String ssid;
  final String security;
  final int signalStrength;

  WifiScanResult(this.ssid, this.security, this.signalStrength);
}
