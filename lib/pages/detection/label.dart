import 'package:binsight_ai/util/providers.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class LabelAnnotation extends StatelessWidget {
  const LabelAnnotation({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TextButton(
        onPressed: () {
          LabelNotifier labelNotifier =
              Provider.of<LabelNotifier>(context, listen: false);
          labelNotifier.setLabel("Carrot");
          GoRouter.of(context).pop();
        },
        child: const Text("Add"),
      ),
    );
  }
}
