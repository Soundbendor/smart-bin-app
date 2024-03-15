// Flutter imports:
import 'dart:convert';

// Package imports:
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:sqflite/sqflite.dart';

// Project imports:
import 'package:binsight_ai/database/connection.dart';
import 'package:binsight_ai/database/models/detection.dart';
import 'package:binsight_ai/util/print.dart';

/// Handles messages from the WebSocket channel.
void handleMessages(WebSocketChannel channel) {
  channel.stream.listen(
    (data) async {
      try {
        final jsonData = await jsonDecode(data);
        final messageType = jsonData['type'];
        if (messageType == 'pre_detection') {
          debug('Emitted predetection was received');
          await updatePreDetection(await jsonDecode(jsonData["pre_detection"]));
        } else if (messageType == 'post_detection') {
          debug('Emitted postdetection was received');
          await addPostDetectionLink(jsonDecode(jsonData["post_detection"]));
        }
      } catch (e) {
        debug('Error decoding JSON: $e');
      }
    },
    onDone: () {
      debug('Socket Closed');
    },
    onError: (error) {
      debug("Socket Error: $error");
    },
  );
}

/// Creates a detection with updated data and saves it to the database.
Future<void> updatePreDetection(Map<String, dynamic> data) async {
  Detection detection = Detection(
    imageId: data['img_id'],
    preDetectImgLink: data['img_link'],
    timestamp: DateTime.now(),
    deviceId: "device_id",
    depthMapImgLink: data['depth_map_link'],
    irImgLink: data['ir_link'], //Update name to name in pydantic model
    weight: data['weight'],
    humidity: data['humidity'],
    temperature: data['temperature'],
    co2: data['co2'], //Update name to name in pydantic model
    vo2: data['vo2'], //Update name to name in pydantic model
    // boxes: data['boxes'] //Update name to name in pydantic model
  );

  await detection.save();
}

/// Updates the post detection link in the database.
Future<void> addPostDetectionLink(
    Map<String, dynamic> postDetectionData) async {
  Database db = await getDatabaseConnection();
  List<Map<String, dynamic>> detections = await db.query(
    "detections",
    where: "imageId = ?",
    whereArgs: [postDetectionData['img_id']],
  );

  if (detections[0].isNotEmpty) {
    Detection detection = Detection.fromMap(detections[0]);
    detection.postDetectImgLink = postDetectionData['img_link'];
    detection.boxes = postDetectionData["boxes"];
    detection.update();
  }
}
