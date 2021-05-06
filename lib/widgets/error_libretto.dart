import 'package:Esse3/utils/provider.dart';
import 'package:flutter/material.dart';

/// Widget di errore in caso in cui non si riesca a caricare il libretto
/// in [LibrettoHomeCard].
class ErrorLibretto extends StatefulWidget {
  /// Future del libretto da ricaricare.
  Future<Map> libretto;

  ErrorLibretto({Key key, this.libretto}) : super(key: key);
  @override
  _ErrorLibrettoState createState() => _ErrorLibrettoState();
}

class _ErrorLibrettoState extends State<ErrorLibretto> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          children: [
            Icon(
              Icons.error,
              color: Colors.redAccent,
            ),
            SizedBox(width: 5),
            Text(
              'Errore nel recuperare i dati!',
            ),
          ],
        ),
        IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                widget.libretto = Provider.getLibretto();
              });
            })
      ],
    );
  }
}
