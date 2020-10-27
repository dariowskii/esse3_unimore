import 'package:Esse3/constants.dart';
import 'package:Esse3/utils/widgets.dart';
import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:flutter/material.dart';

class OrarioLezioniPage extends StatefulWidget {
  @override
  _OrarioLezioniPageState createState() => _OrarioLezioniPageState();
}

class _OrarioLezioniPageState extends State<OrarioLezioniPage> {
  //TODO: inizializzare l'array in maniera dinamica, creare tabella nel database con relativi metodi
  List<List<Widget>> listaOrari = [
    [
      CardOrario(
        isTutorial: true,
      )
    ],
    [],
    [],
    [],
    [],
    []
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: DefaultTabController(
          length: 6,
          child: NestedScrollView(
            physics: NeverScrollableScrollPhysics(),
            body: TabBarView(children: [
              TabOrarioSettimanale(indiceGiorno: 1, listaOrario: listaOrari),
              TabOrarioSettimanale(indiceGiorno: 2, listaOrario: listaOrari),
              TabOrarioSettimanale(indiceGiorno: 3, listaOrario: listaOrari),
              TabOrarioSettimanale(indiceGiorno: 4, listaOrario: listaOrari),
              TabOrarioSettimanale(indiceGiorno: 5, listaOrario: listaOrari),
              TabOrarioSettimanale(indiceGiorno: 6, listaOrario: listaOrari),
            ]),
            headerSliverBuilder: (context, isScrolled) {
              return [
                SliverAppBar(
                  elevation: 2,
                  expandedHeight: 170,
                  collapsedHeight: 170,
                  flexibleSpace: OrarioSettimanaleView(),
                  leading: SizedBox.shrink(),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(height: 10),
                ),
                SliverPersistentHeader(
                  floating: true,
                  pinned: true,
                  delegate: OrarioSettimanaleDelegate(
                    TabBar(
                      labelColor: Colors.white,
                      unselectedLabelColor: kMainColor_extraDark,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicator: BubbleTabIndicator(indicatorColor: kMainColor_extraDark, indicatorHeight: 36),
                      tabs: [
                        Tab(text: "LUN"),
                        Tab(text: "MAR"),
                        Tab(text: "MER"),
                        Tab(text: "GIO"),
                        Tab(text: "VEN"),
                        Tab(text: "SAB"),
                      ],
                    ),
                  ),
                )
              ];
            },
          ),
        ),
      ),
    );
  }
}
