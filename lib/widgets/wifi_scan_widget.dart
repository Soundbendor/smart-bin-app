import 'package:binsight_ai/main.dart';
import 'package:flutter/material.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class WifiScanWidget extends StatefulWidget {
  const WifiScanWidget({super.key});

  @override
  State<WifiScanWidget> createState() => _WifiScanWidgetState();
}

class _WifiScanWidgetState extends State<WifiScanWidget> {
  // _WifiScanWidgetState();

  List<WiFiAccessPoint> wifiResults = [];

  @override
  void initState() {
    super.initState();
    _startScan();
    _initializeWifiPlugin();
  }

  Future<void> _initializeWifiPlugin() async {
    await WiFiForIoTPlugin.forceWifiUsage(true);
  }

  Future<void> _startScan() async {
    final canStartScan =
        await WiFiScan.instance.canStartScan(askPermissions: true);
    // Switch statement should go here
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
    return Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/images/background2.JPG"),
              fit: BoxFit.cover),
        ),
        child: Column(
          children: [
            const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Text(
                    "Connect to your Bin!",
                    style: TextStyle(
                      fontSize: 30,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height / 2,
              width: MediaQuery.of(context).size.width / 2,
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
                          GoRouter.of(context).goNamed('wifi', extra: {
                            Provider.of<DeviceNotifier>(context, listen: false)
                                .getDevice, wifiResult.ssid
                          });
                        }),
                  );
                },
              ),
            ),
          ],
        ),
    );
  }
}
