import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:binsight_ai/util/print.dart';
import 'package:go_router/go_router.dart';
import 'package:binsight_ai/database/models/detection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:binsight_ai/widgets/heading.dart';
import 'package:binsight_ai/widgets/free_draw.dart';

/// Page used for annotating an individual detection image
class AnnotationPage extends StatefulWidget {
  /// The link for the image to be annotated
  late final Future<String>? imageLink;

  AnnotationPage({super.key, String? imageLink, String? detectionId}) {
    if (imageLink != null) {
      this.imageLink = Future.value(imageLink);
    } else if (detectionId != null) {
      this.imageLink = Future(() async {
        return Detection.find(detectionId)
            .then((detection) => detection!.preDetectImgLink);
      });
    } else {
      throw ArgumentError(
          "AnnotationPage requires either an imageLink or a detectionId");
    }
  }

  @override
  State<AnnotationPage> createState() => _AnnotationPageState();
}

class _AnnotationPageState extends State<AnnotationPage> {
  /// Key for the RepaintBoundary widget that's used to capture the annotated image
  final GlobalKey _captureKey = GlobalKey();

  /// Key for the FreeDraw widget that's used to render and annotate the image
  final GlobalKey<dynamic> _freeDrawKey = GlobalKey();

  /// List of unsigned integers representing the bytes of the captured image
  Uint8List? _capturedImage;

  //Points and label for the captured annotation
  DrawingSegment? _capturedPoint;

  /// Input entered by user to label the current annotation
  String? userInput;

  /// List of annotations, each annotation having a label and a list of Offsets
  List<List<dynamic>> annotationsList = [];

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
    debug("Captured image size: ${_capturedImage?.length} bytes");
    setState(() {});
  }

  /// Renders the popup that prompts input for a label of the current annotation
  void _showPopup() {
    TextEditingController userInputController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final textTheme = Theme.of(context).textTheme;
        final colorScheme = Theme.of(context).colorScheme;
        return AlertDialog(
          title: Text('Label Annotation', style: textTheme.headlineLarge),
          content: Column(
            children: [
              Text('Enter a name for your annotation:',
                  style: textTheme.bodyMedium),
              TextField(
                controller: userInputController,
                style: textTheme.bodyMedium,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel',
                  style: textTheme.labelLarge!.copyWith(
                    color: colorScheme.onPrimary,
                  )),
            ),
            TextButton(
              onPressed: () {
                userInput = userInputController.text;
                _capturedPoint = _freeDrawKey.currentState?.combineSegments();

                if (userInput != null &&
                    userInput!.isNotEmpty &&
                    _capturedPoint != null) {
                  annotationsList
                      .add([userInput, _capturedPoint!.toFloatList()]);
                  Navigator.of(context).pop();
                  _capturedPoint = null;
                  debug(annotationsList.length);
                }
              },
              child: Text('Save',
                  style: textTheme.labelLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  )),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
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
                            key: _freeDrawKey,
                            imageLink: snapshot.data as String,
                          ),
                        ),
                      );
                    }
                  }),
              ElevatedButton(
                  onPressed: () {
                    _showPopup();
                  },
                  child: Text("Label Annotation",
                      style: textTheme.labelLarge!.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ))),
              ElevatedButton(
                  onPressed: () {
                    captureImage();
                    debug(annotationsList);
                    _freeDrawKey.currentState?.resetAnnotation();
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
      //Undo and redo buttons
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "Undo",
            onPressed: () {
              _freeDrawKey.currentState?.undo();
            },
            child: const Icon(Icons.undo),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            heroTag: "Redo",
            onPressed: () {
              _freeDrawKey.currentState?.redo();
            },
            child: const Icon(Icons.redo),
          ),
        ],
      ),
    );
  }
}
