import 'dart:convert';

import 'package:Esse3/constants.dart';
import 'package:Esse3/models/studente_model.dart';
import 'package:Esse3/widgets/chip_info.dart';
import 'package:Esse3/widgets/home/animated_avatar.dart';
import 'package:Esse3/widgets/libretto_home_card.dart';
import 'package:Esse3/widgets/prossimi_appelli_card.dart';
import 'package:Esse3/widgets/tasse_home_card.dart';
import 'package:flutter/material.dart';

class HomeScreenBuilder extends StatelessWidget {
  final double deviceWidth;
  final Animation animation;
  final StudenteModel studenteModel;
  late List<String> cdl;

  HomeScreenBuilder({
    Key? key,
    required this.deviceWidth,
    required this.animation,
    required this.studenteModel,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final hasCorso = studenteModel.status?.corso != null;
    if (hasCorso) {
      cdl = studenteModel.status!.corso!.split('(');
      cdl[1] = '(${cdl[1]}';
    }
    return Column(
      children: <Widget>[
        Padding(
          padding: deviceWidth >= 390
              ? const EdgeInsets.symmetric(horizontal: 20)
              : const EdgeInsets.symmetric(horizontal: 0),
          child: Column(
            children: [
              AnimatedAvatar(
                  animation: animation, studenteModel: studenteModel),
              Text(
                studenteModel.datiPersonali?.nomeCompleto ?? 'null',
                style: Constants.fontBold28,
              ),
              const SizedBox(height: 5),
              Text(
                '- Mat. ${studenteModel.datiPersonali?.matricola} -',
                style: Constants.font16,
              ),
              const SizedBox(height: 10),
              Text(
                cdl.first,
                textAlign: TextAlign.center,
                style: Constants.fontBold32,
              ),
              const SizedBox(height: 5),
              Text(
                cdl[1],
                style: Constants.font16,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: -5,
          children: <Widget>[
            ChipInfo(
                text: 'Durata: ${studenteModel.status?.durataCorso}',
                textSize: deviceWidth >= 390 ? 13 : 10),
            ChipInfo(
                text: 'Percorso: ${studenteModel.status?.percorso}',
                textSize: deviceWidth >= 390 ? 13 : 10),
            ChipInfo(
                text: 'Anno di Corso: ${studenteModel.status?.annoCorso}',
                textSize: deviceWidth >= 390 ? 13 : 10),
            ChipInfo(
                text:
                    'Immatricolazione: ${studenteModel.status?.dataImmatricolazione}',
                textSize: deviceWidth >= 390 ? 13 : 10),
            // ChipInfo(
            //     text: 'Part Time: ${userData.data!['part_time']}',
            //     textSize: deviceWidth >= 390 ? 13 : 10),
          ],
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
