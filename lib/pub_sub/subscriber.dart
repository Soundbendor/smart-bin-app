import 'package:binsight_ai/database/connection.dart';
import 'package:binsight_ai/database/models/detection.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:convert';

void handleMessages(WebSocketChannel channel) {
  channel.stream.listen(
    (data) async {
      try {
        final jsonData = await jsonDecode(data);
        final messageType = jsonData['type'];
        if (messageType == 'pre_detection') {
          print('Emitted predetection was received');
          // await updatePreDetection(jsonData["pre_detection"], database);
        } else if (messageType == 'post_detection') {
          print('Emitted postdetection was received');
          // await updatePostDetection(jsonData["post_detection"], database);
        }
      } catch (e) {
        print('Error decoding JSON: $e');
      }
    },
    onDone: () {
      print('Socket Closed');
    },
    onError: (error) {
      print('Socket Error: $error');
    },
  );
}

Future<void> updatePreDetection(Map<String, dynamic> data) async {
  Detection detection = Detection(
      imageId: data['img_id'],
      preDetectImgLink: data['img_link'],
      timestamp: DateTime.now(),
      deviceId: "device_id",
      depthMapImgLink: data['depth_map_link'],
      irImgLink: data['ir_link'], //Update name to name in pydantic model
      weight: data['weight'],
      humidity: data['humditiy'],
      temperature: data['temperature'],
      co2: data['co2'], //Update name to name in pydantic model
      vo2: data['vo2'], //Update name to name in pydantic model
      boxes: data['boxes'] //Update name to name in pydantic model
      );

  await detection.save();
}

Future<void> addPostDetectionLink(
    Map<String, dynamic> postDetectionData) async {
  Database db = await getDatabaseConnection();
  List<Map<String, dynamic>> detections = await db.query(
    "detections",
    where: "imageId = ?",
    whereArgs: [postDetectionData['imageId']],
  );

  if (detections[0].isNotEmpty) {
    Detection detection = Detection.fromMap(detections[0]);
    detection.postDetectImgLink = postDetectionData['img_link'];
    detection.update();
  }
}
