import 'dart:io';

import 'package:Esse3/constants.dart';
import 'package:Esse3/models/studente_model.dart';
import 'package:Esse3/screens/bacheca_prenotazioni_screen.dart';
import 'package:Esse3/screens/info_app_screen.dart';
import 'package:Esse3/screens/login_screen.dart';
import 'package:Esse3/utils/provider.dart';
import 'package:Esse3/widgets/bottone_material_custom.dart';
import 'package:Esse3/widgets/bottone_pagina_drawer.dart';
import 'package:Esse3/widgets/drawer_header_home.dart';
import 'package:Esse3/widgets/future_drawer_header_home.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DrawerHome extends StatelessWidget {
  final StudenteModel? studenteModel;
  final Future<StudenteModel?>? userFuture;

  const DrawerHome(
      {Key? key, required this.studenteModel, required this.userFuture})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(
                top: 16,
                left: 16,
                right: 16,
                bottom: Platform.isAndroid ? 16 : 0),
            width: double.infinity,
            color: Constants.mainColor,
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Client Esse3',
                    style: TextStyle(color: Colors.white, fontSize: 22),
                  ),
                  const Text(
                    'Unimore',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  if (studenteModel == null && userFuture != null)
                    FutureDrawerHeaderHome(userFuture: userFuture!)
                  else
                    DrawerHeaderHome(studenteModel: studenteModel!),
                  const SizedBox(height: 15),
                  const Text(
                    'Created by 145622',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                BottonePaginaDrawer(
                  testoBottone: 'Bacheca prenotazioni',
                  textColor: Theme.of(context).textTheme.bodyText1!.color,
                  onPressed: () async {
                    await Navigator.of(context)
                        .pushNamed(BachecaPrenotazioniScreen.id);
                  },
                ),
                const Divider(),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                BottonePaginaDrawer(
                  testoBottone: "Info sull'applicazione",
                  textColor: Theme.of(context).textTheme.bodyText1!.color,
                  onPressed: () async {
                    await Navigator.of(context).pushNamed(InfoApp.id);
                  },
                ),
                BottoneMaterialCustom(
                  onPressed: () async {
                    Provider.cleanSession();
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.clear();
                    await prefs.setBool(Constants.version, true);
                    await Navigator.pushReplacementNamed(
                        context, LoginScreen.id);
                  },
                  textButton: 'ESCI',
                  backgroundColor: Constants.mainColorDarker,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
