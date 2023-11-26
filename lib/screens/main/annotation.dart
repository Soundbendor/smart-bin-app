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
  Uint8List? capturedImage;

  void captureImage() async {
    RenderRepaintBoundary boundary =
        _captureKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    capturedImage = byteData?.buffer.asUint8List();

    print("Captured image size: ${capturedImage?.length} bytes");
    setState(() {});
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
                  child: FreeDraw(imagePath: widget.imagePath),
                ),
              ),
              ElevatedButton(
                onPressed: captureImage,
                child: const Text("Save Annotation"),
              ),
              if (capturedImage != null)
                Image.memory(
                  capturedImage!,
                  width: 300,
                  height: 300,
                  fit: BoxFit.cover,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
