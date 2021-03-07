import 'dart:convert';
import 'dart:typed_data';
import 'package:Esse3/constants.dart';
import 'package:Esse3/screens/screens.dart';
import 'package:Esse3/utils/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Pagina iniziale di login.
class LoginScreen extends StatefulWidget {
  static const String id = "loginScreen";
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();

  bool _isLoading = false;

  FocusNode _passFocus = FocusNode();

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
            title: Text("Attenzione!"),
            content: Text("Riempi correttamente tutti i campi"),
            actions: <Widget>[

              TextButton(

                child: Text(
                  "Chiudi",
                  style: TextStyle(color: Constants.mainColorLighter),
                ),
                onPressed: () {
                  _passController.clear();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    String _authCred =
        "${_userController.value.text}:${_passController.value.text}";
    Uint8List _bytesInLatin1 = latin1.encode(_authCred);
    String _basichAuth64 = "Basic " + base64.encode(_bytesInLatin1);

    Provider.getAccess(_basichAuth64, _userController.value.text.trim())
        .then((response) async {
      if (response == null) {
        setState(() {
          _isLoading = !_isLoading;
          _userController.clear();
          _passController.clear();
        });
        showDialog(
          context: context,
          builder: (BuildContext ctx) {
            return AlertDialog(
              title: Text("Errore di connessione"),
              content: Text("Riprova a effettuare l'accesso fra 30 secondi."),
              actions: <Widget>[

                TextButton(

                  child: Text(
                    "Chiudi",
                    style: TextStyle(color: Constants.mainColorLighter),
                  ),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                ),
              ],
            );
          },
        );
      } else if (response["success"] == true) {
        SharedPreferences prefs = await SharedPreferences.getInstance();

        prefs.setBool("isLoggedIn", true);
        prefs.setString("auth64Cred", _basichAuth64);
        prefs.setString("username", _userController.value.text.trim());

        setState(() {
          _isLoading = !_isLoading;
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(user: response),
          ),
        );
      } else if (!response["success"]) {
        setState(() {
          _isLoading = !_isLoading;
          _userController.clear();
          _passController.clear();
        });
        showDialog(
          context: context,
          builder: (BuildContext ctx) {
            return AlertDialog(
              title: Text("Credenziali errate!"),
              content: Text("Riprova a inserire le credenziali"),
              actions: <Widget>[

                TextButton(

                  child: Text("Chiudi",
                      style: TextStyle(color: Constants.mainColorLighter)),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
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
    double deviceWidth = MediaQuery.of(context).size.width;
    bool isTablet = deviceWidth > Constants.tabletWidth;
    return Stack(
      children: [
        Scaffold(),
        SvgPicture.asset(
          isTablet
              ? "assets/img/backgroundLoginTablet.svg"
              : "assets/img/backgroundLogin.svg",
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
                        "Esse3 Unimore",
                        style: Constants.fontBold32,
                      ),
                      Text(
                        "App non (ancora) ufficiale",
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
                              "Usa le credenziali Esse3 per accedere.",
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
                                      labelText: "Username",
                                      counterText: "",
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
                                      labelText: "Password",
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
                              child: Text(
                                "ACCEDI",
                                style: Constants.fontBold,
                              ),
                              padding: const EdgeInsets.all(16),
                              color: Constants.mainColor,
                              textColor: Colors.white,
                              disabledTextColor: Colors.black26,
                              minWidth: double.infinity,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30)),
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
