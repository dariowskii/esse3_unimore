import 'package:Esse3/utils/provider.dart';
import 'package:Esse3/utils/widgets.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

class AppelliPage extends StatefulWidget {
  @override
  _AppelliPageState createState() => _AppelliPageState();
}

class _AppelliPageState extends State<AppelliPage> {
  Future _appelli;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _appelli = Provider.getAppelli();
  }

  @override
  Widget build(BuildContext context) {
    final heightScreen = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: FutureBuilder(
          future: _appelli,
          builder: (context, appelli) {
            switch (appelli.connectionState) {
              case ConnectionState.none:
                return CustomScrollView(
                  physics: ClampingScrollPhysics(),
                  slivers: [
                    SliverAppBar(
                      elevation: 2,
                      collapsedHeight: 60,
                      title: Text(
                        "Esse3",
                        style: const TextStyle(color: Colors.white),
                      ),
                      centerTitle: true,
                      leading: IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.of(context).pop()),
                      backgroundColor: kMainColor_darker,
                      floating: true,
                    ),
                    SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                        decoration: BoxDecoration(
                          color: kMainColor_darker,
                          borderRadius:
                              BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Prossimi appelli",
                                  style: TextStyle(
                                    fontSize: width >= 390 ? 32 : 30,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "Dai uno sguardo agli appelli futuri e imposta un promemoria!",
                                  style: const TextStyle(fontSize: 18, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.all(20),
                      sliver: SliverToBoxAdapter(
                        child: Container(
                          height: heightScreen * 0.6,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Image(
                                width: 200,
                                image: AssetImage('assets/img/conn_problem.png'),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Text(
                                "Oops..",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
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
                      ),
                    )
                  ],
                );
              case ConnectionState.waiting:
                return CustomScrollView(
                  physics: ClampingScrollPhysics(),
                  slivers: [
                    SliverAppBar(
                      elevation: 2,
                      collapsedHeight: 60,
                      title: Text(
                        "Esse3",
                        style: const TextStyle(color: Colors.white),
                      ),
                      centerTitle: true,
                      leading: IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.of(context).pop()),
                      backgroundColor: kMainColor_darker,
                      floating: true,
                    ),
                    SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                        decoration: BoxDecoration(
                          color: kMainColor_darker,
                          borderRadius:
                              BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Prossimi appelli",
                                  style: TextStyle(
                                    fontSize: width >= 390 ? 32 : 30,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "Dai uno sguardo agli appelli futuri e imposta un promemoria!",
                                  style: const TextStyle(fontSize: 18, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                        padding: const EdgeInsets.all(20),
                        sliver: SliverToBoxAdapter(
                          child: Container(
                            width: double.infinity,
                            height: heightScreen * 0.6,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(kMainColor_darker),
                                  ),
                                  const SizedBox(height: 15),
                                  Text(
                                    "Solo un secondo...",
                                    style: const TextStyle(color: Color(0xffFF5800), fontSize: 16),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ))
                  ],
                );
              case ConnectionState.active:
              case ConnectionState.done:
                if (appelli.data["success"] && appelli.data["totali"] == 0)
                  return CustomScrollView(
                    physics: ClampingScrollPhysics(),
                    slivers: [
                      SliverAppBar(
                        elevation: 2,
                        collapsedHeight: 60,
                        title: Text(
                          "Esse3",
                          style: const TextStyle(color: Colors.white),
                        ),
                        centerTitle: true,
                        leading: IconButton(
                            icon: Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                            onPressed: () => Navigator.of(context).pop()),
                        backgroundColor: kMainColor_darker,
                        floating: true,
                      ),
                      SliverToBoxAdapter(
                        child: Container(
                          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                          decoration: BoxDecoration(
                            color: kMainColor_darker,
                            borderRadius:
                                BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Prossimi appelli",
                                    style: TextStyle(
                                      fontSize: width >= 390 ? 32 : 30,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "Dai uno sguardo agli appelli futuri e imposta un promemoria!",
                                    style: const TextStyle(fontSize: 18, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SliverPadding(
                          padding: const EdgeInsets.all(32),
                          sliver: SliverToBoxAdapter(
                            child: Container(
                              height: heightScreen * 0.6,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Image(
                                    width: 200,
                                    image: AssetImage('assets/img/no_results.png'),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    "Yuhuhh!",
                                    style: const TextStyle(
                                        color: Colors.black87, fontSize: 25, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "Sembra non ci siano appelli al momento!",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 22,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ))
                    ],
                  );
                //Se la connessione è ok e ci sono risultati...
                return CustomScrollView(
                  physics: ClampingScrollPhysics(),
                  slivers: [
                    SliverAppBar(
                      elevation: 2,
                      collapsedHeight: 60,
                      title: Text(
                        "Esse3",
                        style: const TextStyle(color: Colors.white),
                      ),
                      centerTitle: true,
                      leading: IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.of(context).pop()),
                      backgroundColor: kMainColor_darker,
                      floating: true,
                    ),
                    SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                        decoration: BoxDecoration(
                          color: kMainColor_darker,
                          borderRadius:
                              BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Prossimi appelli",
                                  style: TextStyle(
                                    fontSize: width >= 390 ? 32 : 30,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "Dai uno sguardo agli appelli futuri e imposta un promemoria!",
                                  style: const TextStyle(fontSize: 18, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.all(width >= 390 ? 20 : 15),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return CardAppello(
                            nomeMateria: appelli.data["materia"][index],
                            dataAppello: appelli.data["data_appello"][index],
                            desc: appelli.data["desc"][index],
                            periodoIscrizioni: appelli.data["periodo_iscrizione"][index],
                            sessione: appelli.data["sessione"][index],
                            urlInfo: appelli.data["link_info"][index],
                          );
                        }, childCount: appelli.data["totali"]),
                      ),
                    )
                  ],
                );
              default:
                return Text("Errore FutureBuilder appelli");
            }
          }),
    );
  }
}
