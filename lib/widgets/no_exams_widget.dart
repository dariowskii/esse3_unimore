import 'package:Esse3/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Schermata in cui non ci sono esami in [ProssimiAppelliScreen].
class NoExams extends StatelessWidget {
  final double deviceWidth;
  final bool isTablet;

  const NoExams({Key key, this.deviceWidth, this.isTablet}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          SvgPicture.asset(
            'assets/img/party.svg',
            width: isTablet ? deviceWidth * 0.6 : deviceWidth / 1.7,
          ),
          SizedBox(height: isTablet ? 30 : 15),
          Text('Nessun appello', style: Constants.fontBold28),
          const SizedBox(height: 10),
          Text(
            'Sembra non ci siano appelli, fantastico!',
            style: Constants.font18,
            textAlign: TextAlign.center,
          ),
          Text(
            'Adesso scappa finchè sei in tempo',
            style: Constants.font14,
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}
