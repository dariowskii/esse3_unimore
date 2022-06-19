import 'dart:convert';

abstract class Codable {
  static String get sharedKey => '';

  String encode() => json.encode(toJson());
  void decode(String data);

  Map<String, dynamic> toJson();
}
