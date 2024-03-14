// Flutter imports:
import 'package:flutter/material.dart';

// Flutter imports:
import 'package:binsight_ai/util/styles.dart';

class BluetoothAlertBox extends StatelessWidget {
  const BluetoothAlertBox({
    super.key,
    this.title,
    this.content,
    this.actions,
  });

  final Widget? title;
  final Widget? content;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: title,
      content: content,
      actions: actions,
      shape: bluetoothBorderRadius,
    );
  }
}
