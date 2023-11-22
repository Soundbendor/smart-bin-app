import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:binsight_ai/database/model.dart';
import 'package:binsight_ai/database/models/detection.dart';
import 'package:binsight_ai/database/models/device.dart';

// Modify this when making changes to models
// The entire app should be restarted when changing the schema
const int databaseVersion = 1;

Database? _database;

Future<void> _createTables(
    Database database, List<Model> models, bool isMigration) async {
  for (Model model in models) {
    await database.transaction((txn) async {
      String temporaryTableName = "_tmp_${model.tableName}";
      List<Map<String, dynamic>> oldTableAttributes = await txn.rawQuery("""
        PRAGMA table_info(${model.tableName})
      """);

      if (isMigration) {
        debugPrint("Migrating ${model.tableName}");
        await txn.execute(
            "ALTER TABLE ${model.tableName} RENAME TO $temporaryTableName");
      }
      debugPrint("Creating ${model.tableName}");
      await txn.execute("""
        CREATE TABLE IF NOT EXISTS ${model.tableName} ${model.schema}
      """);
      if (isMigration) {
        debugPrint("Migrating ${model.tableName} - Copying data");
        await txn.execute("""
          INSERT INTO ${model.tableName} (${oldTableAttributes.map((e) => e["name"]).join(", ")})
          SELECT ${oldTableAttributes.map((e) => e["name"]).join(", ")} FROM $temporaryTableName
        """);
        await txn.execute("DROP TABLE IF EXISTS $temporaryTableName");
      }
    });
  }
}

/// Creates the database connection if it doesn't exist and returns it.
Future<Database> getDatabaseConnection() async {
  List<Model> models = [
    Device.createDefault(),
    Detection.createDefault(),
  ];

  if (_database != null) {
    return _database!;
  }

  _database = await openDatabase(
    join(
      await getDatabasesPath(),
      "application.db",
    ),
    version: databaseVersion,
    onCreate: (db, version) async {
      await _createTables(db, models, false);
    },
    onUpgrade: (db, oldVersion, newVersion) async {
      await _createTables(db, models, true);
    },
  );
  return _database!;
}

Future<void> closeDatabaseConnection() async {
  if (_database != null) {
    await _database!.close();
    _database = null;
  }
}
