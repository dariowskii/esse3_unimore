import 'dart:core';
import 'package:Esse3/utils/provider.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';
import 'package:animated_splash/animated_splash.dart';
import 'package:background_fetch/background_fetch.dart';

import 'package:flutter/material.dart';
import 'screens/screens.dart';

void backgroundFetchLibretto(String taskId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var nuoviVoti = prefs.getInt("totEsamiSuperati") ?? 99;
  Provider.getLibretto().then((libretto) {
    if (libretto != null && libretto["success"]) {
      prefs.setInt("totEsamiSuperati", libretto["superati"]);
      if (libretto["superati"] > nuoviVoti) {
        AwesomeNotifications().createNotification(
          content: NotificationContent(
              color: kMainColor_darker,
              backgroundColor: Colors.white,
              id: 1,
              channelKey: 'libretto',
              title: 'Nuovo voto registrato!',
              body: "Potrebbero aver registrato un nuovo voto nel libretto, dai un'occhiata."),
        );
      }
    }
  });
  BackgroundFetch.finish(taskId);
}

void backgroundFetchTasse(String taskId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var tasseDaPagare = prefs.getInt("tasseDaPagare") ?? 0;
  Provider.getTasse().then((tasse) {
    if (tasse != null && tasse["success"]) {
      prefs.setInt("tasseDaPagare", tasse["da_pagare"]);
      if (tasse["da_pagare"] > tasseDaPagare) {
        AwesomeNotifications().createNotification(
          content: NotificationContent(
              color: kMainColor_darker,
              backgroundColor: Colors.white,
              id: 1,
              channelKey: 'tasse',
              title: 'Nuove tasse!',
              body: "Potrebbero esserci nuove tasse da pagare, dai un'occhiata"),
        );
      }
    }

  });
  BackgroundFetch.finish(taskId);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var status = prefs.getBool('isLoggedIn') ?? false;
  BackgroundFetch.registerHeadlessTask(backgroundFetchTasse);
  BackgroundFetch.registerHeadlessTask(backgroundFetchLibretto);
  AwesomeNotifications().setChannel(NotificationChannel(
      importance: NotificationImportance.Max,
      channelKey: 'tasse',
      channelName: 'Tasse',
      channelDescription: 'Tasse universitarie.',
      defaultColor: Colors.white,
      ledColor: kMainColor_darker));
  AwesomeNotifications().setChannel(NotificationChannel(
      importance: NotificationImportance.Max,
      channelKey: 'libretto',
      channelName: 'Libretto',
      channelDescription: 'Libretto universitario',
      defaultColor: Colors.white,
      ledColor: kMainColor_darker));
  AwesomeNotifications().initialize('@mipmap/ic_launcher', [
    NotificationChannel(
      importance: NotificationImportance.Max,
      channelKey: 'libretto',
    ),
    NotificationChannel(
      importance: NotificationImportance.Max,
      channelKey: 'tasse',
    )
  ]);
  runApp(MyApp(status: status));
}

class MyApp extends StatefulWidget {
  MyApp({@required this.status});

  final bool status;

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    // Configure BackgroundFetch.
    BackgroundFetch.configure(
        BackgroundFetchConfig(
          minimumFetchInterval: 1440,
          stopOnTerminate: false,
          enableHeadless: true,
          requiresBatteryNotLow: true,
          requiresCharging: false,
          requiresStorageNotLow: false,
          requiresDeviceIdle: false,
          requiredNetworkType: NetworkType.ANY,
        ), (String taskId) async {
      backgroundFetchLibretto(taskId);
      backgroundFetchTasse(taskId);
    }).catchError((e) {
      print('[BackgroundFetch] configure ERROR: $e');
    });

    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          color: Colors.white,
          iconTheme: IconThemeData(
            color: kMainColor,
          ),
          textTheme: TextTheme(
            headline6:
                TextStyle(color: kMainColor, fontWeight: FontWeight.bold, fontFamily: 'Proxima Nova', fontSize: 20),
          ),
        ),
        accentColorBrightness: Brightness.light,
        buttonTheme: ButtonThemeData(
          colorScheme: Theme.of(context).colorScheme.copyWith(secondary: kMainColor),
        ),
        accentColor: kMainColor,
        primaryColor: kMainColor,
        backgroundColor: Colors.white,
        splashColor: Colors.white,
        primaryColorDark: kMainColor_darker,
        fontFamily: 'Proxima Nova',
      ),
      home: AnimatedSplash(
        home: widget.status ? HomePage() : LoginPage(),
        imagePath: 'assets/img/logo_app.png',
        duration: 1500,
        type: AnimatedSplashType.StaticDuration,
      ),
    );
  }
}
