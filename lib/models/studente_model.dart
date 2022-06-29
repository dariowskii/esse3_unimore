import 'dart:convert';

import 'package:Esse3/models/dati_personali_studente.dart';
import 'package:Esse3/models/riepilogo_esami_studente.dart';
import 'package:Esse3/models/status_studente.dart';
import 'package:Esse3/utils/interfaces/codable.dart';
import 'package:html/dom.dart';

class StudenteModel extends Codable {
  static String get sharedKey => 'studenteModel';

  DatiPersonaliStudente? _datiPersonali;
  StatusStudente? _status;
  RiepilogoEsamiStudente? _riepilogoEsami;

  DatiPersonaliStudente? get datiPersonali => _datiPersonali;
  StatusStudente? get status => _status;
  RiepilogoEsamiStudente? get riepilogoEsami => _riepilogoEsami;

  bool get isValid =>
      datiPersonali != null && status != null && riepilogoEsami != null;

  @override
  void decode(String data) {
    final jsonData = json.decode(data) as Map<String, dynamic>;

    final datiPersonali = jsonData['datiPersonali'] as Map<String, dynamic>?;
    final status = jsonData['status'] as Map<String, dynamic>?;
    final riepilogoEsami = jsonData['riepilogoEsami'] as Map<String, dynamic>?;
    if (datiPersonali != null) {
      _datiPersonali = DatiPersonaliStudente()
        ..fromJson(datiPersonali);
    }
    if (status != null) {
      _status = StatusStudente()..fromJson(status);
    }
    if (riepilogoEsami != null) {
      _riepilogoEsami = RiepilogoEsamiStudente()..fromJson(riepilogoEsami);
    }
  }

  @override
  Map<String, dynamic> toJson() => {
        'datiPersonali': _datiPersonali?.toJson(),
        'status': _status?.toJson(),
        'riepilogoEsami': _riepilogoEsami?.toJson(),
      };

  @override
  void fromJson(Map<String, dynamic> json) {
    
  }

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
