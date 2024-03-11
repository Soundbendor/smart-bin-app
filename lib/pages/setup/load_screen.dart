import 'package:binsight_ai/widgets/background.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';


class LoadScreen extends StatefulWidget {
  const LoadScreen({super.key, required this.transitionKey});

  final GlobalKey<IntroductionScreenState> transitionKey;

  @override
  State<LoadScreen> createState() => _LoadScreenState();
}

class _LoadScreenState extends State<LoadScreen> {

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () => widget.transitionKey.currentState?.next());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomBackground(
        imageURL: 'assets/images/load_screen.png',
        child: Center(
          child: Text("binsight.ai", style: Theme.of(context).textTheme.displayLarge),
        ),
      ),
    );
  }
}
