import 'package:flutter/material.dart';

class EsameModel {
  final String nome;
  final String codiceEsame;
  final String dataEsame;
  final int crediti;
  final int voto;

  bool get studenteIdoneo => voto == -2;
  bool get superato => voto > 0;

  EsameModel({
    @required this.nome,
    @required this.codiceEsame,
    @required this.dataEsame,
    @required this.crediti,
    @required this.voto,
  });
}
