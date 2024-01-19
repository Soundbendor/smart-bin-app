import 'package:flutter_test/flutter_test.dart';
import 'package:binsight_ai/database/connection.dart';
import 'package:binsight_ai/database/models/device.dart';
import '../shared.dart';

void main() async {
  test("database connection is closed", () async {
    FakeDatabase db = FakeDatabase();
    setDatabase(db);

    expect(db.isOpen, true);
    closeDatabaseConnection();
    expect(db.isOpen, false);
  });

  test("table is created", () async {
    FakeDatabase db = FakeDatabase();
    setDatabase(db);

    await createTables(db, [Device.createDefault()], false);

    // find using regex in the list
    expect(db.queries.any((element) {
      return element.contains("CREATE TABLE") &&
          element.contains(Device.createDefault().tableName) &&
          element.contains(Device.createDefault().schema);
    }), true);

    // No drops or inserts
    expect(db.queries.any((element) {
      return element.contains("DROP TABLE") || element.contains("INSERT INTO");
    }), false);
  });

  test("table is modified", () async {
    FakeDatabase db = FakeDatabase();
    setDatabase(db);

    await createTables(db, [Device.createDefault()], true);

    // find using regex in the list
    expect(db.queries.any((element) {
      return element.contains("CREATE TABLE") &&
          element.contains(Device.createDefault().tableName) &&
          element.contains(Device.createDefault().schema);
    }), true);

    // drop and insert and alter
    expect(db.queries.any((element) {
      return element.contains("DROP TABLE");
    }), true);
    expect(db.queries.any((element) {
      return element.contains("INSERT INTO") &&
          element.contains("(foo, bar)"); // See FakeDatabase.rawQuery
    }), true);
    expect(db.queries.any((element) {
      return element.contains("ALTER TABLE");
    }), true);
  });
}
