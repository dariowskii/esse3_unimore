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
  });

  final String nomeMateria;
  final String iscrizione;
  final String tipoEsame;
  final String svolgimento;
  final String dataAppello;
  final String oraAppello;
  final String docenti;
  final String linkCancellazione;
}

class AppelliPrenotatiWrapper {
  AppelliPrenotatiWrapper({
    @required this.appelliTotali,
  });

  final int appelliTotali;
  final List<AppelloPrenotatoModel> appelli = [];
}
