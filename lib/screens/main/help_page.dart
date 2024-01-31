import 'package:flutter/material.dart';
import 'package:binsight_ai/widgets/heading.dart';

/// Displays the Help page.
// TODO: Add FAQ/User Guide/Help information and email contact form.
class HelpPage extends StatelessWidget {
  const HelpPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(10),
        child: const Column(
          children: [
            Expanded(
              child: ExpansionTile(
                title: Heading(text: "FAQ"),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("FAQ Content"),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ExpansionTile(
                title: Heading(text: "User Guide"),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("User Guide Content"),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ExpansionTile(
                title: Heading(text: "Help"),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Help Content"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
