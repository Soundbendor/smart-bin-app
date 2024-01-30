import 'package:flutter/material.dart';

/// The usage and statistics page
// TODO: Complete
// Meant to show the user their usage and statistics in a pretty way.
class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          "Stats Page Content",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
