import 'package:flutter/material.dart';

///
class CustomBackground extends StatelessWidget {
  const CustomBackground(
      {super.key,
      required this.child,
      this.imageURL = "assets/images/background2.JPG"});
  final Widget child;
  final String imageURL;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage(imageURL), fit: BoxFit.cover),
      ),
      child: child,
    );
  }
}
