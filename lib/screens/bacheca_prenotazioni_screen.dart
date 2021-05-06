import 'package:Esse3/constants.dart';
import 'package:Esse3/utils/provider.dart';
import 'package:Esse3/widgets/card_appello_prenotato.dart';
import 'package:Esse3/widgets/loading_bacheca_prenotazioni.dart';
import 'package:Esse3/widgets/reload_appelli_widget.dart';
import 'package:Esse3/widgets/ricarica_bacheca_prenotazioni.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

/// Pagina in cui vedere la bacheca prenotazioni.
class BachecaPrenotazioniScreen extends StatefulWidget {
  static const String id = 'bachecaPrenotazioniScreen';
  @override
  _BachecaPrenotazioniScreenState createState() =>
      _BachecaPrenotazioniScreenState();
}

class _BachecaPrenotazioniScreenState extends State<BachecaPrenotazioniScreen> {
  /// Future degli appelli per il [FutureBuilder].
  Future<Map> _appelli;

  @override
  void initState() {
    _appelli = Provider.getAppelliPrenotati();
    super.initState();
  }

  /// Ricarica la bacheca.
  Future<void> _refreshBacheca() {
    return _appelli = Provider.getAppelliPrenotati().whenComplete(() {
      Future.delayed(const Duration(milliseconds: 1500), () {
        setState(() {});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;
    final darkModeOn = Theme.of(context).brightness == Brightness.dark;
    final isTablet = deviceWidth > Constants.tabletWidth;
    final _svgAsset =
        SvgPicture.asset('assets/img/party.svg', width: deviceWidth * 0.7);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Esse3'),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: _appelli,
        builder: (context, appello) {
          switch (appello.connectionState) {
            case ConnectionState.none:
              return ReloadAppelli(
                deviceWidth: deviceWidth,
                deviceHeight: deviceHeight,
                onReload: _refreshBacheca,
              );
            case ConnectionState.waiting:
              return LoadingBachecaPrenotazioni(darkModeOn: darkModeOn);
            case ConnectionState.active:
            case ConnectionState.done:
              //In caso di risposta nulla..
              if (appello.data == null) {
                return ReloadAppelli(
                  deviceWidth: deviceWidth,
                  deviceHeight: deviceHeight,
                  onReload: _refreshBacheca,
                );
              }
              if (appello.data['success'] as bool) {
                //In caso non ci siano appelli
                if (appello.data['totali'] == 0) {
                  return RicaricaBachecaPrenotazioni(
                      refreshBacheca: _refreshBacheca, svgAsset: _svgAsset);
                }
                //In caso ci siano appelli...
                return LiquidPullToRefresh(
                  animSpeedFactor: 1.5,
                  height: 80,
                  color: Theme.of(context).primaryColorLight,
                  onRefresh: _refreshBacheca,
                  showChildOpacityTransition: false,
                  child: SingleChildScrollView(
                      child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bacheca prenotazioni',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 25),
                        ),
                        const Divider(),
                        const SizedBox(height: 15),
                        ListView.builder(
                          shrinkWrap: true,
                          padding: isTablet
                              ? EdgeInsets.symmetric(
                                  horizontal: deviceWidth / 6)
                              : null,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: appello.data['totali'] as int,
                          itemBuilder: (context, index) {
                            return CardAppelloPrenotato(
                              nomeEsame: appello.data['esame'][index] as String,
                              iscrizione:
                                  appello.data['iscrizione'][index] as String,
                              giorno: appello.data['giorno'][index] as String,
                              ora: appello.data['ora'][index] as String,
                              docente: appello.data['docente'][index] as String,
                              formHiddens: appello.data['formHiddens'] as Map,
                              index: index,
                              darkModeOn: darkModeOn,
                              isTablet: isTablet,
                            );
                          },
                        ),
                      ],
                    ),
                  )),
                );
              } else {
                return ReloadAppelli(
                  deviceWidth: deviceWidth,
                  deviceHeight: deviceHeight,
                  onReload: _refreshBacheca,
                );
              }
              //In caso di altri errori...
              return ReloadAppelli(
                deviceWidth: deviceWidth,
                deviceHeight: deviceHeight,
                onReload: _refreshBacheca,
              );
            default:
              return ReloadAppelli(
                deviceWidth: deviceWidth,
                deviceHeight: deviceHeight,
                onReload: _refreshBacheca,
              );
          }
        },
      ),
    );
  }
}
