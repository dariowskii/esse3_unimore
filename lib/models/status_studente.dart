import 'dart:convert';

import 'package:Esse3/constants.dart';
import 'package:Esse3/extensions/string_extension.dart';
import 'package:Esse3/utils/interfaces/codable.dart';
import 'package:html/dom.dart';

class StatusStudente extends Codable {
  String? _annoAccademico;
  String? _annoRegolamento;
  String? _statoCarriera;
  String? _corso;
  String? _dipartimento;
  String? _percorso;
  String? _classe;
  String? _durataCorso;
  String? _annoCorso;
  String? _ordinamento;
  String? _normativa;
  String? _dataImmatricolazione;

  String? get annoAccademico => _annoAccademico;
  String? get annoRegolamento => _annoRegolamento;
  String? get statoCarriera => _statoCarriera;
  String? get corso => _corso;
  String? get dipartimento => _dipartimento;
  String? get percorso => _percorso;
  String? get classe => _classe;
  String? get durataCorso => _durataCorso;
  String? get annoCorso => _annoCorso;
  String? get ordinamento => _ordinamento;
  String? get normativa => _normativa;
  String? get dataImmatricolazione => _dataImmatricolazione;

  @override
  void decode(String data) {
    final jsonData =
        Map<String, String>.from(json.decode(data) as Map<String, dynamic>);
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

  @override
  void fromJson(Map<String, dynamic> json) {
    final jsonData = Map<String, String>.from(json);
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

  void fromHtmlElement({required Element status}) {
    final annoInfo = status.querySelector('#gu-textStatusStudente');
    if (annoInfo != null) {
      final info =
          annoInfo.children.where((element) => element.localName == 'b');
      if (info.isNotEmpty) {
        _annoAccademico = info.first.innerHtml.replaceAll('<br>', '').trim();
        _annoRegolamento =
            info.elementAt(1).innerHtml.replaceAll('<br>', '').trim();
        _statoCarriera = info.elementAt(2).innerHtml.camelCase();
      }
    }
    final corsoInfo = status.querySelector('#gu-textStatusStudenteCorsoFac');
    if (corsoInfo != null) {
      _corso = corsoInfo
          .querySelector('#gu-textStatusStudenteCorsoFac-text-link2')
          ?.innerHtml;
      _dipartimento = corsoInfo
          .querySelector('#gu-textStatusStudenteCorsoFac-text-link4')
          ?.innerHtml;
      final percorso = corsoInfo
          .querySelector('#gu-textStatusStudenteCorsoFac-text-link6')
          ?.innerHtml
          .replaceAll(Constants.emptyHtmlSpecialChar, '');

      if (percorso != null) {
        final regex = RegExp('[a-zA-Z0-9]{1,}');
        _percorso =
            regex.allMatches(percorso).elementAt(0).group(0)?.camelCase();
      }
      final info =
          corsoInfo.children.where((element) => element.localName == 'b');
      if (info.isNotEmpty) {
        _classe = info.last.innerHtml.replaceAll('<br>', '').trim();
      }
    }

    final statusIscrizione =
        status.querySelector('#gu-boxStatusStudenteIscriz1')?.children.first;
    if (statusIscrizione != null) {
      final info = statusIscrizione.children
          .where((element) => element.localName == 'b');
      if (info.isNotEmpty) {
        final durata =
            info.first.innerHtml.replaceAll(Constants.emptyHtmlSpecialChar, '');
        final regex = RegExp('[a-zA-Z0-9]{1,}');
        var durataCompose = '';
        for (final match in regex.allMatches(durata)) {
          final word = match.group(0);
          if (word != null) {
            if (durataCompose.isEmpty) {
              durataCompose += word;
            } else {
              durataCompose += ' $word';
            }
          }
        }
        _durataCorso = durataCompose;

        final annoDiCorso = statusIscrizione.children
            .where((element) => element.localName == 'b')
            .elementAt(1)
            .innerHtml
            .replaceAll('\n', '')
            .trim();
        final regexAnno = RegExp('[a-zA-Z0-9°()]{2,}');
        var annoCompose = '';
        for (final match in regexAnno.allMatches(annoDiCorso)) {
          final word = match.group(0);
          if (word != null) {
            if (annoCompose.isEmpty) {
              annoCompose += word;
            } else {
              annoCompose += ' $word';
            }
          }
        }
        _annoCorso = annoCompose;
      }
    }

    final statusIscrizione2 =
        status.querySelector('#gu-boxStatusStudenteIscriz2')?.children.first;
    if (statusIscrizione2 != null) {
      final info = statusIscrizione2.children
          .where((element) => element.localName == 'b');
      if (info.isNotEmpty) {
        final ordinamento =
            info.first.innerHtml.replaceAll(Constants.emptyHtmlSpecialChar, '');
        final regex = RegExp('[0-9]{4}');
        _ordinamento = regex.allMatches(ordinamento).elementAt(0).group(0);
        _normativa = info.elementAt(1).innerHtml;
      }
    }

    _dataImmatricolazione = status
        .querySelector('#gu-textStatusStudenteImma')
        ?.children
        .first
        .innerHtml;
  }
}
