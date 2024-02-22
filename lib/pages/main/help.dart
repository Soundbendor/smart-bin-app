import 'package:flutter/material.dart';
import 'package:binsight_ai/util/print.dart';
import 'package:binsight_ai/widgets/heading.dart';

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
                    child: _ContactForm(),
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

/// State class for the contact form widget.
class _ContactForm extends StatefulWidget {
  const _ContactForm();

  @override
  _ContactFormState createState() => _ContactFormState();
}

/// Displays a form for users to submit a contact request.
class _ContactFormState extends State<_ContactForm> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  // TODO add form validation and error checking
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: emailController,
          decoration: const InputDecoration(labelText: 'Email'),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: messageController,
          decoration: const InputDecoration(labelText: 'Message'),
          maxLines: 15,
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            // TODO logic to handle form submission
            debug('Email: ${emailController.text}');
            debug('Message: ${messageController.text}');
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
