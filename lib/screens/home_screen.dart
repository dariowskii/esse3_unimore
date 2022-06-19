import 'dart:io';

import 'package:Esse3/constants.dart';
import 'package:Esse3/models/auth_credential_model.dart';
import 'package:Esse3/utils/database.dart';
import 'package:Esse3/utils/provider.dart';
import 'package:Esse3/utils/shared_wrapper.dart';
import 'package:Esse3/widgets/drawer_home.dart';
import 'package:Esse3/widgets/home/future_home_screen.dart';
import 'package:Esse3/widgets/home/home_screen_builder.dart';
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
    final authCredential = await SharedWrapper.shared.getUserCreditentials();
    return authCredential.username;
  }

  Future<void> _initSession() async {
    if (Provider.shibSessionCookie.isEmpty) {
      final authCredential = await SharedWrapper.shared.getUserCreditentials();
      await Provider.getSession(
          authCredential.username, authCredential.password);
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
                    ? FutureHomeScreen(
                        userFuture: _userFuture,
                        controllerAnimation: _controller,
                        animation: _animation,
                        deviceWidth: deviceWidth,
                      )
                    : HomeScreenBuilder(
                        deviceWidth: deviceWidth,
                        animation: _animation,
                        user: widget.user,
                        cdl: _cdl,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
