import 'package:Esse3/constants.dart';
import 'package:Esse3/screens/prossimi_appelli_screen.dart';
import 'package:Esse3/utils/provider.dart';
import 'package:flutter/material.dart';

/// Card per reinderizzare l'utente in [ProssimiAppelliScreen].
class ProssimiAppelliCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
              color: Colors.black12,
              offset: Offset(0, 2),
              spreadRadius: 1,
              blurRadius: 3),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Prossimi appelli',
                  style: Constants.fontBold20.copyWith(
                    color: Theme.of(context).primaryColorLight,
                  ),
                ),
                Icon(
                  Icons.mode_edit,
                  color: Theme.of(context).primaryColorLight,
                ),
              ],
            ),
            SizedBox(height: 20),
            MaterialButton(
              onPressed: () {
                Navigator.of(context)
                    .push(
                  MaterialPageRoute(
                    builder: (context) => ProssimiAppelliScreen(),
                  ),
                )
                    .then((value) {
                  Provider.getAppelliPrenotati();
                });
              },
              textColor: Colors.white,
              color: Theme.of(context).primaryColor,
              disabledColor: Theme.of(context).disabledColor,
              minWidth: double.infinity,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(50))),
              child: Text(
                'Guarda i prossimi appelli',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
