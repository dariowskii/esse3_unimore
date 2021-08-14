import 'package:flutter/material.dart';

class AppelloPrenotatoModel {
  AppelloPrenotatoModel({
    @required this.nomeMateria,
    @required this.iscrizione,
    @required this.tipoEsame,
    @required this.svolgimento,
    @required this.dataAppello,
    @required this.oraAppello,
    @required this.docenti,
    @required this.linkCancellazione,
    @required this.codiceEsame,
  });

  final String nomeMateria;
  final String codiceEsame;
  final String iscrizione;
  final String tipoEsame;
  final String svolgimento;
  final String dataAppello;
  final String oraAppello;
  final String docenti;
  final String linkCancellazione;

  DateTime get dataAppelloDateTime {
    final anno = dataAppello.substring(6);
    final mese = dataAppello.substring(3, 5);
    final giorno = dataAppello.substring(0, 2);
    return DateTime.parse("$anno-$mese-$giorno");
  }

  Map<String, dynamic> get hiddensCancellazione {
    final map = <String, dynamic>{};

    var buffer = linkCancellazione.replaceFirst(
        'auth/studente/Appelli/ConfermaCancellaAppello.do?', '');
    var list = buffer.split('&');

    for (String element in list) {
      var newBuffer = element.split('=');
      map[newBuffer[0]] = newBuffer[1];
    }

    return map;
  }
}

class AppelliPrenotatiWrapper {
  AppelliPrenotatiWrapper({
    @required this.appelliTotali,
  });

  final int appelliTotali;
  final List<AppelloPrenotatoModel> appelli = [];
}
