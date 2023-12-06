import 'package:binsight_ai/database/connection.dart';
import 'package:binsight_ai/database/models/detection.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:convert';

void subToSocket(WebSocketChannel channel, Database database) {
  channel.stream.listen(
    (data) async {
      final jsonData = jsonDecode(data);
      final messageType = jsonData['type'];
      if (messageType == 'pre_detection') {
        await updatePreDetection(jsonData["pre_detection"], database);
      } else if (messageType == 'post_detection') {
        await updatePostDetection(jsonData["post_detection"], database);
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

Future<void> updatePreDetection(
    Map<String, dynamic> data, Database database) async {
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

  Database database = await getDatabaseConnection();
  await database.insert(detection.tableName, detection.toMap());
}

Future<void> updatePostDetection(
    Map<String, dynamic> data, Database database) async {
  List<Map<String, dynamic>> detection = await database.query(
    "detections",
    where: "img_id = ?",
    whereArgs: [data['img_id']],
  );
  if (detection.isNotEmpty) {
    await database.update(
      "detections",
      {'postDetectImgLink': data['img_link']},
      where: "img_id = ?",
      whereArgs: [data['img_id']],
    );
  }
}
