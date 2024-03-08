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
      title: "Connecting Your Bin",
      body:
          "To enable your bin to do its work collecting and categorizing compost data, you'll need to grant it both Bluetooth access and WiFi connection through the app.",
      image: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.bluetooth, size: 100),
        Icon(Icons.wifi, size: 100)
      ]),
    ),
    PageViewModel(
      title: "Using Your Bin",
      body:
          "Toss compostable items into your bin, and give yourself a high five for keeping that CO2 out of the landfill!",
      image: const Icon(Icons.compost, size: 100),
    ),
    PageViewModel(
      title: "Annotating Images",
      body:
          "After you compost, photos will be captured of the composted items, from there, you can help us by manually annotating the item(s) you composted!",
      image: const Icon(Icons.auto_fix_high, size: 100),
    ),
    PageViewModel(
      title: "That's All You Need to Know!",
      body:
          "That's it! Check back every now and again to annotate your compost images.",
      image: const Icon(Icons.check_circle, size: 100),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: listPageViewModels,
      showBackButton: true,
      back: const Icon(Icons.arrow_back),
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
