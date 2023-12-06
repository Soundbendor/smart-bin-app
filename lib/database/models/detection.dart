import 'package:sqflite/sqflite.dart';
import 'package:binsight_ai/database/connection.dart';
import 'package:binsight_ai/database/model.dart';

class Detection extends Model {
  String imageId;
  String preDetectImgLink;
  String? postDetectImgLink;
  String? depthMapImgLink;
  String? irImgLink;
  double? weight;
  double? humidity;
  double? temperature;
  double? co2;
  double? vo2;
  String? boxes;
  DateTime timestamp;
  String deviceId;

  Detection({
    required this.imageId,
    required this.preDetectImgLink,
    required this.timestamp,
    required this.deviceId,
    this.postDetectImgLink,
    this.depthMapImgLink,
    this.irImgLink,
    this.weight,
    this.humidity,
    this.temperature,
    this.co2,
    this.vo2,
    this.boxes,
  });

  Detection.createDefault()
      : imageId = "1",
        preDetectImgLink = "assets/images/placeholder.png",
        timestamp = DateTime.now(),
        deviceId = "1";

  @override
  Map<String, dynamic> toMap() {
    return {
      "imageId": imageId,
      "preDetectImgLink": preDetectImgLink,
      "postDetectImgLink": postDetectImgLink,
      "depthMapImgLink": depthMapImgLink,
      "irImgLink": irImgLink,
      "weight": weight,
      "humidity": humidity,
      "temperature": temperature,
      "co2": co2,
      "vo2": vo2,
      "boxes": boxes,
      "timestamp": timestamp.toIso8601String(),
      "deviceId": deviceId,
    };
  }

  @override
  String get tableName => "detections";

  @override
  String get schema => """
    (
      preDetectImgLink TEXT PRIMARY KEY,
      postDetectImgLink TEXT,
      depthMapImgLink TEXT,
      irImgLink TEXT,
      humidity DOUBLE,
      temperature DOUBLE,
      co2 DOUBLE,
      vo2 DOUBLE,
      boxes TEXT,
      timestamp DATETIME NOT NULL,
      deviceId VARCHAR(255) NOT NULL,
      FOREIGN KEY (deviceId) REFERENCES devices (id)
    )
  """;

  @override
  Future<void> delete() async {
    Database db = await getDatabaseConnection();
    await db.delete(tableName,
        where: "preDetectImgLink = ?", whereArgs: [preDetectImgLink]);
  }
}
