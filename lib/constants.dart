import 'package:flutter/material.dart';

/// Classe contenente le costanti di stile dell'applicazione.
class Constants {
  // Variabili
  static const double tabletWidth = 650;
  static const double refreshDisplacement = 30;
  static const String _fontFamily = 'SF Pro';
  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    fontFamily: _fontFamily,
    primaryColor: mainColorLighter,
    primaryColorLight: mainColorDarkLighter,
    disabledColor: buttonDisabled.withOpacity(0.3),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: Constants.mainColorLighter,
    ),
    // textTheme: const TextTheme(),
  );
  // Light Theme
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    fontFamily: _fontFamily,
    primaryColor: mainColor,
    primaryColorLight: mainColorLighter,
    disabledColor: buttonDisabled,
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: Constants.mainColor,
    ),
    // textTheme: const TextTheme(),
  );
  // Fonts
  static const TextStyle fontBold = TextStyle(fontWeight: FontWeight.bold);
  static const TextStyle fontBold18 =
      TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
  static const TextStyle fontBold20 =
      TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
  static const TextStyle fontBold24 =
      TextStyle(fontSize: 24, fontWeight: FontWeight.bold);
  static const TextStyle fontBold28 =
      TextStyle(fontSize: 28, fontWeight: FontWeight.bold);
  static const TextStyle fontBold32 =
      TextStyle(fontSize: 32, fontWeight: FontWeight.bold);
  static const TextStyle font14 = TextStyle(fontSize: 14);
  static const TextStyle font16 = TextStyle(fontSize: 16);
  static const TextStyle font18 = TextStyle(fontSize: 18);
  static const TextStyle font20 = TextStyle(fontSize: 20);
  // Colors
  static const Color mainColorDarkLighter = Color(0xffFF7D38);
  static const Color mainColorLighter = Color(0xffFF600B);
  static const Color mainColor = Color(0xffFF5800);
  static const Color mainColorDarker = Color(0xffFF4E00);
  static const Color mainColorExtraDark = Color(0xffCC4700);
  static const Color buttonDisabled = Color(0xffEEEEEE);
  static const Color backgroundDark = Color(0xff323232);

  static Map<int, Color> mapMainSwatch = {
    50: Colors.grey,
    100: mainColorLighter.withOpacity(0.1),
    200: mainColorLighter.withOpacity(0.2),
    300: mainColorLighter.withOpacity(0.3),
    400: mainColorLighter.withOpacity(0.4),
    500: mainColorLighter.withOpacity(0.5),
    600: mainColorLighter.withOpacity(0.7),
    700: mainColorLighter.withOpacity(0.8),
    800: mainColorLighter.withOpacity(0.9),
    900: mainColorLighter,
  };
  // Widgets
  static const SizedBox sized10H = SizedBox(height: 10);
  static const SizedBox sized20H = SizedBox(height: 20);
  // Functions
  static void showAdaptiveWaitingDialog(BuildContext context) {
    final content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        CircularProgressIndicator.adaptive(
          valueColor: AlwaysStoppedAnimation<Color>(Constants.mainColorLighter),
        ),
        SizedBox(width: 10),
        Text(
          'Attendi un secondo...',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ],
    );

    showModalBottomSheet(
        context: context,
        isDismissible: false,
        enableDrag: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) {
          return SizedBox(
            height: 180,
            child: content,
          );
        });
  }

  static void showAdaptiveDialog(BuildContext context,
      {@required bool success,
      @required String successText,
      @required String errorText}) {
    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              success ? Icons.check_circle : Icons.error,
              color: success ? Colors.green : Colors.redAccent,
            ),
            const SizedBox(width: 15),
            Text(
              success ? successText : errorText,
              style: Constants.fontBold18,
            ),
          ],
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: MaterialButton(
            color: success ? Colors.green : Colors.redAccent,
            minWidth: 150,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            onPressed: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
            child: const Text(
              'Chiudi',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SizedBox(
          height: 200,
          child: content,
        );
      },
    );
  }

  static Widget getAskingModalBottomSheet(BuildContext context,
      {@required Function() onAccepted,
      @required String title,
      @required String text}) {
    return SizedBox(
      height: 180,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: Constants.fontBold20,
          ),
          const SizedBox(height: 5),
          Text(
            text,
            style: const TextStyle(fontFamily: 'SF Pro'),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Flexible(
                  child: MaterialButton(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    minWidth: double.maxFinite,
                    color: Colors.green,
                    onPressed: onAccepted,
                    child: const Text(
                      'Si',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: MaterialButton(
                    minWidth: double.maxFinite,
                    color: Colors.redAccent,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'No',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
