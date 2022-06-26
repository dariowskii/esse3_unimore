import 'dart:convert';

import 'package:Esse3/models/dati_personali_studente.dart';
import 'package:Esse3/models/riepilogo_esami_studente.dart';
import 'package:Esse3/models/status_studente.dart';
import 'package:Esse3/utils/interfaces/codable.dart';
import 'package:html/dom.dart';

class StudenteModel extends Codable {
  DatiPersonaliStudente? _datiPersonali;
  StatusStudente? _status;
  RiepilogoEsamiStudente? _riepilogoEsami;

  DatiPersonaliStudente? get datiPersonali => _datiPersonali;
  StatusStudente? get status => _status;
  RiepilogoEsamiStudente? get riepilogoEsami => _riepilogoEsami;

  @override
  void decode(String data) {
    final jsonData = json.decode(data) as Map<String, String>;
    final datiPersonali = jsonData['datiPersonali'];
    final status = jsonData['status'];
    final riepilogoEsami = jsonData['riepilogoEsami'];
    if (datiPersonali != null) {
      _datiPersonali = DatiPersonaliStudente()..decode(datiPersonali);
    }
    if (status != null) {
      _status = StatusStudente()..decode(status);
    }
    if (riepilogoEsami != null) {
      _riepilogoEsami = RiepilogoEsamiStudente()..decode(riepilogoEsami);
    }
  }

  @override
  Map<String, dynamic> toJson() => {
        'datiPersonali': _datiPersonali?.encode(),
        'status': _status?.encode(),
        'riepilogoEsami': _riepilogoEsami?.encode(),
      };

  void fromHtmlBody({Document? document}) {}
}
