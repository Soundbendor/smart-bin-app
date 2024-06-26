// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:introduction_screen/introduction_screen.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:binsight_ai/pages/setup/bluetooth.dart';
import 'package:binsight_ai/pages/setup/index.dart';
import 'package:binsight_ai/pages/setup/load_screen.dart';
import 'package:binsight_ai/pages/setup/wifi_configuration.dart';
import 'package:binsight_ai/pages/setup/wifi_scan.dart';
import 'package:binsight_ai/util/providers/setup_key_notifier.dart';

/// Introduction screen for explaining the usage of the app to new users.
class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key, this.startPageIndex = 0});

  final int startPageIndex;

  @override
  State<SetupScreen> createState() => SetupScreenState();
}

class SetupScreenState extends State<SetupScreen> {
  @override
  Widget build(BuildContext context) {
    GlobalKey<IntroductionScreenState> setupKey =
        Provider.of<SetupKeyNotifier>(context).setupKey;
    // Creates setup sequence with just the raw pages and animation controller key
    return IntroductionScreen(
      key: setupKey,
      rawPages: const [
        LoadScreen(),
        SplashPage(),
        BluetoothPage(),
        WifiScanPage(),
        WifiConfigurationPage(),
      ],
      initialPage: widget.startPageIndex,
      freeze: true,
      animationDuration: 750,
      showDoneButton: false,
      showNextButton: false,
      isProgress: false,
    );
  }
}
