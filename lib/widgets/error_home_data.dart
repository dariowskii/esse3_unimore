import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Schermata di errore per la [HomeScreen] in caso in cui non
/// si riescano a recuperare le informazioni dell'utente.
class ErrorHomeData extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SvgPicture.asset('assets/img/networkError.svg', width: 200),
            const SizedBox(
              height: 20,
            ),
            const Text(
              'Oops..',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
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
      ),
    );
  }
}
