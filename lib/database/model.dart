abstract class Model {
  String get tableName;
  String get schema;
  Map<String, dynamic> toMap();
}
