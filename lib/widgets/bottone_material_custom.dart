import 'package:flutter/material.dart';

/// Bottone custom utilizzato in [HomeScreen] nel [Drawer].
class BottoneMaterialCustom extends StatelessWidget {
  final Function() onPressed;
  final Color textColor, backgroundColor;
  final String textButton;
  final double minWidth, height, elevation, fontSize, padding;
  final FontWeight fontWeight;

  const BottoneMaterialCustom(
      {Key key,
      @required this.onPressed,
      this.backgroundColor = Colors.redAccent,
      this.textColor = Colors.white,
      @required this.textButton,
      this.minWidth = double.infinity,
      this.height = 40,
      this.fontWeight = FontWeight.bold,
      this.elevation = 1,
      this.fontSize = 14,
      this.padding = 0})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      minWidth: minWidth,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(50)),
      ),
      height: height,
      elevation: elevation,
      textColor: textColor,
      color: backgroundColor,
      onPressed: onPressed,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Text(
          textButton,
          style: TextStyle(fontWeight: fontWeight, fontSize: fontSize),
        ),
      ),
    );
  }
}
