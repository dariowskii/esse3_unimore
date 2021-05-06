import 'package:Esse3/constants.dart';
import 'package:flutter/material.dart';

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
                ? nomeAppello.substring(0, 28) + '...'
                : nomeAppello,
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
                  TextSpan(text: dataAppello, style: Constants.fontBold18)
                ]),
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
                  TextSpan(text: descrizione, style: Constants.fontBold)
                ]),
          ),
        ],
      ),
    );
  }
}
