import 'dart:async';
import 'dart:collection';
import 'dart:io';

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
  final client = FlutterReactiveBle();
  final Set<String> deviceSet = {};
  final List<DiscoveredDevice> scannedDevices = [];
  StreamSubscription? scanSubscription;
  bool connected = false;

  @override
  void initState() {
    super.initState();
    scanForDevices();
  }
  /// After ensuring the platform-dependent permissions are accepted, performs a scan for nearby devices.
  void scanForDevices() async {
    if (Platform.isAndroid) {
      var status = await Permission.location.request();

      if (status != PermissionStatus.granted) {
        throw Exception("Fine location permission denied");
      } else {
        debug("Fine location permission granted");
      }

      status = await Permission.bluetoothScan.request();
      if (status != PermissionStatus.granted) {
        throw Exception("Bluetooth scan permission denied");
      } else {
        debug("Bluetooth scan permission granted");
      }

      status = await Permission.bluetoothConnect.request();
      if (status != PermissionStatus.granted) {
        throw Exception("Bluetooth connect permission denied");
      } else {
        debug("Bluetooth connect permission granted");
      }
    } else {
      if (await Permission.bluetooth.isRestricted) {
        var status = await Permission.bluetooth.request();
        if (status != PermissionStatus.granted) {
          throw Exception("Bluetooth permission denied");
        } else {
          debug("Bluetooth permission granted");
        }
      }
    }
  final sub = client.scanForDevices(withServices: [
      Uuid.parse("31415924535897932384626433832790")
    ]).listen((device) {
      debug("Found device: ${device.name}");
      if (device.name.trim() == "") return;
      setState(() {
        if (!deviceSet.contains(device.id)) {
          deviceSet.add(device.id);
          scannedDevices.add(device);
        }
      });
    });
    setState(() {
      scanSubscription = sub;
    });
  }

  /// Connects to the specified device and discovers its services. 
  /// If it has to attempt more than three times, it will fail out.
  void connect(BluetoothDevice device) async {
    debug(device);
    if (!device.isConnected) {
      int tries = 0;
      while (tries < 3) {
        try {
          await device.connect();
          break;
        } catch (e) {
          debug("Failed to connect to device: $e");
          tries++;
        }
      }
      debug("Connected to device: ${device.advName}");
    }
    int tries = 0;
    while (tries < 3) {
      try {
        var services = await device.discoverServices();
        setState(() {
          connected = true;
          services = services;
        });
        break;
      } catch (e) {
        debug("Failed to discover services: $e");
        tries++;
      }
    }
  }

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
                  itemCount: scannedDevices.length,
                  itemBuilder: (BuildContext context, int index) {
                    final device = scannedDevices[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0)),
                      child: ListTile(
                        leading: const Icon(Icons.bluetooth),
                        title: Text(device.name),
                        trailing: const Icon(Icons.keyboard_arrow_right),
                        onTap: () async {
                          // THIS LINE IS SO FUCKING SCUFFED?!?!? COULDNT CAST FROM DISCOVEREDDEVICE TO BTDEVICE
                          connect(BluetoothDevice(remoteId: DeviceIdentifier(device.id)));
                          Provider.of<DeviceNotifier>(context, listen: false)
                              .setDevice(device);
                          debug(Provider.of<DeviceNotifier>(context,
                                  listen: false)
                              .getDevice());
                          scanSubscription?.cancel();
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
