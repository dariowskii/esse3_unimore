import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

/// Schermata di errore che appare quando la richiesta
/// della [BachecaPrenotazioniScreen] non va a buon fine.
class ReloadAppelli extends StatelessWidget {
  final Future<void> Function()? onReload;
  final double? deviceHeight, deviceWidth;

  const ReloadAppelli(
      {Key? key, this.onReload, this.deviceHeight, this.deviceWidth})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LiquidPullToRefresh(
      animSpeedFactor: 1.5,
      height: 80,
      color: Theme.of(context).primaryColorLight,
      onRefresh: onReload!,
      showChildOpacityTransition: false,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: deviceHeight! - 130,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bacheca prenotazioni',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                ),
                const Divider(),
                const SizedBox(height: 50),
                Center(
                  child: Column(
                    children: <Widget>[
                      SvgPicture.asset(
                        'assets/img/networkError.svg',
                        width: deviceWidth! * 0.7,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        'Oops..',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 32),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Ci sono problemi nel recuperare i tuoi dati, aggiorna oppure riprova tra un pò!',
                        softWrap: true,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 20,
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
