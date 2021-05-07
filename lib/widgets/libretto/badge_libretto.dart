import 'package:Esse3/constants.dart';
import 'package:flutter/material.dart';

class BadgeLibretto extends StatelessWidget {
  final Map<String, dynamic> libretto;

  const BadgeLibretto({Key key, @required this.libretto})
      : assert(libretto != null),
        super(key: key);
  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: ((libretto['media_pond'] as double).toInt() >= 24) ? -22 : -20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: (libretto['media_pond'] as double).toInt() >= 24
              ? Colors.yellow[700]
              : (libretto['media_pond'] as double).toInt() >= 18
                  ? Colors.green[700]
                  : Colors.yellow[700],
          borderRadius: const BorderRadius.all(Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: (libretto['media_pond'] as double).toInt() >= 24
                  ? Colors.black12
                  : Colors.transparent,
              blurRadius: 10,
              spreadRadius: 3,
            ),
          ],
          border: Border.all(
              color: ((libretto['media_pond'] as double).toInt() >= 24)
                  ? Colors.white
                  : Colors.transparent,
              width:
                  ((libretto['media_pond'] as double).toInt() >= 24) ? 2 : 0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
                (libretto['media_pond'] as double).toInt() >= 24
                    ? Icons.stars
                    : (libretto['media_pond'] as double).toInt() >= 18
                        ? Icons.check_circle
                        : Icons.warning,
                color: Colors.white),
            const SizedBox(width: 5),
            Text(
              (libretto['media_pond'] as double).toInt() >= 24
                  ? 'fantastico!'.toUpperCase()
                  : libretto['media_pond'] as int >= 18
                      ? 'vai così'.toUpperCase()
                      : 'attenzione'.toUpperCase(),
              style: Constants.fontBold.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
