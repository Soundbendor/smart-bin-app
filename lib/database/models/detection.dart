import 'package:sqflite/sqflite.dart';
import 'package:binsight_ai/database/connection.dart';
import 'package:binsight_ai/database/model.dart';

/// The detection model.
///
/// Contains all the information about a detection.
class Detection extends Model {
  /// The image ID.
  String imageId;

  /// The link to the pre-detection image.
  String preDetectImgLink;

  /// The link to the post-detection image.
  String? postDetectImgLink;

  /// The link to the depth map image.
  String? depthMapImgLink;

  /// The link to the IR image.
  String? irImgLink;

  // The weight value.
  double? weight;

  /// The humidity value.
  double? humidity;

  /// The temperature value.
  double? temperature;

  /// The CO2 value.
  double? co2;

  /// The VO2 value.
  double? vo2;

  /// The bounding boxes, in JSON format.
  String? boxes;

  /// The timestamp of the detection.
  DateTime timestamp;

  /// The device ID.
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

  /// Creates a blank device for testing or retrieving properties of the model.
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

  static Detection fromMap(Map<String, dynamic> map) {
    return Detection(
      imageId: map['imageId'],
      preDetectImgLink: map['preDetectImgLink'],
      timestamp: DateTime.parse(map['timestamp']),
      deviceId: map['deviceId'],
      postDetectImgLink: map['postDetectImgLink'],
      depthMapImgLink: map['depthMapImgLink'],
      irImgLink: map['irImgLink'],
      weight: map['weight']?.toDouble(),
      humidity: map['humidity']?.toDouble(),
      temperature: map['temperature']?.toDouble(),
      co2: map['co2']?.toDouble(),
      vo2: map['vo2']?.toDouble(),
      boxes: map['boxes'],
    );
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
