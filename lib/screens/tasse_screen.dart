import 'dart:math';
import 'package:Esse3/constants.dart';
import 'package:Esse3/models/tassa_model.dart';
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
  Future<Map<String, dynamic>>? _tasse;

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
  late Random _rand;

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
    final darkModeOn = Theme.of(context).brightness == Brightness.dark;
    final isTablet = deviceWidth > Constants.tabletWidth;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Esse3'),
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
                        : Colors.redAccent,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 32, horizontal: 16),
                    child: Column(
                      children: [
                        Row(
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
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.0),
                              child:
                                  Icon(Icons.attach_money, color: Colors.white),
                            )
                          ],
                        ),
                        FutureBuilder<Map<String, dynamic>>(
                          future: _tasse,
                          builder: (context, snapshot) {
                            switch (snapshot.connectionState) {
                              case ConnectionState.done:
                                if (snapshot.hasData &&
                                    (snapshot.data!['success'] as bool) &&
                                    snapshot.data!['item'] != null) {
                                  final _tasseDaPagare =
                                      snapshot.data!['da_pagare'] as int;
                                  if (_tasseDaPagare > 0) {
                                    return Column(
                                      children: [
                                        Constants.sized20H,
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.warning,
                                              color: darkModeOn
                                                  ? Colors.redAccent
                                                  : Colors.white,
                                            ),
                                            const SizedBox(width: 5),
                                            RichText(
                                              text: TextSpan(
                                                text: 'Hai ancora ',
                                                style: const TextStyle(
                                                  fontFamily: 'SF Pro',
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                ),
                                                children: [
                                                  TextSpan(
                                                    text: '$_tasseDaPagare',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: darkModeOn
                                                            ? Colors.redAccent
                                                            : Colors.white,
                                                        decoration: darkModeOn
                                                            ? null
                                                            : TextDecoration
                                                                .underline),
                                                  ),
                                                  TextSpan(
                                                      text:
                                                          ' ${_tasseDaPagare > 1 ? "tasse" : "tassa"} da pagare!'),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  }
                                }
                                return const SizedBox.shrink();
                                break;

                              default:
                                return const SizedBox.shrink();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                FutureBuilder<Map<String, dynamic>>(
                  future: _tasse,
                  builder: (context, tasseSnap) {
                    switch (tasseSnap.connectionState) {
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
                        if (tasseSnap.hasData &&
                            (tasseSnap.data!['success'] as bool) &&
                            tasseSnap.data!['item'] != null) {
                          final tasse =
                              tasseSnap.data!['item'] as List<TassaModel>;
                          return Column(
                            children: [
                              ListView.separated(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                padding: isTablet
                                    ? EdgeInsets.symmetric(
                                        horizontal: deviceWidth / 6,
                                        vertical: 32)
                                    : const EdgeInsets.all(16),
                                cacheExtent: 20,
                                itemCount: tasse.length,
                                itemBuilder: (context, index) {
                                  return TassaExpansionTile(
                                    tassa: tasse[index],
                                    darkModeOn: darkModeOn,
                                  );
                                },
                                separatorBuilder: (context, index) {
                                  return const SizedBox(height: 5);
                                },
                              ),
                              Padding(
                                padding: isTablet
                                    ? EdgeInsets.only(
                                        left: deviceWidth / 6,
                                        right: deviceWidth / 6,
                                        bottom: 32)
                                    : const EdgeInsets.only(
                                        left: 32, bottom: 32, right: 32),
                                child: Text(
                                  _citTasse[_rand.nextInt(_citTasse.length)],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontStyle: FontStyle.italic),
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
