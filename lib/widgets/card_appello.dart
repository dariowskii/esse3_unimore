import 'dart:io';

import 'package:Esse3/constants.dart';
import 'package:Esse3/screens/home_screen.dart';
import 'package:Esse3/utils/provider.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class _RichiediAltreInfo extends StatefulWidget {
  _RichiediAltreInfo(
      {Key key,
      this.altreInfo,
      this.linkInfo,
      this.nomeAppello,
      this.dataAppello,
      this.descrizione})
      : super(key: key);

  Future<Map<String, dynamic>> altreInfo;
  final String linkInfo;
  final String nomeAppello;
  final String dataAppello;
  final String descrizione;
  @override
  __RichiediAltreInfoState createState() => __RichiediAltreInfoState();
}

class __RichiediAltreInfoState extends State<_RichiediAltreInfo> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: widget.altreInfo,
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
                      'Errore nel recuperare i dati!',
                    ),
                    Expanded(child: Container()),
                    IconButton(
                        icon: Icon(Icons.refresh),
                        onPressed: () {
                          setState(() {
                            widget.altreInfo =
                                Provider.getInfoAppello(widget.linkInfo);
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
                  onPressed: () {
                    final event = Event(
                      title:
                          'Appello: ${widget.nomeAppello} (${widget.descrizione} - ${widget.dataAppello})',
                      description:
                          "Non dimenticarti di prenotare l'esame e in bocca al lupo!",
                      location: 'Esse3',
                      startDate: DateTime.parse(
                              widget.dataAppello.substring(6) +
                                  widget.dataAppello.substring(3, 5) +
                                  widget.dataAppello.substring(0, 2))
                          .subtract(Duration(days: 7))
                          .add(Duration(hours: 10)),
                      endDate: DateTime.parse(widget.dataAppello.substring(6) +
                              widget.dataAppello.substring(3, 5) +
                              widget.dataAppello.substring(0, 2))
                          .subtract(Duration(days: 6)),
                    );
                    Add2Calendar.addEvent2Cal(event);
                  },
                  child: Text('IMPOSTA PROMEMORIA',
                      style: TextStyle(color: Colors.white)),
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
                      'Sto scaricando le info...',
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
                  onPressed: () {
                    final event = Event(
                      title:
                          'Appello: ${widget.nomeAppello} (${widget.descrizione} - ${widget.dataAppello})',
                      description:
                          "Non dimenticarti di prenotare l'esame e in bocca al lupo!",
                      location: 'Esse3',
                      startDate: DateTime.parse(
                              widget.dataAppello.substring(6) +
                                  widget.dataAppello.substring(3, 5) +
                                  widget.dataAppello.substring(0, 2))
                          .subtract(Duration(days: 7))
                          .add(Duration(hours: 10)),
                      endDate: DateTime.parse(widget.dataAppello.substring(6) +
                              widget.dataAppello.substring(3, 5) +
                              widget.dataAppello.substring(0, 2))
                          .subtract(Duration(days: 6)),
                    );
                    Add2Calendar.addEvent2Cal(event);
                  },
                  child: Text('IMPOSTA PROMEMORIA',
                      style: TextStyle(color: Colors.white)),
                )
              ],
            );
          case ConnectionState.done:
            if (altreInfo.data == null ||
                !(altreInfo.data['success'] as bool)) {
              return Text('Sembra non ci siano risultati...');
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    text: 'Tipo esame: ',
                    style: TextStyle(
                        fontFamily: 'SF Pro',
                        color: Theme.of(context).textTheme.bodyText1.color),
                    children: [
                      TextSpan(
                          text: altreInfo.data['tipo_esame'] as String,
                          style: Constants.fontBold),
                    ],
                  ),
                ),
                RichText(
                  text: TextSpan(
                    text: 'Verbalizzazione: ',
                    style: TextStyle(
                        fontFamily: 'SF Pro',
                        color: Theme.of(context).textTheme.bodyText1.color),
                    children: [
                      TextSpan(
                          text: altreInfo.data['verbalizzazione'] as String,
                          style: Constants.fontBold),
                    ],
                  ),
                ),
                RichText(
                  text: TextSpan(
                    text: 'Aula: ',
                    style: TextStyle(
                        fontFamily: 'SF Pro',
                        color: Theme.of(context).textTheme.bodyText1.color),
                    children: [
                      TextSpan(
                          text: altreInfo.data['aula'] as String,
                          style: Constants.fontBold),
                    ],
                  ),
                ),
                RichText(
                  text: TextSpan(
                    text: 'Numero iscritti: ',
                    style: TextStyle(
                        fontFamily: 'SF Pro',
                        color: Theme.of(context).textTheme.bodyText1.color),
                    children: [
                      TextSpan(
                          text: altreInfo.data['num_iscritti'] as String,
                          style: Constants.fontBold),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Docente: ${altreInfo.data['docente']}',
                  style: Constants.fontBold,
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: 15),
                Row(
                  children: [
                    altreInfo.data['tabellaHidden'] != null
                        ? Flexible(
                            child: MaterialButton(
                              padding: const EdgeInsets.all(0),
                              minWidth: double.infinity,
                              color: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      if (Platform.isIOS) {
                                        return CupertinoAlertDialog(
                                          title: Text(
                                            'Prenotazione appello',
                                            style:
                                                TextStyle(fontFamily: 'SF Pro'),
                                          ),
                                          content: Text(
                                            'Sei sicuro di volerti prenotare?',
                                            style:
                                                TextStyle(fontFamily: 'SF Pro'),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                showDialog(
                                                    context: context,
                                                    builder: (ctx) {
                                                      return WillPopScope(
                                                        onWillPop: () async =>
                                                            null,
                                                        child:
                                                            CupertinoAlertDialog(
                                                          content: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceEvenly,
                                                            children: [
                                                              CupertinoActivityIndicator(),
                                                              const SizedBox(
                                                                  width: 10),
                                                              Text(
                                                                'Attendi un secondo...',
                                                                style: TextStyle(
                                                                    fontStyle:
                                                                        FontStyle
                                                                            .italic),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    });
                                              },
                                              child: Text(
                                                'Si',
                                                style: Constants.font16,
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text(
                                                'No',
                                                style: TextStyle(
                                                    color: Colors.redAccent),
                                              ),
                                            ),
                                          ],
                                        );
                                      }
                                      return AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        title: Text('Prenotazione appello'),
                                        content: Text(
                                            'Sei sicuro di volerti prenotare?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return WillPopScope(
                                                      onWillPop: () async =>
                                                          null,
                                                      child: AlertDialog(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(20),
                                                        ),
                                                        content: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceEvenly,
                                                          children: [
                                                            CircularProgressIndicator(
                                                              valueColor:
                                                                  AlwaysStoppedAnimation<
                                                                          Color>(
                                                                      Constants
                                                                          .mainColorLighter),
                                                            ),
                                                            const SizedBox(
                                                                width: 10),
                                                            Text(
                                                              'Attendi un secondo...',
                                                              style: TextStyle(
                                                                  fontStyle:
                                                                      FontStyle
                                                                          .italic),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  });
                                              Provider.prenotaAppello(altreInfo
                                                          .data
                                                      as Map<String, dynamic>)
                                                  .then((result) {
                                                if (result != null &&
                                                    result['success'] as bool) {
                                                  Navigator.of(context).pop();
                                                  showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return WillPopScope(
                                                          onWillPop: () async =>
                                                              null,
                                                          child: AlertDialog(
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20),
                                                            ),
                                                            content: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceEvenly,
                                                              children: [
                                                                Icon(
                                                                  Icons.check,
                                                                  color: Colors
                                                                      .green,
                                                                ),
                                                                const SizedBox(
                                                                    width: 10),
                                                                Text(
                                                                    'Prenotazione effettuata!'),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      });
                                                  Future.delayed(
                                                      Duration(seconds: 1), () {
                                                    Navigator.of(context)
                                                        .pushNamed(
                                                            HomeScreen.id);
                                                  });
                                                } else {
                                                  Navigator.of(context).pop();
                                                  showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return WillPopScope(
                                                          onWillPop: () async =>
                                                              null,
                                                          child: AlertDialog(
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20),
                                                            ),
                                                            content: Row(
                                                              children: [
                                                                Icon(
                                                                  Icons.error,
                                                                  color: Colors
                                                                      .redAccent,
                                                                ),
                                                                const SizedBox(
                                                                    width: 10),
                                                                Text(
                                                                    'Prenotazione non effettuata'),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      });
                                                  Future.delayed(
                                                      Duration(seconds: 1), () {
                                                    Navigator.of(context).pop();
                                                    if (result['error'] !=
                                                        null) {
                                                      showDialog(
                                                          context: context,
                                                          builder: (context) {
                                                            return AlertDialog(
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20),
                                                              ),
                                                              scrollable: true,
                                                              actions: [
                                                                TextButton(
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  },
                                                                  child: Text(
                                                                    'Ok',
                                                                    style: TextStyle(
                                                                        color: Theme.of(context)
                                                                            .primaryColor),
                                                                  ),
                                                                ),
                                                              ],
                                                              title: Text(
                                                                  'Questo messaggio può presentarsi se:'),
                                                              content: Text(
                                                                result['error']
                                                                    as String,
                                                                textAlign:
                                                                    TextAlign
                                                                        .left,
                                                              ),
                                                            );
                                                          });
                                                    }
                                                  });
                                                }
                                              });
                                            },
                                            child: Text(
                                              'SI',
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .bodyText1
                                                      .color),
                                            ),
                                          ),
                                          MaterialButton(
                                            color: Colors.redAccent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                            ),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('NO'),
                                          ),
                                        ],
                                      );
                                    });
                              },
                              child: Text('PRENOTA',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          )
                        : SizedBox.shrink(),
                    altreInfo.data['tabellaHidden'] != null
                        ? SizedBox(width: 10)
                        : SizedBox.shrink(),
                    Flexible(
                      child: MaterialButton(
                        minWidth: double.infinity,
                        color: Theme.of(context).primaryColorLight,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        onPressed: () {
                          final event = Event(
                            title:
                                'Appello: ${widget.nomeAppello} (${widget.descrizione} - ${widget.dataAppello})',
                            description:
                                "Non dimenticarti di prenotare l'esame e in bocca al lupo!",
                            location: 'Esse3',
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
                        child: altreInfo.data['tabellaHidden'] == null
                            ? Text('IMPOSTA PROMEMORIA',
                                style: TextStyle(color: Colors.white))
                            : Text('PROMEMORIA',
                                style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                )
              ],
            );
          default:
            return Text('Errore interno');
        }
      },
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
          ),
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
              text: 'Data appello: ',
              style: TextStyle(
                fontFamily: 'SF Pro',
                color: Theme.of(context).textTheme.bodyText1.color,
              ),
              children: [
                TextSpan(text: widget.dataAppello, style: Constants.fontBold18)
              ],
            ),
          ),
          SizedBox(height: 10),
          RichText(
            text: TextSpan(
              text: 'Descrizione: ',
              style: TextStyle(
                fontFamily: 'SF Pro',
                color: Theme.of(context).textTheme.bodyText1.color,
              ),
              children: [
                TextSpan(text: widget.descrizione, style: Constants.fontBold)
              ],
            ),
          ),
          RichText(
            text: TextSpan(
              text: 'Periodo iscrizioni: ',
              style: TextStyle(
                fontFamily: 'SF Pro',
                color: Theme.of(context).textTheme.bodyText1.color,
              ),
              children: [
                TextSpan(
                    text: widget.periodoIscrizioni, style: Constants.fontBold)
              ],
            ),
          ),
          RichText(
            text: TextSpan(
              text: 'Sessione: ',
              style: TextStyle(
                fontFamily: 'SF Pro',
                color: Theme.of(context).textTheme.bodyText1.color,
              ),
              children: [
                TextSpan(text: widget.sessione, style: Constants.fontBold)
              ],
            ),
          ),
          SizedBox(height: 10),
          _isRequestedAltreInfo ? _RichiediAltreInfo() : SizedBox.shrink(),
          Column(
            children: [
              _isRequestedAltreInfo
                  ? SizedBox.shrink()
                  : MaterialButton(
                      onPressed: () {
                        setState(() {
                          _isRequestedAltreInfo = !_isRequestedAltreInfo;
                          _altreInfo = Provider.getInfoAppello(widget.linkInfo);
                        });
                      },
                      child: Text('ALTRE INFO',
                          style: TextStyle(
                              color: Theme.of(context).primaryColorLight)),
                    ),
              _isRequestedAltreInfo
                  ? SizedBox.shrink()
                  : MaterialButton(
                      minWidth: double.infinity,
                      color: Theme.of(context).primaryColorLight,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      onPressed: () {
                        final event = Event(
                          title:
                              'Appello: ${widget.nomeAppello} (${widget.descrizione} - ${widget.dataAppello})',
                          description:
                              "Non dimenticarti di prenotare l'esame e in bocca al lupo!",
                          location: 'Esse3',
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
                      child: Text('IMPOSTA PROMEMORIA',
                          style: TextStyle(color: Colors.white)),
                    ),
            ],
          ),
        ],
      ),
    );
  }
}
