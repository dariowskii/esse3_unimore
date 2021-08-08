import 'package:flutter/material.dart';

class EsameModel {
  final String nome;
  final String codiceEsame;
  final String dataEsame;
  final String altroVoto;
  final int crediti;
  final int voto;

  bool get esameIdoneo => altroVoto != null || voto > 0;

  EsameModel({
    @required this.nome,
    @required this.codiceEsame,
    @required this.dataEsame,
    @required this.crediti,
    @required this.voto,
    this.altroVoto,
  });
}
