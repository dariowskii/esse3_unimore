import 'dart:convert';

import 'package:Esse3/constants.dart';
import 'package:Esse3/widgets/chip_info.dart';
import 'package:Esse3/widgets/home/animated_avatar.dart';
import 'package:Esse3/widgets/libretto_home_card.dart';
import 'package:Esse3/widgets/prossimi_appelli_card.dart';
import 'package:Esse3/widgets/tasse_home_card.dart';
import 'package:flutter/material.dart';

class HomeScreenBuilder extends StatelessWidget {
  final double deviceWidth;
  final Animation animation;
  final Map<String, dynamic> user;
  final List<String> cdl;

  const HomeScreenBuilder({
    Key key,
    @required this.deviceWidth,
    @required this.animation,
    @required this.user,
    @required this.cdl,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: deviceWidth >= 390
              ? const EdgeInsets.symmetric(horizontal: 20)
              : const EdgeInsets.symmetric(horizontal: 0),
          child: Column(
            children: [
              AnimatedAvatar(animation: animation, userData: user),
              Text(
                user['nome'] as String,
                style: Constants.fontBold28,
              ),
              const SizedBox(height: 5),
              Text(
                '- Mat. ${user['matricola']} -',
                style: Constants.font16,
              ),
              const SizedBox(height: 10),
              Text(
                cdl[1].toUpperCase(),
                textAlign: TextAlign.center,
                style: Constants.fontBold32,
              ),
              const SizedBox(height: 5),
              Text(cdl[0], style: Constants.font16),
              const SizedBox(height: 20),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: -5,
                children: <Widget>[
                  ChipInfo(
                      text: user['tipo_corso'] as String,
                      textSize: deviceWidth >= 390 ? 13 : 10),
                  ChipInfo(
                      text: 'Profilo: ${user['profilo_studente']}',
                      textSize: deviceWidth >= 390 ? 13 : 10),
                  ChipInfo(
                      text: 'Anno di Corso: ${user['anno_corso']}',
                      textSize: deviceWidth >= 390 ? 13 : 10),
                  ChipInfo(
                      text: 'Immatricolazione: ${user['data_imm']}',
                      textSize: deviceWidth >= 390 ? 13 : 10),
                  ChipInfo(
                      text: 'Part Time: ${user['part_time']}',
                      textSize: deviceWidth >= 390 ? 13 : 10),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const LibrettoHomeCard(),
        const SizedBox(height: 15),
        ProssimiAppelliCard(),
        const SizedBox(height: 15),
        TasseHomeCard(),
      ],
    );
  }
}
