import 'package:Esse3/constants.dart';
import 'package:Esse3/screens/libretto_screen.dart';
import 'package:Esse3/widgets/error_libretto.dart';
import 'package:flutter/material.dart';

class FutureLibretto extends StatelessWidget {
  final Future<Map<String, dynamic>> libretto;
  final Function() onPressed;

  const FutureLibretto(
      {Key key, @required this.libretto, @required this.onPressed})
      : assert(libretto != null),
        assert(onPressed != null),
        super(key: key);
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
        future: libretto,
        builder: (_, snapLibretto) {
          switch (snapLibretto.connectionState) {
            case ConnectionState.none:
              return ErrorLibretto(libretto: libretto);
            case ConnectionState.waiting:
              return Column(
                children: <Widget>[
                  Text(
                    'Sto recuperando i tuoi dati...',
                  ),
                  SizedBox(height: 10),
                  LinearProgressIndicator(
                    backgroundColor: Colors.transparent,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Constants.mainColor),
                  ),
                ],
              );
            case ConnectionState.active:
            case ConnectionState.done:
              if (snapLibretto.data == null ||
                  !(snapLibretto.data['success'] as bool)) {
                return ErrorLibretto(libretto: libretto);
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  RichText(
                    text: TextSpan(
                      text: snapLibretto.data['superati'].toString(),
                      style: TextStyle(
                        fontFamily: 'SF Pro',
                        color: Theme.of(context).textTheme.bodyText1.color,
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
                          text: snapLibretto.data['totali'].toString(),
                        ),
                        TextSpan(
                          text: ' superati. ',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        snapLibretto.data['superati'] == 0
                            ? TextSpan(
                                text: 'Il cammino è lungo, ma ce la farai!',
                              )
                            : snapLibretto.data['superati'] ==
                                    snapLibretto.data['totali']
                                ? TextSpan(
                                    text: 'Che la Sbronza sia con te! 🍻',
                                  )
                                : snapLibretto.data['superati'] as int <=
                                        (snapLibretto.data['totali'] as int) / 2
                                    ? TextSpan(
                                        text: 'Continua così!',
                                      )
                                    : snapLibretto.data['superati'] as int >
                                            (snapLibretto.data['totali']
                                                    as int) /
                                                2
                                        ? TextSpan(
                                            text: 'Ci sei quasi, dai!',
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
                              color: Theme.of(context).primaryColorLight,
                              width: 2),
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          color: Theme.of(context).cardColor,
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: LayoutBuilder(
                            builder: (BuildContext context,
                                BoxConstraints constraints) {
                              return Container(
                                height: 5,
                                width: constraints.maxWidth /
                                    (snapLibretto.data['totali'] as int) *
                                    (snapLibretto.data['superati'] as int),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColorLight,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20)),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: MaterialButton(
                          minWidth: double.infinity,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(50)),
                          ),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => LibrettoScreen(
                                  libretto: snapLibretto.data,
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
                        onPressed: onPressed,
                      ),
                    ],
                  ),
                ],
              );
            default:
              return ErrorLibretto(libretto: libretto);
          }
        });
  }
}
