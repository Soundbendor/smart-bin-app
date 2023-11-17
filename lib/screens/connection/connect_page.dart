import 'package:flutter/material.dart';
import 'package:wifi_scan/wifi_scan.dart';

class ConnectPage extends StatefulWidget {
  final void Function(int) changeScreen;

  const ConnectPage({required this.changeScreen, Key? key}) : super(key: key);

  @override
  State<ConnectPage> createState() => _ConnectPageState();
}

class _ConnectPageState extends State<ConnectPage> {
  List<WiFiAccessPoint> wifiResults = [];

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  Future<void> _startScan() async {
    final canStartScan = await WiFiScan.instance.canStartScan(askPermissions: true);

    switch (canStartScan) {
    case CanStartScan.yes:
      final isScanning = await WiFiScan.instance.startScan();
      if (isScanning) {
        _getScannedResults();
      }
      break;
    case CanStartScan.failed:
      // Handle the case where scanning is not possible
      break;
    case CanStartScan.notSupported:
      // Handle the case where the user denied the necessary permissions
      break;
    default:
      // handle default case
  }
}

  Future<void> _getScannedResults() async {
    final canGetResults = await WiFiScan.instance.canGetScannedResults(askPermissions: true);

    switch (canGetResults) {
      case CanGetScannedResults.yes:
        final accessPoints = await WiFiScan.instance.getScannedResults();
        setState(() {
          wifiResults = accessPoints;
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
              flex: 1,
              child: Center(
                child: Text(
                  "Connect to your Bin!",
                  style: TextStyle(
                    fontSize: 30,
                  ),
                ),
              ),
            ),
            Flexible(
              flex: 5,
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
                          onTap: () {
                            widget.changeScreen(3);
                          }),
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
