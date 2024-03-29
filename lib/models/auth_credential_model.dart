import 'dart:convert';

import 'package:Esse3/utils/interfaces/codable.dart';

class AuthCredential extends Codable {
  static String get sharedKey => 'authCredential';

  String? _username;
  String? _password;

  String? get username => _username;
  String? get password => _password;

  AuthCredential({
    String? username,
    String? password,
  })  : _username = username,
        _password = password;

  @override
  void decode(String data) {
    final jsonData =
        Map<String, String>.from(json.decode(data) as Map<String, dynamic>);
    _username = jsonData['username'];
    _password = jsonData['password'];
  }

  @override
  Map<String, dynamic> toJson() => {
        'username': _username,
        'password': _password,
      };

  @override
  void fromJson(Map<String, dynamic> json) {
    _username = json['username'] as String;
    _password = json['password'] as String;
  }
}
