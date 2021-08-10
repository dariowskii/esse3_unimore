import 'package:flutter/material.dart';

class InfoRichText extends StatelessWidget {
  const InfoRichText({
    Key key,
    @required this.text,
    @required this.value,
    this.fontSize = 16,
  }) : super(key: key);

  final String text;
  final String value;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
          text: text,
          style: DefaultTextStyle.of(context).style,
          children: [
            TextSpan(
              text: value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: fontSize,
              ),
            )
          ]),
    );
  }
}
