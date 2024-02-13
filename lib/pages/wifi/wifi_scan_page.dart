 import 'dart:convert';

import 'package:binsight_ai/main.dart';
import 'package:binsight_ai/util/print.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:wifi_scan/wifi_scan.dart';

/// Displays the WiFi configuration page with background and padding.
class WifiScanPage extends StatefulWidget {
  const WifiScanPage({super.key});

  @override
  State<WifiScanPage> createState() => _WifiScanPageState();
}

class _WifiScanPageState extends State<WifiScanPage> {
  // _WifiScanPageState();

  List<WiFiAccessPoint> wifiResults = [];
  final flutterReactiveBle = FlutterReactiveBle();
  final Uuid _binServiceID = Uuid.parse("31415924535897932384626433832790");
  final Uuid _wifiCredID = Uuid.parse("31415924535897932384626433832793");

  Future<void> _initializeWifiPlugin() async {
    await WiFiForIoTPlugin.forceWifiUsage(true);
  }

  void _startScan(DiscoveredDevice? bluetoothDevice) {
    if (bluetoothDevice != null) {
      final characteristic = QualifiedCharacteristic(
          serviceId: _binServiceID,
          characteristicId: _wifiCredID,
          deviceId: bluetoothDevice.id);
      flutterReactiveBle.subscribeToCharacteristic(characteristic).listen(
        (data) {
          debug(utf8.decode(data));
          // }, onError: (dynamic error) {
        },
      );
    }
  }

  // Future<void> _startScan() async {
  //   final canStartScan =
  //       await WiFiScan.instance.canStartScan(askPermissions: true);
  //   // Switch statement should go here
  //   switch (canStartScan) {
  //     case CanStartScan.yes:
  //       final isScanning = await WiFiScan.instance.startScan();
  //       if (isScanning) {
  //         _getScannedResults();
  //       }
  //       break;
  //     case CanStartScan.failed:
  //       // Handle the case where scanning is not possible
  //       break;
  //     case CanStartScan.notSupported:
  //       // Handle the case where the user denied the necessary permissions
  //       break;
  //     case CanStartScan.noLocationServiceDisabled:
  //       debug("location service disabled");
  //     default:
  //       // handle default case
  //       debug("default case: $canStartScan");
  //   }
  // }

  Future<void> _getScannedResults() async {
    final canGetResults =
        await WiFiScan.instance.canGetScannedResults(askPermissions: true);

    switch (canGetResults) {
      case CanGetScannedResults.yes:
        final accessPoints = await WiFiScan.instance.getScannedResults();
        // Define regex on wifi ssid
        RegExp wifiNameCheck = RegExp(r'');
        // List of wifi access points that will store the filtered, regex'd networks that match our bins
        List<WiFiAccessPoint> filteredAccessPoints = [];
        // List of strings that keep track of what access points have been added to our display list
        List<String> filteredAccessPointsString = [];
        // Iterate through all scanned access points and only add the ones that meet our criteria
        for (var point in accessPoints) {
          if (wifiNameCheck.hasMatch(point.ssid) &&
              !filteredAccessPointsString.contains(point.ssid)) {
            filteredAccessPoints.add(point);
          }

          filteredAccessPointsString.add(point.ssid);
        }

        setState(() {
          wifiResults = filteredAccessPoints;
        });
        break;
      case CanGetScannedResults.noLocationServiceDisabled:
        // Handle the case where getting results is not possible
        break;
      case CanGetScannedResults.noLocationPermissionDenied:
        // Handle the case where the user denied the necessary permissions
        break;
      default:
      // handle default
    }
  }

  @override
  Widget build(BuildContext context) {
    final DiscoveredDevice? bluetoothDevice =
        Provider.of<DeviceNotifier>(context, listen: false).getDevice();
    _startScan(bluetoothDevice);
    const textSize = 20.0;

    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/images/FlowersBackground.png"),
              fit: BoxFit.cover),
        ),
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
                  itemBuilder: (BuildContext context, int index) {
                    final wifiResult = wifiResults[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0)),
                      child: ListTile(
                          leading: const Icon(Icons.wifi),
                          title: Text(wifiResult.ssid),
                          trailing: const Icon(Icons.keyboard_arrow_right),
                          onTap: () async {
                            GoRouter.of(context)
                                .goNamed('wifi', extra: wifiResult.ssid);
                          }),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
