import 'package:Esse3/constants.dart';
import 'package:Esse3/widgets/chip_info.dart';
import 'package:Esse3/widgets/error_home_data.dart';
import 'package:Esse3/widgets/home/animated_avatar.dart';
import 'package:Esse3/widgets/libretto_home_card.dart';
import 'package:Esse3/widgets/prossimi_appelli_card.dart';
import 'package:Esse3/widgets/tasse_home_card.dart';
import 'package:flutter/material.dart';

class FutureHomeScreen extends StatelessWidget {
  FutureHomeScreen({
    Key? key,
    required this.userFuture,
    required this.controllerAnimation,
    required this.animation,
    required this.deviceWidth,
  }) : super(key: key);

  final Future<Map<String, dynamic>?>? userFuture;
  final AnimationController? controllerAnimation;
  final Animation? animation;
  final double deviceWidth;
  late List<String> cdl;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: userFuture,
      builder: (context, userData) {
        switch (userData.connectionState) {
          case ConnectionState.none:
            return ErrorHomeData();
          case ConnectionState.waiting:
            return const Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(Constants.mainColorDarker),
              ),
            );
          case ConnectionState.active:
          case ConnectionState.done:
            if (!userData.hasData) return ErrorHomeData();
            cdl = userData.data!['corso_stud'].toString().split('] - ');
            cdl[0] += ']';
            controllerAnimation!.forward();
            return Column(
              children: <Widget>[
                Padding(
                  padding: deviceWidth >= 390
                      ? const EdgeInsets.symmetric(horizontal: 20)
                      : const EdgeInsets.symmetric(horizontal: 0),
                  child: Column(
                    children: [
                      AnimatedAvatar(
                          animation: animation, userData: userData.data!),
                      Text(
                        userData.data!['nome_studente'] as String,
                        style: Constants.fontBold28,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '- Mat. ${userData.data!['matricola']} -',
                        style: Constants.font16,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        cdl[1].toUpperCase(),
                        textAlign: TextAlign.center,
                        style: Constants.fontBold32,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        cdl[0],
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
                        text: userData.data!['tipo_corso'] as String?,
                        textSize: deviceWidth >= 390 ? 13 : 10),
                    ChipInfo(
                        text: 'Profilo: ${userData.data!['profilo_studente']}',
                        textSize: deviceWidth >= 390 ? 13 : 10),
                    ChipInfo(
                        text: 'Anno di Corso: ${userData.data!['anno_corso']}',
                        textSize: deviceWidth >= 390 ? 13 : 10),
                    ChipInfo(
                        text: 'Immatricolazione: ${userData.data!['data_imm']}',
                        textSize: deviceWidth >= 390 ? 13 : 10),
                    ChipInfo(
                        text: 'Part Time: ${userData.data!['part_time']}',
                        textSize: deviceWidth >= 390 ? 13 : 10),
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
          default:
            return ErrorHomeData();
        }
      },
    );
  }
}
