import 'dart:io';

import 'package:Esse3/constants.dart';
import 'package:Esse3/utils/provider.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
    var darkModeOn = Theme.of(context).brightness == Brightness.dark;
    var _nomeEsame = nomeEsame.split(' - ');
    var numIsc = iscrizione.replaceFirst('Numero Iscrizione: ', '');
    final Map<String, dynamic> internalHiddens = {};
    formHiddens.forEach((key, value) {
      if (key.toString().startsWith(index.toString())) {
        internalHiddens[
            key.toString().replaceFirst(index.toString() + '_', '')] = value;
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
                text: 'Giorno: ',
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
                text: 'Ora: ',
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
                text: 'Numero iscrizione: ',
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
                text: 'Docente: ',
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
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        if (Platform.isAndroid) {
                          return AlertDialog(
                            title: Text('Annulla prenotazione'),
                            content: Text(
                                'Sei sicuro di voler cancellare la prenotazione?'),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            actions: [
                              TextButton(
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
                                                Text('Aspetta un secondo...'),
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
                                                      'Prenotazione cancellata!'),
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
                                                  Text('Errore cancellazione!'),
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
                                child: Text(
                                  'SI',
                                  style: TextStyle(
                                      color: darkModeOn
                                          ? Colors.white
                                          : Colors.black87),
                                ),
                              ),
                              MaterialButton(
                                elevation: 0,
                                color: Colors.redAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('NO',
                                    style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          );
                        }
                        return CupertinoAlertDialog(
                          title: Text('Annulla prenotazione'),
                          content: Text(
                              'Sei sicuro di voler cancellare la prenotazione?'),
                          actions: [
                            TextButton(
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
                                              Text('Aspetta un secondo...'),
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
                                                      'Prenotazione cancellata!'),
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
                                                Text('Errore cancellazione!'),
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
                              child: Text(
                                'SI',
                              ),
                            ),
                            MaterialButton(
                              elevation: 0,
                              textColor: Colors.redAccent,
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('NO'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text('CANCELLATI',
                      style: const TextStyle(color: Colors.white)),
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
                  onPressed: () {
                    var giornoEv = giorno.substring(0, 2);
                    var mese = giorno.substring(3, 5);
                    var anno = int.parse(giorno.substring(6));

                    final event = Event(
                      title: 'Appello ${_nomeEsame[0]} - $giorno',
                      description: _nomeEsame[2],
                      location: 'Università di Modena e Reggio Emilia',
                      startDate: DateTime.parse('$anno-$mese-$giornoEv')
                          .subtract(Duration(days: 3))
                          .add(Duration(hours: 10)),
                      endDate: DateTime.parse('$anno-$mese-$giornoEv')
                          .subtract(Duration(days: 3))
                          .add(Duration(hours: 10)),
                      allDay: true,
                    );

                    Add2Calendar.addEvent2Cal(event);
                  },
                  child: Text('PROMEMORIA',
                      style: TextStyle(
                          color: darkModeOn
                              ? Colors.redAccent
                              : Constants.mainColor)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
