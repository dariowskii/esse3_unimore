import 'package:Esse3/constants.dart';
import 'package:Esse3/models/appello_prenotato_model.dart';
import 'package:Esse3/utils/provider.dart';
import 'package:Esse3/widgets/box_info.dart';
import 'package:Esse3/widgets/info_rich_text.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Card rappresentativa dell'appello prenotato in `BachecaPrenotazioniScreen`.
class CardAppelloPrenotato extends StatelessWidget {
  final bool darkModeOn;
  final bool isTablet;
  final AppelloPrenotatoModel appello;

  const CardAppelloPrenotato({
    Key? key,
    required this.appello,
    this.darkModeOn = false,
    this.isTablet = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        color: darkModeOn ? Theme.of(context).cardColor : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.08),
            offset: const Offset(0, 3),
            blurRadius: 8,
            spreadRadius: 5,
          )
        ],
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
                  appello.nomeMateria,
                  style: isTablet
                      ? Constants.fontBold28.copyWith(
                          color: darkModeOn
                              ? Constants.mainColorDarkLighter
                              : Constants.mainColorLighter)
                      : Constants.fontBold20.copyWith(
                          color: darkModeOn
                              ? Constants.mainColorDarkLighter
                              : Constants.mainColorLighter),
                ),
              ),
              const SizedBox(width: 10),
              BoxInfo(
                darkModeOn: darkModeOn,
                minWidth: null,
                backgroundColor: Theme.of(context).primaryColorLight,
                child: Text(
                  appello.dataAppello,
                  style: Constants.fontBold.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          const Text('Generale', style: Constants.fontBold),
          const SizedBox(height: 5),
          BoxInfo(
            darkModeOn: darkModeOn,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InfoRichText(
                  text: 'Svolgimento: ',
                  value: appello.svolgimento,
                ),
                InfoRichText(
                    text: 'Codice esame: ', value: appello.codiceEsame),
                InfoRichText(text: 'Ora: ', value: appello.oraAppello),
                InfoRichText(
                    text: 'Numero iscrizione: ', value: appello.iscrizione),
                InfoRichText(text: 'Tipologia: ', value: appello.tipoEsame),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Text('Docente', style: Constants.fontBold),
          const SizedBox(height: 5),
          BoxInfo(
            darkModeOn: darkModeOn,
            child: Text(
              appello.docenti,
              style: Constants.fontBold14,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // _CancellaEsameButton(
              //   darkModeOn: darkModeOn,
              //   appello: appello,
              // ),
              // const SizedBox(width: 10),
              _PromemoriaAppello(
                darkModeOn: darkModeOn,
                nomeEsame: appello.nomeMateria,
                appello: appello,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PromemoriaAppello extends StatelessWidget {
  final bool darkModeOn;
  final String nomeEsame;
  final AppelloPrenotatoModel appello;

  const _PromemoriaAppello({
    Key? key,
    required this.darkModeOn,
    required this.nomeEsame,
    required this.appello,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: MaterialButton(
        elevation: 3,
        minWidth: double.maxFinite,
        color: darkModeOn ? Constants.mainColorDarkLighter : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        onPressed: () {
          final event = Event(
            title: '$nomeEsame - ${appello.dataAppello}',
            location: 'Università di Modena e Reggio Emilia',
            startDate:
                appello.dataAppelloDateTime.subtract(const Duration(days: 3)),
            endDate:
                appello.dataAppelloDateTime.subtract(const Duration(days: 3)),
            description:
                'Appello di $nomeEsame per il giorno ${appello.dataAppello} alle ore ${appello.oraAppello}',
            allDay: true,
          );

          Add2Calendar.addEvent2Cal(event);
        },
        child: Text('PROMEMORIA',
            style: TextStyle(
                color: darkModeOn ? Colors.white : Constants.mainColor)),
      ),
    );
  }
}

class _CancellaEsameButton extends StatelessWidget {
  final bool? darkModeOn;
  final AppelloPrenotatoModel? appello;

  const _CancellaEsameButton({
    Key? key,
    this.darkModeOn,
    this.appello,
  }) : super(key: key);

  Future<void> _proponiCancellazioneEsame(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Constants.getAskingModalBottomSheet(
          context,
          onAccepted: () => _cancellaPrenotazione(context),
          title: 'Cancella prenotazione',
          text: 'Sei sicuro di voler cancellare la prenotazione?',
        );
      },
    );
  }

  void _cancellaPrenotazione(BuildContext context) {
    Constants.showAdaptiveWaitingDialog(context);

    Provider.cancellaAppello(
            appello!.hiddensCancellazione, appello!.linkCancellazione)
        .then((success) {
      if (success != null) {
        Constants.showAdaptiveDialog(
          context,
          success: success,
          successText: 'Prenotazione cancellata!',
          errorText: 'Errore nella cancellazione',
        );
      } else {
        Constants.showAdaptiveDialog(
          context,
          success: false,
          successText: 'Prenotazione cancellata!',
          errorText: 'Errore nella cancellazione',
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: MaterialButton(
        elevation: 2,
        minWidth: double.maxFinite,
        color: Colors.redAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        onPressed: () => _proponiCancellazioneEsame(context),
        child: const Text('CANCELLATI', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
