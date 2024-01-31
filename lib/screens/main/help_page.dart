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
        child: ListView(
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
            Expanded(
              child: ExpansionTile(
                title: Heading(text: "Contact Us"),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
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

class ContactForm extends StatefulWidget {
  const ContactForm({super.key});

  @override
  _ContactFormState createState() => _ContactFormState();
}

class _ContactFormState extends State<ContactForm> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: emailController,
          decoration: InputDecoration(labelText: 'Email'),
        ),
        SizedBox(height: 10),
        TextField(
          controller: messageController,
          decoration: InputDecoration(labelText: 'Message'),
          maxLines: 3,
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            // Add logic to handle form submission
            print('Email: ${emailController.text}');
            print('Message: ${messageController.text}');
          },
          child: Text('Submit'),
        ),
      ],
    );
  }
}
