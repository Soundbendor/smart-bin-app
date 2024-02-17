import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:binsight_ai/util/print.dart';
import 'package:binsight_ai/util/bluetooth.dart';
import 'package:binsight_ai/util/providers.dart';

/// Displays the WiFi configuration page with background and padding.
class WifiScanPage extends StatefulWidget {
  const WifiScanPage({super.key});

  @override
  State<WifiScanPage> createState() => _WifiScanPageState();
}

class _WifiScanPageState extends State<WifiScanPage> {
  // _WifiScanPageState();

  List<String> wifiResults = [];

  void _startScan(BleDevice? bluetoothDevice) {
    // TODO: implement scan
  }

  @override
  Widget build(BuildContext context) {
    final BleDevice? bluetoothDevice =
        Provider.of<DeviceNotifier>(context, listen: false).device;
    _startScan(bluetoothDevice);
    const textSize = 20.0;

    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/images/FlowersBackground.png"),
              fit: BoxFit.cover),
        ),
        child: Column(
          children: [
            SizedBox(
              height:
                  (MediaQuery.of(context).size.height / 2) - (200 + textSize),
            ),
            const Text("Select Your Network!",
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
                          title: Text(wifiResult),
                          trailing: const Icon(Icons.keyboard_arrow_right),
                          onTap: () async {
                            GoRouter.of(context)
                                .goNamed('wifi', extra: wifiResult);
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
