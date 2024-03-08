import 'package:flutter/material.dart';
import 'package:binsight_ai/widgets/heading.dart';

/// Displays the User Guide
class UserGuide extends StatelessWidget {
  const UserGuide({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme.bodyMedium;
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: [
            _buildExpansionTile("User Guide", "User Guide Content", textTheme!),
          ],
        ),
      ),
    );
  }

  // ExpansionTile widget for User Guide section
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
