// Flutter imports:
import 'package:flutter/material.dart';

/// Creates a heading with large text and an underline.
class Heading extends StatelessWidget {
  final String text;

  const Heading({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      // Underline tab indicator decoration
      decoration: UnderlineTabIndicator(
        borderSide: BorderSide(
          color: colorScheme.onBackground,
          width: 2,
        ),
      ),
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Text displaying the heading
        Text(
          text,
          style: textTheme.headlineLarge,
          textAlign: TextAlign.left,
        ),
      ]),
    );
  }
}
