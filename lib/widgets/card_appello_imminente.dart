import 'package:Esse3/constants.dart';
import 'package:Esse3/models/appello_model.dart';
import 'package:Esse3/widgets/box_info.dart';
import 'package:flutter/material.dart';

/// Card con poche informazioni sull'appello, utilizzata per gli appelli
/// imminenti in [ProssimiAppelliScreen].
class CardAppelloImminente extends StatelessWidget {
  final String nomeAppello;
  final String dataAppello;
  final String descrizione;
  String get _nomeMateria {
    if (nomeAppello.length > 20) {
      return "${nomeAppello.substring(0, 20)}...";
    }
    return nomeAppello;
  }

  String get _descrizione {
    if (descrizione.length > 60) {
      return "${descrizione.substring(0, 60)}...";
    }
    return descrizione;
  }

  /// Serve per gestire il layout del tablet.
  final bool isTablet;

  /// Larghezza del dispositivo. Serve per gestire il layout del tablet.
  final double deviceWidth;

  const CardAppelloImminente({
    Key key,
    this.nomeAppello,
    this.dataAppello,
    this.descrizione,
    this.isTablet = false,
    this.deviceWidth = 0,
  }) : super(key: key);

  factory CardAppelloImminente.fromAppello(AppelloModel appello) {
    return CardAppelloImminente(
      nomeAppello: appello.nomeMateria,
      dataAppello: appello.dataAppello,
      descrizione: appello.descrizione,
    );
  }

  @override
  Widget build(BuildContext context) {
    final darkModeOn =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      width: isTablet ? 350 : deviceWidth - 70,
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
                  _nomeMateria,
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
                  dataAppello,
                  style: Constants.fontBold.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text('Descrizione', style: Constants.fontBold),
          const SizedBox(height: 5),
          BoxInfo(
            darkModeOn: darkModeOn,
            child: Text(_descrizione),
          ),
        ],
      ),
    );
  }
}
