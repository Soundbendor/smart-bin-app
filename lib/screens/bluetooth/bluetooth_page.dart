import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:sqflite/utils/utils.dart';
import 'dart:async';

class BluetoothPage extends StatefulWidget {
  const BluetoothPage({Key? key}) : super(key: key);

  @override
  State<BluetoothPage> createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
  List<BluetoothDevice> _bluetoothDevices = [];
  bool isScanning = true;
  bool disableButton = false;
  Timer? _delayTimer;


  @override
  void initState() {
    super.initState();

    // Opening the page should start a scan
    performScan();
  }

  Future<void> _getScannedResults() async {
    FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 5)
    );
    
    _delayTimer?.cancel();
    _delayTimer = Timer(const Duration(seconds: 5), () {
      setState(() {
        isScanning = false;
      });
    });
  }

  void rescanButtonPressedLogic() async {
    _delayTimer?.cancel();

    if (isScanning) {
      FlutterBluePlus.stopScan();
      // _delayTimer?.cancel();
      setState(() {
        isScanning = false;
        disableButton = true;
        _delayTimer = Timer(const Duration(seconds: 5), () {
          disableButton = false;
        });
      });
    }
    else {
      setState(() {
        isScanning = true;
        performScan();
      });
    }

  }

  void performScan() {
    setState(() {
      _bluetoothDevices = [];
    });

    _getScannedResults();
  
    // Define regex on bluetooth name
    RegExp bluetoothNameCheck = RegExp(r'');
    // List of bluetooth connections names to ensure no duplicates are captured
    List<String> filteredBluetoothConnectionsString = [];
      // Start scanning for bluetooth connections
      FlutterBluePlus.scanResults.listen((results) {
        // Iterate through all scanned bluetooth connections and only add ones that meet criteria 
        for (ScanResult r in results) {
          if (bluetoothNameCheck.hasMatch(r.advertisementData.advName) &&
          !filteredBluetoothConnectionsString.contains(r.advertisementData.advName)) {
            setState(() {
              _bluetoothDevices.add(r.device);
            });
            filteredBluetoothConnectionsString.add(r.advertisementData.advName);
          }
        }
      });
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
            Expanded(
              child: Padding(
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
                            title: Text(bluetoothDevice.platformName != '' 
                              ? bluetoothDevice.platformName 
                              : 'Unknown Device'),
                            trailing: const Icon(Icons.keyboard_arrow_right),
                            onTap: () {
                                  GoRouter.of(context).goNamed('wifi');
                            }
                          )
                        );
                      },
                    ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 250.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextButton(
                      style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(16.0),
                          textStyle: const TextStyle(fontSize: 20),
                          backgroundColor: const Color(0xFF15a2cd)),
                      onPressed: () {
                        context.goNamed('wifi');
                      },
                      child: const Text('Continue'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextButton(
                      style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(16.0),
                          textStyle: const TextStyle(fontSize: 20),
                          backgroundColor: const Color(0xFF15a2cd)),
                      onPressed: disableButton ? null : () {
                        rescanButtonPressedLogic();
                      },
                      child: isScanning 
                        ? const Text('Stop Scanning') 
                        : const Text("Rescan"),
                    ),
                  ),
                ],
              ),
            ),
        ])
      )
    );
  }
}