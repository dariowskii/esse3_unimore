import 'dart:convert';
import 'dart:typed_data';

import 'package:Esse3/utils/widgets.dart';
import 'package:Esse3/constants.dart';
import 'screens.dart';
import 'package:Esse3/utils/utility.dart';
import 'package:Esse3/utils/database.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

_getCurrentUserName() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString("username");
}

Future _getUserDb(user) async {
  final userData = await DBProvider.db.getUser(user);
  return userData;
}

class HomePage extends StatefulWidget {
  final Map user;

  HomePage({this.user});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Uint8List _image;
  List<String> _cdl;
  String _userName;
  Future _userFuture;

  _loadImageFromPrefs() async {
    Utility.getImageFromPrefs(_userName).then((img) {
      if (null == img) return;
      setState(() {
        _image = base64Decode(img);
      });
    });
  }

  Future getImage() async {
    final _picker = ImagePicker();
    PickedFile image = await _picker.getImage(source: ImageSource.gallery);
    final bytes = await image.readAsBytes();
    Utility.saveImageToPrefs(_userName, Utility.base64String(bytes));
    _loadImageFromPrefs();
  }

  @override
  void initState() {
    super.initState();

    _getCurrentUserName().then((data) {
      _userName = data;
      _loadImageFromPrefs();
      if (widget.user == null) {
        setState(() {
          _userFuture = _getUserDb(data);
        });
      }
    });
    //Se hai appena effettuato il login, salva le informazioni base nel DB
    if (widget.user != null) {
      _cdl = widget.user["corso_stud"].toString().split("] - ");
      _cdl[0] = "${_cdl[0]}]";

      DBProvider.db.checkExistUser(widget.user["username"]).then((data) {
        if (data != null)
          DBProvider.db.updateUser(widget.user, widget.user["username"]);
        else
          DBProvider.db.newUser(widget.user);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          brightness: Brightness.light,
          elevation: 3,
          title: Text(
            "Esse3",
          ),
          centerTitle: true,
        ),
        drawer: Drawer(
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(16),
                width: double.infinity,
                color: kMainColor,
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Client Esse3",
                        style: const TextStyle(color: Colors.white, fontSize: 22),
                      ),
                      Text(
                        "Unimore",
                        style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      widget.user == null
                          ? FutureBuilder(
                              future: _userFuture,
                              builder: (context, userData) {
                                switch (userData.connectionState) {
                                  case ConnectionState.none:
                                    return Text("Nessuna connessione.");
                                  case ConnectionState.waiting:
                                    return LinearProgressIndicator();
                                  case ConnectionState.active:
                                  case ConnectionState.done:
                                    return Row(
                                      children: [
                                        Container(
                                          child: CircleAvatar(
                                            backgroundColor: kMainColor.withOpacity(0.9),
                                            radius: 30,
                                            backgroundImage: _image == null ? null : MemoryImage(_image),
                                            child: _image == null
                                                ? Text(
                                                    userData.data["text_avatar"],
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w100,
                                                      fontSize: 16,
                                                      color: Colors.white,
                                                    ),
                                                  )
                                                : null,
                                          ),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white,
                                          ),
                                          padding: const EdgeInsets.all(1),
                                        ),
                                        const SizedBox(width: 15),
                                        Flexible(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                "${userData.data["nome_studente"]}",
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                softWrap: true,
                                              ),
                                              const SizedBox(height: 5),
                                              Text(
                                                "Matr. ${userData.data["matricola"]}",
                                                style: const TextStyle(color: Colors.white),
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  default:
                                    return Text("Errore builder.");
                                }
                              },
                            )
                          : Row(
                              children: [
                                Container(
                                  child: CircleAvatar(
                                    backgroundColor: kMainColor.withOpacity(0.9),
                                    radius: 30,
                                    backgroundImage: _image == null ? null : MemoryImage(_image),
                                    child: _image == null
                                        ? Text(
                                            widget.user["text_avatar"],
                                            style: TextStyle(
                                              fontWeight: FontWeight.w100,
                                              fontSize: 16,
                                              color: Colors.white,
                                            ),
                                          )
                                        : null,
                                  ),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                  padding: const EdgeInsets.all(1),
                                ),
                                const SizedBox(width: 15),
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "${widget.user["nome"]}",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        softWrap: true,
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        "Matr. ${widget.user["matricola"]}",
                                        style: const TextStyle(color: Colors.white),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                      const SizedBox(height: 15),
                      Text(
                        "Created by 145622",
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      )
                    ],
                  ),
                ),
              ),
              // Divider(
              //   color: Colors.transparent,
              // ),
              // //TODO: decommentare pagina ORARIO LEZIONI !!!
              // BottonePaginaDrawer(
              //   testoBottone: "Orario lezioni",
              //   onPressed: () {
              //     Navigator.of(context).push(MaterialPageRoute(builder: (context) => OrarioLezioniPage()));
              //   },
              // ),
              // Divider(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    BottonePaginaDrawer(testoBottone: "Bacheca prenotazioni", onPressed: (){
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => BachecaPrenotazioniPage()));
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
                        testoBottone: "Impostazioni",
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => ImpostazioniPage()));
                        },
                        icona: Icons.settings),
                    Divider(),
                    BottonePaginaDrawer(
                      testoBottone: "Info sull'applicazione ",
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => InfoApp()));
                      },
                    ),
                    BottoneMaterialCustom(
                      onPressed: () async {
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        prefs.setBool("isLoggedIn", false);
                        prefs.remove("username");
                        prefs.remove("auth64Cred");
                        prefs.remove("tasseDaPagare");
                        prefs.remove("totEsamiSuperati");
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
                      },
                      text: "ESCI",
                      backgroundColor: kMainColor_darker,
                    )
                  ],
                ),
              )
            ],
          ),
        ),
        body: widget.user == null
            ? FutureBuilder<dynamic>(
                initialData: Text("Retrieving data..."),
                future: _userFuture,
                builder: (context, userData) {
                  if (userData.hasError) return Text("${userData.error}");
                  switch (userData.connectionState) {
                    case ConnectionState.none:
                      return Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Image(
                                width: 200,
                                image: AssetImage('assets/img/conn_problem.png'),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Text(
                                "Oops..",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
                              ),
                              SizedBox(height: 10),
                              Text(
                                "Ci sono problemi nel recuperare i tuoi dati, aggiorna oppure riprova tra un pò!",
                                softWrap: true,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 20,
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    case ConnectionState.waiting:
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(kMainColor_darker),
                        ),
                      );
                    case ConnectionState.active:
                      return Text("active");
                    case ConnectionState.done:
                      _cdl = userData.data["corso_stud"].toString().split("] - ");
                      _cdl[0] = "${_cdl[0]}]";

                      return SingleChildScrollView(
                        physics: ClampingScrollPhysics(),
                        child: CustomPaint(
                          size: Size.infinite,
                          painter: BackgroundPainter(),
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.only(
                                left: width >= 390 ? 20 : 16, right: width >= 390 ? 20 : 16, bottom: 24),
                            child: Column(
                              children: <Widget>[
                                AvatarGlow(
                                  endRadius: 100.0,
                                  repeat: true,
                                  glowColor: kMainColor_darker,
                                  child: Container(
                                    child: Stack(
                                      children: <Widget>[
                                        CircleAvatar(
                                          backgroundColor: kMainColor.withOpacity(0.9),
                                          radius: 60,
                                          backgroundImage: _image == null ? null : MemoryImage(_image),
                                          child: _image == null
                                              ? Text(
                                                  userData.data["text_avatar"],
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w100,
                                                    fontSize: 40,
                                                    color: Colors.white,
                                                  ),
                                                )
                                              : null,
                                        ),
                                        Positioned(
                                          bottom: 0,
                                          right: 0,
                                          width: 30,
                                          height: 30,
                                          child: FloatingActionButton(
                                            child: Icon(
                                              Icons.photo_camera,
                                              color: Colors.black,
                                              size: 15,
                                            ),
                                            backgroundColor: Colors.white,
                                            onPressed: () {
                                              getImage();
                                            },
                                          ),
                                        )
                                      ],
                                    ),
                                    padding: EdgeInsets.all(2.0),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFFFFFFF),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 10,
                                          offset: Offset(0, 5),
                                          spreadRadius: 3,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Text(
                                  userData.data["nome_studente"],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: width >= 390 ? 20 : 18),
                                ),
                                SizedBox(height: 15),
                                Text(
                                  "- Mat. ${userData.data["matricola"]} -",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 15),
                                Text(
                                  _cdl[1].toUpperCase(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: width >= 390 ? 25 : 22),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  _cdl[0],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: width >= 390 ? 20 : 18,
                                  ),
                                ),
                                SizedBox(height: 20),
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: 10,
                                  children: <Widget>[
                                    ChipInfo(text: userData.data["tipo_corso"], textSize: width >= 390 ? 13 : 10),
                                    ChipInfo(
                                        text: "Profilo: ${userData.data["profilo_studente"]}",
                                        textSize: width >= 390 ? 13 : 10),
                                    ChipInfo(
                                        text: "Anno di Corso: ${userData.data["anno_corso"]}",
                                        textSize: width >= 390 ? 13 : 10),
                                    ChipInfo(
                                        text: "Immatricolazione: ${userData.data["data_imm"]}",
                                        textSize: width >= 390 ? 13 : 10),
                                    ChipInfo(
                                        text: "Part Time: ${userData.data["part_time"]}",
                                        textSize: width >= 390 ? 13 : 10),
                                  ],
                                ),
                                SizedBox(height: 30),
                                LibrettoHome(),
                                SizedBox(height: 15),
                                ProssimiAppelli(),
                                SizedBox(height: 15),
                                TasseHome(),
                              ],
                            ),
                          ),
                        ),
                      );
                    default:
                      return Container();
                  }
                },
              )
            : SingleChildScrollView(
          physics: ClampingScrollPhysics(),
                child: CustomPaint(
                  size: Size.infinite,
                  painter: BackgroundPainter(),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(left: 20, right: 24, bottom: 20),
                    child: Column(
                      children: <Widget>[
                        AvatarGlow(
                          repeat: true,
                          glowColor: kMainColor_darker,
                          endRadius: 100.0,
                          child: Container(
                            child: Stack(
                              children: <Widget>[
                                CircleAvatar(
                                  backgroundColor: kMainColor.withOpacity(0.9),
                                  radius: 60,
                                  backgroundImage: _image == null ? null : MemoryImage(_image),
                                  child: _image == null
                                      ? Text(
                                          widget.user["text_avatar"],
                                          style: TextStyle(
                                            fontWeight: FontWeight.w100,
                                            fontSize: 40,
                                            color: Colors.white,
                                          ),
                                        )
                                      : null,
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  width: 30,
                                  height: 30,
                                  child: FloatingActionButton(
                                    child: Icon(
                                      Icons.photo_camera,
                                      color: Colors.black,
                                      size: 15,
                                    ),
                                    backgroundColor: Colors.white,
                                    onPressed: () {
                                      getImage();
                                    },
                                  ),
                                )
                              ],
                            ),
                            padding: EdgeInsets.all(2.0),
                            decoration: BoxDecoration(
                              color: Color(0xFFFFFFFF),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                  spreadRadius: 3,
                                )
                              ],
                            ),
                          ),
                        ),
                        Text(
                          widget.user["nome"],
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        SizedBox(height: 15),
                        Text(
                          "- Mat. ${widget.user["matricola"]} -",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 15),
                        Text(
                          _cdl[1].toUpperCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                        ),
                        SizedBox(height: 10),
                        Text(
                          _cdl[0],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        SizedBox(height: 20),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 10,
                          children: <Widget>[
                            ChipInfo(text: widget.user["tipo_corso"]),
                            ChipInfo(text: "Profilo: ${widget.user["profilo_studente"]}"),
                            ChipInfo(text: "Anno di Corso: ${widget.user["anno_corso"]}"),
                            ChipInfo(text: "Immatricolazione: ${widget.user["data_imm"]}"),
                            ChipInfo(text: "Part Time: ${widget.user["part_time"]}"),
                          ],
                        ),
                        SizedBox(height: 30),
                        LibrettoHome(),
                        SizedBox(height: 15),
                        ProssimiAppelli(),
                        SizedBox(height: 15),
                        TasseHome(),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
    final height = 500;
    final width = size.width;

    Paint paint = Paint();

    Path firstPath = Path();
    Path secondPath = Path();

    firstPath.moveTo(0, height * 0.2);
    firstPath.quadraticBezierTo(width * 0.08, height * 0.02, width * 0.2, height * 0.15);
    firstPath.quadraticBezierTo(width * 0.3, height * 0.25, width * 0.4, height * 0.15);
    firstPath.quadraticBezierTo(width * 0.6, height * 0.05, width * 0.7, height * 0.15);
    firstPath.quadraticBezierTo(width * 0.85, height * 0.29, width, height * 0.05);
    firstPath.lineTo(width, 0);
    firstPath.lineTo(0, 0);
    firstPath.close();

    paint.color = kMainColor_darker;
    canvas.drawPath(firstPath, paint);

    secondPath.moveTo(0, height * 0.25);
    secondPath.quadraticBezierTo(width * 0.1, height * 0.5, width * 0.2, height * 0.25);
    secondPath.quadraticBezierTo(width * 0.3, height * 0.05, width * 0.5, height * 0.2);
    secondPath.quadraticBezierTo(width * 0.6, height * 0.4, width * 0.75, height * 0.2);
    secondPath.quadraticBezierTo(width * 0.85, height * 0.1, width * 0.9, height * 0.25);
    secondPath.quadraticBezierTo(width * 0.95, height * 0.4, width, height * 0.3);
    secondPath.lineTo(width, 0);
    secondPath.lineTo(0, 0);
    secondPath.close();

    paint.color = kMainColor.withAlpha(60);
    canvas.drawPath(secondPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return oldDelegate != this;
  }
}
