import 'package:flutter/material.dart';

class ScanList extends StatelessWidget {
  const ScanList({
    super.key,
    required this.itemCount,
    required this.listBuilder,
    required this.onResume,
    required this.title,
    this.inProgress = false,
  });

  final String title;
  final int itemCount;
  final bool inProgress;
  final Widget Function(BuildContext, int) listBuilder;
  final Function() onResume;

  @override
  Widget build(BuildContext context) {
    const textSize = 20.0;
    return Column(
      children: [
        SizedBox(
          height: (MediaQuery.of(context).size.height / 2) - (200 + textSize),
        ),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                fontSize: textSize,
              ),
        ),
        Container(
          color: const Color.fromRGBO(0, 0, 0, 0),
          height: MediaQuery.of(context).size.height / 2.5,
          child: ShaderMask(
            shaderCallback: (Rect rect) {
              return const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromARGB(255, 0, 0, 0),
                  Colors.transparent,
                  Colors.transparent,
                  Color.fromARGB(255, 0, 0, 0)
                ],
                stops: [0.0, 0.2, 0.9, 1.0],
              ).createShader(rect);
            },
            blendMode: BlendMode.dstOut,
            child: ListView.builder(
              itemCount: itemCount,
              itemBuilder: listBuilder,
            ),
          ),
        ),
        inProgress
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: onResume,
                child: Text("Resume Scan",
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                        )),
              ),
      ],
    );
  }
}
