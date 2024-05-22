// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:url_launcher/url_launcher_string.dart';

// Project imports:
import 'package:binsight_ai/widgets/heading.dart';
import 'package:binsight_ai/pages/detection/index.dart';

/// Displays the Help page with sections for Help, Contact Us, and Wi-Fi Status
class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme.bodyLarge;
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: [
            // Help Heading
            const Padding(
              padding: EdgeInsets.only(left: 10, top: 10, bottom: 5),
              child: Heading(text: "Help"),
            ),
            // Help Content
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                "Have questions or need help with your bin? Please contact us for help using the email below.",
                style: textTheme!.copyWith(fontSize: 18),
              ),
            ),
            // Contact Us Section
            Padding(
              padding: const EdgeInsets.only(left: 10, top: 10, bottom: 5),
              child: Text(
                "Contact Us",
                style: textTheme.copyWith(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Provide a detailed description of your issue so our team can assist you.",
                    style: textTheme.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 10.0),
                  Center(
                    child: TextButton(
                      onPressed: _launchEmail,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.email,
                            color: Theme.of(context).colorScheme.onPrimary,
                            size: 30,
                          ),
                          const SizedBox(width: 18.0),
                          Text(
                            'Email',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontSize: 18.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Wi-Fi Status Section
            Padding(
              padding: const EdgeInsets.only(left: 10, top: 10, bottom: 5),
              child: Text(
                "Wi-Fi Status",
                style: textTheme.copyWith(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Need to check or change your Wi-Fi connection?",
                    style: textTheme.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 10.0),
                  Center(
                    child: TextButton(
                      onPressed: DetectionsPageState().checkWifi,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.wifi,
                            color: Theme.of(context).colorScheme.onPrimary,
                            size: 30,
                          ),
                          const SizedBox(width: 18.0),
                          Text(
                            'Check Wi-Fi',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontSize: 18.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
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
