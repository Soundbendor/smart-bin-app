// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';

// Project imports:
import 'package:binsight_ai/database/connection.dart';
import 'package:binsight_ai/database/models/detection.dart';
import '../shared.dart';

class DetectionDatabase extends FakeDatabase {
  final int datatype;

  DetectionDatabase({this.datatype = 0});

  @override
  Future<List<Map<String, Object?>>> query(String table,
      {bool? distinct,
      List<String>? columns,
      String? where,
      List<Object?>? whereArgs,
      String? groupBy,
      String? having,
      String? orderBy,
      int? limit,
      int? offset}) {
    final values = [
      {
        "imageId": "foo-1",
        "timestamp":
            DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        "deviceId": "foo",
      },
      {
        "imageId": "foo-2",
        "timestamp":
            DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        "deviceId": "bar",
        "postDetectImgLink": "https://placehold.co/512x512",
        "depthMapImgLink": "https://placehold.co/512x512",
        "irImgLink": "https://placehold.co/512x512",
        "transcription": "orange peels",
        "weight": 10.0,
        "humidity": 1.5,
        "temperature": 20.0,
        "co2": 0.5,
        "vo2": 0.5,
        "pressure": 10.0,
        "iaq": 10.0,
        "boxes": "[]"
      },
      {
        "imageId": "foo-3",
        "timestamp":
            DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        "deviceId": "bar",
        "postDetectImgLink": "https://placehold.co/512x512",
        "depthMapImgLink": "https://placehold.co/512x512",
        "irImgLink": "https://placehold.co/512x512",
        "transcription": "orange peels",
        "weight": 10.0,
        "humidity": 1.5,
        "temperature": 20.0,
        "co2": 0.5,
        "vo2": 0.5,
        "pressure": 10.0,
        "iaq": 10.0,
        "boxes": "[]"
      },
    ];
    switch (datatype) {
      case 0:
        return Future.value([]);
      case 1:
        return Future.value([values[0]]);
      case 2:
        return Future.value([values[1]]);
      case 3:
        return Future.value([values[1], values[2]]);
      case 4:
        return Future.value(values);
      default:
        return Future.value([]);
    }
  }
}

void main() async {
  testInit();
  test("Finding all detections", () async {
    Database db = DetectionDatabase(datatype: 4);
    setDatabase(db);

    final detections = await Detection.all();
    expect(detections.length, equals(3));
    expect(
        detections[0].imageId,
        equals(
            "${detections[0].deviceId}-${detections[0].timestamp.toIso8601String()}"));
    expect(
        detections[1].imageId,
        equals(
            "${detections[1].deviceId}-${detections[1].timestamp.toIso8601String()}"));
    expect(
        detections[2].imageId,
        equals(
            "${detections[2].deviceId}-${detections[2].timestamp.toIso8601String()}"));
  });

  test("Finding latest detection", () async {
    setDatabase(null);
    await getDatabaseConnection(dbName: "test_database.db");

    final Detection detection_1 = Detection.createDefault();
    detection_1.timestamp = DateTime.now().subtract(const Duration(days: 2));
    detection_1.save();

    final Detection detection_2 = Detection.createDefault();
    detection_2.timestamp = DateTime.now().subtract(const Duration(days: 1));
    detection_2.imageId =
        "${detection_2.deviceId}-${detection_2.timestamp.toIso8601String()}";
    detection_2.save();

    final Detection detection_3 = Detection.createDefault();
    detection_3.timestamp = DateTime.now();
    detection_3.imageId =
        "${detection_3.deviceId}-${detection_3.timestamp.toIso8601String()}";
    detection_3.save();

    final detection = await Detection.latest();
    expect(
        detection.imageId,
        equals(
            "${detection_3.deviceId}-${detection_3.timestamp.toIso8601String()}"));
  });
}
