import 'package:binsight_ai/util/bluetooth.dart';
import 'package:binsight_ai/util/bluetooth_bin_data.dart';
import 'package:binsight_ai/widgets/background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

/// Page which displays scanned Bluetooth devices.
class BluetoothPage extends StatefulWidget {
  BluetoothPage({super.key});

  /// The scanner used to find Bluetooth devices.
  final scanner = BleDeviceScanner();

  @override
  State<BluetoothPage> createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
  /// The list of devices found by the scanner.
  List<BleDevice> devices = [];

  @override
  void initState() {
    super.initState();
    widget.scanner.startScan(serviceFilter: [mainServiceId]);
    widget.scanner.onDeviceListUpdated(onDeviceListUpdated);
  }

  @override
  void dispose() {
    widget.scanner.stopScan();
    widget.scanner.removeListener(
        BleDeviceScannerEvents.deviceListUpdated, onDeviceListUpdated);
    super.dispose();
  }

  void onDeviceListUpdated(List<BleDevice> deviceList) {
    setState(() {
      devices = deviceList;
    });
  }

  @override
  Widget build(BuildContext context) {
    const textSize = 20.0;
    return Scaffold(
        body: CustomBackground(
            child: Column(
      children: [
        SizedBox(
          height: (MediaQuery.of(context).size.height / 2) - (200 + textSize),
        ),
        Text(
          "Find your bin!",
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                fontSize: textSize,
              ),
        ),
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
              itemCount: devices.length,
              itemBuilder: buildDeviceItem,
            ),
          ),
        ),
      ],
    )));
  }

  Widget buildDeviceItem(BuildContext context, int index) {
    final device = devices[index];
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: ListTile(
          leading: const Icon(Icons.bluetooth),
          title: Text(device.name),
          trailing: const Icon(Icons.keyboard_arrow_right),
          onTap: () {}),
    );
  }
}
