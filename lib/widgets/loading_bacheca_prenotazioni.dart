import 'package:Esse3/constants.dart';
import 'package:flutter/material.dart';

class LoadingBachecaPrenotazioni extends StatelessWidget {
  const LoadingBachecaPrenotazioni({
    Key key,
    @required this.darkModeOn,
  })  : assert(darkModeOn != null),
        super(key: key);

  final bool darkModeOn;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bacheca prenotazioni',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
          ),
          const Divider(),
          Flexible(
            child: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Constants.mainColorLighter),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'Sto scaricando i dati...',
                    style: Constants.font16.copyWith(
                        color: darkModeOn
                            ? Colors.white
                            : Constants.mainColorLighter),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
