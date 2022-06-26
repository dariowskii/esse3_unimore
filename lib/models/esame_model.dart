import 'package:flutter/material.dart';

class EsameModel {
  EsameModel({
    required this.nome,
    required this.codiceEsame,
    required this.dataEsame,
    required this.crediti,
    required this.voto,
    this.altroVoto,
  });

  final String nome;
  final String codiceEsame;
  final String dataEsame;
  final String? altroVoto;
  final int crediti;
  final int voto;

  bool get esameIdoneo => altroVoto != null || voto > 0;

  DateTime get dataEsameDateTime {
    final anno = dataEsame.substring(6);
    final mese = dataEsame.substring(3, 5);
    final giorno = dataEsame.substring(0, 2);
    return DateTime.parse("$anno-$mese-$giorno");
  }
}
