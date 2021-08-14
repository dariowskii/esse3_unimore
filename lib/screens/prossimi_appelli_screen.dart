import 'package:Esse3/models/altre_info_appello_model.dart';
import 'package:Esse3/models/appello_model.dart';
import 'package:Esse3/utils/provider.dart';
import 'package:Esse3/widgets/card_appello.dart';
import 'package:Esse3/widgets/card_appello_imminente.dart';
import 'package:Esse3/widgets/connection_error.dart';
import 'package:Esse3/widgets/no_exams_widget.dart';
import 'package:Esse3/widgets/shimmer_loader.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

/// Pagina in cui vedere i prossimi appelli.
class ProssimiAppelliScreen extends StatefulWidget {
  static const String id = 'prossimiAppelliScreen';
  @override
  _ProssimiAppelliScreenState createState() => _ProssimiAppelliScreenState();
}

class _ProssimiAppelliScreenState extends State<ProssimiAppelliScreen> {
  ///Future dei prossimi appelli per il [FutureBuilder].
  Future<Map<String, dynamic>> _prossimiAppelli;

  void _initAppelli() {
    setState(() {
      _prossimiAppelli = Provider.getAppelli();
    });
  }

  @override
  void initState() {
    super.initState();
    _initAppelli();
  }

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;
    final darkModeOn = Theme.of(context).brightness == Brightness.dark;
    final isTablet = deviceWidth > Constants.tabletWidth;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Esse3'),
        centerTitle: true,
        backgroundColor: darkModeOn
            ? Theme.of(context).cardColor
            : Constants.mainColorLighter,
      ),
      body: Theme(
        data: Theme.of(context).copyWith(accentColor: Colors.transparent),
        child: RefreshIndicator(
          displacement: Constants.refreshDisplacement,
          color: Theme.of(context).primaryColorLight,
          onRefresh: () async {
            setState(() {
              _prossimiAppelli = Provider.getAppelli();
            });
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Container(
              constraints: BoxConstraints(minHeight: deviceHeight - 100),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(20)),
                      color: darkModeOn
                          ? Theme.of(context).cardColor
                          : Constants.mainColorLighter,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 32, horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Prossimi Appelli',
                            style: Constants.fontBold32.copyWith(
                                color: darkModeOn
                                    ? Theme.of(context).primaryColorLight
                                    : Colors.white),
                          ),
                          Text(
                            "Dai un'occhiata ai tuoi appelli futuri!",
                            style: darkModeOn
                                ? Constants.font16
                                : Constants.font16
                                    .copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  FutureBuilder<Map<String, dynamic>>(
                    future: _prossimiAppelli,
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.none:
                          return ConnectionError(
                              deviceWidth: deviceWidth, isTablet: isTablet);
                        case ConnectionState.waiting:
                          return ShimmerLoader(
                              deviceWidth: deviceWidth, isTablet: isTablet);
                        case ConnectionState.active:
                        case ConnectionState.done:
                          if (snapshot.data != null &&
                              (snapshot.data['success'] as bool) &&
                              snapshot.data['item'] != null) {
                            final appelliWrapper =
                                snapshot.data['item'] as AppelliWrapper;
                            // In caso non ci siano appelli
                            if (appelliWrapper.totaleApelli <= 0) {
                              return NoExams(
                                  deviceWidth: deviceWidth, isTablet: isTablet);
                            }
                            // In caso ci siano appelli
                            return _ProssimiAppelliBody(
                                isTablet: isTablet,
                                deviceWidth: deviceWidth,
                                appelliWrapper: appelliWrapper);
                          }
                          return ConnectionError(
                              deviceWidth: deviceWidth, isTablet: isTablet);
                        default:
                          return ConnectionError(
                              deviceWidth: deviceWidth, isTablet: isTablet);
                      }
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProssimiAppelliBody extends StatelessWidget {
  const _ProssimiAppelliBody({
    Key key,
    @required this.isTablet,
    @required this.deviceWidth,
    @required this.appelliWrapper,
  }) : super(key: key);

  final bool isTablet;
  final double deviceWidth;
  final AppelliWrapper appelliWrapper;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: isTablet
          ? EdgeInsets.symmetric(horizontal: deviceWidth / 6)
          : const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (appelliWrapper.appelliImminenti.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.only(left: 16.0, top: 16),
              child: Text('Appelli imminenti', style: Constants.fontBold24),
            ),
            SizedBox(
              height: 200,
              child: ListView.separated(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
                cacheExtent: 10,
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: appelliWrapper.appelliImminenti.length,
                itemBuilder: (context, index) {
                  final appello = appelliWrapper.appelliImminenti[index];
                  return CardAppelloImminente(
                    deviceWidth: deviceWidth,
                    isTablet: isTablet,
                    nomeAppello: appello.nomeMateria,
                    dataAppello: appello.dataAppello,
                    descrizione: appello.descrizione,
                  );
                },
                separatorBuilder: (context, index) => const SizedBox(width: 10),
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tutti gli appelli', style: Constants.fontBold24),
                const SizedBox(height: 15),
                ListView.builder(
                  shrinkWrap: true,
                  cacheExtent: 30,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: appelliWrapper.totaleApelli,
                  itemBuilder: (context, index) {
                    final appello = appelliWrapper.appelli[index];

                    return CardAppello.fromAppelloModel(
                        appello, PrenotaEsame());
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PrenotaEsame extends StatelessWidget {
  PrenotaEsame({
    Key key,
    this.altreInfoWrapper,
  }) : super(key: key);

  AltreInfoAppelloWrapper altreInfoWrapper;

  void _prenotaEsame(BuildContext context) {
    Constants.showAdaptiveWaitingDialog(context);

    Provider.prenotaAppello(altreInfoWrapper).then(
      (result) {
        if (result != null) {
          Constants.showAdaptiveDialog(
            context,
            success: result['success'] as bool,
            successText: 'Prenotazione effettuata!',
            errorText: 'Errore prenotazione',
          );
        } else {
          Constants.showAdaptiveDialog(
            context,
            success: false,
            successText: 'Prenotazione effettuata!',
            errorText: 'Errore prenotazione',
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Constants.getAskingModalBottomSheet(
      context,
      onAccepted: () => _prenotaEsame(context),
      title: 'Prenotazione appello',
      text: 'Sei sicuro di volerti prenotare?',
    );
  }
}
