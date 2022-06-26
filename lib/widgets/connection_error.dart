import 'package:Esse3/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Schermata di errore riguardo la connessione.
class ConnectionError extends StatelessWidget {
  final double? deviceWidth;
  final bool? isTablet;

  const ConnectionError({Key? key, this.deviceWidth, this.isTablet})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          SvgPicture.asset(
            'assets/img/networkError.svg',
            width: isTablet! ? deviceWidth! * 0.5 : deviceWidth! / 1.7,
          ),
          SizedBox(height: isTablet! ? 30 : 15),
          const Text('Errore di connessione', style: Constants.fontBold28),
          const SizedBox(height: 5),
          const Text(
            "Sembra ci siano problemi nel recuperare i tuoi dati, riaggiorna oppure riprova tra un po'!",
            style: Constants.font18,
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}
