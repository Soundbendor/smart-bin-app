import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:sqflite/utils/utils.dart';
import 'dart:async';
import 'dart:convert';

Future<void> writeCharacteristic(BluetoothDevice device, Guid characteristicId, List<int> data) async {
  List<BluetoothService> services = await device.discoverServices();
  for (BluetoothService service in services) {
    for (BluetoothCharacteristic characteristic in service.characteristics) {
      if (characteristic.uuid == characteristicId) {
        await characteristic.write(
          data,
          withoutResponse: true
        );
        print('Data written successfully.');
      }
    }
  }
}

Future<void> readCharacteristic(BluetoothDevice device, Guid characteristicId) async {
  List<BluetoothService> services = await device.discoverServices();
  for (BluetoothService service in services) {
    for (BluetoothCharacteristic characteristic in service.characteristics) {
      if (characteristic.uuid == characteristicId) {
        List<int> value = await characteristic.read();
        print('Read value: $value');
      }
    }
  }
}

class BluetoothPage extends StatefulWidget {
  const BluetoothPage({super.key});

  @override
  State<BluetoothPage> createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
  final List<BluetoothDevice> _bluetoothDevices = [];

  @override
  void initState() {
    super.initState();

    // Opening the page should start a scan
    performScan();
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    await device.connect();
  }

  Future<void> _getScannedResults() async {
    // When scanning for devices, continuously update the list and remove old devices
    FlutterBluePlus.startScan(
      continuousUpdates: true,
      removeIfGone: const Duration(seconds: 3),
      // withKeywords: ["LE"]
    );
  }

  void performScan() {
    _getScannedResults();

    // List of bluetooth connections names to ensure no duplicates are captured
    List<String> filteredBluetoothConnectionsString = [];
      // Start scanning for bluetooth connections
      FlutterBluePlus.scanResults.listen((results) {
        // Iterate through all scanned bluetooth connections and only add ones that meet criteria 
        for (ScanResult r in results) {
          if (!filteredBluetoothConnectionsString.contains(r.advertisementData.advName)) {
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
            fit: BoxFit.cover
          ),
        ),
        child: Column(
            children: [
              SizedBox(
                height: (MediaQuery.of(context).size.height / 2) - (200 + textSize),
              ),
              const Text(
                "Find your Bin!",
                style: TextStyle(
                  fontSize: textSize,
                )
              ),
              Container(
                color: Colors.white,
                height: MediaQuery.of(context).size.height / 2,
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
                          await readCharacteristic(bluetoothDevice, Guid("2AF9"));
                          print("got past the connection!!L!!!!OOLODOASKDD");
                          GoRouter.of(context).goNamed('wifi', extra:bluetoothDevice);
                        }
                      ),
                    );
                  },
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