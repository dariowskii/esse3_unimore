import 'dart:io';

import 'package:Esse3/constants.dart';
import 'package:Esse3/screens/screens.dart';
import 'package:Esse3/utils/provider.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';

/// Chip utilizzata per le info primarie della [HomeScreen].
class ChipInfo extends StatelessWidget {
  /// Testo della chip.
  final String text;

  /// Grandezza del font della chip.
  final double textSize;

  ChipInfo({this.text = "null", this.textSize = 14});

  @override
  Widget build(BuildContext context) {
    return Chip(
      backgroundColor: Theme.of(context).primaryColor,
      label: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: textSize,
        ),
      ),
    );
  }
}

/// Schermata di errore per la [HomeScreen] in caso in cui non
/// si riescano a recuperare le informazioni dell'utente.
class ErrorHomeData extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(32.0),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            SvgPicture.asset('assets/img/networkError.svg', width: 200),
            SizedBox(
              height: 20,
            ),
            Text(
              "Oops..",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
            ),
            SizedBox(height: 10),
            Text(
              "Ci sono problemi nel recuperare i tuoi dati, aggiorna oppure riprova tra un pò!",
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

/// Card in cui è possibile richiedere le informazioni del libretto,
/// utilizzata nella [HomeScreen].
class LibrettoHomeCard extends StatefulWidget {
  const LibrettoHomeCard({
    Key key,
  }) : super(key: key);

  @override
  _LibrettoHomeCardState createState() => _LibrettoHomeCardState();
}

class _LibrettoHomeCardState extends State<LibrettoHomeCard> {
  /// Future del libretto.
  Future<Map> _libretto;

  /// Questo valore serve per gestire la visualizzazione nella card.
  bool _isRequestedLibretto = false;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  "Libretto",
                  style: Constants.fontBold20.copyWith(
                    color: Theme.of(context).primaryColorLight,
                  ),
                ),
                Icon(
                  Icons.book,
                  color: Theme.of(context).primaryColorLight,
                ),
              ],
            ),
            const SizedBox(height: 20),
            _isRequestedLibretto
                ? FutureBuilder<Map>(
                    future: _libretto,
                    builder: (_, libretto) {
                      switch (libretto.connectionState) {
                        case ConnectionState.none:
                          return ErrorLibretto(libretto: _libretto);
                        case ConnectionState.waiting:
                          return Column(
                            children: <Widget>[
                              Text(
                                "Sto recuperando i tuoi dati...",
                              ),
                              SizedBox(height: 10),
                              LinearProgressIndicator(
                                backgroundColor: Colors.transparent,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Constants.mainColor),
                              ),
                            ],
                          );
                        case ConnectionState.active:
                        case ConnectionState.done:
                          if (libretto.data == null ||
                              !libretto.data["success"])
                            return ErrorLibretto(libretto: _libretto);
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              RichText(
                                text: TextSpan(
                                  text: libretto.data["superati"].toString(),
                                  style: TextStyle(
                                    fontFamily: "SF Pro",
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        .color,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: " su ",
                                      style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                    TextSpan(
                                      text: libretto.data["totali"].toString(),
                                    ),
                                    TextSpan(
                                      text: " superati. ",
                                      style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                    libretto.data["superati"] == 0
                                        ? TextSpan(
                                            text:
                                                "Il cammino è lungo, ma ce la farai!",
                                          )
                                        : libretto.data["superati"] ==
                                                libretto.data["totali"]
                                            ? TextSpan(
                                                text:
                                                    "Che la Sbronza sia con te! 🍻",
                                              )
                                            : libretto.data["superati"] <=
                                                    libretto.data["totali"] / 2
                                                ? TextSpan(
                                                    text: "Continua così!",
                                                  )
                                                : libretto.data["superati"] >
                                                        libretto.data[
                                                                "totali"] /
                                                            2
                                                    ? TextSpan(
                                                        text:
                                                            "Ci sei quasi, dai!",
                                                      )
                                                    : TextSpan(
                                                        text: "",
                                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Stack(
                                alignment: Alignment.center,
                                children: <Widget>[
                                  Container(
                                    height: 12,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Theme.of(context)
                                              .primaryColorLight,
                                          width: 2),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(20)),
                                      color: Theme.of(context).cardColor,
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 4),
                                      child: LayoutBuilder(
                                        builder: (BuildContext context,
                                            BoxConstraints constraints) {
                                          return Container(
                                            height: 5,
                                            width: (constraints.maxWidth /
                                                libretto.data["totali"] *
                                                libretto.data["superati"]),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .primaryColorLight,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(20)),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: MaterialButton(
                                      minWidth: double.infinity,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(50)),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                LibrettoScreen(
                                              libretto: libretto.data,
                                            ),
                                          ),
                                        );
                                      },
                                      textColor: Colors.white,
                                      color: Theme.of(context).primaryColor,
                                      child: Text(
                                        "Guarda Libretto",
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  IconButton(
                                      icon: Icon(Icons.refresh),
                                      onPressed: () {
                                        setState(() {
                                          _libretto = Provider.getLibretto();
                                        });
                                      }),
                                ],
                              ),
                            ],
                          );
                        default:
                          return ErrorLibretto(libretto: _libretto);
                      }
                    })
                : MaterialButton(
                    minWidth: double.infinity,
                    onPressed: () async {
                      setState(() {
                        _libretto = Provider.getLibretto();
                        _isRequestedLibretto = !_isRequestedLibretto;
                      });
                    },
                    textColor: Colors.white,
                    color: Theme.of(context).primaryColor,
                    disabledColor: Theme.of(context).disabledColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(50))),
                    child: Text(
                      "Scarica info",
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

/// Widget di errore in caso in cui non si riesca a caricare il libretto
/// in [LibrettoHomeCard].
class ErrorLibretto extends StatefulWidget {
  /// Future del libretto da ricaricare.
  Future<Map> libretto;

  ErrorLibretto({Key key, this.libretto}) : super(key: key);
  @override
  _ErrorLibrettoState createState() => _ErrorLibrettoState();
}

class _ErrorLibrettoState extends State<ErrorLibretto> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          children: [
            Icon(
              Icons.error,
              color: Colors.redAccent,
            ),
            SizedBox(width: 5),
            Text(
              "Errore nel recuperare i dati!",
            ),
          ],
        ),
        IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                widget.libretto = Provider.getLibretto();
              });
            })
      ],
    );
  }
}

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
                  "Prossimi appelli",
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
                "Guarda i prossimi appelli",
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card per reinderizzare l'utente in [TasseScreen].
class TasseHomeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.all(Radius.circular(10)),
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
                  "Tasse universitarie",
                  style: Constants.fontBold20.copyWith(
                    color: Colors.white,
                  ),
                ),
                Icon(
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(50))),
              child: Text(
                "Sei sicuro di volerle guardare?",
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card con poche informazioni sull'appello, utilizzata per gli appelli
/// imminenti in [ProssimiAppelliScreen].
class CardAppelloImminente extends StatelessWidget {
  final String nomeAppello;
  final String dataAppello;
  final String descrizione;

  /// Serve per gestire il layout del tablet.
  final bool isTablet;

  /// Larghezza del dispositivo. Serve per gestire il layout del tablet.
  final double deviceWidth;

  const CardAppelloImminente(
      {Key key,
      this.nomeAppello,
      this.dataAppello,
      this.descrizione,
      this.isTablet,
      this.deviceWidth})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      width: isTablet ? 350 : deviceWidth - 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset.zero,
            blurRadius: 5,
            spreadRadius: 2,
          )
        ],
        color: Theme.of(context).cardColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            nomeAppello.length > 30
                ? nomeAppello.substring(0, 28) + "..."
                : nomeAppello,
            style: Constants.fontBold20
                .copyWith(color: Theme.of(context).primaryColorLight),
          ),
          SizedBox(height: 5),
          RichText(
            text: TextSpan(
                text: "Data appello: ",
                style: TextStyle(
                  fontFamily: "SF Pro",
                  color: Theme.of(context).textTheme.bodyText1.color,
                ),
                children: [
                  TextSpan(text: dataAppello, style: Constants.fontBold18)
                ]),
          ),
          SizedBox(height: 10),
          RichText(
            text: TextSpan(
                text: "Descrizione: ",
                style: TextStyle(
                  fontFamily: "SF Pro",
                  color: Theme.of(context).textTheme.bodyText1.color,
                ),
                children: [
                  TextSpan(text: descrizione, style: Constants.fontBold)
                ]),
          ),
        ],
      ),
    );
  }
}

/// Card dell'appello con tutte le informazioni necessarie per prenotarsi,
/// utilizzata in [ProssimiAppelliScreen].
class CardAppello extends StatefulWidget {
  final String nomeAppello;
  final String dataAppello;
  final String descrizione;
  final String periodoIscrizioni;
  final String sessione;

  /// Serve poi per richiedere i parametri per la prenotazione dell'appello.
  final String linkInfo;

  const CardAppello(
      {Key key,
      this.nomeAppello,
      this.dataAppello,
      this.descrizione,
      this.periodoIscrizioni,
      this.sessione,
      this.linkInfo})
      : super(key: key);

  @override
  _CardAppelloState createState() => _CardAppelloState();
}

class _CardAppelloState extends State<CardAppello> {
  Future<Map> _altreInfo;
  bool _isRequestedAltreInfo = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(16),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset.zero,
            blurRadius: 5,
            spreadRadius: 2,
          )
        ],
        color: Theme.of(context).cardColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.nomeAppello,
            style: Constants.fontBold20
                .copyWith(color: Theme.of(context).primaryColorLight),
          ),
          SizedBox(height: 5),
          RichText(
            text: TextSpan(
                text: "Data appello: ",
                style: TextStyle(
                  fontFamily: "SF Pro",
                  color: Theme.of(context).textTheme.bodyText1.color,
                ),
                children: [
                  TextSpan(
                      text: widget.dataAppello, style: Constants.fontBold18)
                ]),
          ),
          SizedBox(height: 10),
          RichText(
            text: TextSpan(
                text: "Descrizione: ",
                style: TextStyle(
                  fontFamily: "SF Pro",
                  color: Theme.of(context).textTheme.bodyText1.color,
                ),
                children: [
                  TextSpan(text: widget.descrizione, style: Constants.fontBold)
                ]),
          ),
          RichText(
            text: TextSpan(
                text: "Periodo iscrizioni: ",
                style: TextStyle(
                  fontFamily: "SF Pro",
                  color: Theme.of(context).textTheme.bodyText1.color,
                ),
                children: [
                  TextSpan(
                      text: widget.periodoIscrizioni, style: Constants.fontBold)
                ]),
          ),
          RichText(
            text: TextSpan(
                text: "Sessione: ",
                style: TextStyle(
                  fontFamily: "SF Pro",
                  color: Theme.of(context).textTheme.bodyText1.color,
                ),
                children: [
                  TextSpan(text: widget.sessione, style: Constants.fontBold)
                ]),
          ),
          SizedBox(height: 10),
          _isRequestedAltreInfo
              ? FutureBuilder(
                  future: _altreInfo,
                  builder: (context, altreInfo) {
                    switch (altreInfo.connectionState) {
                      case ConnectionState.none:
                        return Column(
                          children: [
                            Row(
                              children: <Widget>[
                                Icon(
                                  Icons.error,
                                  color: Colors.redAccent,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  "Errore nel recuperare i dati!",
                                ),
                                Expanded(child: Container()),
                                IconButton(
                                    icon: Icon(Icons.refresh),
                                    onPressed: () {
                                      setState(() {
                                        _altreInfo = Provider.getInfoAppello(
                                            widget.linkInfo);
                                      });
                                    })
                              ],
                            ),
                            MaterialButton(
                              minWidth: double.infinity,
                              color: Theme.of(context).primaryColorLight,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text("IMPOSTA PROMEMORIA",
                                  style: TextStyle(color: Colors.white)),
                              onPressed: () {
                                final Event event = Event(
                                  title:
                                      'Appello: ${widget.nomeAppello} (${widget.descrizione} - ${widget.dataAppello})',
                                  description:
                                      "Non dimenticarti di prenotare l'esame e in bocca al lupo!",
                                  location: "Esse3",
                                  startDate: DateTime.parse(widget.dataAppello
                                              .substring(6) +
                                          widget.dataAppello.substring(3, 5) +
                                          widget.dataAppello.substring(0, 2))
                                      .subtract(Duration(days: 7))
                                      .add(Duration(hours: 10)),
                                  endDate: DateTime.parse(widget.dataAppello
                                              .substring(6) +
                                          widget.dataAppello.substring(3, 5) +
                                          widget.dataAppello.substring(0, 2))
                                      .subtract(Duration(days: 6)),
                                );
                                Add2Calendar.addEvent2Cal(event);
                              },
                            )
                          ],
                        );
                      case ConnectionState.active:
                      case ConnectionState.waiting:
                        return Column(
                          children: <Widget>[
                            SizedBox(
                              height: 16,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CupertinoActivityIndicator(),
                                SizedBox(width: 10),
                                Text(
                                  "Sto scaricando le info...",
                                  style: TextStyle(fontStyle: FontStyle.italic),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            MaterialButton(
                              minWidth: double.infinity,
                              color: Theme.of(context).primaryColorLight,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Text("IMPOSTA PROMEMORIA",
                                  style: TextStyle(color: Colors.white)),
                              onPressed: () {
                                final Event event = Event(
                                  title:
                                      'Appello: ${widget.nomeAppello} (${widget.descrizione} - ${widget.dataAppello})',
                                  description:
                                      "Non dimenticarti di prenotare l'esame e in bocca al lupo!",
                                  location: "Esse3",
                                  startDate: DateTime.parse(widget.dataAppello
                                              .substring(6) +
                                          widget.dataAppello.substring(3, 5) +
                                          widget.dataAppello.substring(0, 2))
                                      .subtract(Duration(days: 7))
                                      .add(Duration(hours: 10)),
                                  endDate: DateTime.parse(widget.dataAppello
                                              .substring(6) +
                                          widget.dataAppello.substring(3, 5) +
                                          widget.dataAppello.substring(0, 2))
                                      .subtract(Duration(days: 6)),
                                );
                                Add2Calendar.addEvent2Cal(event);
                              },
                            )
                          ],
                        );
                      case ConnectionState.done:
                        if (altreInfo.data == null ||
                            !altreInfo.data["success"])
                          return Text("Sembra non ci siano risultati...");
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                text: "Tipo esame: ",
                                style: TextStyle(
                                    fontFamily: "SF Pro",
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        .color),
                                children: [
                                  TextSpan(
                                      text: altreInfo.data["tipo_esame"],
                                      style: Constants.fontBold),
                                ],
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                text: "Verbalizzazione: ",
                                style: TextStyle(
                                    fontFamily: "SF Pro",
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        .color),
                                children: [
                                  TextSpan(
                                      text: altreInfo.data["verbalizzazione"],
                                      style: Constants.fontBold),
                                ],
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                text: "Aula: ",
                                style: TextStyle(
                                    fontFamily: "SF Pro",
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        .color),
                                children: [
                                  TextSpan(
                                      text: altreInfo.data["aula"],
                                      style: Constants.fontBold),
                                ],
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                text: "Numero iscritti: ",
                                style: TextStyle(
                                    fontFamily: "SF Pro",
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        .color),
                                children: [
                                  TextSpan(
                                      text: altreInfo.data["num_iscritti"],
                                      style: Constants.fontBold),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Docente: ${altreInfo.data["docente"]}",
                              style: Constants.fontBold,
                              textAlign: TextAlign.left,
                            ),
                            SizedBox(height: 15),
                            Row(
                              children: [
                                altreInfo.data["tabellaHidden"] != null
                                    ? Flexible(
                                        child: MaterialButton(
                                          padding: const EdgeInsets.all(0),
                                          minWidth: double.infinity,
                                          color: Colors.green,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                          ),
                                          child: Text("PRENOTA",
                                              style: TextStyle(
                                                  color: Colors.white)),
                                          onPressed: () {
                                            showDialog(
                                                context: context,
                                                builder: (context) {
                                                  if (Platform.isIOS)
                                                    return CupertinoAlertDialog(
                                                      title: Text(
                                                        "Prenotazione appello",
                                                        style: TextStyle(
                                                            fontFamily:
                                                                "SF Pro"),
                                                      ),
                                                      content: Text(
                                                        "Sei sicuro di volerti prenotare?",
                                                        style: TextStyle(
                                                            fontFamily:
                                                                "SF Pro"),
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          child: Text(
                                                            "Si",
                                                            style: Constants
                                                                .font16,
                                                          ),
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                            showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (context) {
                                                                  return WillPopScope(
                                                                    onWillPop:
                                                                        () async =>
                                                                            null,
                                                                    child:
                                                                        CupertinoAlertDialog(
                                                                      content:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceEvenly,
                                                                        children: [
                                                                          CupertinoActivityIndicator(),
                                                                          const SizedBox(
                                                                              width: 10),
                                                                          Text(
                                                                            "Attendi un secondo...",
                                                                            style:
                                                                                TextStyle(fontStyle: FontStyle.italic),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  );
                                                                });
                                                            Provider.prenotaAppello(
                                                                    altreInfo
                                                                        .data)
                                                                .then((result) {
                                                              if (result !=
                                                                      null &&
                                                                  result[
                                                                      "success"]) {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                                showDialog(
                                                                    context:
                                                                        context,
                                                                    builder:
                                                                        (context) {
                                                                      return CupertinoAlertDialog(
                                                                        content:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceEvenly,
                                                                          children: [
                                                                            Icon(
                                                                              Icons.check,
                                                                              color: Colors.green,
                                                                            ),
                                                                            const SizedBox(width: 10),
                                                                            Text("Prenotazione effettuata!"),
                                                                          ],
                                                                        ),
                                                                      );
                                                                    });
                                                                Future.delayed(
                                                                    Duration(
                                                                        seconds:
                                                                            1),
                                                                    () {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pushNamed(
                                                                          HomeScreen
                                                                              .id);
                                                                });
                                                              } else {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                                showDialog(
                                                                    context:
                                                                        context,
                                                                    builder:
                                                                        (context) {
                                                                      return WillPopScope(
                                                                        onWillPop:
                                                                            () async =>
                                                                                null,
                                                                        child:
                                                                            CupertinoAlertDialog(
                                                                          content:
                                                                              Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceEvenly,
                                                                            children: [
                                                                              Icon(
                                                                                Icons.error,
                                                                                color: Colors.redAccent,
                                                                              ),
                                                                              const SizedBox(width: 10),
                                                                              Text("Prenotazione non effettuata"),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      );
                                                                    });
                                                                Future.delayed(
                                                                    Duration(
                                                                        seconds:
                                                                            1),
                                                                    () {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                  showDialog(
                                                                      context:
                                                                          context,
                                                                      builder:
                                                                          (context) {
                                                                        return CupertinoAlertDialog(
                                                                          actions: [
                                                                            TextButton(
                                                                              onPressed: () {
                                                                                Navigator.of(context).pop();
                                                                              },
                                                                              child: Text("Ok"),
                                                                            ),
                                                                          ],
                                                                          title:
                                                                              Text("Questo messaggio può presentarsi se:"),
                                                                          content:
                                                                              Text(
                                                                            result["error"],
                                                                            textAlign:
                                                                                TextAlign.left,
                                                                          ),
                                                                        );
                                                                      });
                                                                });
                                                              }
                                                            });
                                                          },
                                                        ),
                                                        TextButton(
                                                          child: Text(
                                                            "No",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .redAccent),
                                                          ),
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                        ),
                                                      ],
                                                    );
                                                  return AlertDialog(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                    ),
                                                    title: Text(
                                                        "Prenotazione appello"),
                                                    content: Text(
                                                        "Sei sicuro di volerti prenotare?"),
                                                    actions: [
                                                      TextButton(
                                                        child: Text(
                                                          "SI",
                                                          style: TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .bodyText1
                                                                  .color),
                                                        ),
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                          showDialog(
                                                              context: context,
                                                              builder:
                                                                  (context) {
                                                                return WillPopScope(
                                                                  onWillPop:
                                                                      () async =>
                                                                          null,
                                                                  child:
                                                                      AlertDialog(
                                                                    shape:
                                                                        RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              20),
                                                                    ),
                                                                    content:
                                                                        Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceEvenly,
                                                                      children: [
                                                                        CircularProgressIndicator(
                                                                          valueColor:
                                                                              AlwaysStoppedAnimation<Color>(Constants.mainColorLighter),
                                                                        ),
                                                                        const SizedBox(
                                                                            width:
                                                                                10),
                                                                        Text(
                                                                          "Attendi un secondo...",
                                                                          style:
                                                                              TextStyle(fontStyle: FontStyle.italic),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                );
                                                              });
                                                          Provider.prenotaAppello(
                                                                  altreInfo
                                                                      .data)
                                                              .then((result) {
                                                            if (result !=
                                                                    null &&
                                                                result[
                                                                    "success"]) {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                              showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (context) {
                                                                    return WillPopScope(

                                                                      onWillPop:
                                                                          () async =>
                                                                              null,
                                                                      child:
                                                                          AlertDialog(
                                                                        shape:
                                                                            RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(20),
                                                                        ),
                                                                        content:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceEvenly,
                                                                          children: [
                                                                            Icon(
                                                                              Icons.check,
                                                                              color: Colors.green,
                                                                            ),
                                                                            const SizedBox(width: 10),
                                                                            Text("Prenotazione effettuata!"),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    );
                                                                  });
                                                              Future.delayed(
                                                                  Duration(
                                                                      seconds:
                                                                          1),
                                                                  () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pushNamed(
                                                                        HomeScreen
                                                                            .id);
                                                              });
                                                            } else {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                              showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (context) {
                                                                    return WillPopScope(
                                                                      onWillPop:
                                                                          () async =>
                                                                              null,
                                                                      child:
                                                                          AlertDialog(
                                                                        shape:
                                                                            RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(20),
                                                                        ),
                                                                        content:
                                                                            Row(
                                                                          children: [
                                                                            Icon(
                                                                              Icons.error,
                                                                              color: Colors.redAccent,
                                                                            ),
                                                                            const SizedBox(width: 10),
                                                                            Text("Prenotazione non effettuata"),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    );
                                                                  });
                                                              Future.delayed(
                                                                  Duration(
                                                                      seconds:
                                                                          1),
                                                                  () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                                if (result[
                                                                        "error"] !=
                                                                    null) {
                                                                  showDialog(
                                                                      context:
                                                                          context,
                                                                      builder:
                                                                          (context) {
                                                                        return AlertDialog(
                                                                          shape:
                                                                              RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(20),
                                                                          ),
                                                                          scrollable:
                                                                              true,
                                                                          actions: [
                                                                            TextButton(
                                                                              onPressed: () {
                                                                                Navigator.of(context).pop();
                                                                              },
                                                                              child: Text(
                                                                                "Ok",
                                                                                style: TextStyle(color: Theme.of(context).primaryColor),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                          title:
                                                                              Text("Questo messaggio può presentarsi se:"),
                                                                          content:
                                                                              Text(
                                                                            result["error"],
                                                                            textAlign:
                                                                                TextAlign.left,
                                                                          ),
                                                                        );
                                                                      });
                                                                }
                                                              });
                                                            }
                                                          });
                                                        },
                                                      ),
                                                      MaterialButton(
                                                        color: Colors.redAccent,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(50),
                                                        ),
                                                        child: Text("NO"),
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                      ),
                                                    ],
                                                  );
                                                });

                                          },
                                        ),
                                      )
                                    : SizedBox.shrink(),
                                altreInfo.data["tabellaHidden"] != null
                                    ? SizedBox(width: 10)
                                    : SizedBox.shrink(),
                                Flexible(
                                  child: MaterialButton(
                                    minWidth: double.infinity,
                                    color: Theme.of(context).primaryColorLight,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: altreInfo.data["tabellaHidden"] ==
                                            null
                                        ? Text("IMPOSTA PROMEMORIA",
                                            style:
                                                TextStyle(color: Colors.white))
                                        : Text("PROMEMORIA",
                                            style:
                                                TextStyle(color: Colors.white)),
                                    onPressed: () {
                                      final Event event = Event(
                                        title:
                                            'Appello: ${widget.nomeAppello} (${widget.descrizione} - ${widget.dataAppello})',
                                        description:
                                            "Non dimenticarti di prenotare l'esame e in bocca al lupo!",
                                        location: "Esse3",
                                        startDate: DateTime.parse(widget
                                                    .dataAppello
                                                    .substring(6) +
                                                widget.dataAppello
                                                    .substring(3, 5) +
                                                widget.dataAppello
                                                    .substring(0, 2))
                                            .subtract(Duration(days: 7))
                                            .add(Duration(hours: 10)),
                                        endDate: DateTime.parse(widget
                                                    .dataAppello
                                                    .substring(6) +
                                                widget.dataAppello
                                                    .substring(3, 5) +
                                                widget.dataAppello
                                                    .substring(0, 2))
                                            .subtract(Duration(days: 6)),
                                      );
                                      Add2Calendar.addEvent2Cal(event);
                                    },
                                  ),
                                ),
                              ],
                            )
                          ],
                        );
                      default:
                        return Text("Errore interno");
                    }
                  },
                )
              : SizedBox.shrink(),
          Column(
            children: [
              _isRequestedAltreInfo
                  ? SizedBox.shrink()
                  : MaterialButton(
                      child: Text("ALTRE INFO",
                          style: TextStyle(
                              color: Theme.of(context).primaryColorLight)),
                      onPressed: () {
                        setState(() {
                          _isRequestedAltreInfo = !_isRequestedAltreInfo;
                          _altreInfo = Provider.getInfoAppello(widget.linkInfo);
                        });
                      }),
              _isRequestedAltreInfo
                  ? SizedBox.shrink()
                  : MaterialButton(
                      minWidth: double.infinity,
                      color: Theme.of(context).primaryColorLight,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text("IMPOSTA PROMEMORIA",
                          style: TextStyle(color: Colors.white)),
                      onPressed: () {
                        final Event event = Event(
                          title:
                              'Appello: ${widget.nomeAppello} (${widget.descrizione} - ${widget.dataAppello})',
                          description:
                              "Non dimenticarti di prenotare l'esame e in bocca al lupo!",
                          location: "Esse3",
                          startDate: DateTime.parse(
                                  widget.dataAppello.substring(6) +
                                      widget.dataAppello.substring(3, 5) +
                                      widget.dataAppello.substring(0, 2))
                              .subtract(Duration(days: 7))
                              .add(Duration(hours: 10)),
                          endDate: DateTime.parse(
                                  widget.dataAppello.substring(6) +
                                      widget.dataAppello.substring(3, 5) +
                                      widget.dataAppello.substring(0, 2))
                              .subtract(Duration(days: 6)),
                        );
                        Add2Calendar.addEvent2Cal(event);
                      },
                    ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Bottone utilizzato in [HomeScreen] nel [Drawer].
class BottonePaginaDrawer extends StatelessWidget {
  final String testoBottone;

  /// Icona del bottone, in caso ne abbia una.
  final IconData icona;

  /// Funzione del bottone quando viene premuto.
  final Function onPressed;
  final Color textColor;

  const BottonePaginaDrawer({
    Key key,
    @required this.testoBottone,
    @required this.onPressed,
    this.textColor,
    this.icona,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return TextButton(
      onPressed: onPressed,
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icona != null
                ? Icon(icona, color: textColor, size: 15)
                : SizedBox.shrink(),
            icona != null ? SizedBox(width: 10) : SizedBox.shrink(),
            Text(
              testoBottone,
              textAlign: TextAlign.center,
              style: Constants.fontBold.copyWith(color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottone custom utilizzato in [HomeScreen] nel [Drawer].
class BottoneMaterialCustom extends StatelessWidget {
  final Function onPressed;
  final Color textColor, backgroundColor;
  final String textButton;
  final double minWidth, height, elevation, fontSize, padding;
  final FontWeight fontWeight;

  const BottoneMaterialCustom(
      {Key key,
      @required this.onPressed,
      this.backgroundColor = Colors.redAccent,
      this.textColor = Colors.white,
      @required this.textButton,
      this.minWidth = double.infinity,
      this.height = 40,
      this.fontWeight = FontWeight.bold,
      this.elevation = 1,
      this.fontSize = 14,
      this.padding = 0})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      minWidth: minWidth,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(50)),
      ),
      height: height,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Text(
          textButton,
          style: TextStyle(fontWeight: fontWeight, fontSize: fontSize),
        ),
      ),
      elevation: elevation,
      textColor: textColor,
      color: backgroundColor,
      onPressed: onPressed,
    );
  }
}

/// Card rappresentativa dell'appello prenotato in [BachecaPrenotazioniScreen].
class CardAppelloPrenotato extends StatelessWidget {
  final String nomeEsame;
  final String iscrizione;
  final String giorno;
  final String ora;
  final String docente;
  final Map formHiddens;
  final int index;
  final bool darkModeOn;
  final bool isTablet;

  const CardAppelloPrenotato(
      {Key key,
      this.nomeEsame,
      this.iscrizione,
      this.giorno,
      this.ora,
      this.docente,
      this.formHiddens,
      this.index,
      this.darkModeOn,
      this.isTablet})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool darkModeOn = Theme.of(context).brightness == Brightness.dark;
    List<String> _nomeEsame = nomeEsame.split(" - ");
    String numIsc = iscrizione.replaceFirst("Numero Iscrizione: ", "");
    Map internalHiddens = new Map();
    formHiddens.forEach((key, value) {
      if (key.toString().startsWith(index.toString())) {
        internalHiddens[
            key.toString().replaceFirst(index.toString() + "_", "")] = value;
      }
    });
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        gradient: darkModeOn
            ? null
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                    Constants.mainColorDarker,
                    Constants.mainColorLighter
                  ]),
        borderRadius: BorderRadius.all(Radius.circular(10)),
        color: darkModeOn ? Theme.of(context).cardColor : null,
      ),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  _nomeEsame[0],
                  style: isTablet
                      ? Constants.fontBold28.copyWith(color: Colors.white)
                      : Constants.fontBold20.copyWith(color: Colors.white),
                ),
              ),
              Text(
                _nomeEsame[1],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          Text(
            _nomeEsame[2],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 10),
          RichText(
            text: TextSpan(
                text: "Giorno: ",
                style: DefaultTextStyle.of(context)
                    .style
                    .copyWith(color: Colors.white),
                children: [
                  TextSpan(
                    text: giorno,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  )
                ]),
          ),
          RichText(
            text: TextSpan(
                text: "Ora: ",
                style: DefaultTextStyle.of(context)
                    .style
                    .copyWith(color: Colors.white),
                children: [
                  TextSpan(
                    text: ora,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  )
                ]),
          ),
          RichText(
            text: TextSpan(
                text: "Numero iscrizione: ",
                style: DefaultTextStyle.of(context)
                    .style
                    .copyWith(color: Colors.white),
                children: [
                  TextSpan(
                    text: numIsc,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  )
                ]),
          ),
          const SizedBox(height: 10),
          RichText(
            text: TextSpan(
                text: "Docente: ",
                style: DefaultTextStyle.of(context)
                    .style
                    .copyWith(color: Colors.white),
                children: [
                  TextSpan(
                    text: docente,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ]),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Flexible(
                child: MaterialButton(
                  elevation: 2,
                  minWidth: double.infinity,
                  color: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text("CANCELLATI",
                      style: const TextStyle(color: Colors.white)),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        if (Platform.isAndroid)
                          return AlertDialog(
                            title: Text("Annulla prenotazione"),
                            content: Text(
                                "Sei sicuro di voler cancellare la prenotazione?"),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            actions: [
                              TextButton(
                                child: Text(
                                  "SI",
                                  style: TextStyle(
                                      color: darkModeOn
                                          ? Colors.white
                                          : Colors.black87),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return WillPopScope(
                                          onWillPop: () async => null,
                                          child: AlertDialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            content: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                CircularProgressIndicator(
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                              Color>(
                                                          Colors.redAccent),
                                                ),
                                                const SizedBox(width: 10),
                                                Text("Aspetta un secondo..."),
                                              ],
                                            ),
                                          ),
                                        );
                                      });
                                  Provider.cancellaAppello(internalHiddens)
                                      .then((value) {
                                    if (value != null && value) {
                                      Navigator.of(context).pop();
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return WillPopScope(
                                            onWillPop: () async => null,
                                            child: AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              content: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  Icon(
                                                    Icons.check,
                                                    color: Colors.green,
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Text(
                                                      "Prenotazione cancellata!"),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                      Future.delayed(Duration(seconds: 1), () {
                                        Navigator.of(context).pop();
                                        Navigator.of(context).pop();
                                      });
                                    } else {
                                      Navigator.of(context).pop();
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return WillPopScope(
                                            onWillPop: () async => null,
                                            child: AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              content: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  Icon(
                                                    Icons.cancel,
                                                    color: Colors.redAccent,
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Text("Errore cancellazione!"),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                      Future.delayed(Duration(seconds: 1), () {
                                        Navigator.of(context).pop();
                                      });
                                    }
                                  });
                                },
                              ),
                              MaterialButton(
                                elevation: 0,
                                color: Colors.redAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Text("NO",
                                    style: TextStyle(color: Colors.white)),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        return CupertinoAlertDialog(
                          title: Text("Annulla prenotazione"),
                          content: Text(
                              "Sei sicuro di voler cancellare la prenotazione?"),
                          actions: [
                            TextButton(
                              child: Text(
                                "SI",
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return WillPopScope(
                                        onWillPop: () async => null,
                                        child: AlertDialog(
                                          content: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              CircularProgressIndicator(
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                            Color>(
                                                        Colors.redAccent),
                                              ),
                                              const SizedBox(width: 10),
                                              Text("Aspetta un secondo..."),
                                            ],
                                          ),
                                        ),
                                      );
                                    });
                                Provider.cancellaAppello(internalHiddens)
                                    .then((value) {
                                  if (value != null && value) {
                                    Navigator.of(context).pop();
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return WillPopScope(
                                            onWillPop: () async => null,
                                            child: AlertDialog(
                                              content: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  Icon(
                                                    Icons.check,
                                                    color: Colors.green,
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Text(
                                                      "Prenotazione cancellata!"),
                                                ],
                                              ),
                                            ),
                                          );
                                        });
                                    Future.delayed(Duration(seconds: 1), () {
                                      Navigator.of(context).pop();
                                      Navigator.of(context).pop();
                                    });
                                  } else {
                                    Navigator.of(context).pop();
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return WillPopScope(
                                          onWillPop: () async => null,
                                          child: AlertDialog(
                                            content: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Icon(
                                                  Icons.cancel,
                                                  color: Colors.redAccent,
                                                ),
                                                const SizedBox(width: 10),
                                                Text("Errore cancellazione!"),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                    Future.delayed(Duration(seconds: 1), () {
                                      Navigator.of(context).pop();
                                    });
                                  }
                                });
                              },
                            ),
                            MaterialButton(
                              elevation: 0,
                              textColor: Colors.redAccent,
                              child: Text("NO"),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: MaterialButton(
                  elevation: 3,
                  minWidth: double.infinity,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text("PROMEMORIA",
                      style: TextStyle(
                          color: darkModeOn
                              ? Colors.redAccent
                              : Constants.mainColor)),
                  onPressed: () {
                    var giornoEv = giorno.substring(0, 2);
                    var mese = giorno.substring(3, 5);
                    int anno = int.parse(giorno.substring(6));

                    final Event event = Event(
                      title: "Appello ${_nomeEsame[0]} - $giorno",
                      description: _nomeEsame[2],
                      location: 'Università di Modena e Reggio Emilia',
                      startDate: DateTime.parse("$anno-$mese-$giornoEv")
                          .subtract(Duration(days: 3))
                          .add(Duration(hours: 10)),
                      endDate: DateTime.parse("$anno-$mese-$giornoEv")
                          .subtract(Duration(days: 3))
                          .add(Duration(hours: 10)),
                      allDay: true,
                    );

                    Add2Calendar.addEvent2Cal(event);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Widget rappresentativo della tassa visualizzata in [TasseScreen].
class TassaExpansionTile extends StatefulWidget {
  final String descTassa;
  final String importo;
  final String scadenza;
  final String stato;
  final bool darkModeOn;

  const TassaExpansionTile(
      {Key key,
      this.descTassa,
      this.importo,
      this.scadenza,
      this.stato,
      this.darkModeOn})
      : super(key: key);

  @override
  _TassaExpansionTileState createState() => _TassaExpansionTileState();
}

class _TassaExpansionTileState extends State<TassaExpansionTile> {
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
          accentColor: widget.stato == "IN ATTESA"
              ? Colors.yellow[700]
              : widget.stato == "NON PAGATO"
                  ? Colors.redAccent
                  : Theme.of(context).textTheme.bodyText1.color),
      child: ExpansionTile(
        maintainState: true,
        backgroundColor: Theme.of(context).cardColor,
        leading: widget.stato == "NON PAGATO"
            ? Icon(Icons.error, color: Colors.redAccent)
            : widget.stato == "IN ATTESA"
                ? Icon(Icons.help, color: Colors.yellow[700])
                : null,
        childrenPadding: EdgeInsets.only(bottom: 16, left: 16, right: 16),
        tilePadding: EdgeInsets.symmetric(vertical: 5, horizontal: 16),
        title: Text(
          widget.descTassa.substring(0, 30) + "...",
          style: Constants.fontBold20.copyWith(
            fontFamily: "SF Pro",
          ),
        ),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
                text: "Descrizione: ",
                style: Constants.fontBold.copyWith(
                    color: Theme.of(context).textTheme.bodyText1.color,
                    fontFamily: "SF Pro"),
                children: [
                  TextSpan(
                      text: widget.descTassa,
                      style: Constants.font14
                          .copyWith(fontWeight: FontWeight.normal))
                ]),
          ),
          const SizedBox(height: 15),
          RichText(
            text: TextSpan(
                text: "Importo: ",
                style: Constants.font18.copyWith(
                    color: Theme.of(context).textTheme.bodyText1.color,
                    fontFamily: "SF Pro"),
                children: [
                  TextSpan(text: widget.importo, style: Constants.fontBold18)
                ]),
          ),
          const SizedBox(height: 5),
          RichText(
            text: TextSpan(
                text: "Scadenza: ",
                style: Constants.font18.copyWith(
                    color: Theme.of(context).textTheme.bodyText1.color,
                    fontFamily: "SF Pro"),
                children: [
                  TextSpan(text: widget.scadenza, style: Constants.fontBold18)
                ]),
          ),
          const SizedBox(height: 5),
          RichText(
            text: TextSpan(
                text: "Stato: ",
                style: Constants.font18.copyWith(
                    color: Theme.of(context).textTheme.bodyText1.color,
                    fontFamily: "SF Pro"),
                children: [
                  TextSpan(text: widget.stato, style: Constants.fontBold18)
                ]),
          ),
          widget.stato == "NON PAGATO"
              ? Column(
                  children: [
                    const SizedBox(height: 15),
                    MaterialButton(
                      minWidth: double.infinity,
                      disabledColor: Theme.of(context).disabledColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                      ),
                      color: Colors.redAccent,
                      textColor: Colors.white,
                      child: Text("AGGIUNGI PROMEMORIA"),
                      onPressed: () {
                        final Event event = Event(
                          title:
                              'Pagare ${widget.descTassa.substring(0, 30)}... entro il ${widget.scadenza}!',
                          description: "Non dimenticarti di pagare la tassa!",
                          location: "Esse3",
                          startDate: DateTime.parse(
                                  widget.scadenza.substring(6) +
                                      widget.scadenza.substring(3, 5) +
                                      widget.scadenza.substring(0, 2))
                              .subtract(Duration(days: 7))
                              .add(Duration(hours: 10)),
                          endDate: DateTime.parse(widget.scadenza.substring(6) +
                                  widget.scadenza.substring(3, 5) +
                                  widget.scadenza.substring(0, 2))
                              .subtract(Duration(days: 6)),
                        );
                        Add2Calendar.addEvent2Cal(event);
                      },
                    ),
                  ],
                )
              : SizedBox.shrink(),
        ],
      ),
    );
  }
}

/// Animazione di caricamento custom da [Shimmer].
class ShimmerCustom extends StatelessWidget {
  final double height;

  const ShimmerCustom({Key key, this.height = 200}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
            color: Colors.black26, borderRadius: BorderRadius.circular(10)),
      ),
      baseColor: Colors.grey[400],
      highlightColor: Colors.grey[300],
    );
  }
}

/// Animazione di caricamento per la pagina [TasseScreen]
/// e [ProssimiAppelliScreen].
class ShimmerLoader extends StatelessWidget {
  final bool isTablet;
  final double deviceWidth;
  final double shimmerHeight;
  final Color colorCircular;

  const ShimmerLoader(
      {Key key,
      this.isTablet,
      this.deviceWidth,
      this.shimmerHeight = 200,
      this.colorCircular = Constants.mainColorLighter})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Platform.isIOS
                    ? CupertinoActivityIndicator()
                    : CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(colorCircular),
                      ),
                SizedBox(width: 20),
                Text(
                  "Sto scaricando i dati...",
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          Padding(
            padding: isTablet
                ? EdgeInsets.symmetric(horizontal: deviceWidth / 6)
                : EdgeInsets.only(bottom: 16.0, left: 16, right: 16),
            child: Column(
              children: [
                ShimmerCustom(height: shimmerHeight),
                SizedBox(height: 10),
                ShimmerCustom(height: shimmerHeight),
                isTablet ? SizedBox(height: 10) : SizedBox.shrink(),
                isTablet
                    ? ShimmerCustom(height: shimmerHeight)
                    : SizedBox.shrink(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Schermata di errore riguardo la connessione.
class ConnectionError extends StatelessWidget {
  final double deviceWidth;
  final bool isTablet;

  const ConnectionError({Key key, this.deviceWidth, this.isTablet})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          SvgPicture.asset(
            'assets/img/networkError.svg',
            width: isTablet ? deviceWidth * 0.5 : deviceWidth / 1.7,
          ),
          SizedBox(height: isTablet ? 30 : 15),
          Text("Errore di connessione", style: Constants.fontBold28),
          const SizedBox(height: 5),
          Text(
            "Sembra ci siano problemi nel recuperare i tuoi dati, riaggiorna oppure riprova tra un po'!",
            style: Constants.font18,
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}

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
          Text("Nessun appello", style: Constants.fontBold28),
          const SizedBox(height: 10),
          Text(
            "Sembra non ci siano appelli, fantastico!",
            style: Constants.font18,
            textAlign: TextAlign.center,
          ),
          Text(
            "Adesso scappa finchè sei in tempo",
            style: Constants.font14,
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}

/// Schermata di errore che appare quando la richiesta
/// della [BachecaPrenotazioniScreen] non va a buon fine.
class ReloadAppelli extends StatelessWidget {
  final Function onReload;
  final double deviceHeight, deviceWidth;

  const ReloadAppelli(
      {Key key, this.onReload, this.deviceHeight, this.deviceWidth})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LiquidPullToRefresh(
      animSpeedFactor: 1.5,
      height: 80,
      color: Theme.of(context).primaryColorLight,
      onRefresh: onReload,
      showChildOpacityTransition: false,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: deviceHeight - 130,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Bacheca prenotazioni",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 25),
                ),
                Divider(),
                const SizedBox(height: 50),
                Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SvgPicture.asset(
                        'assets/img/networkError.svg',
                        width: deviceWidth * 0.7,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Oops..",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 32),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Ci sono problemi nel recuperare i tuoi dati, aggiorna oppure riprova tra un pò!",
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
