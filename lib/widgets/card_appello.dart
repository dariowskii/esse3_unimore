import 'dart:io';

import 'package:Esse3/constants.dart';
import 'package:Esse3/models/appello_model.dart';
import 'package:Esse3/screens/prossimi_appelli_screen.dart';
import 'package:Esse3/utils/provider.dart';
import 'package:Esse3/widgets/box_info.dart';
import 'package:Esse3/widgets/info_rich_text.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class _RichiediAltreInfo extends StatefulWidget {
  _RichiediAltreInfo({
    Key key,
    this.altreInfo,
    this.linkInfo,
    this.nomeAppello,
    this.dataAppello,
    this.descrizione,
    this.prenotaEsame,
    this.darkModeOn,
  }) : super(key: key);

  Future<Map<String, dynamic>> altreInfo;
  final String linkInfo;
  final String nomeAppello;
  final String dataAppello;
  final String descrizione;
  final bool darkModeOn;
  final PrenotaEsame prenotaEsame;
  @override
  __RichiediAltreInfoState createState() => __RichiediAltreInfoState();
}

class __RichiediAltreInfoState extends State<_RichiediAltreInfo> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: widget.altreInfo,
      builder: (context, altreInfo) {
        switch (altreInfo.connectionState) {
          case ConnectionState.none:
            return Column(
              children: [
                Row(
                  children: <Widget>[
                    const Icon(
                      Icons.error,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'Errore nel recuperare i dati!',
                    ),
                    Expanded(child: Container()),
                    IconButton(
                        icon: const Icon(Icons.refresh),
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
                          .subtract(const Duration(days: 7))
                          .add(const Duration(hours: 10)),
                      endDate: DateTime.parse(widget.dataAppello.substring(6) +
                              widget.dataAppello.substring(3, 5) +
                              widget.dataAppello.substring(0, 2))
                          .subtract(const Duration(days: 6)),
                    );
                    Add2Calendar.addEvent2Cal(event);
                  },
                  child: const Text('IMPOSTA PROMEMORIA',
                      style: TextStyle(color: Colors.white)),
                )
              ],
            );
          case ConnectionState.active:
          case ConnectionState.waiting:
            return Column(
              children: <Widget>[
                const SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    CupertinoActivityIndicator(),
                    SizedBox(width: 10),
                    Text(
                      'Sto scaricando le info...',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    )
                  ],
                ),
                const SizedBox(
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
                          .subtract(const Duration(days: 7))
                          .add(const Duration(hours: 10)),
                      endDate: DateTime.parse(widget.dataAppello.substring(6) +
                              widget.dataAppello.substring(3, 5) +
                              widget.dataAppello.substring(0, 2))
                          .subtract(const Duration(days: 6)),
                    );
                    Add2Calendar.addEvent2Cal(event);
                  },
                  child: const Text('IMPOSTA PROMEMORIA',
                      style: TextStyle(color: Colors.white)),
                )
              ],
            );
          case ConnectionState.done:
            if (altreInfo.data == null ||
                !(altreInfo.data['success'] as bool)) {
              return const Text('Sembra non ci siano risultati...');
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BoxInfo(
                  darkModeOn: widget.darkModeOn,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InfoRichText(
                        text: 'Tipo esame: ',
                        value: altreInfo.data['tipo_esame'] as String,
                        fontSize: 14,
                      ),
                      InfoRichText(
                        text: 'Verbalizzazione: ',
                        value: altreInfo.data['verbalizzazione'] as String,
                        fontSize: 14,
                      ),
                      InfoRichText(
                        text: 'Aula: ',
                        value: altreInfo.data['aula'] as String,
                        fontSize: 14,
                      ),
                      InfoRichText(
                        text: 'Numero iscritti: ',
                        value: altreInfo.data['num_iscritti'] as String,
                        fontSize: 14,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                BoxInfo(
                  darkModeOn: widget.darkModeOn,
                  child: InfoRichText(
                    text: 'Docente: ',
                    value: altreInfo.data['docente'] as String,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    if (altreInfo.data['tabellaHidden'] != null) ...[
                      Flexible(
                        child: MaterialButton(
                          padding: const EdgeInsets.all(0),
                          minWidth: double.infinity,
                          color: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20)),
                              ),
                              builder: (context) {
                                widget.prenotaEsame.altreInfo = altreInfo.data;
                                return widget.prenotaEsame;
                              },
                            );
                          },
                          child: const Text('PRENOTA',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
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
                                .subtract(const Duration(days: 7))
                                .add(const Duration(hours: 10)),
                            endDate: DateTime.parse(
                                    widget.dataAppello.substring(6) +
                                        widget.dataAppello.substring(3, 5) +
                                        widget.dataAppello.substring(0, 2))
                                .subtract(const Duration(days: 6)),
                          );
                          Add2Calendar.addEvent2Cal(event);
                        },
                        child: altreInfo.data['tabellaHidden'] == null
                            ? const Text('IMPOSTA PROMEMORIA',
                                style: TextStyle(color: Colors.white))
                            : const Text('PROMEMORIA',
                                style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                )
              ],
            );
          default:
            return const Text('Errore interno');
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
  final PrenotaEsame prenotaEsame;

  /// Serve poi per richiedere i parametri per la prenotazione dell'appello.
  final String linkInfo;

  const CardAppello({
    Key key,
    this.nomeAppello,
    this.dataAppello,
    this.descrizione,
    this.periodoIscrizioni,
    this.sessione,
    this.linkInfo,
    this.prenotaEsame,
  }) : super(key: key);

  factory CardAppello.fromAppelloModel(
      AppelloModel appello, PrenotaEsame prenotaEsame) {
    return CardAppello(
      nomeAppello: appello.nomeMateria,
      dataAppello: appello.dataAppello,
      descrizione: appello.descrizione,
      periodoIscrizioni: appello.periodoIscrizione,
      sessione: appello.sessione,
      linkInfo: appello.linkInfo,
      prenotaEsame: prenotaEsame,
    );
  }

  @override
  _CardAppelloState createState() => _CardAppelloState();
}

class _CardAppelloState extends State<CardAppello> {
  Future<Map<String, dynamic>> _altreInfo;
  bool _isRequestedAltreInfo = false;

  @override
  Widget build(BuildContext context) {
    final darkModeOn =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            offset: const Offset(0, 3),
            blurRadius: 3,
            spreadRadius: 3,
          ),
        ],
        color: Theme.of(context).cardColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  widget.nomeAppello,
                  style: Constants.fontBold20
                      .copyWith(color: Theme.of(context).primaryColorLight),
                ),
              ),
              const SizedBox(width: 10),
              BoxInfo(
                darkModeOn: darkModeOn,
                minWidth: null,
                backgroundColor: Theme.of(context).primaryColorLight,
                child: Text(
                  widget.dataAppello,
                  style: Constants.fontBold.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          BoxInfo(
            darkModeOn: darkModeOn,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InfoRichText(
                  text: 'Descrizione: ',
                  value: widget.descrizione,
                  fontSize: 14,
                ),
                InfoRichText(
                  text: 'Periodo iscrizioni: ',
                  value: widget.periodoIscrizioni,
                  fontSize: 14,
                ),
                InfoRichText(
                  text: 'Sessione: ',
                  value: widget.sessione,
                  fontSize: 14,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          if (_isRequestedAltreInfo)
            _RichiediAltreInfo(
              altreInfo: _altreInfo,
              linkInfo: widget.linkInfo,
              nomeAppello: widget.nomeAppello,
              dataAppello: widget.dataAppello,
              descrizione: widget.descrizione,
              prenotaEsame: widget.prenotaEsame,
              darkModeOn: darkModeOn,
            )
          else
            const SizedBox.shrink(),
          Column(
            children: [
              if (_isRequestedAltreInfo)
                const SizedBox.shrink()
              else
                MaterialButton(
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
              if (_isRequestedAltreInfo)
                const SizedBox.shrink()
              else
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
                          .subtract(const Duration(days: 7))
                          .add(const Duration(hours: 10)),
                      endDate: DateTime.parse(widget.dataAppello.substring(6) +
                              widget.dataAppello.substring(3, 5) +
                              widget.dataAppello.substring(0, 2))
                          .subtract(const Duration(days: 6)),
                    );
                    Add2Calendar.addEvent2Cal(event);
                  },
                  child: const Text('IMPOSTA PROMEMORIA',
                      style: TextStyle(color: Colors.white)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
