import 'package:Esse3/constants.dart';
import 'package:Esse3/screens/home_screen.dart';
import 'package:Esse3/utils/provider.dart';
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

  void _clickBtn() {
    setState(() {
      _isLoading = !_isLoading;
    });
    _login();
  }

  /// Serve per effettuare il login grazie a [Provider.getAccess()].
  void _login() async {
    FocusScope.of(context).unfocus();

    if (_userController.value.text.isEmpty ||
        _passController.value.text.isEmpty) {
      setState(() {
        _isLoading = !_isLoading;
      });
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Attenzione!'),
            content: Text('Riempi correttamente tutti i campi'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  _passController.clear();
                  Navigator.of(context).pop();
                },
                child: Text(
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
            title: Text('Errore di connessione'),
            content: Text("Riprova a effettuare l'accesso fra 30 secondi."),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: Text(
                  'Chiudi',
                  style: TextStyle(color: Constants.mainColorLighter),
                ),
              ),
            ],
          );
        },
      );
    } else if (responseSession['success'] as bool) {
      var prefs = await SharedPreferences.getInstance();

      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('username', _userController.text);
      await prefs.setString('password', _passController.text);

      setState(() {
        _isLoading = !_isLoading;
      });

      final userInfo = await Provider.getHomeInfo();

      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(user: userInfo),
        ),
      );
    } else if (!(responseSession['success'] as bool)) {
      print(responseSession);
      setState(() {
        _isLoading = !_isLoading;
        _userController.clear();
        _passController.clear();
      });
      await showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Text('Credenziali errate!'),
            content: Text('Riprova a inserire le credenziali'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: Text('Chiudi',
                    style: TextStyle(color: Constants.mainColorLighter)),
              ),
            ],
          );
        },
      );
    }
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
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        boxShadow: [
          BoxShadow(
              color: Colors.black12,
              offset: Offset.zero,
              blurRadius: 10,
              spreadRadius: 2),
        ],
        color: Colors.white,
      ),
      padding: EdgeInsets.all(24),
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
              primaryColor: Constants.mainColor,
            ),
            child: Column(
              children: [
                TextField(
                  enabled: !_isLoading,
                  controller: _userController,
                  maxLength: 15,
                  keyboardType: TextInputType.emailAddress,
                  cursorColor: Constants.mainColor,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    counterText: '',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                  onSubmitted: (value) {
                    _passFocus.requestFocus();
                  },
                ),
                const SizedBox(height: 15),
                TextField(
                  enabled: !_isLoading,
                  obscureText: true,
                  focusNode: _passFocus,
                  controller: _passController,
                  cursorColor: Constants.mainColor,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: Colors.redAccent, width: 2),
                    ),
                  ),
                  onSubmitted: (value) {
                    _clickBtn();
                  },
                ),
              ],
            ),
          ),
          Visibility(
              visible: _isLoading,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  LinearProgressIndicator(
                    backgroundColor: Colors.transparent,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Constants.mainColor),
                  ),
                ],
              )),
          const SizedBox(height: 20),
          MaterialButton(
            disabledColor: Constants.buttonDisabled,
            onPressed: !_isLoading
                ? () {
                    _clickBtn();
                  }
                : null,
            padding: const EdgeInsets.all(16),
            color: Constants.mainColor,
            textColor: Colors.white,
            disabledTextColor: Colors.black26,
            minWidth: double.infinity,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(30)),
            ),
            child: Text(
              'ACCEDI',
              style: Constants.fontBold,
            ),
          ),
        ],
      ),
    );
  }
}
