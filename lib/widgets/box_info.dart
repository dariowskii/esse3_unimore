import 'package:flutter/material.dart';

class BoxInfo extends StatelessWidget {
  const BoxInfo({
    Key key,
    @required this.darkModeOn,
    @required this.child,
    this.minWidth = double.maxFinite,
    this.backgroundColor,
  }) : super(key: key);

  final bool darkModeOn;
  final Widget child;
  final double minWidth;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      width: minWidth,
      decoration: BoxDecoration(
        color: backgroundColor ??
            (darkModeOn ? Colors.white12 : Colors.black12.withOpacity(0.04)),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: child,
    );
  }
}
