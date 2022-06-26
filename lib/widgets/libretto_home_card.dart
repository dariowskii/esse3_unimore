import 'package:Esse3/constants.dart';
import 'package:Esse3/utils/provider.dart';
import 'package:Esse3/widgets/libretto/future_libretto.dart';
import 'package:flutter/material.dart';

/// Card in cui è possibile richiedere le informazioni del libretto,
/// utilizzata nella [HomeScreen].
class LibrettoHomeCard extends StatefulWidget {
  const LibrettoHomeCard({
    Key? key,
  }) : super(key: key);

  @override
  _LibrettoHomeCardState createState() => _LibrettoHomeCardState();
}

class _LibrettoHomeCardState extends State<LibrettoHomeCard> {
  /// Future del libretto.
  late Future<Map<String, dynamic>> _libretto;

  /// Questo valore serve per gestire la visualizzazione nella card.
  bool _isRequestedLibretto = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 2),
            spreadRadius: 1,
            blurRadius: 3,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
            if (_isRequestedLibretto)
              FutureLibretto(
                futureLibretto: _libretto,
                onPressed: () {
                  setState(() {
                    _libretto = Provider.getLibretto();
                  });
                },
              )
            else
              _ScaricaLibretto(
                onPressed: () async {
                  setState(() {
                    _libretto = Provider.getLibretto();
                    _isRequestedLibretto = !_isRequestedLibretto;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _ScaricaLibretto extends StatelessWidget {
  const _ScaricaLibretto({Key? key, required this.onPressed})
      : assert(onPressed != null),
        super(key: key);

  final Function() onPressed;
  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      minWidth: double.infinity,
      onPressed: onPressed,
      textColor: Colors.white,
      color: Theme.of(context).primaryColor,
      disabledColor: Theme.of(context).disabledColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(50)),
      ),
      child: const Text(
        'Scarica info',
      ),
    );
  }
}
