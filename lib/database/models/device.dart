import 'package:waste_watchers/database/connection.dart';

class Device implements Model {
  String id;

  Device({ required this.id });

  Device.createDefault() :
    id = "";

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

}
