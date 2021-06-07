import 'package:Esse3/constants.dart';
import 'package:flutter/material.dart';

/// Bottone utilizzato in [HomeScreen] nel [Drawer].
class BottonePaginaDrawer extends StatelessWidget {
  final String testoBottone;

  /// Icona del bottone, in caso ne abbia una.
  final IconData icona;

  /// Funzione del bottone quando viene premuto.
  final Function() onPressed;
  final Color textColor;

  const BottonePaginaDrawer({
    Key key,
    @required this.testoBottone,
    @required this.onPressed,
    this.textColor,
    this.icona,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icona != null) ...[
            Icon(icona, color: textColor, size: 15),
            const SizedBox(width: 10),
          ],
          Text(
            testoBottone,
            textAlign: TextAlign.center,
            style: Constants.fontBold.copyWith(color: textColor),
          ),
        ],
      ),
    );
  }
}
