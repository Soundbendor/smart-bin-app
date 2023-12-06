import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothPage extends StatefulWidget {
  const BluetoothPage({Key? key}) : super(key: key);

  @override
  State<BluetoothPage> createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
  final List<BluetoothDevice> _bluetoothDevices = [];

  @override
  void initState() {
    super.initState();

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

  Future<void> _getScannedResults() async {
    // I need to look into the possibility of adding a "rescan" and/or "stop scanning" button
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
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
            const Flexible(
              flex: 3,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(30.0),
                  child: Text(
                    "Find your Bin!",
                    style: TextStyle(
                      fontSize: 30,
                      color: Color(0xff787878),
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),
            ),

            Flexible(
              flex: 7,
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
                      title: Text(bluetoothDevice.platformName != '' ? bluetoothDevice.platformName : 'Unknown Device'),
                      trailing: const Icon(Icons.keyboard_arrow_right),
                      onTap: () {
                        //TODO: Add popup to prompt password entry
                            GoRouter.of(context).goNamed('wifi');
                      }
                    )
                  );
                },
              ),
            ),
            TextButton(
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
        ])
      )
    );
  }
}