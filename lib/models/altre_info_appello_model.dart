import 'package:flutter/material.dart';

class AltreInfoAppelloModel {
  AltreInfoAppelloModel({
    @required this.tipoEsame,
    @required this.verbalizzazione,
    @required this.docente,
    @required this.numIscritti,
    @required this.aula,
  });

  final String tipoEsame;
  final String verbalizzazione;
  final String docente;
  final String numIscritti;
  final String aula;
}

class AltreInfoAppelloWrapper {
  final int numHiddens;
  final Map<String, String> hiddens = {};
  AltreInfoAppelloModel altreInfo;

  AltreInfoAppelloWrapper({
    @required this.numHiddens,
  });
}
