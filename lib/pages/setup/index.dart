import 'package:binsight_ai/widgets/intro_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// The splash screen prompting the user to continue setting up their application.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  void _onIntroEnd(context) {
    GoRouter.of(context).pushReplacementNamed("bluetooth");
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return StyledIntroScreen();
    // return Scaffold(
    //   body: CustomBackground(
    //     imageURL: "assets/images/background3.JPG",
    //     child: Center(
    //       child: Column(
    //         children: [
    //           Flexible(
    //             flex: 5,
    //             child: Column(
    //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //               children: [
    //                 Padding(
    //                     padding: const EdgeInsets.only(
    //                         left: 16, right: 16, bottom: 30, top: 160),
    //                     child: Text(
    //                       "Welcome!",
    //                       style: textTheme.displayLarge,
    //                     )),
    //                 Padding(
    //                   padding: const EdgeInsets.only(
    //                       left: 80, right: 80, top: 20, bottom: 20),
    //                   child: Text(
    //                     "Let's get you connected to your bin.",
    //                     style: textTheme.headlineLarge!.copyWith(
    //                       color: colorScheme.onBackground,
    //                     ),
    //                     textAlign: TextAlign.center,
    //                   ),
    //                 ),
    //                 Padding(
    //                   padding: const EdgeInsets.all(8.0),
    //                   child: TextButton(
    //                     style: TextButton.styleFrom(
    //                         foregroundColor: colorScheme.onPrimary,
    //                         padding: const EdgeInsets.all(16.0),
    //                         textStyle: textTheme.labelLarge,
    //                         backgroundColor: colorScheme.primary),
    //                     onPressed: () {
    //                       context.goNamed('bluetooth');
    //                     },
    //                     child: const Text('Get Started'),
    //                   ),
    //                 ),
    //               ],
    //             ),
    //           ),
    //           Flexible(flex: 3, child: Container())
    //         ],
    //       ),
    //     ),
    //   ),
    // );
  }
}
