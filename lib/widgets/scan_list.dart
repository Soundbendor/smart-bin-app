// Flutter imports:
import 'package:flutter/material.dart';

/// A list container with a gradient mask at the top and bottom.
///
/// [onResume] is a callback to be run when the 'resume' button is pressed.
/// [inProgress] determines whether a spinner or the 'resume' button is visible. When true, the spinner is visible.
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
    const textSize = 36.0;
    return Column(
      children: [
        SizedBox(
          height: (MediaQuery.of(context).size.height / 2) - (300 + textSize),
        ),
        Center(
          child: Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  fontSize: textSize,
                ),
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
