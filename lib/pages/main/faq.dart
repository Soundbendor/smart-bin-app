// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:binsight_ai/widgets/heading.dart';

/// Displays the FAQ page with dropdown section for content
class FAQ extends StatelessWidget {
  const FAQ({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme.bodyMedium;
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: [
            _buildExpansionTile("FAQ", "FAQ Content", textTheme!),
          ],
        ),
      ),
    );
  }

  // ExpansionTile widget for each FAQ section
  ExpansionTile _buildExpansionTile(
      String title, String content, TextStyle textTheme) {
    return ExpansionTile(
      shape: Border.all(color: Colors.transparent),
      title: Heading(text: title),
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(content, style: textTheme),
        ),
      ],
    );
  }
}
