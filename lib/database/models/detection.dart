import 'package:sqflite/sqflite.dart';
import 'package:waste_watchers/database/connection.dart';
import 'package:waste_watchers/database/model.dart';

class Detection extends Model {
  String preDetectImgLink;
  String? postDetectImgLink;
  String? depthMapImgLink;
  String? irImgLink;
  double? humidity;
  double? temperature;
  double? co2;
  double? vo2;
  String? boxes;
  DateTime timestamp;
  String deviceId;

  Detection({
    required this.preDetectImgLink,
    required this.timestamp,
    required this.deviceId,
    this.postDetectImgLink,
    this.depthMapImgLink,
    this.irImgLink,
    this.humidity,
    this.temperature,
    this.co2,
    this.vo2,
    this.boxes,
  });

  Detection.createDefault()
      : preDetectImgLink = "",
        timestamp = DateTime.now(),
        deviceId = "";

  @override
  Map<String, dynamic> toMap() {
    return {
      "preDetectImgLink": preDetectImgLink,
      "postDetectImgLink": postDetectImgLink,
      "depthMapImgLink": depthMapImgLink,
      "irImgLink": irImgLink,
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
    await db.delete(tableName, where: "preDetectImgLink = ?", whereArgs: [preDetectImgLink]);
  }
}
