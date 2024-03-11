import 'dart:async';

import 'package:binsight_ai/widgets/background.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

/// The splash screen prompting the user to continue setting up their application.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key, required this.transitionKey});

  final GlobalKey<IntroductionScreenState> transitionKey;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  // Define opacity states for individual elements on the page
  double _text1Opacity = 0;
  double _text2Opacity = 0;
  double _button1Opacity = 0;

  // Trigger the animation upon opening the page
  @override
  void initState() {
    super.initState();
    runAnimation();
  }

  // Awaits each animation in order to delay their appearance order
  void runAnimation() async {
    await Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _text1Opacity = 1;
        });
      }
    });
    await Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _text2Opacity = 1;
        });
      }
    });
    await Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _button1Opacity = 1;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: CustomBackground(
        imageURL: "assets/images/splash_screen.png",
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * .15),
            AnimatedOpacity(
              opacity: _text1Opacity,
              duration: const Duration(milliseconds: 500),
              child: Text(
                "Welcome!",
                style: textTheme.displayLarge,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * .05),
            AnimatedOpacity(
              opacity: _text2Opacity,
              duration: const Duration(milliseconds: 500),
              child: Padding(
                padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
                child: Text(
                  "Let's get you connected to your bin.",
                  style: textTheme.headlineLarge!.copyWith(
                      color: colorScheme.onBackground,
                      fontWeight: FontWeight.normal),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * .05),
            AnimatedOpacity(
              opacity: _button1Opacity,
              duration: const Duration(milliseconds: 500),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    elevation: 5,
                    foregroundColor: colorScheme.onPrimary,
                    padding: EdgeInsets.symmetric(
                        vertical: MediaQuery.of(context).size.width * .05,
                        horizontal: 50),
                    textStyle: textTheme.titleLarge!
                        .copyWith(fontWeight: FontWeight.bold),
                    backgroundColor: const Color(0xFF74C1A4)),
                onPressed: () {
                  (_button1Opacity < 1) ? null : widget.transitionKey.currentState?.next();
                },
                child: const Text('Get Started'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
