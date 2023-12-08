import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:binsight_ai/database/connection.dart';
import 'package:binsight_ai/database/models/device.dart';

class FakeDatabase implements Database {
  bool isClosed = false;
  final List<String> queries = [];

  @override
  Batch batch() {
    throw UnimplementedError();
  }

  @override
  Future<void> close() {
    isClosed = true;
    return Future.value();
  }

  @override
  Database get database => throw UnimplementedError();

  @override
  Future<int> delete(String table, {String? where, List<Object?>? whereArgs}) {
    throw UnimplementedError();
  }

  @override
  Future<T> devInvokeMethod<T>(String method, [Object? arguments]) {
    throw UnimplementedError();
  }

  @override
  Future<T> devInvokeSqlMethod<T>(String method, String sql,
      [List<Object?>? arguments]) {
    throw UnimplementedError();
  }

  @override
  Future<void> execute(String sql, [List<Object?>? arguments]) {
    queries.add(sql);
    return Future.value();
  }

  @override
  Future<int> insert(String table, Map<String, Object?> values,
      {String? nullColumnHack, ConflictAlgorithm? conflictAlgorithm}) {
    throw UnimplementedError();
  }

  @override
  bool get isOpen => !isClosed;

  @override
  String get path => throw UnimplementedError();

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
    throw UnimplementedError();
  }

  @override
  Future<QueryCursor> queryCursor(String table,
      {bool? distinct,
      List<String>? columns,
      String? where,
      List<Object?>? whereArgs,
      String? groupBy,
      String? having,
      String? orderBy,
      int? limit,
      int? offset,
      int? bufferSize}) {
    throw UnimplementedError();
  }

  @override
  Future<int> rawDelete(String sql, [List<Object?>? arguments]) {
    throw UnimplementedError();
  }

  @override
  Future<int> rawInsert(String sql, [List<Object?>? arguments]) {
    throw UnimplementedError();
  }

  @override
  Future<List<Map<String, Object?>>> rawQuery(String sql,
      [List<Object?>? arguments]) {
    queries.add(sql);
    return Future.value([
      {
        "name": "foo",
      },
      {
        "name": "bar",
      }
    ]);
  }

  @override
  Future<QueryCursor> rawQueryCursor(String sql, List<Object?>? arguments,
      {int? bufferSize}) {
    throw UnimplementedError();
  }

  @override
  Future<int> rawUpdate(String sql, [List<Object?>? arguments]) {
    throw UnimplementedError();
  }

  @override
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action,
      {bool? exclusive}) {
    FakeTransaction transaction = FakeTransaction(this);
    return Future.value(action(transaction));
  }

  @override
  Future<int> update(String table, Map<String, Object?> values,
      {String? where,
      List<Object?>? whereArgs,
      ConflictAlgorithm? conflictAlgorithm}) {
    throw UnimplementedError();
  }
}

class FakeTransaction implements Transaction {
  final FakeDatabase db;

  FakeTransaction(this.db);

  @override
  Batch batch() {
    throw UnimplementedError();
  }

  @override
  Database get database => db;

  @override
  Future<int> delete(String table, {String? where, List<Object?>? whereArgs}) {
    throw UnimplementedError();
  }

  @override
  Future<void> execute(String sql, [List<Object?>? arguments]) {
    return database.execute(sql, arguments);
  }

  @override
  Future<int> insert(String table, Map<String, Object?> values,
      {String? nullColumnHack, ConflictAlgorithm? conflictAlgorithm}) {
    throw UnimplementedError();
  }

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
    throw UnimplementedError();
  }

  @override
  Future<QueryCursor> queryCursor(String table,
      {bool? distinct,
      List<String>? columns,
      String? where,
      List<Object?>? whereArgs,
      String? groupBy,
      String? having,
      String? orderBy,
      int? limit,
      int? offset,
      int? bufferSize}) {
    throw UnimplementedError();
  }

  @override
  Future<int> rawDelete(String sql, [List<Object?>? arguments]) {
    throw UnimplementedError();
  }

  @override
  Future<int> rawInsert(String sql, [List<Object?>? arguments]) {
    throw UnimplementedError();
  }

  @override
  Future<List<Map<String, Object?>>> rawQuery(String sql,
      [List<Object?>? arguments]) {
    return database.rawQuery(sql, arguments);
  }

  @override
  Future<QueryCursor> rawQueryCursor(String sql, List<Object?>? arguments,
      {int? bufferSize}) {
    throw UnimplementedError();
  }

  @override
  Future<int> rawUpdate(String sql, [List<Object?>? arguments]) {
    throw UnimplementedError();
  }

  @override
  Future<int> update(String table, Map<String, Object?> values,
      {String? where,
      List<Object?>? whereArgs,
      ConflictAlgorithm? conflictAlgorithm}) {
    throw UnimplementedError();
  }
}

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
