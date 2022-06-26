import 'dart:convert';

import 'package:Esse3/models/residenza_studente.dart';
import 'package:Esse3/utils/interfaces/codable.dart';

class DatiPersonaliStudente extends Codable {
  static String get sharedKey => 'datiPersonaliStudente';

  String _nomeCompleto;
  String _matricola;
  ResidenzaStudente _residenza;
  String _emailPersonale;
  String _emailAteneo;
  String _profilePicture;

  String get nomeCompleto => _nomeCompleto;
  String get matricola => _matricola;
  ResidenzaStudente get residenza => _residenza;
  String get emailPersonale => _emailPersonale;
  String get emailAteneo => _emailAteneo;
  String get profilePicture => _profilePicture;

  String get textAvatar {
    final buffer = _nomeCompleto.split(' ');
    if (buffer.length > 1) {
      return buffer[0].substring(0, 2) + buffer[1].substring(0, 2);
    }

    return buffer[0].substring(0, 2);
  }

  @override
  void decode(String data) {
    final jsonData = json.decode(data) as Map<String, dynamic>;
    if (jsonData != null) {
      _nomeCompleto = jsonData['nomeCompleto'] as String;
      _matricola = jsonData['matricola'] as String;
      _residenza = ResidenzaStudente()..decode(jsonData['residenza'] as String);
      _emailPersonale = jsonData['emailPersonale'] as String;
      _emailAteneo = jsonData['emailAteneo'] as String;
      _profilePicture = jsonData['profilePicture'] as String;
    }
  }

  @override
  Map<String, dynamic> toJson() => {
        'nomeCompleto': _nomeCompleto,
        'matricola': _matricola,
        'residenza': _residenza.encode(),
        'emailPersonale': _emailPersonale,
        'emailAteneo': _emailAteneo,
        'profilePicture': _profilePicture,
      };
}
