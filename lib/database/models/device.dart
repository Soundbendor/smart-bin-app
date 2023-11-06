import 'package:sqflite/sqflite.dart';
import 'package:waste_watchers/database/connection.dart';
import 'package:waste_watchers/database/model.dart';

class Device extends Model {
  String id;

  Device({required this.id});

  Device.createDefault() : id = "";

  @override
  Map<String, dynamic> toMap() {
    return {
      "id": id,
    };
  }

  @override
  String get tableName => "devices";

  @override
  String get schema => """
    (
      id VARCHAR(255) PRIMARY KEY
    )
  """;

  @override
  Future<void> delete() async {
    Database db = await getDatabaseConnection();
    await db.delete(tableName, where: "id = ?", whereArgs: [id]);
  }
}
