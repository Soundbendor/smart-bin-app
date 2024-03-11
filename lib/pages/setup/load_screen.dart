import 'package:binsight_ai/pages/setup/intro_sequence.dart';
import 'package:binsight_ai/widgets/background.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';


class LoadScreen extends StatefulWidget {
  const LoadScreen({super.key});

  @override
  State<LoadScreen> createState() => _LoadScreenState();
}

class _LoadScreenState extends State<LoadScreen> {

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () => context.findAncestorStateOfType<SetupScreenState>()!.setupKey.currentState?.next());
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
