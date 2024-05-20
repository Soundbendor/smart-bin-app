// Flutter imports:
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
  void updateDetection(String detectionId) async {
    try {
      final detection = await Detection.find(detectionId);
      if (detection != null) {
        detection.boxes = '''
        [{
          "object_name": "Milk",
          "xy_coord_list": [
            [11.1, 16.4],
            [11.3, 16.5]
          ]
        }]''';
        await detection.update();
        await getAll();
        debug("Updated annotation in DB");
      }
    } catch (error) {
      debug('Error updating annotations: $error');
    }
    // notifyListeners();
  }
}
