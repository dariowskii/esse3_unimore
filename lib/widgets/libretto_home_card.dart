import 'package:Esse3/constants.dart';
import 'package:Esse3/screens/libretto_screen.dart';
import 'package:Esse3/utils/provider.dart';
import 'package:Esse3/widgets/error_libretto.dart';
import 'package:flutter/material.dart';

/// Card in cui è possibile richiedere le informazioni del libretto,
/// utilizzata nella [HomeScreen].
class LibrettoHomeCard extends StatefulWidget {
  const LibrettoHomeCard({
    Key key,
  }) : super(key: key);

  @override
  _LibrettoHomeCardState createState() => _LibrettoHomeCardState();
}

class _LibrettoHomeCardState extends State<LibrettoHomeCard> {
  /// Future del libretto.
  Future<Map> _libretto;

  /// Questo valore serve per gestire la visualizzazione nella card.
  bool _isRequestedLibretto = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
              color: Colors.black12,
              offset: Offset(0, 2),
              spreadRadius: 1,
              blurRadius: 3),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Libretto',
                  style: Constants.fontBold20.copyWith(
                    color: Theme.of(context).primaryColorLight,
                  ),
                ),
                Icon(
                  Icons.book,
                  color: Theme.of(context).primaryColorLight,
                ),
              ],
            ),
            const SizedBox(height: 20),
            _isRequestedLibretto
                ? FutureBuilder<Map>(
                    future: _libretto,
                    builder: (_, libretto) {
                      switch (libretto.connectionState) {
                        case ConnectionState.none:
                          return ErrorLibretto(libretto: _libretto);
                        case ConnectionState.waiting:
                          return Column(
                            children: <Widget>[
                              Text(
                                'Sto recuperando i tuoi dati...',
                              ),
                              SizedBox(height: 10),
                              LinearProgressIndicator(
                                backgroundColor: Colors.transparent,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Constants.mainColor),
                              ),
                            ],
                          );
                        case ConnectionState.active:
                        case ConnectionState.done:
                          if (libretto.data == null ||
                              !(libretto.data['success'] as bool)) {
                            return ErrorLibretto(libretto: _libretto);
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              RichText(
                                text: TextSpan(
                                  text: libretto.data['superati'].toString(),
                                  style: TextStyle(
                                    fontFamily: 'SF Pro',
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        .color,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: ' su ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                    TextSpan(
                                      text: libretto.data['totali'].toString(),
                                    ),
                                    TextSpan(
                                      text: ' superati. ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                    libretto.data['superati'] == 0
                                        ? TextSpan(
                                            text:
                                                'Il cammino è lungo, ma ce la farai!',
                                          )
                                        : libretto.data['superati'] ==
                                                libretto.data['totali']
                                            ? TextSpan(
                                                text:
                                                    'Che la Sbronza sia con te! 🍻',
                                              )
                                            : libretto.data['superati']
                                                        as int <=
                                                    (libretto.data['totali']
                                                            as int) /
                                                        2
                                                ? TextSpan(
                                                    text: 'Continua così!',
                                                  )
                                                : libretto.data['superati']
                                                            as int >
                                                        (libretto.data['totali']
                                                                as int) /
                                                            2
                                                    ? TextSpan(
                                                        text:
                                                            'Ci sei quasi, dai!',
                                                      )
                                                    : TextSpan(
                                                        text: '',
                                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Stack(
                                alignment: Alignment.center,
                                children: <Widget>[
                                  Container(
                                    height: 12,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Theme.of(context)
                                              .primaryColorLight,
                                          width: 2),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(20)),
                                      color: Theme.of(context).cardColor,
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 4),
                                      child: LayoutBuilder(
                                        builder: (BuildContext context,
                                            BoxConstraints constraints) {
                                          return Container(
                                            height: 5,
                                            width: constraints.maxWidth /
                                                (libretto.data['totali']
                                                    as int) *
                                                (libretto.data['superati']
                                                    as int),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .primaryColorLight,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(20)),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: MaterialButton(
                                      minWidth: double.infinity,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(50)),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                LibrettoScreen(
                                              libretto: libretto.data,
                                            ),
                                          ),
                                        );
                                      },
                                      textColor: Colors.white,
                                      color: Theme.of(context).primaryColor,
                                      child: Text(
                                        'Guarda Libretto',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  IconButton(
                                      icon: Icon(Icons.refresh),
                                      onPressed: () {
                                        setState(() {
                                          _libretto = Provider.getLibretto();
                                        });
                                      }),
                                ],
                              ),
                            ],
                          );
                        default:
                          return ErrorLibretto(libretto: _libretto);
                      }
                    })
                : MaterialButton(
                    minWidth: double.infinity,
                    onPressed: () async {
                      setState(() {
                        _libretto = Provider.getLibretto();
                        _isRequestedLibretto = !_isRequestedLibretto;
                      });
                    },
                    textColor: Colors.white,
                    color: Theme.of(context).primaryColor,
                    disabledColor: Theme.of(context).disabledColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(50))),
                    child: Text(
                      'Scarica info',
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
