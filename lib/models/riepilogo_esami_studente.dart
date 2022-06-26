import 'dart:convert';

import 'package:Esse3/utils/interfaces/codable.dart';
import 'package:html/dom.dart';

class RiepilogoEsamiStudente extends Codable {
  String? _esamiRegistrati;
  String? _mediaAritmentica;
  String? _mediaPonderata;
  String? _cfuConseguiti;
  String? _cfuTotali;
  String? _progressoPercCfu;

  String? get esamiRegistrati => _esamiRegistrati;
  String? get mediaAritmentica => _mediaAritmentica;
  String? get mediaPonderata => _mediaPonderata;
  String? get cfuConseguiti => _cfuConseguiti;
  String? get cfuTotali => _cfuTotali;
  String? get progressoPercCfu => _progressoPercCfu;

  @override
  void decode(String data) {
    final jsonData =
        Map<String, String>.from(json.decode(data) as Map<String, dynamic>);
    _esamiRegistrati = jsonData['esamiRegistrati'];
    _mediaAritmentica = jsonData['mediaAritmentica'];
    _mediaPonderata = jsonData['mediaPonderata'];
    _cfuConseguiti = jsonData['cfuConseguiti'];
    _cfuTotali = jsonData['cfuTotali'];
    _progressoPercCfu = jsonData['progressoPercCfu'];
  }

  @override
  Map<String, dynamic> toJson() => {
        'esamiRegistrati': _esamiRegistrati,
        'mediaAritmentica': _mediaAritmentica,
        'mediaPonderata': _mediaPonderata,
        'cfuConseguiti': _cfuConseguiti,
        'cfuTotali': _cfuTotali,
        'progressoPercCfu': _progressoPercCfu,
      };

  void fromHtmlElement({required Element riepilogo}) {}
}
