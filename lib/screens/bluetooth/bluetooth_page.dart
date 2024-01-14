import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:sqflite/utils/utils.dart';
import 'dart:async';

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

  Future<void> _getScannedResults() async {
    // When scanning for devices, continuously update the list and remove old devices
    FlutterBluePlus.startScan(
      continuousUpdates: true,
      removeIfGone: const Duration(seconds: 3),
      withKeywords: ["LE"]
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
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/background2.JPG"),
          fit: BoxFit.cover),
      ),
      child: Column(
        children: [
          const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 180.0, left: 50.0, right: 50.0),
              child: Text(
                "Find your Bin!",
                style: TextStyle(
                  fontSize: 40,
                  color: Color(0xff787878),
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
          ),
          Flex(
            direction: Axis.vertical,
            children: [
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xffe3e3e3),
                    borderRadius: BorderRadius.circular(15.0),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromARGB(255, 150, 150, 150),
                        blurRadius: 3,
                        offset: Offset(0, 5),
                      )
                    ]
                  ),
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
                            onTap: () {
                              GoRouter.of(context).goNamed('wifi');
                            }
                          ),
                        );
                      },
                    ),
                  ),
              ),
            Container()
            ],
          ),
        ],
      ),
    );
  }
}