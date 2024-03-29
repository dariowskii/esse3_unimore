import 'package:Esse3/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Pagina in cui vedere alcune informazioni dell'app.
class InfoApp extends StatelessWidget {
  static const String id = 'infoAppScreen';

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final isTablet = deviceWidth > Constants.tabletWidth;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Esse3'),
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Padding(
            padding: isTablet
                ? EdgeInsets.symmetric(
                    vertical: 32,
                    horizontal: deviceWidth / 6,
                  )
                : const EdgeInsets.all(32),
            child: Column(
              children: [
                const Text(
                  'Esse3',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Text(
                  'Unimore',
                  style: TextStyle(
                    fontSize: 48,
                    height: 1,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'App non (ancora) ufficiale',
                ),
                const SizedBox(height: 40),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Quest'app estrapola i dati del sito https://esse3.unimore.it, per poterli vedere in maniera organizzata e pulita in un design moderno.\n\nL'app è stata sviluppata da uno stesso studente dell'ateneo UniMoRe, dopo tante sfide e problematiche che di certo non sono state facili da superare, ma alla fine siamo qua!\n\nEsse3 (Cineca) non mette a disposizione delle API per raccogliere facilmente i dati, perciò ne ho creata una ad hoc andando poi a manipolare e a gestire le stringhe.\n\n",
                    ),
                    Text(
                      'Le mie informazioni vengono salvate su qualche server?\n',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Assolutamente no! Le informazioni che vedi nell'applicazione restano salvate SOLO ed esclusivamente sul tuo dispositivo.\n\n",
                    ),
                    Text(
                      'Best Regards,\n',
                      style: TextStyle(fontSize: 18),
                    ),
                    Text('145622'),
                  ],
                ),
                //TODO: Aggiornare versione!
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: const [
                    Text(
                      'version: 1.4.2+42',
                      style: Constants.fontBold,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
