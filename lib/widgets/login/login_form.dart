import 'package:Esse3/constants.dart';
import 'package:Esse3/models/auth_credential_model.dart';
import 'package:Esse3/screens/home_screen.dart';
import 'package:Esse3/utils/provider.dart';
import 'package:Esse3/widgets/login/login_button.dart';
import 'package:Esse3/widgets/login/login_text_field.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool _isLoading = false;

  final _userController = TextEditingController();
  final _passController = TextEditingController();
  final FocusNode _passFocus = FocusNode();

  /// Serve per effettuare il login grazie a [Provider.getAccess()].
  Future<void> _login() async {
    setState(() {
      _isLoading = !_isLoading;
    });
    FocusScope.of(context).unfocus();

    if (_userController.text.isEmpty || _passController.text.isEmpty) {
      setState(() {
        _isLoading = !_isLoading;
        _passController.clear();
      });
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Attenzione!'),
            content: const Text('Riempi correttamente tutti i campi'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  _passController.clear();
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Chiudi',
                  style: TextStyle(color: Constants.mainColorLighter),
                ),
              ),
            ],
          );
        },
      );
    }

    final responseSession =
        await Provider.getSession(_userController.text, _passController.text);
    if (responseSession == null) {
      setState(() {
        _isLoading = !_isLoading;
        _userController.clear();
        _passController.clear();
      });
      await showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: const Text('Errore di connessione'),
            content:
                const Text("Riprova a effettuare l'accesso fra 30 secondi."),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: const Text(
                  'Chiudi',
                  style: TextStyle(color: Constants.mainColorLighter),
                ),
              ),
            ],
          );
        },
      );
    } else if (responseSession['success'] as bool) {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setBool('isLoggedIn', true);

      final authCredential = AuthCredential(
        username: _userController.text,
        password: _passController.text,
      );
      await prefs.setString(AuthCredential.sharedKey, authCredential.encode());

      final studentModel = await Provider.getHomeInfo();
      if (studentModel == null) {
        _errorSession();
        return;
      }
      setState(() {
        _isLoading = !_isLoading;
      });

      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(studenteModel: studentModel),
        ),
      );
    } else if (!(responseSession['success'] as bool)) {
      _errorSession();
    }
  }

  void _errorSession() {
    setState(() {
      _isLoading = !_isLoading;
      _userController.clear();
      _passController.clear();
    });
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Credenziali errate!'),
          content: const Text('Riprova a inserire le credenziali'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: const Text('Chiudi',
                  style: TextStyle(color: Constants.mainColorLighter)),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
        color: Colors.white,
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Usa le credenziali Esse3 per accedere.',
            style: Constants.font16.copyWith(
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          Theme(
            data: ThemeData(
              primarySwatch: MaterialColor(
                  Constants.mainColorLighter.value, Constants.mapMainSwatch),
              textSelectionTheme: const TextSelectionThemeData(
                cursorColor: Constants.mainColor,
              ),
            ),
            child: Column(
              children: [
                LoginTextField(
                  enabled: !_isLoading,
                  onSubmitted: (_) => _passFocus.requestFocus(),
                  labelText: 'Username',
                  maxLenght: 15,
                  controller: _userController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 15),
                LoginTextField(
                  enabled: !_isLoading,
                  onSubmitted: (_) => _login(),
                  labelText: 'Password',
                  obscureText: true,
                  focusNode: _passFocus,
                  controller: _passController,
                ),
              ],
            ),
          ),
          Visibility(
              visible: _isLoading,
              child: Column(
                children: const [
                  SizedBox(height: 20),
                  Text(
                    '(potrebbe richiedere qualche secondo)',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(height: 10),
                  LinearProgressIndicator(
                    backgroundColor: Colors.transparent,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Constants.mainColor),
                  ),
                ],
              )),
          const SizedBox(height: 20),
          LoginButton(onPressed: !_isLoading ? _login : null),
        ],
      ),
    );
  }
}
