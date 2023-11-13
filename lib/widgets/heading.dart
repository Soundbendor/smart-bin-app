import 'package:flutter/material.dart';

class Heading extends StatelessWidget {
  final String text;

  const Heading({
    Key? key,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const UnderlineTabIndicator(
        borderSide: BorderSide(
          color: Colors.black,
          width: 2,
        ),
      ),
      margin: const EdgeInsets.only(bottom: 10),
      child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Detections",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.left,
            ),
          ]),
    );
  }
}
