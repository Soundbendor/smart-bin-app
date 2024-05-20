// Flutter imports:
import 'dart:convert';

import 'package:flutter/material.dart';

// Project imports:
import 'package:binsight_ai/util/print.dart';
import 'package:binsight_ai/database/models/detection.dart';

class DetectionNotifier with ChangeNotifier {
  List<Detection> detections = [];

  /// Fetches all detections from the database
  Future<List<Detection>> getAll() async {
    detections = await Detection.all();
    notifyListeners();
    return detections;
  }

  // test function
  // TODO: change with actual data and correct schema
  void updateDetection(String detectionId, List<dynamic> annotations) async {
    try {
      final detection = await Detection.find(detectionId);
      if (detection != null) {
        detection.boxes = jsonEncode(annotations);
        await detection.update();
        await getAll();
        debug("Updated annotation in DB");
      }
    } catch (error) {
      debug('Error updating annotations: $error');
    }
  }
}
