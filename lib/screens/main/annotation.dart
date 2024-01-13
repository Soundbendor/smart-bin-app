import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:binsight_ai/widgets/heading.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:binsight_ai/widgets/free_draw.dart';

/// Page used for annotating an individual detection image
class AnnotationPage extends StatefulWidget {
  ///The link for the image to be annotated
  final String imageLink;

  const AnnotationPage({super.key, required this.imageLink});

  @override
  State<AnnotationPage> createState() => _AnnotationPageState();
}

class _AnnotationPageState extends State<AnnotationPage> {
  ///Key for the RepaintBoundary widget that's used to capture the annotated image
  final GlobalKey _captureKey = GlobalKey();

  ///Key for the FreeDraw widget that's used to render and annotate the image
  final GlobalKey<dynamic> _freeDrawKey = GlobalKey();
  Uint8List? _capturedImage;

  //Points and label for the captured annotation
  DrawingSegment? _capturedPoint;
  String? userInput;

  ///List of annotations, each annotation having a label and a list of Offsets
  List<List<dynamic>> annotationsList = [];

  ///Function to capture the annotated image
  ///
  ///Uses the RepaintBoundary's key to obtain the RenderObject, and converts it
  ///to it into a Uint8List to be used with Image.memory
  void captureImage() async {
    RenderRepaintBoundary boundary =
        _captureKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    _capturedImage = byteData?.buffer.asUint8List();
    print("Captured image size: ${_capturedImage?.length} bytes");
    setState(() {});
  }

  ///Renders the popup that prompts input for a label of the current annotation
  void _showPopup() {
    TextEditingController userInputController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Label Annotation'),
          content: Column(
            children: [
              const Text('Enter a name for your annotation:'),
              TextField(
                controller: userInputController,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                userInput = userInputController.text;
                _capturedPoint = _freeDrawKey.currentState?.lastDrawingPoint;
                if (userInput != null &&
                    userInput!.isNotEmpty &&
                    _capturedPoint != null) {
                  annotationsList.add([userInput, _capturedPoint!.offsets]);
                  Navigator.of(context).pop();
                  _capturedPoint = null;
                  print(annotationsList.length);
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                      child: const Row(
                        children: [
                          Icon(Icons.arrow_back_ios),
                          Text("Back to list"),
                        ],
                      ),
                      onTap: () => Navigator.pop(context),
                    ),
                    const Heading(text: "Annotate Your Image"),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              RepaintBoundary(
                key: _captureKey,
                child: SizedBox(
                  width: 300,
                  height: 300,
                  child: FreeDraw(
                    key: _freeDrawKey,
                    imageLink: widget.imageLink,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _showPopup();
                },
                child: const Text("Label Annotation"),
              ),
              ElevatedButton(
                onPressed: () {
                  captureImage();
                  print(annotationsList);
                },
                child: const Text("Complete Annotations"),
              ),
              //
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
