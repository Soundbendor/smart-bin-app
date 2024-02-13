import 'dart:async';
import 'dart:collection';

import 'package:binsight_ai/main.dart';
import 'package:binsight_ai/util/print.dart';
import 'package:binsight_ai/widgets/background.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// Displays scanned Bluetooth devices.
class BluetoothPage extends StatefulWidget {
  const BluetoothPage({super.key});

  @override
  State<BluetoothPage> createState() => _BluetoothPageState();
}

/// Handles collecting Bluetooth devices to be displayed.
class _BluetoothPageState extends State<BluetoothPage> {
  final flutterReactiveBle = FlutterReactiveBle();
  final List<DiscoveredDevice> _foundBleUARTDevices = [];
  final Uuid _binServiceID = Uuid.parse("31415924535897932384626433832790");
  final List<String> _receivedData = [];
  Set<String>? deviceSet = {};
  PermissionStatus? status;

  @override
  void initState() {
    super.initState();
    // Opening the page should start a scan for devices
    scanForDevices();
  }

  void onNewReceivedData(List<int> data) {
    _receivedData.add(data as String);
  }

  /// Connects to the specified device using Flutter Blue Plus's connect method.
  // Future<void> connectToDevice(BluetoothDevice device) async {
  //   await device.connect();
  // }
  // Future<void> connectToBluetooth(String deviceId) async {
  //   var completer = Completer<void>();
  //   flutterReactiveBle.connectToDevice(
  //       id: deviceId,
  //       servicesWithCharacteristicsToDiscover: {_binServiceID: [Uuid.parse("31415924535897932384626433832791"), Uuid.parse("31415924535897932384626433832792"), Uuid.parse("31415924535897932384626433832793")]},
  //       connectionTimeout: const Duration(seconds: 2),
  //     ).listen((connectionState) {
  //       switch (connectionState.connectionState) {
  //         case DeviceConnectionState.connected:
  //           completer.complete();
  //           return;
  //         default:
  //       }

  //     }, onError: (Object error) {
  //       // Handle a possible error
  //     });
  //   return completer.future;
  // }
  // ################################################################################################
  // Future<void> connectToBluetooth(String deviceId) async {
  //   if (status != PermissionStatus.granted) {
  //     throw Exception("Fine location permission denied");
  //   }

  //   Completer<void> completer = Completer<void>();

  //   Stream<ConnectionStateUpdate> connectionStream =
  //       flutterReactiveBle.connectToDevice(
  //     id: deviceId,
  //     servicesWithCharacteristicsToDiscover: {
  //       _binServiceID: [
  //         Uuid.parse("31415924535897932384626433832791"),
  //         Uuid.parse("31415924535897932384626433832792"),
  //         Uuid.parse("31415924535897932384626433832793")
  //       ]
  //     },
  //     connectionTimeout: const Duration(seconds: 2),
  //   );

  //   await for (ConnectionStateUpdate connectionState in connectionStream) {
  //     switch (connectionState.connectionState) {
  //       case DeviceConnectionState.connected:
  //         completer.complete();
  //         return;
  //       case DeviceConnectionState.connecting:
  //         debug("CONNECTING");
  //         continue;
  //       case DeviceConnectionState.disconnecting:
  //         debug("DISCONNECTING");
  //         break;
  //       case DeviceConnectionState.disconnected:
  //         debug("DISCONNECTED");
  //         break;
  //       default:
  //     }
  //   }
  //   await completer.future;
  //   // return;
  //   // throw Exception("Connection failed");
  // }
  // ################################################################################################

  void connectToBluetooth(device) async {
    await device.connect();
  }
  
  Stream<DiscoveredDevice>? scanForDevices() {
    flutterReactiveBle.scanForDevices(withServices: []).listen(
      (device) {
        if (deviceSet != null && !deviceSet!.contains(device.name)) {
          deviceSet!.add(device.name);
          setState(
            () {
              _foundBleUARTDevices.add(device);
            },
          );
        }
      },
    );
    return null;
    // }, onError: () {
    //   //code for handling error
    // });
  }

  /// Starts the Flutter Blue Plus scan and populates the results with found devices.
  // void performScan() {
  //   // When scanning for devices, continuously update the list and remove old devices
  //   FlutterBluePlus.startScan(
  //     continuousUpdates: true,
  //     removeIfGone: const Duration(seconds: 3),
  //     // The below comment can be uncommented when the official device naming convention is decided
  //     // withKeywords: ["LE"]
  //   );

  //   // Listen to the scan stream to populate the found devices
  //   List<String> filteredBluetoothConnectionsString = [];
  //   FlutterBluePlus.scanResults.listen((results) {
  //     // Only add devices that have not already been put into _bluetoothDevices
  //     for (ScanResult r in results) {
  //       if (!filteredBluetoothConnectionsString
  //           .contains(r.advertisementData.advName)) {
  //         setState(() {
  //           _bluetoothDevices.add(r.device);
  //         });
  //         filteredBluetoothConnectionsString.add(r.advertisementData.advName);
  //       }
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    const textSize = 20.0;

    return Scaffold(
      body: CustomBackground(
        child: Column(
          children: [
            SizedBox(
              height:
                  (MediaQuery.of(context).size.height / 2) - (200 + textSize),
            ),
            const Text("Find your Bin!",
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
                  itemCount: _foundBleUARTDevices.length,
                  itemBuilder: (BuildContext context, int index) {
                    final bluetoothDevice = _foundBleUARTDevices[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0)),
                      child: ListTile(
                        leading: const Icon(Icons.bluetooth),
                        title: Text(bluetoothDevice.name),
                        trailing: const Icon(Icons.keyboard_arrow_right),
                        onTap: () async {
                          Provider.of<DeviceNotifier>(context, listen: false)
                              .setDevice(bluetoothDevice);
                          debug(Provider.of<DeviceNotifier>(context,
                                  listen: false)
                              .getDevice());
                          connectToBluetooth(bluetoothDevice);
                          // await bluetoothDevice.connect();
                          // await bluetoothDevice.createBond();
                          // await readCharacteristic(
                          // bluetoothDevice, Guid("2AF9"));
                          if (!mounted) return;
                          GoRouter.of(context).goNamed('wifi-scan');
                        },
                      ),
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
