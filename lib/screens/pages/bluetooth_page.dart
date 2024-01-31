import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:go_router/go_router.dart';

/// Writes specified characteristic data to the device.
Future<void> writeCharacteristic(
    BluetoothDevice device, Guid characteristicId, List<int> data) async {
  // Compile all of the services and characteristics on the device
  List<BluetoothService> services = await device.discoverServices();
  for (BluetoothService service in services) {
    for (BluetoothCharacteristic characteristic in service.characteristics) {
      // Only write to the specified characteristic
      if (characteristic.uuid == characteristicId) {
        await characteristic.write(data,
            // This line was used for debugging, as we could not get proof-of-concept without it,
            // a general error was being consistently thrown and there was no indicator of what was causing it
            withoutResponse: true);
      }
    }
  }
}

/// Reads specified characteristic data from the device.
Future<void> readCharacteristic(
    BluetoothDevice device, Guid characteristicId) async {
  // Compile all of the services and characteristics on the device
  List<BluetoothService> services = await device.discoverServices();
  for (BluetoothService service in services) {
    for (BluetoothCharacteristic characteristic in service.characteristics) {
      // Only read the specified characteristic
      if (characteristic.uuid == characteristicId) {
        List<int> value = await characteristic.read();
        print('Read value: $value');
      }
    }
  }
}

/// Displays scanned Bluetooth devices.
class BluetoothPage extends StatefulWidget {
  const BluetoothPage({super.key});

  @override
  State<BluetoothPage> createState() => _BluetoothPageState();
}

/// Handles collecting Bluetooth devices to be displayed.
class _BluetoothPageState extends State<BluetoothPage> {
  final List<BluetoothDevice> _bluetoothDevices = [];

  @override
  void initState() {
    super.initState();

    // Opening the page should start a scan for devices
    performScan();
  }

  /// Connects to the specified device using Flutter Blue Plus's connect method.
  Future<void> connectToDevice(BluetoothDevice device) async {
    await device.connect();
  }

  /// Starts the Flutter Blue Plus scan and populates the results with found devices.
  void performScan() {
    // When scanning for devices, continuously update the list and remove old devices
    FlutterBluePlus.startScan(
      continuousUpdates: true,
      removeIfGone: const Duration(seconds: 3),
      // The below comment can be uncommented when the official device naming convention is decided
      // withKeywords: ["LE"]
    );

    // Listen to the scan stream to populate the found devices
    List<String> filteredBluetoothConnectionsString = [];
    FlutterBluePlus.scanResults.listen((results) {
      // Only add devices that have not already been put into _bluetoothDevices
      for (ScanResult r in results) {
        if (!filteredBluetoothConnectionsString
            .contains(r.advertisementData.advName)) {
          setState(() {
            _bluetoothDevices.add(r.device);
          });
          filteredBluetoothConnectionsString.add(r.advertisementData.advName);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const textSize = 20.0;

    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/images/background2.JPG"),
              fit: BoxFit.cover),
        ),
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
                      Colors.purple,
                      Colors.transparent,
                      Colors.transparent,
                      Colors.purple
                    ],
                    stops: [0.0, 0.2, 0.6, 1.0],
                  ).createShader(rect);
                },
                blendMode: BlendMode.dstOut,
                child: ListView.builder(
                  itemCount: _bluetoothDevices.length,
                  itemBuilder: (BuildContext context, int index) {
                    final bluetoothDevice = _bluetoothDevices[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0)),
                      child: ListTile(
                          leading: const Icon(Icons.bluetooth),
                          title: Text(bluetoothDevice.platformName),
                          trailing: const Icon(Icons.keyboard_arrow_right),
                          onTap: () async {
                            FlutterBluePlus.stopScan();
                            await connectToDevice(bluetoothDevice);
                            await readCharacteristic(
                                bluetoothDevice, Guid("2AF9"));
                            GoRouter.of(context)
                                .goNamed('wifi', extra: bluetoothDevice);
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

// listen for disconnection
// var subscription = device.connectionState.listen((BluetoothConnectionState state) async {
//     if (state == BluetoothConnectionState.disconnected) {
//         // 1. typically, start a periodic timer that tries to
//         //    reconnect, or just call connect() again right now
//         // 2. you must always re-discover services after disconnection!
//         print("${device.disconnectReasonCode} ${device.disconnectReasonDescription}");
//     }
// });
