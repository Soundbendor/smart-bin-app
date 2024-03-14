import 'package:flutter/material.dart';

/// Styled background that applies a BoxDecoration with a specified asset image URL.
class CustomBackground extends StatelessWidget {
  const CustomBackground(
      {super.key, required this.child, required this.imageURL});
  final Widget child;
  final String imageURL;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(imageURL),
          fit: BoxFit.cover,
        ),
      ),
      child: child,
    );
  }
}
