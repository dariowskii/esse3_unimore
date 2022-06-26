import 'dart:convert';

import 'package:Esse3/utils/interfaces/codable.dart';

class StatusStudente extends Codable {
  String _annoAccademico;
  String _annoRegolamento;
  String _statoCarriera;
  String _corso;
  String _dipartimento;
  String _percorso;
  String _classe;
  String _durataCorso;
  String _annoCorso;
  String _ordinamento;
  String _normativa;
  String _dataImmatricolazione;

  String get annoAccademico => _annoAccademico;
  String get annoRegolamento => _annoRegolamento;
  String get statoCarriera => _statoCarriera;
  String get corso => _corso;
  String get dipartimento => _dipartimento;
  String get percorso => _percorso;
  String get classe => _classe;
  String get durataCorso => _durataCorso;
  String get annoCorso => _annoCorso;
  String get ordinamento => _ordinamento;
  String get normativa => _normativa;
  String get dataImmatricolazione => _dataImmatricolazione;

  @override
  void decode(String data) {
    final jsonData = json.decode(data) as Map<String, String>;
    if (jsonData != null) {
      _annoAccademico = jsonData['annoAccademico'];
      _annoRegolamento = jsonData['annoRegolamento'];
      _statoCarriera = jsonData['statoCarriera'];
      _corso = jsonData['corso'];
      _dipartimento = jsonData['dipartimento'];
      _percorso = jsonData['percorso'];
      _classe = jsonData['classe'];
      _durataCorso = jsonData['durataCorso'];
      _annoCorso = jsonData['annoCorso'];
      _ordinamento = jsonData['ordinamento'];
      _normativa = jsonData['normativa'];
      _dataImmatricolazione = jsonData['dataImmatricolazione'];
    }
  }

  @override
  Map<String, dynamic> toJson() => {
        'annoAccademico': _annoAccademico,
        'annoRegolamento': _annoRegolamento,
        'statoCarriera': _statoCarriera,
        'corso': _corso,
        'dipartimento': _dipartimento,
        'percorso': _percorso,
        'classe': _classe,
        'durataCorso': _durataCorso,
        'annoCorso': _annoCorso,
        'ordinamento': _ordinamento,
        'normativa': _normativa,
        'dataImmatricolazione': _dataImmatricolazione,
      };
}
