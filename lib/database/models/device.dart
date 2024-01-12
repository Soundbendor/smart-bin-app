import 'package:sqflite/sqflite.dart';
import 'package:binsight_ai/database/connection.dart';
import 'package:binsight_ai/database/model.dart';

/// The device model.
///
/// Represents a device that is connected to the application.
class Device extends Model {

  /// The device ID.
  String id;

  Device({required this.id});

  /// Creates a blank device for testing or retrieving properties of the model.
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

  /// Finds a device by its ID.
  static Future<Device?> find(String id) async {
    Database db = await getDatabaseConnection();
    List<Map<String, dynamic>> results = await db.query(
      "devices",
      where: "id = ?",
      whereArgs: [id],
    );
    if (results.isEmpty) {
      return null;
    }
    return Device(id: results[0]["id"]);
  }

  /// Returns all devices.
  static Future<List<Device>> all() async {
    Database db = await getDatabaseConnection();
    List<Map<String, dynamic>> results = await db.query("devices");
    return results.map((result) => Device(id: result["id"])).toList();
  }

}
