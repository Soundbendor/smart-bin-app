import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:introduction_screen/introduction_screen.dart';

/// Introduction screen for explaining the usage of the app to new users.
class StyledIntroScreen extends StatelessWidget {
  StyledIntroScreen({super.key});

  final List<PageViewModel> listPageViewModels = [
    PageViewModel(
      title: "Welcome to Binsight!",
      body:
          "You're going to love it here. Let's go through a quick summary of the app.",
      image: const FractionallySizedBox(
        widthFactor: 0.5,
        child: Image(image: AssetImage('assets/images/bin.png')),
      ),
    ),
    PageViewModel(
      title: "Connecting to Your Bin",
      body:
          "To ensure you stay up to date with your composting progress, you will need to connect to your bin via Bluetooth, and then connect your bin to WiFi.",
      image: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.bluetooth, size: 100),
        Icon(Icons.wifi, size: 100)
      ]),
    ),
    PageViewModel(
      title: "Using the Bin",
      body:
          "Compost as you typically would, just toss your items in, and forget about them!",
      image: const Icon(Icons.compost, size: 100),
    ),
    PageViewModel(
      title: "Annotating Images",
      body:
          "After you compost, photos will be captured of the composted items, from there, you can help us by manually annotating the item(s) you composted!",
      image: const Icon(Icons.auto_fix_high, size: 100),
    ),
    PageViewModel(
      title: "You're Done!",
      body: "That's it! Get out there and have FUN!",
      image: const Icon(Icons.check_circle, size: 100),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: listPageViewModels,
      showSkipButton: true,
      skip: const Icon(Icons.skip_next),
      next: const Text("Next"),
      done: const Text("Done"),
      onDone: () {
        GoRouter.of(context).goNamed('bluetooth');
      },
      onSkip: () {
        GoRouter.of(context).goNamed('bluetooth');
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
