// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:binsight_ai/util/providers.dart';

class LabelAnnotation extends StatelessWidget {
  const LabelAnnotation({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TextButton(
        onPressed: () {
          context.read<AnnotationNotifier>().setLabel("Carrot");
          GoRouter.of(context).pop();
        },
        child: const Text("Add"),
      ),
    );
  }
}
