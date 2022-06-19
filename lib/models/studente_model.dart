import 'dart:ffi';

import 'package:Esse3/utils/interfaces/codable.dart';

class StudenteModel implements Codable {
  String _profilePicBase64;

  final String username;
  final String nomeCompleto;
  final Uint8 matricola;
  String tipoCorso;
  String profiloStudente;
  String annoCorsoCorrente;
  String dataImmatricolazione;
  String corsoDiLaurea;
  bool partTime;
  bool hasSceltaCarriera;

  String get textAvatar {
    final buffer = nomeCompleto.split(' ');
    return buffer[0].substring(0, 2) + buffer[1].substring(0, 2);
  }

  String get nomeCompletoCamel {
    var result = '';

    for (var i = 0; i < nomeCompleto.length; i++) {
      if (i == 0) {
        result += nomeCompleto[i].toUpperCase();
        continue;
      }

      if (nomeCompleto[i] == ' ') {
        i++;
        result += ' ';
        result += nomeCompleto[i].toUpperCase();
      } else {
        result += nomeCompleto[i];
      }
    }

    return result;
  }

  // Core

  StudenteModel({
    this.username,
    this.nomeCompleto,
    this.matricola,
  });

  // Getters

  Map<String, Object> toJson() => {
        'username': username,
        'nomeCompleto': nomeCompleto,
        'matricola': matricola,
        'tipoCorso': tipoCorso,
        'profiloStudente': profiloStudente,
        'annoCorsoCorrente': annoCorsoCorrente,
        'dataImmatricolazione': dataImmatricolazione,
        'corsoDiLaurea': corsoDiLaurea,
        'partTime': partTime,
        'hasSceltaCarriera': hasSceltaCarriera,
        'textAvatar': textAvatar,
        'profilePicBase64': _profilePicBase64,
      };

  @override
  void decode(String data) {
    // TODO: implement decode
  }

  @override
  String encode() {
    // TODO: implement encode
    throw UnimplementedError();
  }

  @override
  // TODO: implement jsonString
  String get jsonString => throw UnimplementedError();
}
