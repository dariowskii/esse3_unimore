import 'package:Esse3/constants.dart';
import 'package:Esse3/models/libretto_model.dart';
import 'package:Esse3/screens/libretto_screen.dart';
import 'package:Esse3/widgets/error_libretto.dart';
import 'package:flutter/material.dart';

class FutureLibretto extends StatelessWidget {
  final Future<Map<String, dynamic>> futureLibretto;
  final Function() onPressed;

  const FutureLibretto(
      {Key key, @required this.futureLibretto, @required this.onPressed})
      : assert(futureLibretto != null),
        assert(onPressed != null),
        super(key: key);
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
        future: futureLibretto,
        builder: (context, snapLibretto) {
          switch (snapLibretto.connectionState) {
            case ConnectionState.none:
              return ErrorLibretto(onPressed: onPressed);
            case ConnectionState.waiting:
              return Column(
                children: const [
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
                return ErrorLibretto(onPressed: onPressed);
              }
              if (snapLibretto.data['item'] != null) {
                final _libretto = snapLibretto.data['item'] as LibrettoModel;
                final fraseLibretto = _libretto.esamiSuperati ==
                        _libretto.esamiTotali
                    ? 'Che la Sbronza sia con te! 🍻'
                    : _libretto.esamiSuperati <= _libretto.esamiTotali / 2
                        ? 'Continua così!'
                        : _libretto.esamiSuperati > (_libretto.esamiTotali / 2)
                            ? 'Ci sei quasi, dai!'
                            : '';
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    RichText(
                      text: TextSpan(
                        text: "${_libretto.esamiSuperati}",
                        style: TextStyle(
                          fontFamily: 'SF Pro',
                          color: Theme.of(context).textTheme.bodyText1.color,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          const TextSpan(
                            text: ' su ',
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          TextSpan(
                            text: "${_libretto.esamiTotali}",
                          ),
                          const TextSpan(
                            text: ' superati. ',
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          if (_libretto.esamiSuperati == 0)
                            const TextSpan(
                              text: 'Il cammino è lungo, ma ce la farai!',
                            )
                          else
                            TextSpan(
                              text: fraseLibretto,
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
                            borderRadius:
                                const BorderRadius.all(Radius.circular(20)),
                            color: Theme.of(context).cardColor,
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: LayoutBuilder(
                              builder: (BuildContext context,
                                  BoxConstraints constraints) {
                                return Container(
                                  height: 5,
                                  width: constraints.maxWidth /
                                      (_libretto.esamiTotali) *
                                      (_libretto.esamiSuperati),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColorLight,
                                    borderRadius: const BorderRadius.all(
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: MaterialButton(
                            minWidth: double.infinity,
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50)),
                            ),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => LibrettoScreen(
                                    libretto: _libretto,
                                  ),
                                ),
                              );
                            },
                            textColor: Colors.white,
                            color: Theme.of(context).primaryColor,
                            child: const Text(
                              'Guarda Libretto',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: onPressed,
                        ),
                      ],
                    ),
                  ],
                );
              }
              return ErrorLibretto(onPressed: onPressed);
            default:
              return ErrorLibretto(onPressed: onPressed);
          }
        });
  }
}
