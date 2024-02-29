import 'package:binsight_ai/widgets/background.dart';
import 'package:binsight_ai/widgets/intro_screen.dart';
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
  double _text4 = 0;

  @override
  void initState() {
    super.initState();
    List<double> textControllers = [_text1, _text2, _text3, _text4];
    for (int i = 0; i < 4; i++) {
      Future.delayed(const Duration(seconds: 1), () => opacityController('one'));
      Future.delayed(const Duration(seconds: 3), () => opacityController('two'));
      Future.delayed(const Duration(seconds: 5), () => opacityController('three'));
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
    // return StyledIntroScreen();
    return Scaffold(
      body: CustomBackground(
        imageURL: "assets/images/background3.JPG",
        child: Center(
          child: Column(
            children: [
              Flexible(
                flex: 5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Padding(
                        padding: const EdgeInsets.only(
                            left: 16, right: 16, bottom: 30, top: 160),
                        child: AnimatedOpacity(
                          opacity: _text1,
                          duration: const Duration(seconds: 2),
                          child: Text(
                            "Welcome!",
                            style: textTheme.displayLarge,
                          ),
                        )),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 80, right: 80, top: 20, bottom: 20),
                      child: AnimatedOpacity(
                        opacity: _text2,
                        duration: const Duration(seconds: 2),
                        child: Text(
                          "Let's get you connected to your bin.",
                          style: textTheme.headlineLarge!.copyWith(
                            color: colorScheme.onBackground,
                            fontWeight: FontWeight.normal
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: AnimatedOpacity(
                        opacity: _text3,
                        duration: const Duration(seconds: 2),
                        child: TextButton(
                          style: TextButton.styleFrom(
                              foregroundColor: colorScheme.onPrimary,
                              padding: const EdgeInsets.all(16.0),
                              textStyle: textTheme.labelLarge,
                              backgroundColor: colorScheme.primary),
                          onPressed: () {
                            context.goNamed('bluetooth');
                          },
                          child: const Text('Get Started'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(flex: 3, child: Container())
            ],
          ),
        ),
      ),
    );
  }
}
