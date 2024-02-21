import 'package:flutter/material.dart';

/// Creates a decorated container with a background and child specified by the user using the imageURL and child properties (respectively).
///
/// This will typically be used as the body of a Scaffold to apply a background image to the page it is on.
///
/// If no imageURL is specified, it defaults to "background2.JPG".
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
