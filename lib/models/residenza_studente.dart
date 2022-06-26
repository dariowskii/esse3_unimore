import 'dart:convert';

import 'package:Esse3/utils/interfaces/codable.dart';

class ResidenzaStudente extends Codable {
  static String get sharedKey => 'residenzaStudente';

  String? _via;
  String? _cap;
  String? _citta;

  String? get via => _via;
  String? get cap => _cap;
  String? get citta => _citta;

  @override
  void decode(String data) {
    final jsonData = json.decode(data) as Map<String, String>?;
    if (jsonData != null) {
      _via = jsonData['via'];
      _cap = jsonData['cap'];
      _citta = jsonData['citta'];
    }
  }

  @override
  Map<String, dynamic> toJson() => {
        'via': _via,
        'cap': _cap,
        'citta': _citta,
      };
}
