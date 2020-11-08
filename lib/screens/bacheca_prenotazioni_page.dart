import 'package:Esse3/constants.dart';
import 'package:Esse3/utils/provider.dart';
import 'package:Esse3/utils/widgets.dart';
import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class BachecaPrenotazioniPage extends StatefulWidget {
  @override
  _BachecaPrenotazioniPageState createState() =>
      _BachecaPrenotazioniPageState();
}

class _BachecaPrenotazioniPageState extends State<BachecaPrenotazioniPage> {
  Future<Map> _appelli;

  @override
  void initState() {
    _appelli = Provider.getAppelliPrenotati();
    super.initState();
  }

  Future<void> _refreshBacheca() {
    return _appelli = Provider.getAppelliPrenotati().whenComplete((){
      Future.delayed(Duration(milliseconds: 1500), (){
        setState(() {

        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text("Esse3"),
        centerTitle: true,
        brightness: Brightness.light,
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: _appelli,
          builder: (context, appello) {
            // ignore: missing_return
            switch (appello.connectionState) {
              case ConnectionState.none:
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Bacheca prenotazioni",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 25),
                      ),
                      Divider(),
                      Flexible(
                        child: Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Image(
                                width: width * 0.7,
                                image: AssetImage('assets/img/conn_problem.png'),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Text(
                                "Oops..",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 32),
                              ),
                              SizedBox(height: 10),
                              Text(
                                "Ci sono problemi nel recuperare i tuoi dati, aggiorna oppure riprova tra un pò!",
                                softWrap: true,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 20,
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                );
              case ConnectionState.waiting:
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Bacheca prenotazioni",
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
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(kMainColor),
                              ),
                              const SizedBox(height: 15),
                              Text(
                                "Sto scaricando i dati...",
                                style: TextStyle(color: kMainColor, fontSize: 16),
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
                if (appello.data != null && appello.data["success"]) {
                  if (appello.data["totali"] == 0) {
                    return LiquidPullToRefresh(
                      animSpeedFactor: 1.5,
                      height: 80,
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
                                  "Bacheca prenotazioni",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 25),
                                ),
                                Divider(),
                                SizedBox(height: height * 0.1),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Image(
                                      width: width * 0.7,
                                      image: AssetImage('assets/img/no_exams.png'),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Text(
                                      "Nessuna prenotazione",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 32),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      "È tempo di preparare qualche esame e prenotarsi!",
                                      softWrap: true,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 20,
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return LiquidPullToRefresh(
                    animSpeedFactor: 1.5,
                    height: 80,
                    onRefresh: _refreshBacheca,
                    showChildOpacityTransition: false,
                    child: CustomScrollView(
                        slivers: [
                          SliverPadding(
                            padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
                            sliver: SliverToBoxAdapter(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Bacheca prenotazioni",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 25),
                                  ),
                                  Divider(),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ),
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  return CardAppelloPrenotato(
                                    esame: appello.data["esame"][index],
                                    iscrizione: appello.data["iscrizione"][index],
                                    giorno: appello.data["giorno"][index],
                                    ora: appello.data["ora"][index],
                                    docente: appello.data["docente"][index],
                                    formHiddens: appello.data["formHiddens"],
                                    index: index,
                                  );
                                },
                                childCount: appello.data["totali"],
                              ),
                            ),
                          )
                        ]),
                  );
                }
                return Container();

              default:
                return Center(
                  child: Text("Errore Future Builder"),
                );
            }
          },
        ),
      ),
    );
  }
}
