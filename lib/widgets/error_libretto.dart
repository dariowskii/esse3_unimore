import 'package:flutter/material.dart';

/// Widget di errore in caso in cui non si riesca a caricare il libretto
/// in [LibrettoHomeCard].
class ErrorLibretto extends StatelessWidget {
  /// Future del libretto da ricaricare.
  final Function() onPressed;

  const ErrorLibretto({Key key, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          children: const [
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
          icon: const Icon(Icons.refresh),
          onPressed: onPressed,
        ),
      ],
    );
  }
}
