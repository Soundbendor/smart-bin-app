import 'package:flutter/material.dart';

/// A form for users to submit their contact information and message.
class ContactForm extends StatefulWidget {
  const ContactForm({super.key});

  @override
  _ContactFormState createState() => _ContactFormState();
}

/// Handles the state and submission of the contact form.
class _ContactFormState extends State<ContactForm> {
  
  // final GlobalKey<FormState> _formKey = GlobalKey();
  final _formKey = GlobalKey<FormState>(); 

  String email = '';
  String message = ''; 
  
  void _submit() {
    // Validate form before submitting
    if (_formKey.currentState?.validate() ?? false) {
      // Form is valid, proceed with submission logic
      _formKey.currentState?.save();
      // Add submission logic here
      print('Email: $email');
      print('Message: $message');
    }
  }

  /// Builds the contact form with email and message fields.
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[

          TextFormField(
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Enter your email'),
            keyboardType: TextInputType.emailAddress,
            onFieldSubmitted: (value) {
              setState(() {
                email = value;
              });
            },
            validator: (String? value) {
              if ((value?.isEmpty ?? true) ||
                  (!(value?.contains('@') ?? false))) {
                return 'Invalid email address';
              }
              return null; // Return null if the validation passes
            },
          ),

          TextFormField(
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Enter your message'),
            keyboardType:
                TextInputType.multiline, // Use multiline for long text block
            maxLines: null, // Allow unlimited lines for a long message
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              return null; // Return null if the validation passes
            },
            onFieldSubmitted: (value) {
              setState(() {
                message = value;
              });
            },
          ),
          
          ElevatedButton(
            onPressed: _submit,
            child: const Text("Submit"),
          ),
          const SizedBox(
            height: 20,
          ),
          
          Column(
            children: <Widget>[
              email.isEmpty ? const Text("No data") : Text(email),
              const SizedBox(
                height: 10,
              ),
              message.isEmpty ? const Text("No Data") : Text(message),
            ],
          ),
        ],
      ),
    );
  }
}
