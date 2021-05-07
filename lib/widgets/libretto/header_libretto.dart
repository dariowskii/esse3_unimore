import 'package:Esse3/constants.dart';
import 'package:Esse3/widgets/libretto/grafico_libretto.dart';
import 'package:flutter/material.dart';

class HeaderLibretto extends StatelessWidget {
  const HeaderLibretto({
    Key key,
    this.darkModeOn = false,
    @required this.puntiGrafico,
  })  : assert(puntiGrafico != null),
        super(key: key);

  final bool darkModeOn;
  final List puntiGrafico;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Libretto',
          style: Constants.fontBold32.copyWith(
              color: darkModeOn
                  ? Theme.of(context).primaryColorLight
                  : Colors.white),
        ),
        Text(
          'Qui puoi vedere il tuo libretto universitario.',
          style: darkModeOn
              ? Constants.font16
              : Constants.font16.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 20),
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (puntiGrafico.isEmpty)
                  const SizedBox.shrink()
                else
                  Text(
                    puntiGrafico.isEmpty
                        ? 'Nessun esame con voto ancora'
                        : puntiGrafico.length == 1
                            ? 'Il tuo ultimo esame'
                            : 'I tuoi ultimi ${puntiGrafico.length} esami',
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 5),
            if (puntiGrafico.isEmpty)
              const Text(
                'Non ho abbastanza elementi\nper disegnare un grafico...',
                style:
                    TextStyle(fontStyle: FontStyle.italic, color: Colors.white),
                textAlign: TextAlign.center,
              )
            else
              GraficoLibretto(
                puntiGrafico: puntiGrafico,
                darkModeOn: darkModeOn,
              ),
          ],
        ),
      ],
    );
  }
}
