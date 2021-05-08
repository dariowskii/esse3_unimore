import 'dart:convert';
import 'dart:io';

import 'package:Esse3/constants.dart';
import 'package:Esse3/utils/database.dart';
import 'package:Esse3/utils/provider.dart';
import 'package:Esse3/widgets/chip_info.dart';
import 'package:Esse3/widgets/drawer_home.dart';
import 'package:Esse3/widgets/error_home_data.dart';
import 'package:Esse3/widgets/libretto_home_card.dart';
import 'package:Esse3/widgets/prossimi_appelli_card.dart';
import 'package:Esse3/widgets/tasse_home_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Home screen dell'app.
class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  static const String id = 'homeScreen';

  // ignore: prefer_const_constructors_in_immutables
  HomeScreen({this.user});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  List<String> _cdl;

  /// Future dell'utente in caso sia già loggato.
  Future<Map<String, dynamic>> _userFuture;
  AnimationController _controller;
  Animation _animation;

  /// Riprende le info dell'utente dal [DBProvider.db].
  Future<Map<String, dynamic>> _getUserDb(String user) async {
    final userData = await DBProvider.db.getUser(user);
    return userData;
  }

  /// Ritorna lo username corrente.
  Future<String> _getCurrentUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }

  Future<void> _initSession() async {
    if (Provider.shibSessionCookie.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username');
      final password = prefs.getString('password');
      await Provider.getSession(username, password);
    }
  }

  @override
  void initState() {
    _initSession();
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.decelerate,
    );
    _controller.addListener(() {
      setState(() {});
    });

    if (widget.user == null) {
      _getCurrentUserName().then((data) {
        setState(() {
          _userFuture = _getUserDb(data);
        });
      });
    } else {
      _cdl = widget.user['corso_stud'].toString().split('] - ');
      _cdl[0] = '${_cdl[0]}]';

      DBProvider.db
          .checkExistUser(widget.user['username'] as String)
          .then((data) {
        if (data != null) {
          DBProvider.db.updateUser(widget.user);
        } else {
          DBProvider.db.newUser(widget.user);
        }
      });

      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;
    final isTablet = deviceWidth > Constants.tabletWidth;
    return WillPopScope(
      onWillPop: () async {
        if (Platform.isAndroid) {
          await SystemNavigator.pop(animated: true);
        }
        return null;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Esse3',
          ),
          centerTitle: true,
        ),
        drawer: DrawerHome(user: widget.user, userFuture: _userFuture),
        body: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Stack(
            children: [
              SvgPicture.asset(
                'assets/img/backgroundHome.svg',
                width: deviceWidth,
              ),
              Container(
                width: deviceWidth,
                constraints: BoxConstraints(
                  minHeight: deviceHeight - 50,
                ),
                padding: isTablet
                    ? EdgeInsets.symmetric(horizontal: deviceWidth / 6)
                    : EdgeInsets.only(
                        left: deviceWidth >= 390 ? 20 : 16,
                        right: deviceWidth >= 390 ? 20 : 16,
                        bottom: 24),
                child: widget.user == null
                    ? FutureBuilder<dynamic>(
                        future: _userFuture,
                        builder: (context, userData) {
                          switch (userData.connectionState) {
                            case ConnectionState.none:
                              return ErrorHomeData();
                            case ConnectionState.waiting:
                              return const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Constants.mainColorDarker),
                                ),
                              );
                            case ConnectionState.active:
                            case ConnectionState.done:
                              if (!userData.hasData) return ErrorHomeData();
                              _cdl = userData.data['corso_stud']
                                  .toString()
                                  .split('] - ');
                              _cdl[0] += ']';
                              _controller.forward();
                              return Column(
                                children: <Widget>[
                                  Padding(
                                    padding: deviceWidth >= 390
                                        ? const EdgeInsets.symmetric(
                                            horizontal: 20)
                                        : const EdgeInsets.symmetric(
                                            horizontal: 0),
                                    child: Column(
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 20),
                                          width: 100,
                                          height: 100,
                                          alignment: Alignment.center,
                                          child: Container(
                                            width:
                                                (_animation.value as double) *
                                                    100,
                                            height:
                                                (_animation.value as double) *
                                                    100,
                                            padding: const EdgeInsets.all(2.0),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black12
                                                      .withOpacity(
                                                          (_animation.value
                                                                  as double) *
                                                              0.12),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 5),
                                                  spreadRadius: 3,
                                                )
                                              ],
                                            ),
                                            child: CircleAvatar(
                                              backgroundColor:
                                                  Constants.mainColorLighter,
                                              radius:
                                                  (_animation.value as double) *
                                                      50,
                                              backgroundImage: userData.data[
                                                          'profile_pic'] ==
                                                      'no'
                                                  ? null
                                                  : MemoryImage(base64Decode(
                                                      userData.data[
                                                              'profile_pic']
                                                          as String)),
                                              child: userData.data[
                                                          'profile_pic'] ==
                                                      'no'
                                                  ? Text(
                                                      userData.data[
                                                              'text_avatar']
                                                          as String,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w100,
                                                        fontSize:
                                                            (_animation.value
                                                                    as double) *
                                                                40,
                                                        color: Colors.white,
                                                      ),
                                                    )
                                                  : const SizedBox.shrink(),
                                            ),
                                          ),
                                        ),
                                        Text(
                                          userData.data['nome_studente']
                                              as String,
                                          style: Constants.fontBold28,
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          '- Mat. ${userData.data['matricola']} -',
                                          style: Constants.font16,
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          _cdl[1].toUpperCase(),
                                          textAlign: TextAlign.center,
                                          style: Constants.fontBold32,
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          _cdl[0],
                                          style: Constants.font16,
                                        ),
                                        const SizedBox(height: 20),
                                      ],
                                    ),
                                  ),
                                  Wrap(
                                    alignment: WrapAlignment.center,
                                    spacing: 10,
                                    runSpacing: -5,
                                    children: <Widget>[
                                      ChipInfo(
                                          text: userData.data['tipo_corso']
                                              as String,
                                          textSize:
                                              deviceWidth >= 390 ? 13 : 10),
                                      ChipInfo(
                                          text:
                                              'Profilo: ${userData.data['profilo_studente']}',
                                          textSize:
                                              deviceWidth >= 390 ? 13 : 10),
                                      ChipInfo(
                                          text:
                                              'Anno di Corso: ${userData.data['anno_corso']}',
                                          textSize:
                                              deviceWidth >= 390 ? 13 : 10),
                                      ChipInfo(
                                          text:
                                              'Immatricolazione: ${userData.data['data_imm']}',
                                          textSize:
                                              deviceWidth >= 390 ? 13 : 10),
                                      ChipInfo(
                                          text:
                                              'Part Time: ${userData.data['part_time']}',
                                          textSize:
                                              deviceWidth >= 390 ? 13 : 10),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  const LibrettoHomeCard(),
                                  const SizedBox(height: 15),
                                  ProssimiAppelliCard(),
                                  const SizedBox(height: 15),
                                  TasseHomeCard(),
                                ],
                              );
                            default:
                              return ErrorHomeData();
                          }
                        },
                      )
                    : Column(
                        children: <Widget>[
                          Padding(
                            padding: deviceWidth >= 390
                                ? const EdgeInsets.symmetric(horizontal: 20)
                                : const EdgeInsets.symmetric(horizontal: 0),
                            child: Column(
                              children: [
                                Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 20),
                                  alignment: Alignment.center,
                                  width: 100,
                                  height: 100,
                                  child: Container(
                                    width: (_animation.value as double) * 100,
                                    height: (_animation.value as double) * 100,
                                    padding: const EdgeInsets.all(2.0),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFFFFF),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12.withOpacity(
                                              (_animation.value as double) *
                                                  0.12),
                                          blurRadius: 10,
                                          offset: const Offset(0, 5),
                                          spreadRadius: 3,
                                        )
                                      ],
                                    ),
                                    child: CircleAvatar(
                                      backgroundColor:
                                          Constants.mainColorLighter,
                                      radius: (_animation.value as double) * 50,
                                      backgroundImage:
                                          widget.user['profile_pic'] == 'no'
                                              ? null
                                              : MemoryImage(base64Decode(
                                                  widget.user['profile_pic']
                                                      as String)),
                                      child: widget.user['profile_pic'] == 'no'
                                          ? Text(
                                              widget.user['text_avatar']
                                                  as String,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w100,
                                                fontSize: 40,
                                                color: Colors.white,
                                              ),
                                            )
                                          : const SizedBox.shrink(),
                                    ),
                                  ),
                                ),
                                Text(
                                  widget.user['nome'] as String,
                                  style: Constants.fontBold28,
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '- Mat. ${widget.user['matricola']} -',
                                  style: Constants.font16,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  _cdl[1].toUpperCase(),
                                  textAlign: TextAlign.center,
                                  style: Constants.fontBold32,
                                ),
                                const SizedBox(height: 5),
                                Text(_cdl[0], style: Constants.font16),
                                const SizedBox(height: 20),
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: 10,
                                  runSpacing: -5,
                                  children: <Widget>[
                                    ChipInfo(
                                        text:
                                            widget.user['tipo_corso'] as String,
                                        textSize: deviceWidth >= 390 ? 13 : 10),
                                    ChipInfo(
                                        text:
                                            'Profilo: ${widget.user['profilo_studente']}',
                                        textSize: deviceWidth >= 390 ? 13 : 10),
                                    ChipInfo(
                                        text:
                                            'Anno di Corso: ${widget.user['anno_corso']}',
                                        textSize: deviceWidth >= 390 ? 13 : 10),
                                    ChipInfo(
                                        text:
                                            'Immatricolazione: ${widget.user['data_imm']}',
                                        textSize: deviceWidth >= 390 ? 13 : 10),
                                    ChipInfo(
                                        text:
                                            'Part Time: ${widget.user['part_time']}',
                                        textSize: deviceWidth >= 390 ? 13 : 10),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          const LibrettoHomeCard(),
                          const SizedBox(height: 15),
                          ProssimiAppelliCard(),
                          const SizedBox(height: 15),
                          TasseHomeCard(),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
