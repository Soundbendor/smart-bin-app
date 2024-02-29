import 'package:binsight_ai/widgets/background.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// The splash screen prompting the user to continue setting up their application.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  double _text1 = 0;
  double _text2 = 0;
  double _text3 = 0;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 4; i++) {
      Future.delayed(
          const Duration(seconds: 1), () => opacityController('one'));
      Future.delayed(
          const Duration(seconds: 3), () => opacityController('two'));
      Future.delayed(
          const Duration(seconds: 5), () => opacityController('three'));
    }
  }

  void _onIntroEnd(context) {
    GoRouter.of(context).pushReplacementNamed("bluetooth");
  }

  void opacityController(variable) {
    setState(() {
      switch (variable) {
        case 'one':
          _text1 = 1;
          break;
        case 'two':
          _text2 = 1;
          break;
        case 'three':
          _text3 = 1;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: CustomBackground(
        imageURL: "assets/images/background3.JPG",
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * .20),
              AnimatedOpacity(
                opacity: _text1,
                duration: const Duration(seconds: 1),
                child: Text(
                  "Welcome!",
                  style: textTheme.displayLarge,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * .05),
              AnimatedOpacity(
                opacity: _text2,
                duration: const Duration(seconds: 1),
                child: Text(
                  "Let's get you connected to your bin.",
                  style: textTheme.headlineLarge!.copyWith(
                      color: colorScheme.onBackground,
                      fontWeight: FontWeight.normal),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * .10),
              AnimatedOpacity(
                opacity: _text3,
                duration: const Duration(seconds: 1),
                child: TextButton(
                  style: TextButton.styleFrom(
                      foregroundColor: colorScheme.onPrimary,
                      padding: EdgeInsets.all(MediaQuery.of(context).size.width * .05),
                      textStyle: textTheme.displaySmall,
                      backgroundColor: const Color(0xFF74C1A4)),
                  onPressed: () {
                    (_text3 < 1) ? null : context.goNamed('bluetooth');
                  },
                  child: const Text('Get Started'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
