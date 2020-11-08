import 'dart:convert';

import 'package:Esse3/constants.dart';
import 'package:Esse3/screens/screens.dart';
import 'package:Esse3/utils/provider.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();

  bool isLoading = false;

  FocusNode _passFocus = FocusNode();

  void clickBtn() {
    setState(() {
      isLoading = !isLoading;
    });
    login();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  void login() async {
    FocusScope.of(context).unfocus();

    if (_userController.value.text.isEmpty || _passController.value.text.isEmpty) {
      setState(() {
        isLoading = !isLoading;
      });
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Attenzione!"),
            content: Text("Riempi correttamente tutti i campi"),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  "Chiudi",
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

    var _authCred = "${_userController.value.text}:${_passController.value.text}";
    var _bytesInLatin1 = latin1.encode(_authCred);
    var authCred64 = base64.encode(_bytesInLatin1);
    var basichAuth64 = "Basic " + authCred64;

    Provider.getAccess(basichAuth64, _userController.value.text.trim()).then((data) async {
      if (data == null) {
        setState(() {
          isLoading = !isLoading;
          _userController.clear();
          _passController.clear();
        });
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: new Text("Errore di connessione"),
              content: new Text("Riprova a effettuare l'accesso fra 30 secondi."),
              actions: <Widget>[
                new FlatButton(
                  child: new Text("Chiudi"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } else if (data["success"] == true) {
        SharedPreferences prefs = await SharedPreferences.getInstance();

        prefs.setBool("isLoggedIn", true);
        prefs.setString("auth64Cred", authCred64);
        prefs.setString("username", _userController.value.text.trim());

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(user: data),
          ),
        );

        setState(() {
          isLoading = !isLoading;
        });
      } else if (!data["success"]) {
        setState(() {
          isLoading = !isLoading;
          _userController.clear();
          _passController.clear();
        });
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Credenziali errate!"),
              content: Text("Riprova a inserire le credenziali"),
              actions: <Widget>[
                FlatButton(
                  child: Text("Chiudi"),
                  onPressed: () {
                    Navigator.of(context).pop();
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
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        color: Colors.white,
        child: CustomPaint(
          willChange: false,
          painter: LoginPainter(height: height, width: width),
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: SingleChildScrollView(
              child: Container(
                height: height,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Expanded(child: Container()),
                    Padding(
                      padding: const EdgeInsets.only(right: 32),
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Text(
                                  "Esse3",
                                  style: TextStyle(
                                    textBaseline: TextBaseline.ideographic,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  "Unimore",
                                  style: TextStyle(
                                    height: 1.0,
                                    fontSize: width >= 390 ? 54 : 44,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text("App non (ancora) ufficiale"),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(32),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "Login",
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                "Usa le credenziali Esse3 per accedere",
                                style: TextStyle(
                                  fontWeight: FontWeight.w300,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 30),
                              TextField(
                                enabled: !isLoading,
                                maxLength: 8,
                                onSubmitted: (value){
                                  _passFocus.requestFocus();
                                },
                                cursorColor: kMainColor_darker,
                                controller: _userController,
                                decoration: InputDecoration(
                                    hintText: "Username", counterText: "", contentPadding: EdgeInsets.all(10)),
                              ),
                              SizedBox(height: 15),
                              TextField(
                                enabled: !isLoading,
                                focusNode: _passFocus,
                                onSubmitted: (value){
                                  if(!isLoading){
                                    clickBtn();
                                  }
                                },
                                obscureText: true,
                                cursorColor: kMainColor_darker,
                                controller: _passController,
                                decoration: InputDecoration(hintText: "Password", contentPadding: EdgeInsets.all(10)),
                              ),
                              SizedBox(height: 40),
                              isLoading
                                  ? Container(
                                      child: Column(
                                        children: <Widget>[LinearProgressIndicator(), SizedBox(height: 40)],
                                      ),
                                    )
                                  : SizedBox.shrink(),
                              MaterialButton(
                                onPressed: isLoading ? null : clickBtn,
                                disabledElevation: 1,
                                textColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30))),
                                minWidth: double.infinity,
                                elevation: 4,
                                color: kMainColor_darker,
                                height: 50,
                                child: Text("ENTRA"),
                                disabledColor: Colors.grey[350],
                              ),
                              SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LoginPainter extends CustomPainter {
  LoginPainter({this.height, this.width});

  final width;
  final height;

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint

    Paint paint = Paint();

    Path firstPath = Path();
    Path secondPath = Path();

    firstPath.moveTo(width * 0.4, 0);
    firstPath.quadraticBezierTo(width * 0.5, height * 0.15, width * 0.2, height * 0.2);
    firstPath.quadraticBezierTo(width * 0.05, height * 0.23, width * 0.1, height * 0.3);
    firstPath.quadraticBezierTo(width * 0.15, height * 0.36, 0, height * 0.4);
    firstPath.lineTo(0, 0);
    firstPath.close();

    paint.color = kMainColor;
    canvas.drawPath(firstPath, paint);

    secondPath.moveTo(width * 0.5, 0);
    secondPath.quadraticBezierTo(width * 0.6, height * 0.15, width * 0.3, height * 0.2);
    secondPath.quadraticBezierTo(width * 0.15, height * 0.23, width * 0.2, height * 0.3);
    secondPath.quadraticBezierTo(width * 0.25, height * 0.36, 0, height * 0.45);
    secondPath.lineTo(0, 0);
    secondPath.close();

    paint.color = kMainColor.withAlpha(60);
    canvas.drawPath(secondPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate != null;
  }
}
