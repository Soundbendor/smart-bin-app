import 'package:flutter/material.dart';
import 'package:waste_watchers/widgets/wifi_configuration_widget.dart';

class WifiPage extends StatelessWidget {
  final void Function() changeWifiConnected;

  const WifiPage({required this.changeWifiConnected, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        WifiConfigurationWidget(changeWifiConnected: changeWifiConnected),
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/background2.JPG"),
                fit: BoxFit.cover),
          ),
          child: const Center(
            child: Text("Wifi Page Content"),
          ),
        ),
      ],
    ));
  }
}
