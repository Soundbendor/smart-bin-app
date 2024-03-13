import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:binsight_ai/util/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:binsight_ai/database/models/detection.dart';
import 'package:binsight_ai/widgets/heading.dart';
import 'package:binsight_ai/widgets/free_draw.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  /// Key for the RepaintBoundary widget that's used to capture the annotated image
  final GlobalKey _captureKey = GlobalKey();

  /// List of unsigned integers representing the bytes of the captured image
  Uint8List? _capturedImage;

  //Points and label for the captured annotation
  DrawingSegment? _capturedPoint;

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

  /// Function to capture the annotated image
  ///
  /// Uses the RepaintBoundary's key to obtain the RenderObject, and converts it
  /// to it into a Uint8List to be used with Image.memory
  void captureImage() async {
    RenderRepaintBoundary boundary =
        _captureKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    _capturedImage = byteData?.buffer.asUint8List();
    setState(() {});
  }

  /// Renders the popup that educates the user on how to properly annotate their composted items
  void _showAnnotationPopup() {
    final textTheme = Theme.of(context).textTheme;
    showDialog(
        context: context,
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
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 2.0)),
                  child: Image.asset('assets/images/annotation.gif'),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                      "Trace the composted item with your finger or a stylus as accurately as possible."),
                ),
                Row(
                  children: [
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
                  if (!mounted) return;
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
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    GestureDetector(
                      child: Row(
                        children: [
                          const Icon(Icons.arrow_back_ios),
                          Text("Back to detection",
                              style: textTheme.labelLarge),
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
                      return RepaintBoundary(
                        key: _captureKey,
                        child: SizedBox(
                          width: 300,
                          height: 300,
                          child: FreeDraw(
                            imageLink: snapshot.data as String,
                          ),
                        ),
                      );
                    }
                  }),
              Text('Current Label: ${notifier.label}'),
              ElevatedButton(
                onPressed: () {
                  GoRouter.of(context)
                      .push("/main/detection/${widget.detectionId}/label");
                },
                child: Text(
                  "Select Label",
                  style: textTheme.labelLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (notifier.isCompleteAnnotation()) {
                    notifier.addToAllAnnotations();
                  } else {
                    String message;
                    if (notifier.label == null) {
                      message = "Please Enter a Label for Current Annotation";
                    } else {
                      message = "Please Draw Your Annotation";
                    }
                    print(message);
                  }
                },
                child: Text(
                  "Save Current Label",
                  style: textTheme.labelLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
              ElevatedButton(
                  onPressed: () {
                    captureImage();
                    notifier.reset();
                  },
                  child: Text("Complete Annotations",
                      style: textTheme.labelLarge!.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ))),
              if (_capturedImage != null)
                Image.memory(
                  _capturedImage!,
                  width: 300,
                  height: 300,
                  fit: BoxFit.cover,
                ),
            ],
          ),
        ),
      ),
      // Undo and redo buttons
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "Undo",
            onPressed: () {
              notifier.undo();
            },
            child: const Icon(Icons.undo),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            heroTag: "Redo",
            onPressed: () {
              notifier.redo();
            },
            child: const Icon(Icons.redo),
          ),
        ],
      ),
    );
  }
}
