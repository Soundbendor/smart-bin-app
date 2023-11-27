import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:waste_watchers/widgets/free_draw.dart';

class AnnotationPage extends StatefulWidget {
  final String imagePath;

  const AnnotationPage({required this.imagePath, Key? key}) : super(key: key);

  @override
  State<AnnotationPage> createState() => _AnnotationPageState();
}

class _AnnotationPageState extends State<AnnotationPage> {
  final GlobalKey _captureKey = GlobalKey();
  final GlobalKey<dynamic> _freeDrawKey = GlobalKey();
  Uint8List? _capturedImage;
  DrawingPoint? _capturedPoint;
  String? userInput;
  List<List<dynamic>> annotationsList = [];

  void captureImage() async {
    RenderRepaintBoundary boundary =
        _captureKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    _capturedImage = byteData?.buffer.asUint8List();
    print("Captured image size: ${_capturedImage?.length} bytes");
    setState(() {});
  }

  void _showPopup() {
    TextEditingController userInputController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Label Annotation'),
          content: Column(
            children: [
              Text('Enter a name for your annotation:'),
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
              RepaintBoundary(
                key: _captureKey,
                child: SizedBox(
                  width: 300,
                  height: 300,
                  child: FreeDraw(
                    key: _freeDrawKey,
                    imagePath: widget.imagePath,
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
