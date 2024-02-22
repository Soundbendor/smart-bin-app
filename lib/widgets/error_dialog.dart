import 'package:flutter/material.dart';

class ErrorDialog extends StatelessWidget {
  const ErrorDialog({
    super.key,
    required this.text,
    required this.description,
    required this.callback,
  });

  final String text;
  final String description;
  final Function() callback;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(text, style: Theme.of(context).textTheme.headlineMedium),
      content: Text(
        description,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      actions: [
        TextButton(
          onPressed: callback,
          child: const Text("OK"),
        ),
      ],
    );
  }
}
