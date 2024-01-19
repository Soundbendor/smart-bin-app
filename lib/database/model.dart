import 'package:sqflite/sqflite.dart';
import 'package:binsight_ai/database/connection.dart';

/// The base class for models.
abstract class Model {
  /// The table name.
  String get tableName;

  /// The SQL table schema.
  String get schema;

  /// Generates a dictionary of values to be inserted into the database.
  Map<String, dynamic> toMap();

  /// Saves the model to the database.
  Future<void> save() async {
    Database db = await getDatabaseConnection();
    await db.insert(tableName, toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Deletes the model record from the database.
  Future<void> delete();
}
