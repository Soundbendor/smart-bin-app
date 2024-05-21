// Package imports:
import 'package:sqflite/sqflite.dart';

// Project imports:
import 'package:binsight_ai/database/connection.dart';
import 'package:binsight_ai/database/model.dart';

/// The detection model.
///
/// Contains all the information about a detection.
class Detection extends Model {
  /// The image ID.
  String imageId;

  /// The link to the post-detection image.
  String? postDetectImgLink;

  /// The link to the depth map image.
  String? depthMapImgLink;

  /// The link to the IR image.
  String? irImgLink;

  /// The audio transcription.
  String? transcription;

  /// The total weight value.
  double? totalWeight;

  // The weight value (delta).
  double? weight;

  /// The humidity value.
  double? humidity;

  /// The pressure value.
  double? pressure;

  /// The temperature value.
  double? temperature;

  /// The IAQ value (Indoor Air Quality).
  double? iaq;

  /// The CO2 value.
  double? co2;

  /// The TVOC value (Total volatile organic compounds).
  double? vo2;

  /// The bounding boxes, in JSON format.
  String? boxes;

  /// The timestamp of the detection.
  DateTime timestamp;

  /// The device ID.
  String deviceId;

  Detection({
    required this.imageId,
    required this.timestamp,
    required this.deviceId,
    this.postDetectImgLink,
    this.depthMapImgLink,
    this.irImgLink,
    this.transcription,
    this.weight,
    this.humidity,
    this.temperature,
    this.co2,
    this.vo2,
    this.boxes,
    this.totalWeight,
    this.pressure,
    this.iaq,
  });

  /// Creates a blank device for testing or retrieving properties of the model.
  Detection.createDefault()
      : imageId = "1",
        postDetectImgLink = "assets/images/placeholder.png",
        timestamp = DateTime.now(),
        deviceId = "1";

  /// Creates a null object pattern equivalent for a Detection that is not found.
  Detection.notFound()
      : imageId = "-1",
        postDetectImgLink = "assets/images/placeholder.png",
        timestamp = DateTime.now(),
        deviceId = "-1";

  @override
  Map<String, dynamic> toMap() {
    return {
      "imageId": imageId,
      "postDetectImgLink": postDetectImgLink,
      "depthMapImgLink": depthMapImgLink,
      "irImgLink": irImgLink,
      "transcription": transcription,
      "weight": weight,
      "humidity": humidity,
      "temperature": temperature,
      "co2": co2,
      "vo2": vo2,
      "pressure": pressure,
      "iaq": iaq,
      "boxes": boxes,
      "timestamp": timestamp.toIso8601String(),
      "deviceId": deviceId,
    };
  }

  static Future<Detection?> find(String imageId) async {
    Database db = await getDatabaseConnection();
    List<Map<String, dynamic>> results = await db.query("detections",
        where: "imageId = ?", whereArgs: [imageId], limit: 1);
    if (results.isEmpty) {
      return null;
    }
    return Detection.fromMap(results.first);
  }

  static Detection fromMap(Map<String, dynamic> map) {
    // Note: As of this commit, the actual server schema is not known. This is just a placeholder.
    return Detection(
      //TODO: Create new imageID instead of reusing timestamp
      imageId: "${map['deviceId']}-${DateTime.parse(map['timestamp']).toIso8601String()}",
      timestamp: DateTime.parse(map['timestamp']),
      deviceId: map['deviceId'],
      postDetectImgLink: map['postDetectImgLink'],
      depthMapImgLink: map['depthMapImgLink'],
      irImgLink: map['irImgLink'],
      transcription: map['transcription'],
      weight: map['weight']?.toDouble(),
      humidity: map['humidity']?.toDouble(),
      temperature: map['temperature']?.toDouble(),
      co2: map['co2']?.toDouble(),
      vo2: map['vo2']?.toDouble(),
      pressure: map['pressure']?.toDouble(),
      iaq: map['iaq']?.toDouble(),
      boxes: map['boxes'],
    );
  }

  @override
  String get tableName => "detections";

  @override
  String get schema => """
    (
      imageId TEXT PRIMARY KEY,
      postDetectImgLink TEXT,
      depthMapImgLink TEXT,
      irImgLink TEXT,
      transcription TEXT,
      weight DOUBLE,
      humidity DOUBLE,
      temperature DOUBLE,
      co2 DOUBLE,
      vo2 DOUBLE,
      pressure DOUBLE,
      iaq DOUBLE,
      boxes TEXT,
      timestamp DATETIME NOT NULL,
      deviceId VARCHAR(255) NOT NULL,
      FOREIGN KEY (deviceId) REFERENCES devices (id)
    )
  """;

  @override
  Future<void> update() async {
    Database db = await getDatabaseConnection();
    await db
        .update(tableName, toMap(), where: "imageId = ?", whereArgs: [imageId]);
  }

  @override
  Future<void> delete() async {
    Database db = await getDatabaseConnection();
    await db.delete(tableName, where: "imageId = ?", whereArgs: [imageId]);
  }

  /// Returns all detections.
  static Future<List<Detection>> all() async {
    Database db = await getDatabaseConnection();
    List<Map<String, dynamic>> results =
        await db.query("detections", orderBy: "timestamp DESC");
    return results
        .map((result) => Detection.fromMap(
              result,
            ))
        .toList();
  }

  /// Returns the latest detection in the local database, null Detection if none found.
  static Future<Detection> latest() async {
    Database db = await getDatabaseConnection();
    List<Map<String, dynamic>> results =
        await db.query("detections", orderBy: "timestamp DESC");
    if (results.isNotEmpty) {
      return Detection.fromMap(results.first);
    } else {
      return Detection.notFound();
    }
  }
}
