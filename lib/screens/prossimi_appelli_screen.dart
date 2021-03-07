import 'package:Esse3/utils/provider.dart';
import 'package:Esse3/utils/widgets.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

/// Pagina in cui vedere i prossimi appelli.
class ProssimiAppelliScreen extends StatefulWidget {
  static const String id = "prossimiAppelliScreen";
  @override
  _ProssimiAppelliScreenState createState() => _ProssimiAppelliScreenState();
}

class _ProssimiAppelliScreenState extends State<ProssimiAppelliScreen> {
  ///Future dei prossimi appelli per il [FutureBuilder].
  Future<Map> _proxAppelli;

  void _initAppelli() {
    setState(() {
      _proxAppelli = Provider.getAppelli();
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
    bool darkModeOn = Theme.of(context).brightness == Brightness.dark;
    bool isTablet = deviceWidth > Constants.tabletWidth;
    return Scaffold(
      appBar: AppBar(
        title: Text("Esse3"),
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
              _proxAppelli = Provider.getAppelli();
            });
          },
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Container(
              constraints: BoxConstraints(minHeight: deviceHeight - 100),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.vertical(bottom: Radius.circular(20)),
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
                            "Prossimi Appelli",
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
                  FutureBuilder<Map>(
                    future: _proxAppelli,
                    builder: (context, appelli) {
                      switch (appelli.connectionState) {
                        case ConnectionState.none:
                          return ConnectionError(
                              deviceWidth: deviceWidth, isTablet: isTablet);
                        case ConnectionState.waiting:
                          return ShimmerLoader(
                              deviceWidth: deviceWidth, isTablet: isTablet);
                        case ConnectionState.active:
                        case ConnectionState.done:

                          print(appelli.data);
                          if (appelli.data != null &&
                              appelli.data["success"] &&
                              appelli.data["totali"] > 0) {
                            List indexImminenti = [];
                            for (int i = 0; i < appelli.data["totali"]; i++) {
                              DateTime dataOggi = DateTime.now();
                              DateTime dataEsame = DateTime.parse(
                                  appelli.data["data_appello"][i].substring(6) +
                                      appelli.data["data_appello"][i]
                                          .substring(3, 5) +
                                      appelli.data["data_appello"][i]
                                          .substring(0, 2));
                              Duration diffTempo =
                                  dataEsame.difference(dataOggi);
                              if (diffTempo.inDays <= 15)
                                indexImminenti.add(
                                    {'index': i, 'data': dataEsame.toString()});
                            }
                            indexImminenti.sort((a, b) {
                              var adate =
                                  a['data']; //before -> var adate = a.expiry;
                              var bdate = b['data']; //var bdate = b.expiry;
                              return adate.compareTo(bdate);
                            });
                            return Padding(
                              padding: isTablet
                                  ? EdgeInsets.symmetric(
                                      horizontal: deviceWidth / 6)
                                  : EdgeInsets.all(0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding:
                                        EdgeInsets.only(left: 16.0, top: 16),
                                    child: Text("Appelli imminenti",
                                        style: Constants.fontBold24),
                                  ),
                                  Container(
                                    height: 170,
                                    child: ListView.builder(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 15, horizontal: 16),
                                        cacheExtent: 10,
                                        shrinkWrap: true,
                                        scrollDirection: Axis.horizontal,
                                        itemCount: indexImminenti.length,
                                        itemBuilder: (context, index) {
                                          return Container(
                                            margin: index ==
                                                    indexImminenti.length - 1
                                                ? null
                                                : EdgeInsets.only(right: 10),
                                            child: CardAppelloImminente(
                                              deviceWidth: deviceWidth,
                                              isTablet: isTablet,
                                              nomeAppello:
                                                  appelli.data["materia"][
                                                      indexImminenti[index]
                                                          ['index']],
                                              dataAppello:
                                                  appelli.data["data_appello"][
                                                      indexImminenti[index]
                                                          ['index']],
                                              descrizione: appelli.data["desc"][
                                                  indexImminenti[index]
                                                      ['index']],
                                            ),
                                          );
                                        }),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("Tutti gli appelli",
                                            style: Constants.fontBold24),
                                        const SizedBox(height: 15),
                                        ListView.builder(
                                          shrinkWrap: true,
                                          cacheExtent: 30,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          itemCount: appelli.data["totali"],
                                          itemBuilder: (context, index) {
                                            return CardAppello(
                                              nomeAppello: appelli
                                                  .data["materia"][index],
                                              dataAppello: appelli
                                                  .data["data_appello"][index],
                                              descrizione: appelli.data["desc"]
                                                  [index],
                                              periodoIscrizioni: appelli.data[
                                                  "periodo_iscrizione"][index],
                                              sessione: appelli.data["sessione"]
                                                  [index],
                                              linkInfo: appelli
                                                  .data["link_info"][index],
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else if (appelli.data != null &&
                              appelli.data["success"] &&
                              appelli.data["totali"] <= 0) {
                            return NoExams(
                                deviceWidth: deviceWidth, isTablet: isTablet);
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
