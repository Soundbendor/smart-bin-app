import 'package:binsight_ai/util/providers.dart';
import 'package:binsight_ai/widgets/background.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:provider/provider.dart';

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
    initKey();
    Future.delayed(const Duration(seconds: 3),
        () => transitionKey.currentState?.next());
  }

  initKey() {
    setState(() {
      transitionKey = Provider.of<SetupKeyNotifier>(context, listen: false).setupKey;
    });
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
