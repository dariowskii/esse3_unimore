import 'package:Esse3/constants.dart';
import 'package:Esse3/screens/bacheca_prenotazioni_screen.dart';
import 'package:Esse3/screens/home_screen.dart';
import 'package:Esse3/screens/info_app_screen.dart';
import 'package:Esse3/screens/login_screen.dart';
import 'package:Esse3/screens/prossimi_appelli_screen.dart';
import 'package:Esse3/screens/tasse_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Metodo principale che avvia [Esse3].
///
/// Controlla se l'utente è già loggato o se deve effettuare il login,
/// in modo da reinderizzare correttamente l'utente.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //Forzo il device ad orientarsi verticalmente
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  //Controllo se l'utente è loggato
  final prefs = await SharedPreferences.getInstance();
  final version = prefs.getBool(Constants.version) ?? false;
  if (!version) {
    await prefs.clear();
    await prefs.setBool(Constants.version, true);
  }
  final status = prefs.getBool('isLoggedIn') ?? false;
  runApp(Esse3(logged: status));
}

/// Rappresenta la classe che avvia l'applicazione.
class Esse3 extends StatelessWidget {
  const Esse3({required this.logged});

  /// Serve per controllare se l'utente è loggato.
  final bool logged;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      darkTheme: Constants.darkTheme,
      theme: Constants.lightTheme,
      initialRoute: logged ? HomeScreen.id : LoginScreen.id,
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
