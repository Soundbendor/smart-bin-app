import 'package:flutter/material.dart';

class ConnectPage extends StatelessWidget {
  final void Function(int) changeScreen;

  const ConnectPage({required this.changeScreen, Key? key}) : super(key: key);

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
                child: Text(
                  "Connect to your Bin!",
                  style: TextStyle(
                    fontSize: 30,
                    ),
                  ),
                
              ),
            ),
            Flexible(
              flex: 5,
              child: ListView.builder(
                itemCount: 8,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0)
                      ),
                    child: ListTile(
                    leading: const Icon(Icons.wifi),
                    title: Text("Bin # $index"),
                    subtitle: const Text('Strength:'),
                    trailing: const Icon(Icons.keyboard_arrow_right),
                    onTap: () {
                      changeScreen(2);
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
