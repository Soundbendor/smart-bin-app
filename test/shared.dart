// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void testInit() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
}

/// Allows for the creation of a testable widget
///
/// Provides a [MediaQuery] with a given size and a [Scaffold] with a given child for testing.
/// This avoids errors related to the lack of a [Material] ancestor.
Widget makeTestableWidget({required Widget child, required Size size}) {
  return MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(size: size),
      child: Scaffold(body: child),
    ),
  );
}

// Taken from https://remelehane.dev/posts/widget-testing-rendeflex-overflow/
/// Ignores overflow errors in tests.
ignoreOverflowErrors(
    void Function(FlutterErrorDetails details)? originalHandler) {
  return (
    FlutterErrorDetails details, {
    bool forceReport = false,
  }) {
    // Detect overflow error.
    var exception = details.exception;
    if (exception is FlutterError) {
      if (!exception.diagnostics.any(
        (e) => e.value.toString().startsWith("A RenderFlex overflowed by"),
      )) return;
      if (!exception.diagnostics.any(
        (e) => e.value.toString().startsWith("Unable to load asset"),
      )) return;
    }

    // Ignore if is not overflow error.
    originalHandler?.call(details);
  };
}

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

  @override
  Future<T> readTransaction<T>(Future<T> Function(Transaction txn) action) {
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
