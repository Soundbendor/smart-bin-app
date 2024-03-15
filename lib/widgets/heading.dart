// Flutter imports:
import 'package:flutter/material.dart';

/// Creates a heading with large text
class Heading extends StatelessWidget {
  final String text;

  const Heading({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Text displaying the heading
        Text(
          text,
          style: textTheme.displayMedium,
          textAlign: TextAlign.left,
        ),
      ]),
    );
  }
}
