import 'package:binsight_ai/database/connection.dart';
import 'package:binsight_ai/database/models/detection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
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
        "preDetectImgLink": "https://placehold.co/512x512",
        "timestamp": DateTime.now().toIso8601String(),
        "deviceId": "foo",
      },
      {
        "imageId": "foo-2",
        "preDetectImgLink": "https://placehold.co/512x512",
        "timestamp": DateTime.now().toIso8601String(),
        "deviceId": "bar",
        "postDetectImgLink": "https://placehold.co/512x512",
        "depthMapImgLink": "https://placehold.co/512x512",
        "irImgLink": "https://placehold.co/512x512",
        "weight": 10.0,
        "humidity": 1.5,
        "temperature": 20.0,
        "co2": 0.5,
        "vo2": 0.5,
        "boxes": "[]",
      },
      {
        "imageId": "foo-3",
        "preDetectImgLink": "https://placehold.co/512x512",
        "timestamp": DateTime.now().toIso8601String(),
        "deviceId": "bar",
        "depthMapImgLink": "https://placehold.co/512x512",
        "irImgLink": "https://placehold.co/512x512",
        "weight": 20.0,
        "humidity": 2.5,
        "temperature": 30.0,
        "co2": 2.5,
        "vo2": 4.5,
      }
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
  test("Finding all devices", () async {
    Database db = DetectionDatabase(datatype: 4);
    setDatabase(db);

    final devices = await Detection.all();
    expect(devices.length, equals(3));
    expect(devices[0].imageId, equals("foo-1"));
    expect(devices[1].imageId, equals("foo-2"));
    expect(devices[2].imageId, equals("foo-3"));
  });
}
