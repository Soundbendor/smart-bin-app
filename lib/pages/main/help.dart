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
            _buildExpansionTile("FAQ", "FAQ Content", textTheme!),
            _buildExpansionTile("User Guide", "User Guide Content", textTheme),
            _buildExpansionTile("Help", "Help Content", textTheme),
            _buildContactUsExpansionTile(textTheme),
          ],
        ),
      ),
    );
  }

  // ExpansionTile widget for each section (aside from Contact Us section)
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

  // ExpansionTile widget for Contact Us section
  ExpansionTile _buildContactUsExpansionTile(TextStyle textTheme) {
    return ExpansionTile(
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
                  onPressed: _launchEmail,
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
                              color: Color.fromARGB(255, 255, 255, 255),
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
    );
  }

  // Launches email client with pre-filled email to Binsight support
  Future<void> _launchEmail() async {
    const email = 'mailto:binsight.help@gmail.com?subject=Help Request!'
        '&body=Please provide a detailed description of your issue.';
    try {
      await launchUrlString(email);
    } catch (e) {
      throw 'Could not launch $email';
    }
  }
}
