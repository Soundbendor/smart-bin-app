import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';

class WifiConfigurationWidget extends StatefulWidget {
  const WifiConfigurationWidget({super.key});

  @override
  State<WifiConfigurationWidget> createState() =>
      _WifiConfigurationWidgetState();
}

class _WifiConfigurationWidgetState extends State<WifiConfigurationWidget> {
  TextEditingController ssidController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> sendWifiCredentials() async {
    final url = Uri.parse('http://192.168.1.1/configure_wifi');
    if (!kDebugMode) {
      final response = await http.post(
        url,
        body: {
          'ssid': ssidController.text,
          'password': passwordController.text,
        },
      );

      if (response.statusCode == 200) {
        // Request successful, handle the response if needed
      } else {
        // Request failed, handle the error
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Connect to Compost Bin'),
        TextField(
          controller: ssidController,
          decoration: const InputDecoration(labelText: 'SSID'),
        ),
        TextField(
          controller: passwordController,
          decoration: const InputDecoration(labelText: 'Password'),
        ),
        ElevatedButton(
          onPressed: () {
            sendWifiCredentials();
            context.goNamed('main');
          },
          child: const Text('Connect'),
        ),
      ], // Column children
    );
  }
}
