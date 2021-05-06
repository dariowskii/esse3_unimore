import 'dart:math';
import 'package:Esse3/constants.dart';
import 'package:Esse3/utils/provider.dart';
import 'package:Esse3/widgets/connection_error.dart';
import 'package:Esse3/widgets/shimmer_loader.dart';
import 'package:Esse3/widgets/tassa_expansion_tile.dart';
import 'package:flutter/material.dart';

/// Pagina in cui vedere le tasse universitarie.
class TasseScreen extends StatefulWidget {
  static const String id = 'tasseScreen';
  @override
  _TasseScreenState createState() => _TasseScreenState();
}

class _TasseScreenState extends State<TasseScreen> {
  /// Future delle tasse per il [FutureBuilder].
  Future<Map> _tasse;

  /// Lista di citazioni sulle tasse.
  final List<String> _citTasse = [
    '"Credo che dovremmo tutti pagare le nostre tasse con un sorriso. Io ci ho provato, ma hanno voluto dei contanti."\n\n(Anonimo)',
    'Bisognerebbe tassare la frase "diminuiremo le tasse."\n\n(Anonimo)',
    '"In questo mondo non vi è nulla di sicuro, tranne la morte e le tasse."\n\n(B. Franklin)',
    '"Nessuno è patriottico quando si tratta di pagare le tasse."\n\n(G. Orwell)',
    '"La cosa più difficile al mondo è capire la tassa sul reddito."\n\n(A. Einstein)',
    'Sai qual è il colmo delle tasse? Nessuno.\nLe tasse non fanno ridere.\n\n(Anonimo)',
    '"Quando una nazione tenta di tassare se stessa per raggiungere la prosperità è come se un uomo si mettesse in piedi dentro un secchio e cercasse di sollevarsi per il manico."\n\n(W. Churchill)',
  ];

  /// Numero random per estrarre a caso la citazione.
  Random _rand;

  @override
  void initState() {
    super.initState();
    _tasse = Provider.getTasse();
    _rand = Random();
  }

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;
    var darkModeOn = Theme.of(context).brightness == Brightness.dark;
    var isTablet = deviceWidth > Constants.tabletWidth;
    return Scaffold(
      appBar: AppBar(
        title: Text('Esse3'),
        centerTitle: true,
        backgroundColor:
            darkModeOn ? Theme.of(context).cardColor : Colors.redAccent,
      ),
      body: RefreshIndicator(
        displacement: Constants.refreshDisplacement,
        color: Colors.redAccent,
        onRefresh: () async {
          setState(() {
            _tasse = Provider.getTasse();
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
                        : Colors.redAccent,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 32, horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tasse',
                                style: Constants.fontBold32.copyWith(
                                    color: darkModeOn
                                        ? Colors.redAccent
                                        : Colors.white),
                              ),
                              Text(
                                'Qui puoi vedere lo storico delle tue tasse universitarie.',
                                style: darkModeOn
                                    ? Constants.font16
                                    : Constants.font16
                                        .copyWith(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Icon(Icons.attach_money, color: Colors.white),
                        )
                      ],
                    ),
                  ),
                ),
                FutureBuilder<Map>(
                  future: _tasse,
                  builder: (context, tasse) {
                    switch (tasse.connectionState) {
                      case ConnectionState.none:
                        return ConnectionError(
                            deviceWidth: deviceWidth, isTablet: isTablet);
                      case ConnectionState.waiting:
                        return ShimmerLoader(
                            colorCircular: Colors.redAccent,
                            deviceWidth: deviceWidth,
                            isTablet: isTablet,
                            shimmerHeight: 150);
                      case ConnectionState.active:
                      case ConnectionState.done:
                        if (tasse.hasData && tasse.data['success'] as bool) {
                          return Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                padding: isTablet
                                    ? EdgeInsets.symmetric(
                                        horizontal: deviceWidth / 6,
                                        vertical: 32)
                                    : EdgeInsets.all(16),
                                cacheExtent: 20,
                                itemCount: tasse.data['totali'] as int,
                                itemBuilder: (ctx, index) {
                                  return TassaExpansionTile(
                                    descTassa:
                                        tasse.data['desc'][index] as String,
                                    importo:
                                        tasse.data['importi'][index] as String,
                                    scadenza:
                                        tasse.data['scadenza'][index] as String,
                                    stato: tasse.data['stato_pagamento'][index]
                                        as String,
                                    darkModeOn: darkModeOn,
                                  );
                                },
                              ),
                              Padding(
                                padding: isTablet
                                    ? EdgeInsets.only(
                                        left: deviceWidth / 6,
                                        right: deviceWidth / 6,
                                        bottom: 32)
                                    : EdgeInsets.only(
                                        left: 32, bottom: 32, right: 32),
                                child: Text(
                                  _citTasse[_rand.nextInt(_citTasse.length)],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontStyle: FontStyle.italic),
                                ),
                              )
                            ],
                          );
                        }
                        return ConnectionError(
                            deviceWidth: deviceWidth, isTablet: isTablet);
                      default:
                        return ConnectionError(
                            deviceWidth: deviceWidth, isTablet: isTablet);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
