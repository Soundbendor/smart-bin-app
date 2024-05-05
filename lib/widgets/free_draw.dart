// Flutter imports:
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:binsight_ai/widgets/image.dart';
import '../util/providers/annotation_notifier.dart';

/// Widget with logic to annotate and render detection images
class FreeDraw extends StatefulWidget {
  /// The link for the image to be annotated
  final String imageLink;

  const FreeDraw({
    required this.imageLink,
    super.key,
  });

  @override
  State<FreeDraw> createState() => _FreeDrawState();
}

class _FreeDrawState extends State<FreeDraw> {
  /// The DrawingSegment being actively updated
  DrawingSegment? currentDrawingSegment;

  /// Key for the Image widget that renders the detection image
  late GlobalKey imageKey;

  int startIndex = 0;

  @override
  void initState() {
    imageKey = GlobalKey();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AnnotationNotifier>(
      builder: (context, notifier, crhild) {
        return SizedBox(
          width: 300,
          height: 300,
          child: GestureDetector(
            // When first touching within the image, create a single Offset
            onPanStart: (details) {
              setState(() {
                if (_isPointOnImage(details.localPosition)) {
                  currentDrawingSegment = DrawingSegment(
                    id: DateTime.now().microsecondsSinceEpoch,
                    offsets: [details.localPosition],
                  );
                  notifier.startCurrentAnnotation(currentDrawingSegment!);
                  notifier.updateCurrentAnnotationHistory();
                }
              });
            },
            // When dragging your finger, update the current drawing's offsets to include the new point
            // Update the most recent segment in the annotation's list of Segments
            onPanUpdate: (details) {
              setState(() {
                if (currentDrawingSegment != null &&
                    _isPointOnImage(details.localPosition)) {
                  Offset localPosition = details.localPosition;

                  currentDrawingSegment = currentDrawingSegment?.copyWith(
                    offsets: currentDrawingSegment!.offsets..add(localPosition),
                  );
                  notifier.updateCurrentAnnotation(currentDrawingSegment!);
                  notifier.updateCurrentAnnotationHistory();
                }
              });
            },
            onPanEnd: (_) {
              currentDrawingSegment = null;
            },
            // Render the drawing on top of the image
            child: Stack(
              children: [
                DynamicImage(widget.imageLink,
                    key: imageKey, fit: BoxFit.cover),
                CustomPaint(
                  painter: DrawingPainter(
                    activeSegments: notifier.currentAnnotation,
                    allSegments: notifier.oldAnnotations,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Checks whether an Offset is within the bounds of the image
  bool _isPointOnImage(Offset point) {
    RenderBox renderBox =
        imageKey.currentContext!.findRenderObject() as RenderBox;
    Rect imageBounds = renderBox.paintBounds;
    return imageBounds.contains(point);
  }
}

/// Implementation of the Custom Painter to provide drawing capabilities
///
/// To be used as the painter within the CustomPaint widget, providing the
/// implementation of paint, specifying what to paint and what data to use
class DrawingPainter extends CustomPainter {
  final List<DrawingSegment> activeSegments;
  final List<DrawingSegment> allSegments;

  DrawingPainter({
    required this.activeSegments,
    required this.allSegments,
  });

  @override
  void paint(Canvas canvas, ui.Size size) {
    // Draws a line between each drawingSegment's Offsets
    // for each segment in drawingSegments
    void drawSegments(List<DrawingSegment> segments, Color color) {
      for (var drawingSegment in segments) {
        final paint = Paint()
          ..color = color
          ..isAntiAlias = true
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.round;

        for (var i = 0; i < drawingSegment.offsets.length; i++) {
          var notLastOffset = i != drawingSegment.offsets.length - 1;

          if (notLastOffset) {
            final current = drawingSegment.offsets[i];
            final next = drawingSegment.offsets[i + 1];
            canvas.drawLine(current, next, paint);
          }
        }
      }
    }

    drawSegments(allSegments, Colors.black);
    drawSegments(activeSegments, Colors.blue);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

/// Represents one continous stroke in an annotation
///
/// When annotating an image, multiple segments can be drawn to make up the
/// larger annotation. Each continious stroke is registred as one DrawingSegment
class DrawingSegment {
  /// Unique identifier for the segment
  int id;

  /// List of x,y Offsets that make up the segment
  List<Offset> offsets;

  DrawingSegment({
    this.id = -1,
    this.offsets = const [],
  });

  /// Allows for creation of a new DrawingSegment instance with updated offsets
  /// but the same id.
  DrawingSegment copyWith({List<Offset>? offsets}) {
    return DrawingSegment(
      id: id,
      offsets: offsets ?? this.offsets,
    );
  }

  List<List<double>> toFloatList() {
    List<List<double>> list = offsets.map((offset) {
      return [offset.dx, offset.dy];
    }).toList();
    return list;
  }
}
