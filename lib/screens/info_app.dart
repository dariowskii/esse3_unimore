import 'package:flutter/material.dart';

class InfoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Esse3"),
        brightness: Brightness.light,
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              children: <Widget>[
                Text(
                  "Esse3",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "Unimore",
                  style: TextStyle(
                    fontSize: 48,
                    height: 1,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "App non (ancora) ufficiale",
                ),
                SizedBox(height: 40),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                        "Quest'app estrapola i dati del sito https://esse3.unimore.it, per poterli vedere in maniera organizzata e pulita in un design moderno.\n\nL'app è stata sviluppata da uno stesso studente dell'ateneo UniMoRe, dopo tante sfide e problematiche che di certo non sono state facili da superare, ma alla fine siamo qua!\n\nEsse3 (Cineca) non mette a disposizione delle API per raccogliere facilmente i dati, perciò ne ho creata una ad hoc andando poi a manipolare e a gestire le stringhe.\n\n"),
                    Text(
                      "Le mie informazioni vengono salvate su qualche server?\n",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                        "Assolutamente no! Le informazioni che vedi nell'applicazione restano salvate SOLO ed esclusivamente sul tuo dispositivo.\n\n"),
                    Text(
                      "Best Regards,\n",
                      style: TextStyle(fontSize: 18),
                    ),
                    Text("145622"),
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
