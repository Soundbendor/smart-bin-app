import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:waste_watchers/database/models/detection.dart';
import 'package:waste_watchers/database/models/device.dart';

// Modify this when making changes to models
const int databaseVersion = 1;

late Database _database;

abstract class Model {
  String get tableName;
  String get schema;
  Map<String, dynamic> toMap();
}

Future<void> _createTables(List<Model> models, bool isMigration) async {
  for (Model model in models) {
    await _database.transaction((txn) async {
      String temporaryTableName = "_tmp_${model.tableName}";
      List<Map<String, dynamic>> oldTableAttributes = await txn.rawQuery("""
        PRAGMA table_info(${model.tableName})
      """);

      if (isMigration) {
        await txn.execute("ALTER TABLE ${model.tableName} RENAME TO $temporaryTableName");
      }
      await txn.execute("""
        CREATE TABLE IF NOT EXISTS ${model.tableName} ${model.schema}
      """);
      if (isMigration) {
        await txn.execute("""
          INSERT INTO ${model.tableName} (${oldTableAttributes.map((e) => e["name"]).join(", ")})
          SELECT ${oldTableAttributes.map((e) => e["name"]).join(", ")} FROM $temporaryTableName
        """);
        await txn.execute("DROP TABLE IF EXISTS $temporaryTableName");
      }
    });
  }
}

Future<Database> getDatabaseConnection() async {

  List<Model> models = [
    Device.createDefault(),
    Detection.createDefault(),
  ];

  _database = await openDatabase(
    join(
      await getDatabasesPath(),
      "application.db",
    ),
    version: databaseVersion,
    onCreate: (db, version) async {
      await _createTables(models, false);
    },
    onUpgrade: (db, oldVersion, newVersion) async {
      await _createTables(models, true);
    },
  );
  return _database;
}
