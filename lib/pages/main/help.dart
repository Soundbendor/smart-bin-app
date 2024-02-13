import 'package:flutter/material.dart';
import 'package:binsight_ai/widgets/heading.dart';
import 'package:binsight_ai/widgets/contact_form.dart';

/// Displays the Help page with dropdown sections for FAQ, User Guide, Help, and Contact Us form.
class HelpPage extends StatelessWidget {
  const HelpPage({super.key});
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme.bodyMedium;
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: [
            Expanded(
              child: ExpansionTile(
                title: const Heading(text: "FAQ"),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("FAQ Content", style: textTheme),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ExpansionTile(
                title: const Heading(text: "User Guide"),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("User Guide Content", style: textTheme),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ExpansionTile(
                title: const Heading(text: "Help"),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Help Content", style: textTheme),
                  ),
                ],
              ),
            ),
            const Expanded(
              child: ExpansionTile(
                title: Heading(text: "Contact Us"),
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: ContactForm(),
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
