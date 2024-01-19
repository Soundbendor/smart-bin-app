import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// The splash screen prompting the user to continue setting up their application.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/images/background3.JPG"),
              fit: BoxFit.cover),
        ),
        child: Center(
          child: Column(
            children: [
              Flexible(
                flex: 5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Padding(
                        padding: EdgeInsets.only(left: 16, right: 16, bottom: 30, top: 160),
                        child: Text(
                          "Welcome!",
                          style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff787878)
                              ),
                        )
                      ),
                    const Padding(
                      padding: EdgeInsets.only(left: 80, right: 80, top: 20, bottom: 20),
                      child: Text(
                        "Let's get you connected to your bin.",
                        style: TextStyle(
                          fontSize: 30,
                          color: Color(0xff787878),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextButton(
                        style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(16.0),
                            textStyle: const TextStyle(fontSize: 20),
                            backgroundColor: const Color(0xFF15a2cd)),
                        onPressed: () {
                          context.goNamed('bluetooth');
                        },
                        child: const Text('Continue'),
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
