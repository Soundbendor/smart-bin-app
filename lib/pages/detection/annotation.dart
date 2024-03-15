// Flutter imports:
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// Package imports:
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:binsight_ai/database/models/detection.dart';
import 'package:binsight_ai/util/print.dart';
import 'package:binsight_ai/util/providers.dart';
import 'package:binsight_ai/widgets/free_draw.dart';
import 'package:binsight_ai/widgets/heading.dart';

/// Page used for annotating an individual detection image
class AnnotationPage extends StatefulWidget {
  /// The link for the image to be annotated
  late final Future<String> imageLink;
  final String detectionId;
  AnnotationPage({super.key, required this.detectionId}) {
    imageLink = Future(() async {
      return Detection.find(detectionId)
          .then((detection) => detection!.preDetectImgLink);
    });
  }

  @override
  State<AnnotationPage> createState() => _AnnotationPageState();
}

class _AnnotationPageState extends State<AnnotationPage> {
  /// Whether the user has started drawing on the image
  bool drawStarted = false;

  /// Key for the RepaintBoundary widget that's used to capture the annotated image
  final GlobalKey _captureKey = GlobalKey();

  /// User's decision to show annotation tutorial upon opening annotation screen
  bool? dontShowAgain = false;

  @override
  void initState() {
    super.initState();
    initPreferences();
  }

  /// Recalls user's decision of whether to show the annotation guide or not
  void initPreferences() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      dontShowAgain = preferences.getBool('dontShowAgain') ?? false;
    });
    if (dontShowAgain == false) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showAnnotationPopup();
      });
    }
  }

  /// Captures the annotated image
  ///
  /// Uses the RepaintBoundary's key to obtain the RenderObject, and converts it
  /// to it into a Uint8List to be used with Image.memory
  void captureImage() async {
    RenderRepaintBoundary boundary =
        _captureKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final capturedImage = byteData?.buffer.asUint8List();
    debug("Captured Image Size: ${capturedImage?.length}");
    setState(() {});
  }

  /// Renders the popup that educates the user on how to properly annotate their composted items
  void _showAnnotationPopup() {
    final textTheme = Theme.of(context).textTheme;
    showDialog(
        context: context,
        // Don't allow the user to dismiss the dialog to ensure the preference is set
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            surfaceTintColor: Colors.transparent,
            title: Center(
                child: Text('How to Annotate', style: textTheme.headlineLarge)),
            content: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Display annotation gif with border
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 2.0)),
                  child: Image.asset('assets/images/annotation.gif'),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                      "Trace the composted item with your finger as accurately as possible."),
                ),
                Row(
                  children: [
                    // Gives dialog's context the ability to update state (for checkbox)
                    StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                      return Checkbox(
                        checkColor: Colors.black,
                        value: dontShowAgain,
                        onChanged: (value) {
                          setState(() => dontShowAgain = value!);
                        },
                      );
                    }),
                    const Text("Don't show this screen again"),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  SharedPreferences preferences =
                      await SharedPreferences.getInstance();
                  preferences.setBool('dontShowAgain', dontShowAgain!);
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                },
                child: const Text("Close"),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    AnnotationNotifier notifier = context.read<AnnotationNotifier>();
    if (notifier.currentDetection != widget.detectionId) {
      notifier.reset();
      notifier.setDetection(widget.detectionId);
    }
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  GestureDetector(
                    child: Row(
                      children: [
                        const Icon(Icons.arrow_back_ios),
                        Text("Back to detection", style: textTheme.labelLarge),
                      ],
                    ),
                    onTap: () => GoRouter.of(context).pop(),
                  ),
                  const Heading(text: "Annotate Your Image"),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            FutureBuilder(
              future: widget.imageLink,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else {
                  return Stack(
                    children: [
                      RepaintBoundary(
                        key: _captureKey,
                        child: SizedBox(
                          width: 300,
                          height: 300,
                          child: FreeDraw(
                            imageLink: snapshot.data as String,
                          ),
                        ),
                      ),
                      if (!drawStarted)
                        Positioned(
                          child: GestureDetector(
                            onTap: () => setState(() {
                              drawStarted = true;
                            }),
                            child: Container(
                              width: 300,
                              height: 300,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                              ),
                              child: Center(
                                child: Text(
                                  "Tap to start",
                                  style: textTheme.displaySmall!.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                }
              },
            ),
            SingleChildScrollView(
              child: Consumer<AnnotationNotifier>(
                  builder: (context, notifier, child) {
                return SizedBox(
                  width: 300,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton.filled(
                                  disabledColor: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withAlpha(150),
                                  onPressed: notifier.canUndo()
                                      ? () {
                                          notifier.undo();
                                        }
                                      : null,
                                  icon: const Icon(Icons.undo)),
                              IconButton.filled(
                                  disabledColor: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withAlpha(150),
                                  onPressed: notifier.canRedo()
                                      ? () {
                                          notifier.redo();
                                        }
                                      : null,
                                  icon: const Icon(Icons.redo)),
                            ],
                          ),
                          Text(
                            notifier.label == null
                                ? 'No label selected yet'
                                : 'Selected Label: ${notifier.label}',
                            style: textTheme.labelLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              GoRouter.of(context).push(
                                  "/main/detection/${widget.detectionId}/label");
                            },
                            child: Text(
                              notifier.label == null
                                  ? "Add Label"
                                  : "Change Label",
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: !notifier.isCompleteAnnotation()
                                ? Theme.of(context)
                                    .elevatedButtonTheme
                                    .style!
                                    .copyWith(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                        Theme.of(context).colorScheme.surface,
                                      ),
                                    )
                                : null,
                            onPressed: () {
                              if (notifier.isCompleteAnnotation()) {
                                notifier.addToAllAnnotations();
                                notifier.clearCurrentAnnotation();
                                notifier.label = null;
                              } else {
                                String message;
                                if (notifier.label == null) {
                                  message =
                                      "Please Enter a Label for Current Annotation";
                                } else {
                                  message = "Please Draw Your Annotation";
                                }
                                debug(message);
                              }
                            },
                            child: Text(
                              "Save",
                              style: textTheme.labelLarge!.copyWith(
                                color: notifier.isCompleteAnnotation()
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withAlpha(150),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 300,
                          height: 100,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  style: Theme.of(context)
                                      .elevatedButtonTheme
                                      .style!
                                      .copyWith(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                          Theme.of(context)
                                              .colorScheme
                                              .tertiary,
                                        ),
                                      ),
                                  onPressed: () {
                                    notifier.clearCurrentAnnotation();
                                    Future.delayed(
                                        const Duration(milliseconds: 100), () {
                                      captureImage();
                                      notifier.reset();
                                    });
                                  },
                                  child: Text(
                                    "Done",
                                    style: textTheme.labelLarge!.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onTertiary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
