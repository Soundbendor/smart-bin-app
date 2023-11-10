import 'package:flutter/material.dart';

class ConnectPage extends StatelessWidget {
  const ConnectPage({super.key});

  @override
Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/images/background2.JPG"),
              fit: BoxFit.cover),
        ),
        child: Column(
          children: [
            const Flexible(
              flex: 1,
              child: Center(
                child: Text("Connect to your Bin!"),
                
              ),
            ),
            Flexible(
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0)
                      ),
                    child: ListTile(
                    leading: const Icon(Icons.wifi),
                    title: Text("Wifi # $index"),
                    subtitle: const Text('Strength:'),
                    trailing: const Icon(Icons.keyboard_arrow_right),
                    onTap: () {
                      // Add functionality for when a network is tapped
                    }
                    ),
                  );
                }),
                
              ),
          ],
        ),
      ),
    );
  }
}
