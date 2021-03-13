import 'package:Esse3/constants.dart';
import 'package:Esse3/utils/provider.dart';
import 'package:Esse3/utils/widgets.dart';
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
      Future.delayed(Duration(milliseconds: 1500), () {
        setState(() {});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var deviceWidth = MediaQuery.of(context).size.width;
    var deviceHeight = MediaQuery.of(context).size.height;
    var darkModeOn = Theme.of(context).brightness == Brightness.dark;
    var isTablet = deviceWidth > Constants.tabletWidth;
    Widget _svgAsset =
        SvgPicture.asset('assets/img/party.svg', width: deviceWidth * 0.7);
    return Scaffold(
      appBar: AppBar(
        title: Text('Esse3'),
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
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bacheca prenotazioni',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 25),
                    ),
                    Divider(),
                    Flexible(
                      child: Container(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Constants.mainColorLighter),
                            ),
                            const SizedBox(height: 15),
                            Text(
                              'Sto scaricando i dati...',
                              style: Constants.font16.copyWith(
                                  color: darkModeOn
                                      ? Colors.white
                                      : Constants.mainColorLighter),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              );
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
              if (appello.data['success']) {
                //In caso non ci siano appelli
                if (appello.data['totali'] == 0) {
                  return LiquidPullToRefresh(
                    animSpeedFactor: 1.5,
                    height: 80,
                    color: Theme.of(context).primaryColorLight,
                    onRefresh: _refreshBacheca,
                    showChildOpacityTransition: false,
                    child: ListView(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bacheca prenotazioni',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 25),
                              ),
                              Divider(),
                              const SizedBox(height: 50),
                              Center(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    _svgAsset,
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Text(
                                      'Nessuna prenotazione',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 32),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      'È tempo di preparare qualche esame e prenotarsi!',
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
                      ],
                    ),
                  );
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
                        Text(
                          'Bacheca prenotazioni',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 25),
                        ),
                        Divider(),
                        const SizedBox(height: 15),
                        ListView.builder(
                          shrinkWrap: true,
                          padding: isTablet
                              ? EdgeInsets.symmetric(
                                  horizontal: deviceWidth / 6)
                              : null,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: appello.data['totali'],
                          itemBuilder: (context, index) {
                            return CardAppelloPrenotato(
                              nomeEsame: appello.data['esame'][index],
                              iscrizione: appello.data['iscrizione'][index],
                              giorno: appello.data['giorno'][index],
                              ora: appello.data['ora'][index],
                              docente: appello.data['docente'][index],
                              formHiddens: appello.data['formHiddens'],
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
