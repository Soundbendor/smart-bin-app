import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:binsight_ai/widgets/heading.dart';

/// Displays the Help page with dropdown sections for FAQ, User Guide, Help, and Contact Us email connection
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
                shape: Border.all(color: Colors.transparent),
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
                shape: Border.all(color: Colors.transparent),
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
                shape: Border.all(color: Colors.transparent),
                title: const Heading(text: "Help"),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Help Content", style: textTheme),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ExpansionTile(
                shape: Border.all(color: Colors.transparent),
                title: const Heading(text: "Contact Us"),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        const Text(
                            "Have questions or need help with your bin?\nContact us for help!"),
                        const SizedBox(height: 10.0),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: TextButton(
                            onPressed: () => launchUrlString(
                                'mailto:binsight.help@gmail.com?subject=Help Request!'),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.email,
                                  color: Color.fromARGB(255, 33, 63, 148),
                                  size: 30,
                                ),
                                SizedBox(width: 18.0),
                                Text('Email',
                                    style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 255, 255, 255),
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
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
