import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothPage extends StatefulWidget {
  const BluetoothPage({Key? key}) : super(key: key);

  @override
  State<BluetoothPage> createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
  List<BluetoothDevice> _bluetoothDevices = [];

  @override
  void initState() {
    super.initState();

    _getScannedResults();
    
    FlutterBluePlus.scanResults.listen((results) {
      print(results);
      for (ScanResult r in results) {
        setState(() {
          _bluetoothDevices.add(r.device);
        });
      }
    });
  }

  Future<void> _getScannedResults() async {
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));

    await Future.delayed(
      const Duration(
        seconds: 1,
        )
      );
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
                      title: Text(bluetoothDevice.platformName ?? 'Unknown Device'),
                      trailing: const Icon(Icons.keyboard_arrow_right),
                      onTap: () {
                        //TODO: Add popup to prompt password entry
                            GoRouter.of(context).goNamed('bin_connect');
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
                          context.goNamed('bluetooth');
                        },
                        child: const Text('Continue'),
                      ),
        ])
      )
    );
  }
}