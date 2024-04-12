import 'package:flutter/material.dart';

/// A small card that displays a statistic.
class StatisticCard extends StatelessWidget {
  final String title;
  final String value;

  const StatisticCard({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(title, style: textTheme.labelLarge),
            Text(value, style: textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
