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
        'datiPersonali': _datiPersonali?.toJson(),
        'status': _status?.toJson(),
        'riepilogoEsami': _riepilogoEsami?.toJson(),
      };

  void fromHtmlBody({
    required Document document,
    String? matricola,
    String? profilePicture,
  }) {
    final datiPersonali = document
        .getElementById('gu-hpstu-boxDatiPersonali')
        ?.querySelector('.record-riga');
    final status = document.getElementById('gu-homepagestudente-cp2Child');
    final riepilogoEsami = document.getElementById('gu-boxRiepilogoEsami');
    if (datiPersonali != null) {
      _datiPersonali = DatiPersonaliStudente()
        ..fromHtmlElement(
          element: datiPersonali,
          matricola: matricola,
          profilePicture: profilePicture,
        );
    }
    if (status != null) {
      _status = StatusStudente()..fromHtmlElement(status: status);
    }
    if (riepilogoEsami != null) {
      _riepilogoEsami = RiepilogoEsamiStudente()
        ..fromHtmlElement(riepilogo: riepilogoEsami);
    }
  }
}
