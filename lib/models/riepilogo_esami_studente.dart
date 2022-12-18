import 'dart:convert';

import 'package:Esse3/constants.dart';
import 'package:Esse3/utils/interfaces/codable.dart';
import 'package:html/dom.dart';

class RiepilogoEsamiStudente extends Codable {
  String? _esamiRegistrati;
  String? _mediaAritmetica;
  String? _mediaPonderata;
  String? _cfuConseguiti;
  String? _cfuTotali;
  String? _progressoPercCfu;

  String? get esamiRegistrati => _esamiRegistrati;
  String? get mediaAritmetica => _mediaAritmetica;
  String? get mediaPonderata => _mediaPonderata;
  String? get cfuConseguiti => _cfuConseguiti;
  String? get cfuTotali => _cfuTotali;
  String? get progressoPercCfu => _progressoPercCfu;

  @override
  void decode(String data) {
    final jsonData =
        Map<String, String>.from(json.decode(data) as Map<String, dynamic>);
    _esamiRegistrati = jsonData['esamiRegistrati'];
    _mediaAritmetica = jsonData['mediaAritmetica'];
    _mediaPonderata = jsonData['mediaPonderata'];
    _cfuConseguiti = jsonData['cfuConseguiti'];
    _cfuTotali = jsonData['cfuTotali'];
    _progressoPercCfu = jsonData['progressoPercCfu'];
  }

  @override
  Map<String, dynamic> toJson() => {
        'esamiRegistrati': _esamiRegistrati,
        'mediaAritmetica': _mediaAritmetica,
        'mediaPonderata': _mediaPonderata,
        'cfuConseguiti': _cfuConseguiti,
        'cfuTotali': _cfuTotali,
        'progressoPercCfu': _progressoPercCfu,
      };

  @override
  void fromJson(Map<String, dynamic> json) {
    _esamiRegistrati = json['esamiRegistrati'] as String;
    _mediaAritmetica = json['mediaAritmetica'] as String;
    _mediaPonderata = json['mediaPonderata'] as String;
    _cfuConseguiti = json['cfuConseguiti'] as String;
    _cfuTotali = json['cfuTotali'] as String;
    _progressoPercCfu = json['progressoPercCfu'] as String;
  }

  void fromHtmlElement({required Element riepilogo}) {
    final info = riepilogo
        .querySelector('dl.record-riga')
        ?.children
        .where((element) => element.localName == 'dd');
    if (info != null && info.isNotEmpty) {
      final esamiRegistrati = info.first.innerHtml;
      final regex = RegExp('[0-9]{1,}');
      final regexMedia = RegExp('[0-9.]{1,}');

      _esamiRegistrati = regex.allMatches(esamiRegistrati).first.group(0);

      // Se l'utente non ha ancora superato nessun esame, non ci sono medie
      if (_esamiRegistrati != "0") {
        final mediaAritmetica = info
            .elementAt(1)
            .innerHtml
            .replaceAll('/30${Constants.emptyHtmlSpecialChar}', '');
        _mediaAritmetica =
            regexMedia.allMatches(mediaAritmetica).first.group(0);

        final mediaPonderata = info
            .elementAt(2)
            .innerHtml
            .replaceAll('/30${Constants.emptyHtmlSpecialChar}', '');
        _mediaPonderata = regexMedia.allMatches(mediaPonderata).first.group(0);
      } else {
        _mediaAritmetica = "0";
        _mediaPonderata = "0";
      }

      final cfuConseguiti = info
          .elementAt((_esamiRegistrati == "0") ? 1 : 3)
          .innerHtml
          .replaceAll(Constants.emptyHtmlSpecialChar, '');
      final cfuMatches = regexMedia.allMatches(cfuConseguiti);
      _cfuConseguiti = cfuMatches.first.group(0);
      _cfuTotali = cfuMatches.elementAt(1).group(0);

      final progressoPercCfu = info
          .elementAt((_esamiRegistrati == "0") ? 2 : 4)
          .innerHtml
          .replaceAll(Constants.emptyHtmlSpecialChar, '');
      _progressoPercCfu =
          regexMedia.allMatches(progressoPercCfu).first.group(0);
    }
  }
}
