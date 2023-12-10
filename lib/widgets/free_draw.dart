import 'package:flutter/material.dart';

class FreeDraw extends StatefulWidget {
  final String imageLink;

  const FreeDraw({
    required this.imageLink,
    Key? key,
  }) : super(key: key);

  @override
  State<FreeDraw> createState() => _FreeDrawState();
}

class _FreeDrawState extends State<FreeDraw> {
  var historyDrawingPoints = <DrawingPoint>[];
  var drawingPoints = <DrawingPoint>[];
  String? userInput;

  DrawingPoint? currentDrawingPoint;
  DrawingPoint? tempDrawingPoint;
  late GlobalKey imageKey;

  @override
  void initState() {
    super.initState();
    imageKey = GlobalKey();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 300,
      child: GestureDetector(
        onPanStart: (details) {
          setState(() {
            if (_isPointOnImage(details.localPosition)) {
              currentDrawingPoint = DrawingPoint(
                id: DateTime.now().microsecondsSinceEpoch,
                offsets: [details.localPosition],
              );
              drawingPoints.add(currentDrawingPoint!);
              historyDrawingPoints = List.of(drawingPoints);
            }
          });
        },
        onPanUpdate: (details) {
          setState(() {
            if (currentDrawingPoint != null &&
                _isPointOnImage(details.localPosition)) {
              Offset localPosition = details.localPosition;

              currentDrawingPoint = currentDrawingPoint?.copyWith(
                offsets: currentDrawingPoint!.offsets..add(localPosition),
              );
              drawingPoints.last = currentDrawingPoint!;
              historyDrawingPoints = List.of(drawingPoints);
            }
          });
        },
        onPanEnd: (_) {
          currentDrawingPoint = null;
        },
        child: Stack(
          children: [
            Image.asset(
              widget.imageLink,
              key: imageKey,
              fit: BoxFit.cover,
            ),
            CustomPaint(
              painter: DrawingPainter(
                drawingPoints: drawingPoints,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isPointOnImage(Offset point) {
    RenderBox renderBox =
        imageKey.currentContext!.findRenderObject() as RenderBox;
    Rect imageBounds = renderBox.paintBounds;
    return imageBounds.contains(point);
  }

  DrawingPoint? get lastDrawingPoint {
    return drawingPoints.isNotEmpty ? drawingPoints.last : null;
  }

  void undo() {
    setState(() {
      if (drawingPoints.isNotEmpty && historyDrawingPoints.isNotEmpty) {
        drawingPoints.removeLast();
      }
    });
  }

  void redo() {
    setState(() {
      if (drawingPoints.length < historyDrawingPoints.length) {
        final index = drawingPoints.length;
        drawingPoints.add(historyDrawingPoints[index]);
      }
    });
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
