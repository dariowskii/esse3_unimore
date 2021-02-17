import 'package:flutter/material.dart';

/// Classe contenente le costanti di stile dell'applicazione.
class Constants {
  //Var
  static const double tabletWidth = 650;
  static const double refreshDisplacement = 30;
  static const String _fontFamily = "SF Pro";
  //Dark Theme
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    fontFamily: _fontFamily,
    primaryColor: mainColorLighter,
    primaryColorLight: mainColorDarkLighter,
    disabledColor: buttonDisabled.withOpacity(0.3),
    textTheme: TextTheme(),
  );
  //Light Theme
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    fontFamily: _fontFamily,
    primaryColor: mainColor,
    primaryColorLight: mainColorLighter,
    disabledColor: buttonDisabled,
    textTheme: TextTheme(),
  );
  //Fonts
  static const TextStyle fontBold = TextStyle(fontWeight: FontWeight.bold);
  static const TextStyle fontBold18 = TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
  static const TextStyle fontBold20 = TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
  static const TextStyle fontBold24 = TextStyle(fontSize: 24, fontWeight: FontWeight.bold);
  static const TextStyle fontBold28 = TextStyle(fontSize: 28, fontWeight: FontWeight.bold);
  static const TextStyle fontBold32 = TextStyle(fontSize: 32, fontWeight: FontWeight.bold);
  static const TextStyle font14 = TextStyle(fontSize: 14);
  static const TextStyle font16 = TextStyle(fontSize: 16);
  static const TextStyle font18 = TextStyle(fontSize: 18);
  static const TextStyle font20 = TextStyle(fontSize: 20);
  //Colors
  static const Color mainColorDarkLighter = Color(0xffFF7D38);
  static const Color mainColorLighter = Color(0xffFF600B);
  static const Color mainColor = Color(0xffFF5800);
  static const Color mainColorDarker = Color(0xffFF4E00);
  static const Color mainColorExtraDark = Color(0xffCC4700);
  static const Color buttonDisabled = Color(0xffEEEEEE);
  static const Color backgroundDark = Color(0xff323232);
}
