import 'dart:io';

import 'package:Esse3/constants.dart';
import 'package:Esse3/models/altre_info_appello_model.dart';
import 'package:Esse3/models/appello_model.dart';
import 'package:Esse3/screens/prossimi_appelli_screen.dart';
import 'package:Esse3/utils/provider.dart';
import 'package:Esse3/widgets/box_info.dart';
import 'package:Esse3/widgets/info_rich_text.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Card dell'appello con tutte le informazioni necessarie per prenotarsi,
/// utilizzata in [ProssimiAppelliScreen].
class CardAppello extends StatefulWidget {
  final AppelloModel appello;
  final PrenotaEsame prenotaEsame;

  const CardAppello({
    Key key,
    this.appello,
    this.prenotaEsame,
  }) : super(key: key);

  factory CardAppello.fromAppelloModel(
      AppelloModel appello, PrenotaEsame prenotaEsame) {
    return CardAppello(
      appello: appello,
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
                  widget.appello.nomeMateria,
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
                  widget.appello.dataAppello,
                  style: Constants.fontBold.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Generale',
            style: Constants.fontBold,
          ),
          const SizedBox(height: 5),
          BoxInfo(
            darkModeOn: darkModeOn,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InfoRichText(
                  text: 'Descrizione: ',
                  value: widget.appello.descrizione,
                  fontSize: 14,
                ),
                InfoRichText(
                  text: 'Periodo iscrizioni: ',
                  value: widget.appello.periodoIscrizione,
                  fontSize: 14,
                ),
                InfoRichText(
                  text: 'Sessione: ',
                  value: widget.appello.sessione,
                  fontSize: 14,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          if (_isRequestedAltreInfo)
            _RichiediAltreInfo(
              altreInfo: _altreInfo,
              appello: widget.appello,
              prenotaEsame: widget.prenotaEsame,
              darkModeOn: darkModeOn,
            ),
          Column(
            children: [
              if (!_isRequestedAltreInfo) ...[
                MaterialButton(
                  onPressed: () {
                    setState(() {
                      _isRequestedAltreInfo = !_isRequestedAltreInfo;
                      _altreInfo =
                          Provider.getInfoAppello(widget.appello.linkInfo);
                    });
                  },
                  child: Text('ALTRE INFO',
                      style: TextStyle(
                          color: Theme.of(context).primaryColorLight)),
                ),
                _BottonePromemoriaAppello(
                  appello: widget.appello,
                  otherInfoRequested: false,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ignore: must_be_immutable
class _RichiediAltreInfo extends StatefulWidget {
  _RichiediAltreInfo({
    Key key,
    @required this.altreInfo,
    @required this.appello,
    @required this.prenotaEsame,
    @required this.darkModeOn,
  }) : super(key: key);

  Future<Map<String, dynamic>> altreInfo;
  final AppelloModel appello;
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
            return _ErrorRequestAltreInfo(
                appello: widget.appello, altreInfo: widget.altreInfo);
          case ConnectionState.active:
          case ConnectionState.waiting:
            return _WaitingRequestAltreInfo(appello: widget.appello);
          case ConnectionState.done:
            if (altreInfo.data == null ||
                !(altreInfo.data['success'] as bool) ||
                altreInfo.data['item'] == null) {
              return const Text('Sembra non ci siano risultati...');
            }
            final altreInfoWrapper =
                altreInfo.data['item'] as AltreInfoAppelloWrapper;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Appello',
                  style: Constants.fontBold,
                ),
                const SizedBox(height: 5),
                BoxInfo(
                  darkModeOn: widget.darkModeOn,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InfoRichText(
                        text: 'Tipo esame: ',
                        value: altreInfoWrapper.altreInfo.tipoEsame,
                        fontSize: 14,
                      ),
                      InfoRichText(
                        text: 'Verbalizzazione: ',
                        value: altreInfoWrapper.altreInfo.verbalizzazione,
                        fontSize: 14,
                      ),
                      InfoRichText(
                        text: 'Aula: ',
                        value: altreInfoWrapper.altreInfo.aula,
                        fontSize: 14,
                      ),
                      InfoRichText(
                        text: 'Numero iscritti: ',
                        value: altreInfoWrapper.altreInfo.numIscritti,
                        fontSize: 14,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Docente',
                  style: Constants.fontBold,
                ),
                const SizedBox(height: 5),
                BoxInfo(
                  darkModeOn: widget.darkModeOn,
                  child: Text(altreInfoWrapper.altreInfo.docente,
                      style: Constants.fontBold14),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    _PrenotaEsameButton(
                      altreInfoWrapper: altreInfoWrapper,
                      prenotaEsame: widget.prenotaEsame,
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: _BottonePromemoriaAppello(
                        appello: widget.appello,
                        otherInfoRequested: true,
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

class _WaitingRequestAltreInfo extends StatelessWidget {
  const _WaitingRequestAltreInfo({
    Key key,
    @required this.appello,
  }) : super(key: key);

  final AppelloModel appello;

  @override
  Widget build(BuildContext context) {
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
        _BottonePromemoriaAppello(
          appello: appello,
          otherInfoRequested: false,
        ),
      ],
    );
  }
}

class _BottonePromemoriaAppello extends StatelessWidget {
  const _BottonePromemoriaAppello({
    Key key,
    @required this.appello,
    @required this.otherInfoRequested,
  }) : super(key: key);

  final AppelloModel appello;
  final bool otherInfoRequested;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      minWidth: double.infinity,
      color: Theme.of(context).primaryColorLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50),
      ),
      onPressed: () {
        final event = Event(
          title:
              'Appello: ${appello.nomeMateria} (${appello.descrizione} - ${appello.dataAppello})',
          description:
              "Non dimenticarti di prenotare l'esame e in bocca al lupo!",
          location: 'Esse3',
          startDate: appello.dataAppelloDateTime
              .subtract(const Duration(days: 7))
              .add(const Duration(hours: 10)),
          endDate:
              appello.dataAppelloDateTime.subtract(const Duration(days: 6)),
        );
        Add2Calendar.addEvent2Cal(event);
      },
      child: Text(otherInfoRequested ? 'PROMEMORIA' : 'IMPOSTA PROMEMORIA',
          style: const TextStyle(color: Colors.white)),
    );
  }
}

class _ErrorRequestAltreInfo extends StatefulWidget {
  _ErrorRequestAltreInfo({
    Key key,
    @required this.appello,
    @required this.altreInfo,
  }) : super(key: key);

  final AppelloModel appello;
  Future<Map<String, dynamic>> altreInfo;

  @override
  __ErrorRequestAltreInfoState createState() => __ErrorRequestAltreInfoState();
}

class __ErrorRequestAltreInfoState extends State<_ErrorRequestAltreInfo> {
  @override
  Widget build(BuildContext context) {
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
                        Provider.getInfoAppello(widget.appello.linkInfo);
                  });
                })
          ],
        ),
        _BottonePromemoriaAppello(
          appello: widget.appello,
          otherInfoRequested: false,
        ),
      ],
    );
  }
}

class _PrenotaEsameButton extends StatelessWidget {
  const _PrenotaEsameButton({
    Key key,
    @required this.altreInfoWrapper,
    @required this.prenotaEsame,
  }) : super(key: key);

  final PrenotaEsame prenotaEsame;
  final AltreInfoAppelloWrapper altreInfoWrapper;

  @override
  Widget build(BuildContext context) {
    return Flexible(
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
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) {
              prenotaEsame.altreInfoWrapper = altreInfoWrapper;
              return prenotaEsame;
            },
          );
        },
        child: const Text('PRENOTA', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
