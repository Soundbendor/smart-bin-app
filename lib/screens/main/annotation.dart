import 'package:flutter/material.dart';

class Annotation extends StatefulWidget {
  final String imagePath;

  const Annotation({required this.imagePath, Key? key}) : super(key: key);

  @override
  State<Annotation> createState() => _AnnotationState();
}

class _AnnotationState extends State<Annotation> {
  var historyDrawingPoints = <DrawingPoint>[];
  var drawingPoints = <DrawingPoint>[];

  DrawingPoint? currentDrawingPoint;
  late GlobalKey imageKey;
  @override
  void initState() {
    super.initState();
    imageKey = GlobalKey();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          widget.imagePath,
          key: imageKey,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height / 2,
          fit: BoxFit.cover,
        ),
        GestureDetector(
          onPanStart: (details) {
            setState(() {
              currentDrawingPoint = DrawingPoint(
                id: DateTime.now().microsecondsSinceEpoch,
                offsets: [
                  details.localPosition,
                ],
              );

              if (currentDrawingPoint == null) return;
              drawingPoints.add(currentDrawingPoint!);
              historyDrawingPoints = List.of(drawingPoints);
            });
          },
          onPanUpdate: (details) {
            setState(() {
              if (currentDrawingPoint == null) return;

              RenderBox renderBox =
                  imageKey.currentContext!.findRenderObject() as RenderBox;
              Offset localPosition =
                  renderBox.globalToLocal(details.globalPosition);

              double customWidth = renderBox.size.width;
              double customHeight = renderBox.size.height;

              if (localPosition.dx < customWidth &&
                  localPosition.dy < customHeight) {
                currentDrawingPoint = currentDrawingPoint?.copyWith(
                  offsets: currentDrawingPoint!.offsets..add(localPosition),
                );
              }

              drawingPoints.last = currentDrawingPoint!;
              historyDrawingPoints = List.of(drawingPoints);
            });
          },
          onPanEnd: (_) {
            print(currentDrawingPoint?.offsets);
            currentDrawingPoint = null;
          },
          child: CustomPaint(
            painter: DrawingPainter(
              drawingPoints: drawingPoints,
            ),
            size: Size(
              MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height / 2,
            ),
          ),
        ),
      ],
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<DrawingPoint> drawingPoints;

  DrawingPainter({
    required this.drawingPoints,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var drawingPoint in drawingPoints) {
      final paint = Paint()
        ..color = Colors.black
        ..isAntiAlias = true
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round;

      for (var i = 0; i < drawingPoint.offsets.length; i++) {
        var notLastOffset = i != drawingPoint.offsets.length - 1;

        if (notLastOffset) {
          final current = drawingPoint.offsets[i];
          final next = drawingPoint.offsets[i + 1];
          canvas.drawLine(current, next, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class DrawingPoint {
  int id;
  List<Offset> offsets;

  DrawingPoint({
    this.id = -1,
    this.offsets = const [],
  });

  DrawingPoint copyWith({List<Offset>? offsets}) {
    return DrawingPoint(
      id: id,
      offsets: offsets ?? this.offsets,
    );
  }
}
