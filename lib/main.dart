import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';
import 'package:flutter/material.dart';
import 'screens/screens.dart';

/// Metodo principale che avvia [Esse3].
///
/// Controlla se l'utente è già loggato o se deve effettuare il login,
/// in modo da reinderizzare correttamente l'utente.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //Forzo il device ad orientarsi verticalmente
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  //Controllo se l'utente è loggato
  var prefs = await SharedPreferences.getInstance();
  var version = prefs.getBool('1.2.0') ?? false;
  if (!version) {
    await prefs.clear();
    await prefs.setBool('1.2.0', true);
  }
  var status = prefs.getBool('isLoggedIn') ?? false;
  runApp(Esse3(logged: status));
}

/// Rappresenta la classe che avvia l'applicazione.
class Esse3 extends StatefulWidget {
  Esse3({@required this.logged});

  /// Serve per controllare se l'utente è loggato.
  final bool logged;

  @override
  _Esse3State createState() => _Esse3State();
}

class _Esse3State extends State<Esse3> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      darkTheme: Constants.darkTheme,
      theme: Constants.lightTheme,
      initialRoute: widget.logged ? HomeScreen.id : LoginScreen.id,
      routes: {
        LoginScreen.id: (context) => LoginScreen(),
        HomeScreen.id: (context) => HomeScreen(),
        TasseScreen.id: (context) => TasseScreen(),
        BachecaPrenotazioniScreen.id: (context) => BachecaPrenotazioniScreen(),
        ProssimiAppelliScreen.id: (context) => ProssimiAppelliScreen(),
        InfoApp.id: (context) => InfoApp(),
      },
    );
  }
}
