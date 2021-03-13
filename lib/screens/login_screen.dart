import 'dart:convert';
import 'package:Esse3/constants.dart';
import 'package:Esse3/screens/screens.dart';
import 'package:Esse3/utils/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Pagina iniziale di login.
class LoginScreen extends StatefulWidget {
  static const String id = 'loginScreen';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();

  bool _isLoading = false;

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

    var _authCred =
        '${_userController.value.text}:${_passController.value.text}';
    var _bytesInLatin1 = latin1.encode(_authCred);
    var _basichAuth64 = 'Basic ' + base64.encode(_bytesInLatin1);

    await Provider.getAccess(_basichAuth64, _userController.value.text.trim())
        .then((response) async {
      if (response == null) {
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
      } else if (response['success'] == true) {
        var prefs = await SharedPreferences.getInstance();

        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('auth64Cred', _basichAuth64);
        await prefs.setString('username', _userController.text);

        setState(() {
          _isLoading = !_isLoading;
        });

        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(user: response),
          ),
        );
      } else if (!response['success']) {
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
    });
  }

  @override
  Widget build(BuildContext context) {
    var deviceWidth = MediaQuery.of(context).size.width;
    var isTablet = deviceWidth > Constants.tabletWidth;
    return Stack(
      children: [
        Scaffold(),
        SvgPicture.asset(
          isTablet
              ? 'assets/img/backgroundLoginTablet.svg'
              : 'assets/img/backgroundLogin.svg',
          width: deviceWidth,
          height: MediaQuery.of(context).size.height,
          fit: BoxFit.cover,
        ),
        GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Builder(builder: (BuildContext context) {
              return Padding(
                padding: isTablet
                    ? EdgeInsets.symmetric(horizontal: deviceWidth / 6)
                    : EdgeInsets.all(32.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Esse3 Unimore',
                        style: Constants.fontBold32,
                      ),
                      Text(
                        'App non (ancora) ufficiale',
                        style: Constants.font20,
                      ),
                      const SizedBox(height: 30),
                      Container(
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
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)),
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
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)),
                                        borderSide: BorderSide(
                                            color: Colors.redAccent, width: 2),
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
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Constants.mainColor),
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
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30)),
                              ),
                              child: Text(
                                'ACCEDI',
                                style: Constants.fontBold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
