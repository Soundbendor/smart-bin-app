// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingPopup extends StatelessWidget {
  const LoadingPopup({super.key});

  static const spinkit = SpinKitFadingCircle(
    color: Colors.white,
    size: 50.0,
  );

  @override
  Widget build(BuildContext context) {
    return spinkit;
  }
}
