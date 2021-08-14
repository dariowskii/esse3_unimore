import 'package:Esse3/constants.dart';
import 'package:Esse3/screens/tasse_screen.dart';
import 'package:flutter/material.dart';

/// Card per reinderizzare l'utente in [TasseScreen].
class TasseHomeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Tasse universitarie',
                  style: Constants.fontBold20.copyWith(
                    color: Colors.white,
                  ),
                ),
                const Icon(
                  Icons.monetization_on,
                  color: Colors.white,
                ),
              ],
            ),
            const SizedBox(height: 20),
            MaterialButton(
              elevation: 0,
              onPressed: () {
                Navigator.of(context).pushNamed(TasseScreen.id);
              },
              color: Colors.white,
              textColor: Colors.redAccent,
              minWidth: double.infinity,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(50))),
              child: const Text(
                'Sei sicuro di volerle guardare?',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
