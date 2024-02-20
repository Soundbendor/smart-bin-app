import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:binsight_ai/util/bluetooth.dart';
import 'package:binsight_ai/util/providers.dart';
import 'package:binsight_ai/util/wifi_scan.dart';
import 'package:binsight_ai/widgets/background.dart';

/// Widget for configuring the wifi credentials of the compost bin
class WifiConfigurationPage extends StatefulWidget {
  const WifiConfigurationPage({super.key, required this.wifiResult});

  /// The wifi scan result
  final WifiScanResult wifiResult;

  @override
  State<WifiConfigurationPage> createState() => _WifiConfigurationPageState();
}

/// State class for WifiConfigurationWidget
class _WifiConfigurationPageState extends State<WifiConfigurationPage> {
  /// Whether the modal is currently open
  bool isModalOpen = false;

  /// The status of the wifi configuration
  WifiConfigurationStatus status = WifiConfigurationStatus.waiting;

  /// The error that occurred
  Exception? error;

  /// Controller for the SSID text field
  final TextEditingController ssidController = TextEditingController();

  /// Controller for the password text field
  final TextEditingController passwordController = TextEditingController();

  void sendCredentials() async {}

  @override
  void initState() {
    super.initState();
    ssidController.text = widget.wifiResult.ssid;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: CustomBackground(
        imageURL: "assets/images/FlowersBackground.png",
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Connect Bin to WiFi', style: textTheme.headlineMedium),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: TextField(
                controller: ssidController,
                decoration: const InputDecoration(labelText: 'SSID'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
            ),
            ElevatedButton(
              onPressed: () {},
              child: Text('Connect',
                  style: textTheme.labelLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  )),
            ),
            ElevatedButton(
              onPressed: () {
                GoRouter.of(context).goNamed("wifi-scan");
              },
              child: Text("Back",
                  style: textTheme.labelLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  )),
            ),
          ], // Column children
        ),
      ),
    );
  }
}

enum WifiConfigurationStatus {
  waiting,
  sending,
  verifying,
  error,
}
