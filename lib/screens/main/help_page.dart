import 'package:flutter/material.dart';

/// Displays the Help page.
// TODO: Add FAQ/User Guide/Help information and email contact form.
class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          children: [
            Text("FAQ"),
            Text("User Guide"),
            Text("Help"),
          ],
        ),
      ),
    );
  }
}

asyncExample() async {
  print("Fetching data...");
  var data = await fetchData();
  print("Data received: $data");
}

Future<String> fetchData() async {
  await Future.delayed(Duration(seconds: 2));
  return "Sample Data";
}
