import 'dart:convert';

import 'package:Esse3/extensions/string_extension.dart';
import 'package:Esse3/utils/interfaces/codable.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';

class ResidenzaStudente extends Codable {
  static String get sharedKey => 'residenzaStudente';

  String? _indirizzo;
  String? _citta;
  String? _telefono;

  String? get indirizzo => _indirizzo;
  String? get citta => _citta;
  String? get telefono => _telefono;

  @override
  void decode(String data) {
    final jsonData =
        Map<String, String>.from(json.decode(data) as Map<String, dynamic>);
    _indirizzo = jsonData['indirizzo'];
    _citta = jsonData['citta'];
    _telefono = jsonData['telefono'];
  }

  @override
  Map<String, dynamic> toJson() => {
        'indirizzo': _indirizzo,
        'citta': _citta,
        'telefono': _telefono,
      };

  void fromHtmlElement({required Element residenza}) {
    final tmp = residenza.innerHtml.split('<br>');
    if (tmp.length <= 2) {
      return;
    }

    final indirizzo = parseFragment(tmp[0]).text?.cleanFromEntities();
    final capCitta = parseFragment(tmp[1]).text?.cleanFromEntities();
    final tel = parseFragment(tmp[2]).text?.cleanFromEntities();

    if (indirizzo != null) {
      _indirizzo = indirizzo;
    }
    if (capCitta != null) {
      _citta = capCitta;
    }
    if (tel != null) {
      _telefono = tel;
    }
  }
}
