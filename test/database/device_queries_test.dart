// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';

// Project imports:
import 'package:binsight_ai/database/connection.dart';
import 'package:binsight_ai/database/models/device.dart';
import '../shared.dart';

class DeviceDatabase extends FakeDatabase {
  final bool exists;

  DeviceDatabase({this.exists = true});

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
    if (exists) {
      return Future.value([
        {
          "id": "foo",
        },
        {
          "id": "bar",
        },
      ]);
    } else {
      return Future.value([]);
    }
  }

  @override
  Future<T> readTransaction<T>(Future<T> Function(Transaction txn) action) {
    // TODO: implement readTransaction
    throw UnimplementedError();
  }
}

void main() async {
  testInit();

  test("Finding a device that exists", () async {
    Database db = DeviceDatabase();
    setDatabase(db);

    Device? device = await Device.find("foo");
    expect(device, isNotNull);
    expect(device!.id, equals("foo"));
  });

  test("Finding a device that does not exist", () async {
    Database db = DeviceDatabase(exists: false);
    setDatabase(db);

    Device? device = await Device.find("foo");
    expect(device, isNull);
  });

  test("Finding all devices", () async {
    Database db = DeviceDatabase();
    setDatabase(db);

    List<Device> devices = await Device.all();
    expect(devices.length, equals(2));
    expect(devices[0].id, equals("foo"));
    expect(devices[1].id, equals("bar"));
  });
}
