import 'package:flutter/material.dart';
import 'package:binsight_ai/ui_components/bottom_nav_bar.dart';
import 'package:binsight_ai/ui_components/top_nav_bar.dart';

/// 
class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopNavBar(),
      body: BottomNavBar(child: child),
    );
  }
}
