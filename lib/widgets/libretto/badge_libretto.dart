import 'package:Esse3/constants.dart';
import 'package:flutter/material.dart';

class BadgeLibretto extends StatelessWidget {
  final double mediaPonderata;

  const BadgeLibretto({Key? key, required this.mediaPonderata})
      : assert(mediaPonderata != null),
        super(key: key);
  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: (mediaPonderata >= 24) ? -22 : -20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: mediaPonderata >= 24
              ? Colors.yellow[700]
              : mediaPonderata >= 18
                  ? Colors.green[700]
                  : Colors.yellow[700],
          borderRadius: const BorderRadius.all(Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: mediaPonderata >= 24 ? Colors.black12 : Colors.transparent,
              blurRadius: 10,
              spreadRadius: 3,
            ),
          ],
          border: Border.all(
              color: mediaPonderata >= 24 ? Colors.white : Colors.transparent,
              width: mediaPonderata >= 24 ? 2 : 0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
                mediaPonderata >= 24
                    ? Icons.stars
                    : mediaPonderata >= 18
                        ? Icons.check_circle
                        : Icons.warning,
                color: Colors.white),
            const SizedBox(width: 5),
            Text(
              mediaPonderata >= 24
                  ? 'fantastico!'.toUpperCase()
                  : mediaPonderata >= 18
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
