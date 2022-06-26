import 'package:flutter/material.dart';

class AppelloModel {
  AppelloModel({
    required this.nomeMateria,
    required this.dataAppello,
    required this.periodoIscrizione,
    required this.descrizione,
    required this.sessione,
    required this.linkInfo,
  });

  final String nomeMateria;
  final String dataAppello;
  final String periodoIscrizione;
  final String descrizione;
  final String sessione;
  final String? linkInfo;

  DateTime get dataAppelloDateTime {
    final anno = dataAppello.substring(6);
    final mese = dataAppello.substring(3, 5);
    final giorno = dataAppello.substring(0, 2);
    return DateTime.parse("$anno-$mese-$giorno");
  }
}

class AppelliWrapper {
  AppelliWrapper({
    required this.totaleApelli,
  });

  final int totaleApelli;
  final List<AppelloModel> appelli = [];
  final List<AppelloModel> _appelliImminenti = [];

  List<AppelloModel> get appelliImminenti {
    if (_appelliImminenti.isNotEmpty) {
      return _appelliImminenti;
    }

    final appelliImminenti = <AppelloModel>[];
    final dataOggi = DateTime.now();

    for (var i = 0; i < totaleApelli; i++) {
      final appello = appelli[i];
      final diffTempo = appello.dataAppelloDateTime.difference(dataOggi);
      if (diffTempo.inDays <= 20) {
        appelliImminenti.add(appello);
      }
    }

    appelliImminenti
        .sort((a, b) => a.dataAppelloDateTime.compareTo(b.dataAppelloDateTime));

    _appelliImminenti.addAll(appelliImminenti);
    return appelliImminenti;
  }
}
