// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:binsight_ai/database/models/detection.dart';

class DetectionNotifier with ChangeNotifier {
  List<Detection> detections = [];

  Future<List<Detection>> update() async {
    detections = await Detection.all();
    return detections;
  }
}
