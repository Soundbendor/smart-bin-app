// Flutter imports:
import 'dart:io';
import 'dart:ui' as ui;
import 'package:binsight_ai/util/image.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:binsight_ai/util/providers/annotation_notifier.dart';

/// Widget with logic to annotate and render detection images
class FreeDraw extends StatefulWidget {
  /// The link for the image to be annotated
  final String imageLink;

  /// The size of the widget/viewport
  final double size;

  /// The scale of the image. Used to scale the values of the drawing segments between 0 and 100
  final double scale;

  /// The base directory for the image
  final Directory baseDir;

  const FreeDraw({
    required this.imageLink,
    required this.baseDir,
    required this.size,
    super.key,
  }) : scale = size / 100;

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

  void onDrawStart(DragStartDetails details, AnnotationNotifier notifier) {
    setState(() {
      if (_isPointOnImage(details.localPosition)) {
        final scaledPosition = Offset(
          details.localPosition.dx / widget.scale,
          details.localPosition.dy / widget.scale,
        );
        currentDrawingSegment = DrawingSegment(
          id: DateTime.now().microsecondsSinceEpoch,
          offsets: [scaledPosition],
        );
        notifier.startCurrentAnnotation(currentDrawingSegment!);
        notifier.updateCurrentAnnotationHistory();
      }
    });
  }

  void onDrawUpdate(DragUpdateDetails details, AnnotationNotifier notifier) {
    setState(() {
      if (currentDrawingSegment != null &&
          _isPointOnImage(details.localPosition)) {
        Offset localPosition = details.localPosition;
        final scaledPosition = Offset(
          localPosition.dx / widget.scale,
          localPosition.dy / widget.scale,
        );

        currentDrawingSegment = currentDrawingSegment?.copyWith(
          offsets: currentDrawingSegment!.offsets..add(scaledPosition),
        );
        notifier.updateCurrentAnnotation(currentDrawingSegment!);
        notifier.updateCurrentAnnotationHistory();
      }
    });
  }

  void onDrawEnd() {
    setState(() {
      currentDrawingSegment = null;
    });
  }

  bool isDrawing() {
    return currentDrawingSegment != null;
  }

  @override
  Widget build(BuildContext context) {
    File? image = getImage(widget.imageLink, widget.baseDir);
    return Consumer<AnnotationNotifier>(
      builder: (context, notifier, crhild) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: GestureDetector(
            // When first touching within the image, create a single Offset
            onVerticalDragStart: (details) => onDrawStart(details, notifier),
            onPanStart: (details) => onDrawStart(details, notifier),
            // When dragging your finger, update the current drawing's offsets to include the new point
            // Update the most recent segment in the annotation's list of Segments
            onVerticalDragUpdate: (details) => onDrawUpdate(details, notifier),
            onPanUpdate: (details) => onDrawUpdate(details, notifier),
            // When the user lifts their finger, stop updating the current drawing segment
            onVerticalDragEnd: (_) => onDrawEnd(),
            onPanEnd: (_) => onDrawEnd(),
            // Render the drawing on top of the image
            child: Stack(
              children: [
                image != null
                    ? Image.file(image, key: imageKey, fit: BoxFit.fill)
                    : Container(),
                CustomPaint(
                  painter: DrawingPainter(
                    activeSegments: scaleSegments(notifier.currentAnnotation),
                    allSegments: scaleSegments(notifier.oldAnnotations),
                  ),
                ),
                if (!isDrawing()) FreeDrawText(scale: widget.scale)
              ],
            ),
          ),
        );
      },
    );
  }

  List<DrawingSegment> scaleSegments(List<DrawingSegment> segments) {
    return segments.map((segment) {
      return DrawingSegment(
        id: segment.id,
        offsets: segment.offsets
            .map((offset) => Offset(
                  offset.dx * widget.scale,
                  offset.dy * widget.scale,
                ))
            .toList(),
      );
    }).toList();
  }

  /// Checks whether an Offset is within the bounds of the image
  bool _isPointOnImage(Offset point) {
    RenderBox renderBox =
        imageKey.currentContext!.findRenderObject() as RenderBox;
    Rect imageBounds = renderBox.paintBounds;
    return imageBounds.contains(point);
  }
}

class FreeDrawText extends StatelessWidget {
  const FreeDrawText({
    super.key,
    required this.scale,
  });

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Consumer<AnnotationNotifier>(builder: (context, notifier, child) {
      final textTheme = Theme.of(context).textTheme;
      return Stack(
        children: notifier.allAnnotations.map((annotation) {
          return Positioned(
            left: annotation["xy_coord_list"][0][0] * scale,
            top: annotation["xy_coord_list"][0][1] * scale,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xaaffffff),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                annotation["object_name"],
                style: textTheme.labelMedium,
                textAlign: TextAlign.center,
              ),
            ),
          );
        }).toList(),
      );
    });
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
