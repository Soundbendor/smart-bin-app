import 'package:sqflite/sqflite.dart';
import 'package:binsight_ai/database/connection.dart';

abstract class Model {
  String get tableName;
  String get schema;
  Map<String, dynamic> toMap();

  Future<void> save() async {
    Database db = await getDatabaseConnection();
    await db.insert(tableName, toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> delete();
}
