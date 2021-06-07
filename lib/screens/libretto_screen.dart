import 'package:Esse3/constants.dart';
import 'package:Esse3/widgets/libretto/andamento_libretto.dart';
import 'package:Esse3/widgets/libretto/badge_libretto.dart';
import 'package:Esse3/widgets/libretto/header_libretto.dart';
import 'package:Esse3/widgets/libretto/tile_materia_libretto.dart';
import 'package:flutter/material.dart';

/// Pagina in cui visualizzare il libretto universitario.
// ignore: must_be_immutable
class LibrettoScreen extends StatelessWidget {
  static const id = 'librettoScreen';

  /// Map del libretto passatto da [Provider.getLibretto()].
  final Map<String, dynamic> libretto;

  LibrettoScreen({@required this.libretto}) : assert(libretto != null);

  double _votoLaurea = 0;
  int _cfu = 0;

  var _puntiGrafico = [];

  void _initGrafico() {
    for (var i = 0; i < (libretto['totali'] as int); i++) {
      String voto = libretto['voti'][i].toString();
      if (voto != '') {
        _cfu += int.parse(libretto['crediti'][i].toString());
        if (int.tryParse(voto) != null || voto == '30 LODE' || voto == '30L') {
          if (voto == '30 LODE' || voto == '30L') voto = '30';
          _puntiGrafico.add(
              {'voto': int.parse(voto), 'data': libretto['data_esame'][i]});
        }
      }
    }

    if (_puntiGrafico.isNotEmpty) {
      _puntiGrafico.sort((a, b) {
        final ad =
            '${a['data'].toString().substring(6)}-${a['data'].toString().substring(3, 5)}-${a['data'].toString().substring(0, 2)}';
        final bd =
            '${b['data'].toString().substring(6)}-${b['data'].toString().substring(3, 5)}-${b['data'].toString().substring(0, 2)}';
        return ad.compareTo(bd);
      });
    }

    if (_puntiGrafico.length >= 8) {
      _puntiGrafico =
          _puntiGrafico.sublist(_puntiGrafico.length - 8, _puntiGrafico.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final darkModeOn = Theme.of(context).brightness == Brightness.dark;
    final isTablet = deviceWidth > Constants.tabletWidth;
    _initGrafico();
    final mediaPonderata = libretto['media_pond'];
    _votoLaurea = mediaPonderata is double ? ((mediaPonderata * 110) / 30) : 0;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Esse3'),
        centerTitle: true,
        backgroundColor: darkModeOn
            ? Theme.of(context).cardColor
            : Constants.mainColorLighter,
      ),
      body: Theme(
        data: Theme.of(context)
            .copyWith(accentColor: Theme.of(context).primaryColorLight),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomCenter,
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
                      padding: const EdgeInsets.only(
                          left: 16.0, right: 16, top: 16, bottom: 36),
                      child: HeaderLibretto(
                        puntiGrafico: _puntiGrafico,
                        darkModeOn: darkModeOn,
                      ),
                    ),
                  ),
                  if (libretto['media_pond'] != 'NaN')
                    BadgeLibretto(mediaPonderata: mediaPonderata as double),
                ],
              ),
              Padding(
                padding: isTablet
                    ? EdgeInsets.symmetric(
                        horizontal: deviceWidth / 6, vertical: 32)
                    : const EdgeInsets.only(
                        left: 16.0, right: 16, bottom: 16, top: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AndamentoLibretto(
                        libretto: libretto, cfu: _cfu, votoLaurea: _votoLaurea),
                    const SizedBox(height: 20),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      cacheExtent: 30,
                      itemCount: libretto['totali'] as int,
                      itemBuilder: (context, index) {
                        return TileMateriaLibretto(
                          libretto: libretto,
                          index: index,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
