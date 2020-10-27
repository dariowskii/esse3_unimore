import 'package:flutter/cupertino.dart';

class User {
  String username;
  String full_name;
  String matricola;
  String cdl;
  String tipo_corso;
  String tipo_profilo;
  String anno_corso;
  String data_immatr;
  String part_time;
  String text_avatar;

  User(
      {@required this.username,
      @required this.full_name,
      @required this.matricola,
      @required this.cdl,
      @required this.tipo_corso,
      @required this.tipo_profilo,
      @required this.anno_corso,
      @required this.data_immatr,
      @required this.part_time,
      @required this.text_avatar});
}
