import 'package:binsight_ai/pages/setup/bluetooth.dart';
import 'package:binsight_ai/pages/setup/index.dart';
import 'package:binsight_ai/pages/setup/wifi_configuration.dart';
import 'package:binsight_ai/pages/setup/wifi_scan.dart';
import 'package:binsight_ai/util/providers.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:provider/provider.dart';

/// Introduction screen for explaining the usage of the app to new users.
class SetupScreen extends StatelessWidget {
  SetupScreen({super.key});

  // final List<Widget> listWidgets = 
    
  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      rawPages: const [
    SplashPage(),
    BluetoothPage(),
    WifiScanPage(),
    WifiConfigurationPage(),
  ],
      showBottomPart: true,
      showDoneButton: false,
      showNextButton: true,
      isProgress: false,
      next: Center(child: Container(width: 100, height: 100, child: const Text("Next"))),
      onDone: () {
        GoRouter.of(context).goNamed('main');
      },
      dotsDecorator: DotsDecorator(
          size: const Size.square(10),
          activeSize: const Size(20, 10),
          activeColor: Theme.of(context).colorScheme.secondary,
          color: Colors.black26,
          spacing: const EdgeInsets.symmetric(horizontal: 3),
          activeShape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
    );
  }
}
