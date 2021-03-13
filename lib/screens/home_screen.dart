import 'dart:convert';
import 'dart:io';

import 'package:Esse3/utils/widgets.dart';
import 'package:Esse3/constants.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'screens.dart';
import 'package:Esse3/utils/database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Home screen dell'app.
class HomeScreen extends StatefulWidget {
  final Map user;
  static const String id = 'homeScreen';

  HomeScreen({this.user});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  List<String> _cdl;

  /// Future dell'utente in caso sia già loggato.
  Future _userFuture;
  AnimationController _controller;
  Animation _animation;

  /// Riprende le info dell'utente dal [DBProvider.db].
  Future _getUserDb(String user) async {
    final userData = await DBProvider.db.getUser(user);
    return userData;
  }

  /// Ritorna lo username corrente.
  Future<String> _getCurrentUserName() async {
    var prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 600),
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

      DBProvider.db.checkExistUser(widget.user['username']).then((data) {
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
    var deviceWidth = MediaQuery.of(context).size.width;
    var deviceHeight = MediaQuery.of(context).size.height;
    var isTablet = deviceWidth > Constants.tabletWidth;
    return WillPopScope(
      onWillPop: () async {
        if (Platform.isAndroid) {
          await SystemNavigator.pop(animated: true);
        }
        return null;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Esse3',
          ),
          centerTitle: true,
        ),
        drawer: Drawer(
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
                      Text(
                        'Client Esse3',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 22),
                      ),
                      Text(
                        'Unimore',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      widget.user == null
                          ? FutureBuilder(
                              future: _userFuture,
                              builder: (context, userData) {
                                switch (userData.connectionState) {
                                  case ConnectionState.none:
                                    return Text('Nessuna connessione.');
                                  case ConnectionState.waiting:
                                    return LinearProgressIndicator();
                                  case ConnectionState.active:
                                  case ConnectionState.done:
                                    if (!userData.hasData) {
                                      return Text(
                                          'Errore nel recuperare i dati.');
                                    }
                                    return Row(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white,
                                          ),
                                          padding: const EdgeInsets.all(1),
                                          child: CircleAvatar(
                                            backgroundColor: Constants.mainColor
                                                .withOpacity(0.9),
                                            radius: 30,
                                            backgroundImage: userData
                                                        .data['profile_pic'] ==
                                                    'no'
                                                ? null
                                                : MemoryImage(base64Decode(
                                                    userData
                                                        .data['profile_pic'])),
                                            child: userData
                                                        .data['profile_pic'] ==
                                                    'no'
                                                ? Text(
                                                    userData
                                                        .data['text_avatar'],
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w100,
                                                      fontSize: 16,
                                                      color: Colors.white,
                                                    ),
                                                  )
                                                : SizedBox.shrink(),
                                          ),
                                        ),
                                        const SizedBox(width: 15),
                                        Flexible(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                '${userData.data['nome_studente']}',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                softWrap: true,
                                              ),
                                              const SizedBox(height: 5),
                                              Text(
                                                'Matr. ${userData.data['matricola']}',
                                                style: const TextStyle(
                                                    color: Colors.white),
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  default:
                                    return Text('Errore builder.');
                                }
                              },
                            )
                          : Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                  padding: const EdgeInsets.all(1),
                                  child: CircleAvatar(
                                    backgroundColor:
                                        Constants.mainColor.withOpacity(0.9),
                                    radius: 30,
                                    backgroundImage:
                                        widget.user['profile_pic'] == 'no'
                                            ? null
                                            : MemoryImage(base64Decode(
                                                widget.user['profile_pic'])),
                                    child: widget.user['profile_pic'] == 'no'
                                        ? Text(
                                            widget.user['text_avatar'],
                                            style: TextStyle(
                                              fontWeight: FontWeight.w100,
                                              fontSize: 16,
                                              color: Colors.white,
                                            ),
                                          )
                                        : SizedBox.shrink(),
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${widget.user['nome']}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        softWrap: true,
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        'Matr. ${widget.user['matricola']}',
                                        style: const TextStyle(
                                            color: Colors.white),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                      const SizedBox(height: 15),
                      Text(
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
                        textColor: Theme.of(context).textTheme.bodyText1.color,
                        onPressed: () {
                          Navigator.of(context)
                              .pushNamed(BachecaPrenotazioniScreen.id);
                        }),
                    Divider(),
                  ],
                ),
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    BottonePaginaDrawer(
                      testoBottone: "Info sull'applicazione",
                      textColor: Theme.of(context).textTheme.bodyText1.color,
                      onPressed: () {
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => InfoApp()));
                      },
                    ),
                    BottoneMaterialCustom(
                      onPressed: () async {
                        var prefs =
                            await SharedPreferences.getInstance();
                        await prefs.clear();
                        await prefs.setBool('1.2.0', true);
                        await Navigator.pushReplacementNamed(context, LoginScreen.id);
                      },
                      textButton: 'ESCI',
                      backgroundColor: Constants.mainColorDarker,
                    )
                  ],
                ),
              )
            ],
          ),
        ),
        body: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          child: Stack(
            children: [
              SvgPicture.asset(
                'assets/img/backgroundHome.svg',
                width: deviceWidth,
              ),
              Container(
                width: double.infinity,
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
                              return Center(
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
                                        ? EdgeInsets.symmetric(horizontal: 20)
                                        : EdgeInsets.symmetric(horizontal: 0),
                                    child: Column(
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 20),
                                          width: 100,
                                          height: 100,
                                          alignment: Alignment.center,
                                          child: Container(
                                            width: _animation.value * 100,
                                            height: _animation.value * 100,
                                            padding: EdgeInsets.all(2.0),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black12
                                                      .withOpacity(
                                                          _animation.value *
                                                              0.12),
                                                  blurRadius: 10,
                                                  offset: Offset(0, 5),
                                                  spreadRadius: 3,
                                                )
                                              ],
                                            ),
                                            child: CircleAvatar(
                                              backgroundColor:
                                                  Constants.mainColorLighter,
                                              radius: _animation.value * 50,
                                              backgroundImage: userData.data[
                                                          'profile_pic'] ==
                                                      'no'
                                                  ? null
                                                  : MemoryImage(base64Decode(
                                                      userData.data[
                                                          'profile_pic'])),
                                              child: userData.data[
                                                          'profile_pic'] ==
                                                      'no'
                                                  ? Text(
                                                      userData
                                                          .data['text_avatar'],
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w100,
                                                        fontSize:
                                                            _animation.value *
                                                                40,
                                                        color: Colors.white,
                                                      ),
                                                    )
                                                  : SizedBox.shrink(),
                                            ),
                                          ),
                                        ),
                                        Text(
                                          userData.data['nome_studente'],
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
                                          text: userData.data['tipo_corso'],
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
                                  LibrettoHomeCard(),
                                  SizedBox(height: 15),
                                  ProssimiAppelliCard(),
                                  SizedBox(height: 15),
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
                                ? EdgeInsets.symmetric(horizontal: 20)
                                : EdgeInsets.symmetric(horizontal: 0),
                            child: Column(
                              children: [
                                Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 20),
                                  alignment: Alignment.center,
                                  width: 100,
                                  height: 100,
                                  child: Container(
                                    width: _animation.value * 100,
                                    height: _animation.value * 100,
                                    padding: EdgeInsets.all(2.0),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFFFFFFF),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12.withOpacity(
                                              _animation.value * 0.12),
                                          blurRadius: 10,
                                          offset: Offset(0, 5),
                                          spreadRadius: 3,
                                        )
                                      ],
                                    ),
                                    child: CircleAvatar(
                                      backgroundColor:
                                          Constants.mainColorLighter,
                                      radius: _animation.value * 50,
                                      backgroundImage:
                                          widget.user['profile_pic'] == 'no'
                                              ? null
                                              : MemoryImage(base64Decode(
                                                  widget.user['profile_pic'])),
                                      child: widget.user['profile_pic'] == 'no'
                                          ? Text(
                                              widget.user['text_avatar'],
                                              style: TextStyle(
                                                fontWeight: FontWeight.w100,
                                                fontSize: 40,
                                                color: Colors.white,
                                              ),
                                            )
                                          : SizedBox.shrink(),
                                    ),
                                  ),
                                ),
                                Text(
                                  widget.user['nome'],
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
                                        text: widget.user['tipo_corso'],
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
                          LibrettoHomeCard(),
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
