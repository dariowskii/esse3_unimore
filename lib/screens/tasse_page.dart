import 'package:Esse3/utils/provider.dart';
import 'package:Esse3/utils/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TassePage extends StatefulWidget {
  @override
  _TassePageState createState() => _TassePageState();
}

class _TassePageState extends State<TassePage> {
  Future _tasse;

  @override
  void initState() {
    super.initState();

    _tasse = Provider.getTasse();
  }

  @override
  Widget build(BuildContext context) {
    final heightScreen = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      // body: FutureBuilder(
      //     future: _tasse,
      //     builder: (context, tasse) {
      //       switch (tasse.connectionState) {
      //         case ConnectionState.none:
      //           return Padding(
      //             padding: EdgeInsets.all(32.0),
      //             child: Center(
      //               child: Column(
      //                 crossAxisAlignment: CrossAxisAlignment.center,
      //                 mainAxisAlignment: MainAxisAlignment.center,
      //                 mainAxisSize: MainAxisSize.max,
      //                 children: <Widget>[
      //                   Image(
      //                     width: 200,
      //                     image: AssetImage('assets/img/conn_problem.png'),
      //                   ),
      //                   SizedBox(
      //                     height: 20,
      //                   ),
      //                   Text(
      //                     "Oops..",
      //                     style: TextStyle(
      //                         fontWeight: FontWeight.bold, fontSize: 32),
      //                   ),
      //                   SizedBox(height: 10),
      //                   Text(
      //                     "Ci sono problemi nel recuperare i tuoi dati, aggiorna oppure riprova tra un pò!",
      //                     softWrap: true,
      //                     textAlign: TextAlign.center,
      //                     style: TextStyle(
      //                       fontWeight: FontWeight.w500,
      //                       fontSize: 20,
      //                     ),
      //                   )
      //                 ],
      //               ),
      //             ),
      //           );
      //         case ConnectionState.waiting:
      //           return Center(
      //             child: CircularProgressIndicator(
      //               valueColor:
      //                   AlwaysStoppedAnimation<Color>(kMainColor_darker),
      //             ),
      //           );
      //         case ConnectionState.active:
      //         case ConnectionState.done:
      //           if (tasse.data == null)
      //             return Padding(
      //               padding: EdgeInsets.all(32.0),
      //               child: Center(
      //                 child: Column(
      //                   crossAxisAlignment: CrossAxisAlignment.center,
      //                   mainAxisAlignment: MainAxisAlignment.center,
      //                   mainAxisSize: MainAxisSize.max,
      //                   children: <Widget>[
      //                     Image(
      //                       width: 200,
      //                       image: AssetImage('assets/img/conn_problem.png'),
      //                     ),
      //                     SizedBox(
      //                       height: 20,
      //                     ),
      //                     Text(
      //                       "Oops..",
      //                       style: TextStyle(
      //                           fontWeight: FontWeight.bold, fontSize: 32),
      //                     ),
      //                     SizedBox(height: 10),
      //                     Text(
      //                       "Ci sono problemi nel recuperare i tuoi dati, aggiorna oppure riprova tra un pò!",
      //                       softWrap: true,
      //                       textAlign: TextAlign.center,
      //                       style: TextStyle(
      //                         fontWeight: FontWeight.w500,
      //                         fontSize: 20,
      //                       ),
      //                     )
      //                   ],
      //                 ),
      //               ),
      //             );
      //           _updateNumTasse(tasse.data["da_pagare"]);
      //           return ListView.builder(
      //             padding: EdgeInsets.all(24),
      //             itemCount: tasse.data["totali"],
      //             itemBuilder: (context, index) {
      //               return CardTassa(
      //                 desc: tasse.data["desc"][index],
      //                 pagamento: tasse.data["stato_pagamento"][index],
      //                 scadenza: tasse.data["scadenza"][index],
      //                 euro: tasse.data["importi"][index],
      //               );
      //             },
      //           );
      //         default:
      //           return Center(child: Text("Errore FutureBuilder tasse!"));
      //       }
      //     }),
      body: FutureBuilder(
          future: _tasse,
          builder: (context, tasse) {
            switch (tasse.connectionState) {
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
                      backgroundColor: Colors.redAccent,
                      floating: true,
                    ),
                    SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius:
                              BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Flex(
                              direction: Axis.horizontal,
                              children: [
                                Flexible(
                                  flex: 6,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Tasse universitarie",
                                        style: TextStyle(
                                          fontSize: width >= 390 ? 32 : 30,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        "Qui puoi guardare lo storico delle tasse universitarie.",
                                        style: const TextStyle(fontSize: 18, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                                Flexible(
                                  flex: 1,
                                  child: Center(
                                    child: Icon(
                                      Icons.attach_money,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
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
              // return Padding(
              //   padding: EdgeInsets.all(32.0),
              //   child: Center(
              //     child: Column(
              //       crossAxisAlignment: CrossAxisAlignment.center,
              //       mainAxisAlignment: MainAxisAlignment.center,
              //       mainAxisSize: MainAxisSize.max,
              //       children: <Widget>[
              //         Image(
              //           width: 200,
              //           image: AssetImage('assets/img/conn_problem.png'),
              //         ),
              //         SizedBox(
              //           height: 20,
              //         ),
              //         Text(
              //           "Oops..",
              //           style: TextStyle(
              //               fontWeight: FontWeight.bold, fontSize: 32),
              //         ),
              //         SizedBox(height: 10),
              //         Text(
              //           "Ci sono problemi nel recuperare i tuoi dati, aggiorna oppure riprova tra un pò!",
              //           softWrap: true,
              //           textAlign: TextAlign.center,
              //           style: TextStyle(
              //             fontWeight: FontWeight.w500,
              //             fontSize: 20,
              //           ),
              //         )
              //       ],
              //     ),
              //   ),
              // );
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
                      backgroundColor: Colors.redAccent,
                      floating: true,
                    ),
                    SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius:
                              BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Flex(
                              direction: Axis.horizontal,
                              children: [
                                Flexible(
                                  flex: 6,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Tasse universitarie",
                                        style: TextStyle(
                                          fontSize: width >= 390 ? 32 : 30,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        "Qui puoi guardare lo storico delle tasse universitarie.",
                                        style: const TextStyle(fontSize: 18, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                                Flexible(
                                  flex: 1,
                                  child: Center(
                                    child: Icon(
                                      Icons.attach_money,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
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
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent),
                                ),
                                const SizedBox(height: 15),
                                Text(
                                  "Solo un secondo...",
                                  style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                );
              // return Center(
              //   child: Column(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: [
              //       CircularProgressIndicator(
              //         valueColor:
              //             AlwaysStoppedAnimation<Color>(Colors.redAccent),
              //       ),
              //       const SizedBox(height: 15),
              //       Text(
              //         "Solo un secondo...",
              //         style: const TextStyle(
              //             color: Colors.redAccent, fontSize: 16),
              //       )
              //     ],
              //   ),
              // );
              case ConnectionState.active:
              case ConnectionState.done:
                if (tasse.data["success"] && tasse.data["totali"] == 0)
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
                        backgroundColor: Colors.redAccent,
                        floating: true,
                      ),
                      SliverToBoxAdapter(
                        child: Container(
                          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius:
                                BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Flex(
                                direction: Axis.horizontal,
                                children: [
                                  Flexible(
                                    flex: 6,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Tasse universitarie",
                                          style: TextStyle(
                                            fontSize: width >= 390 ? 32 : 30,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          "Qui puoi guardare lo storico delle tasse universitarie.",
                                          style: const TextStyle(fontSize: 18, color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Flexible(
                                    flex: 1,
                                    child: Center(
                                      child: Icon(
                                        Icons.attach_money,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
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
                                  image: AssetImage('assets/img/no_tax.png'),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    "Non hai nessuna tassa registrata!",
                                    softWrap: true,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 25,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  );
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
                      backgroundColor: Colors.redAccent,
                      floating: true,
                    ),
                    SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius:
                              BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Flex(
                              direction: Axis.horizontal,
                              children: [
                                Flexible(
                                  flex: 6,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Tasse universitarie",
                                        style: TextStyle(
                                          fontSize: width >= 390 ? 32 : 30,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        "Qui puoi guardare lo storico delle tasse universitarie.",
                                        style: const TextStyle(fontSize: 18, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                                Flexible(
                                  flex: 1,
                                  child: Center(
                                    child: Icon(
                                      Icons.attach_money,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
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
                          return CardTassa(
                            desc: tasse.data["desc"][index],
                            pagamento: tasse.data["stato_pagamento"][index],
                            scadenza: tasse.data["scadenza"][index],
                            euro: tasse.data["importi"][index],
                          );
                        }, childCount: tasse.data["totali"]),
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
