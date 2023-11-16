import 'package:flutter/material.dart';

class SplashPage extends StatelessWidget {
  final void Function(int) changeScreen;

  const SplashPage({required this.changeScreen, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/images/background2.JPG"),
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
                        padding: EdgeInsets.all(20),
                        child: Text(
                          "Welcome!",
                          style: TextStyle(
                              fontSize: 40, fontWeight: FontWeight.bold),
                        )),
                    const Text(
                      "Connect your Smart Bin to WiFi to start collecting data",
                      style: TextStyle(
                        fontSize: 25,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: TextButton(
                          style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.all(16.0),
                              textStyle: const TextStyle(fontSize: 20),
                              backgroundColor: const Color(0xFF15a2cd)),
                          onPressed: () {
                            changeScreen(1);
                          },
                          child: const Text('Continue'),
                        ),
                      ),
                    )
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
