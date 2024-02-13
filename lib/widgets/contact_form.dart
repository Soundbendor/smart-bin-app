import 'package:flutter/material.dart';
import 'package:binsight_ai/util/print.dart';

/// State class for the contact form widget.
class ContactForm extends StatefulWidget {
  const ContactForm({super.key});

  @override
  ContactFormState createState() => ContactFormState();
}

/// Displays a form for users to submit a contact request.
class ContactFormState extends State<ContactForm> {
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
