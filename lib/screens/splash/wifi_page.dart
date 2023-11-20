import 'package:flutter/material.dart';
import 'package:waste_watchers/widgets/wifi_configuration_widget.dart';

class WifiPage extends StatelessWidget {
  const WifiPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/images/background2.JPG"),
              fit: BoxFit.cover),
        ),
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                WifiConfigurationWidget(),
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text("Wifi Page Content"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
