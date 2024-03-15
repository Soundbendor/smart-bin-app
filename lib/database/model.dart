// Package imports:
import 'package:sqflite/sqflite.dart';

// Project imports:
import 'package:binsight_ai/database/connection.dart';

/// The base class for models.
abstract class Model {
  /// The table name.
  String get tableName;

  /// The SQL table schema.
  String get schema;

  /// Generates a dictionary of values to be inserted into the database.
  Map<String, dynamic> toMap();

  /// Generates a Model from a dictionary of values.
  static Model fromMap(Map<String, dynamic> map) {
    throw UnimplementedError("Must implement fromMap method");
  }

  /// Saves the model to the database.
  Future<void> save() async {
    Database db = await getDatabaseConnection();
    await db.insert(tableName, toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> update();

  /// Deletes the model record from the database.
  Future<void> delete();
}
