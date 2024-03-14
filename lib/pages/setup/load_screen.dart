// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:introduction_screen/introduction_screen.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:binsight_ai/util/providers.dart';
import 'package:binsight_ai/widgets/background.dart';

/// Loading screen that is displayed to the user on app startup
class LoadScreen extends StatefulWidget {
  const LoadScreen({super.key});

  @override
  State<LoadScreen> createState() => _LoadScreenState();
}

class _LoadScreenState extends State<LoadScreen> {
  late GlobalKey<IntroductionScreenState> transitionKey;

  @override
  void initState() {
    super.initState();
    transitionKey = Provider.of<SetupKeyNotifier>(context, listen: false).setupKey;
    Future.delayed(const Duration(seconds: 3),
        () => transitionKey.currentState?.next());
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: CustomBackground(
        imageURL: 'assets/images/load_screen.png',
        child: SizedBox(),
      ),
    );
  }
}
