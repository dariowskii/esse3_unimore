import 'package:Esse3/constants.dart';
import 'package:Esse3/screens/screens.dart';
import 'package:Esse3/utils/provider.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ChipInfo extends StatelessWidget {
  final String text;
  final double textSize;

  ChipInfo({this.text, this.textSize});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: textSize,
        ),
      ),
      backgroundColor: kMainColor_darker,
    );
  }
}

class LibrettoHome extends StatefulWidget {
  const LibrettoHome({
    Key key,
  }) : super(key: key);

  @override
  _LibrettoHomeState createState() => _LibrettoHomeState();
}

class _LibrettoHomeState extends State<LibrettoHome> {
  Future<Map> _libretto;
  bool _isRequestedLibretto = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(color: Colors.black12, offset: Offset(0, 2), spreadRadius: 1, blurRadius: 3),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Libretto",
                  style: TextStyle(
                    color: kMainColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 22,
                  ),
                ),
                Icon(
                  Icons.book,
                  color: kMainColor_darker,
                ),
              ],
            ),
            SizedBox(height: 20),
            _isRequestedLibretto
                ? FutureBuilder(
                    future: _libretto,
                    builder: (_, libretto) {
                      switch (libretto.connectionState) {
                        case ConnectionState.none:
                          return Row(
                            children: <Widget>[
                              Icon(
                                Icons.error,
                                color: Colors.redAccent,
                              ),
                              SizedBox(width: 5),
                              Text(
                                "Errore nel recuperare i dati!",
                              ),
                              Expanded(child: Container()),
                              IconButton(
                                  icon: Icon(Icons.refresh),
                                  onPressed: () {
                                    setState(() {
                                      _libretto = Provider.getLibretto();
                                    });
                                  })
                            ],
                          );
                        case ConnectionState.waiting:
                          return Column(
                            children: <Widget>[
                              Text(
                                "Sto recuperando i tuoi dati...",
                                style: TextStyle(
                                  color: kMainColor,
                                ),
                              ),
                              SizedBox(height: 10),
                              LinearProgressIndicator(),
                            ],
                          );
                        case ConnectionState.active:
                        case ConnectionState.done:
                          if (libretto.data == null)
                            return Row(
                              children: <Widget>[
                                Icon(
                                  Icons.error,
                                  color: Colors.redAccent,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  "Errore nel recuperare i dati!",
                                ),
                                Expanded(child: Container()),
                                IconButton(
                                    icon: Icon(Icons.refresh),
                                    onPressed: () {
                                      setState(() {
                                        _libretto = Provider.getLibretto();
                                      });
                                    })
                              ],
                            );
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Flexible(
                                    child: RichText(
                                      text: TextSpan(
                                        text: '${libretto.data["superati"]} esami su ${libretto.data["totali"]} '
                                            'superati. ',
                                        style: DefaultTextStyle.of(context).style.copyWith(fontSize: 15),
                                        children: <TextSpan>[
                                          TextSpan(
                                              text: libretto.data["superati"] == libretto.data["totali"]
                                                  ? "Che la Sbronza sia con te!"
                                                  : libretto.data["superati"] > (libretto.data["totali"] / 2)
                                                      ? "Ci sei quasi!"
                                                      : "Continua cosi!",
                                              style: TextStyle(fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Stack(
                                alignment: Alignment.center,
                                children: <Widget>[
                                  Container(
                                    height: 12,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: kMainColor, width: 2),
                                      borderRadius: BorderRadius.all(Radius.circular(20)),
                                      color: Colors.white,
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 4),
                                      child: LayoutBuilder(
                                        builder: (BuildContext context, BoxConstraints constraints) {
                                          return Container(
                                            height: 5,
                                            width: (constraints.maxWidth /
                                                libretto.data["totali"] *
                                                libretto.data["superati"]),
                                            decoration: BoxDecoration(
                                              color: kMainColor,
                                              borderRadius: BorderRadius.all(Radius.circular(20)),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                              Center(
                                child: MaterialButton(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(50)),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => LibrettoPage(
                                          libretto: libretto.data,
                                        ),
                                      ),
                                    );
                                  },
                                  color: kMainColor,
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Text(
                                      "Guarda Libretto",
                                      style: TextStyle(color: Colors.white, fontSize: 16),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        default:
                          return Container();
                      }
                    })
                : MaterialButton(
                    onPressed: () async {
                      setState(() {
                        _libretto = Provider.getLibretto();
                        _isRequestedLibretto = !_isRequestedLibretto;
                      });
                    },
                    color: kMainColor,
                    minWidth: double.infinity,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(50))),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        "Scarica info",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class ProssimiAppelli extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(color: Colors.black12, offset: Offset(0, 2), spreadRadius: 1, blurRadius: 3),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Prossimi appelli",
                  style: TextStyle(
                    color: kMainColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 22,
                  ),
                ),
                Icon(
                  Icons.mode_edit,
                  color: kMainColor_darker,
                ),
              ],
            ),
            SizedBox(height: 20),
            MaterialButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AppelliPage(),
                  ),
                ).then((value){
                  //TODO: sistemare getAppelliPrenotati
                  Provider.getAppelliPrenotati();
                });
              },
              color: kMainColor,
              minWidth: double.infinity,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(50))),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  "Guarda i prossimi appelli",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TasseHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Tasse universitarie",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 22,
                  ),
                ),
                Icon(
                  Icons.monetization_on,
                  color: Colors.white,
                ),
              ],
            ),
            SizedBox(height: 20),
            MaterialButton(
              elevation: 0,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => TassePage(),
                  ),
                );
              },
              color: Colors.white,
              minWidth: double.infinity,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(50))),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  "Sei sicuro di volerle guardare?",
                  style: TextStyle(color: Colors.redAccent, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CardEsame extends StatelessWidget {
  CardEsame({this.nomeEsame, this.codiceEsame, this.votoEsame, this.dataEsame, this.cfu});

  final String cfu;
  final String nomeEsame;
  final String codiceEsame;
  final String votoEsame;
  final String dataEsame;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 15),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(10)),
            // border: Border.all(color: kMainColor, width: 1),
            boxShadow: [
              BoxShadow(color: Colors.black12, offset: Offset(0, 2), spreadRadius: 1, blurRadius: 3),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        nomeEsame,
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20, color: kMainColor),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        codiceEsame,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Text(
                            "CFU: ",
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            cfu,
                            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                          )
                        ],
                      )
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  color: Colors.black12,
                  width: 1,
                  height: 30,
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: <Widget>[
                      Text(
                        "VOTO",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 5),
                      votoEsame != ""
                          ? Text(
                              votoEsame,
                              style: TextStyle(
                                fontSize: 20,
                                color: kMainColor_extraDark,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : Text("NaN"),
                      dataEsame.length > 1 ? SizedBox(height: 8) : SizedBox.shrink(),
                      dataEsame.length > 1
                          ? Text(
                              "Esame del $dataEsame",
                              textAlign: TextAlign.center,
                            )
                          : SizedBox.shrink(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        dataEsame.length > 1
            ? Positioned(
                right: 0,
                top: 0,
                child: Image(
                  image: AssetImage("assets/img/premio.png"),
                  height: 40,
                ),
              )
            : SizedBox.shrink(),
      ],
    );
  }
}

class BollinoAndamento extends StatelessWidget {
  final String testo;
  final IconData icona;
  final Color colore;
  final Color coloreSfondo;
  final bool bordoOmbra;
  final double fontSize;

  const BollinoAndamento({
    Key key,
    @required this.testo,
    @required this.icona,
    this.colore = Colors.white,
    @required this.coloreSfondo,
    this.bordoOmbra = false,
    this.fontSize = 16,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: bordoOmbra ? Border.all(width: 2, color: Colors.white) : null,
        boxShadow: bordoOmbra
            ? [
                BoxShadow(
                  offset: Offset(0, 0),
                  color: Colors.black12,
                  blurRadius: 10,
                )
              ]
            : null,
        color: coloreSfondo,
        borderRadius: BorderRadius.all(Radius.circular(30)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          Icon(
            icona,
            color: colore,
          ),
          const SizedBox(width: 5),
          Text(
            testo.toUpperCase(),
            style: TextStyle(color: colore, fontSize: fontSize),
          ),
        ],
      ),
    );
  }
}

class CardAppello extends StatefulWidget {
  final String nomeMateria;
  final String dataAppello;
  final String desc;
  final String periodoIscrizioni;
  final String sessione;
  final String urlInfo;

  CardAppello({this.nomeMateria, this.dataAppello, this.desc, this.periodoIscrizioni, this.sessione, this.urlInfo});

  @override
  _CardAppelloState createState() => _CardAppelloState();
}

class _CardAppelloState extends State<CardAppello> {
  Future<Map> _altreInfo;
  bool _isRequestedAltreInfo = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      width: double.infinity,
      decoration: BoxDecoration(
        // border: Border.all(color: kMainColor_darker),
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(color: Colors.black12, offset: Offset(0, 2), spreadRadius: 1, blurRadius: 3),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    widget.nomeMateria,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 22,
                      color: kMainColor,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: <Widget>[
                      Text("Data appello: ", style: TextStyle(fontSize: 16)),
                      Text(
                        widget.dataAppello,
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text("Descrizione: ${widget.desc}"),
                  SizedBox(
                    height: 5,
                  ),
                  Text("Periodo iscrizioni: ${widget.periodoIscrizioni}"),
                  SizedBox(
                    height: 5,
                  ),
                  Text("Sessione: ${widget.sessione}"),
                  SizedBox(
                    height: 20,
                  ),
                  _isRequestedAltreInfo
                      ? FutureBuilder(
                          future: _altreInfo,
                          builder: (context, altreInfo) {
                            switch (altreInfo.connectionState) {
                              case ConnectionState.none:
                                return Column(
                                  children: [
                                    Row(
                                      children: <Widget>[
                                        Icon(
                                          Icons.error,
                                          color: Colors.redAccent,
                                        ),
                                        SizedBox(width: 5),
                                        Text(
                                          "Errore nel recuperare i dati!",
                                        ),
                                        Expanded(child: Container()),
                                        IconButton(
                                            icon: Icon(Icons.refresh),
                                            onPressed: () {
                                              setState(() {
                                                _altreInfo = Provider.getInfoAppello(widget.urlInfo);
                                              });
                                            })
                                      ],
                                    ),
                                    MaterialButton(
                                      padding: const EdgeInsets.all(0),
                                      minWidth: double.infinity,
                                      color: kMainColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      child: Text("PROMEMORIA", style: TextStyle(color: Colors.white)),
                                      onPressed: () {
                                        var giorno = widget.dataAppello.substring(0, 2);
                                        var mese = widget.dataAppello.substring(3, 5);
                                        int anno = int.parse(widget.dataAppello.substring(6));

                                        final Event event = Event(
                                          title: widget.nomeMateria,
                                          description: widget.desc,
                                          location: 'Università di Modena e Reggio Emilia',
                                          startDate: DateTime.parse("$anno-$mese-$giorno"),
                                          endDate: DateTime.parse("$anno-$mese-$giorno"),
                                          allDay: true,
                                        );

                                        Add2Calendar.addEvent2Cal(event);
                                      },
                                    )
                                  ],
                                );
                              case ConnectionState.waiting:
                                return Column(
                                  children: <Widget>[
                                    Text(
                                      "Sto recuperando i tuoi dati...",
                                      style: TextStyle(
                                        color: kMainColor,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    LinearProgressIndicator(),
                                    SizedBox(
                                      height: 16,
                                    ),
                                    MaterialButton(
                                      padding: const EdgeInsets.all(0),
                                      minWidth: double.infinity,
                                      color: kMainColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      child: Text("PROMEMORIA", style: TextStyle(color: Colors.white)),
                                      onPressed: () {
                                        var giorno = widget.dataAppello.substring(0, 2);
                                        var mese = widget.dataAppello.substring(3, 5);
                                        int anno = int.parse(widget.dataAppello.substring(6));

                                        final Event event = Event(
                                          title: widget.nomeMateria,
                                          description: widget.desc,
                                          location: 'Università di Modena e Reggio Emilia',
                                          startDate: DateTime.parse("$anno-$mese-$giorno"),
                                          endDate: DateTime.parse("$anno-$mese-$giorno"),
                                          allDay: true,
                                        );

                                        Add2Calendar.addEvent2Cal(event);
                                      },
                                    )
                                  ],
                                );
                              case ConnectionState.active:
                              case ConnectionState.done:
                                if (altreInfo.data == null) return Text("Errore caricamento");
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text("Tipo esame: "),
                                        Text(
                                          altreInfo.data["tipo_esame"],
                                          style: TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                    Text("Verbalizzazione: ${altreInfo.data["verbalizzazione"]}"),
                                    Text("Aula: ${altreInfo.data["aula"]}"),
                                    Row(
                                      children: [
                                        Text("Numero iscritti: "),
                                        Text(
                                          altreInfo.data["num_iscritti"],
                                          style: TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      "Docente: ${altreInfo.data["docente"]}",
                                      style: TextStyle(fontWeight: FontWeight.w600),
                                      textAlign: TextAlign.left,
                                    ),
                                    SizedBox(height: 20),
                                    Row(
                                      children: [
                                        altreInfo.data["tabellaHidden"] != null ?
                                        Flexible(
                                          child: MaterialButton(
                                            padding: const EdgeInsets.all(0),
                                            minWidth: double.infinity,
                                            color: Colors.green,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(50),
                                            ),
                                            child: Text("PRENOTA", style: TextStyle(color: Colors.white)),
                                            onLongPress: (){
                                              showDialog(
                                                context: context,
                                                child: AlertDialog(
                                                  title: Text("Prenotazione appello"),
                                                  content: Text("Sei sicuro di volerti prenotare?"),
                                                  actions: [
                                                    FlatButton(
                                                      child: Text("SI", style: TextStyle(color: Colors.black87),),
                                                      onPressed: (){
                                                        Navigator.of(context).pop();
                                                        showDialog(
                                                          context: context,
                                                          child: WillPopScope(
                                                            onWillPop: () async => null,
                                                            child: AlertDialog(
                                                              content: Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                children: [
                                                                  CircularProgressIndicator(),
                                                                  const SizedBox(width: 10),
                                                                  Text("Attendi un secondo..."),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                        Provider.prenotaAppello(altreInfo.data).then((value){
                                                          if(value != null && value){
                                                            Navigator.of(context).pop();
                                                            showDialog(
                                                              context: context,
                                                              child: AlertDialog(
                                                                content: Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                  children: [
                                                                    Icon(
                                                                      Icons.check,
                                                                      color: Colors.green,
                                                                    ),
                                                                    const SizedBox(width: 10),
                                                                    Text("Prenotazione effettuata!"),
                                                                  ],
                                                                ),
                                                              )
                                                            );
                                                            Future.delayed(Duration(seconds: 1), (){
                                                              Navigator.of(context).pop();
                                                              Navigator.of(context).pop();
                                                            });
                                                          }
                                                          else {
                                                            Navigator.of(context).pop();
                                                            showDialog(
                                                              context: context,
                                                              child: WillPopScope(
                                                                onWillPop: () async => null,
                                                                child: AlertDialog(
                                                                  content: Row(
                                                                    children: [
                                                                      Icon(Icons.error, color: Colors.redAccent,),
                                                                      const SizedBox(width: 10),
                                                                      Text("Prenotazione non effettuata"),
                                                                    ],
                                                                  ),
                                                                ),
                                                              )
                                                            );
                                                            Future.delayed(Duration(seconds: 1), (){
                                                              Navigator.of(context).pop();
                                                            });
                                                          }
                                                        });
                                                      },
                                                    ),
                                                    MaterialButton(
                                                      color: Colors.redAccent,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(50),
                                                      ),
                                                      child: Text("NO"),
                                                      onPressed: (){
                                                        Navigator.of(context).pop();
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              );

                                            },
                                          ),
                                        ) : SizedBox.shrink(),
                                        altreInfo.data["tabellaHidden"] != null ?
                                        SizedBox(width: 10) : SizedBox.shrink(),
                                        Flexible(
                                          child: MaterialButton(
                                            padding: const EdgeInsets.all(0),
                                            minWidth: double.infinity,
                                            color: kMainColor,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(50),
                                            ),
                                            child: Text("PROMEMORIA", style: TextStyle(color: Colors.white)),
                                            onPressed: () {
                                              var giorno = widget.dataAppello.substring(0, 2);
                                              var mese = widget.dataAppello.substring(3, 5);
                                              int anno = int.parse(widget.dataAppello.substring(6));

                                              final Event event = Event(
                                                title: widget.nomeMateria,
                                                description: widget.desc,
                                                location: 'Università di Modena e Reggio Emilia',
                                                startDate: DateTime.parse("$anno-$mese-$giorno"),
                                                endDate: DateTime.parse("$anno-$mese-$giorno"),
                                                allDay: true,
                                              );

                                              Add2Calendar.addEvent2Cal(event);
                                            },
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                );
                              default:
                                return Text("Errore interno");
                            }
                          },
                        )
                      : SizedBox.shrink(),
                  Column(
                    children: [
                      _isRequestedAltreInfo
                          ? SizedBox.shrink()
                          : MaterialButton(
                              child: Text("ALTRE INFO", style: TextStyle(color: kMainColor)),
                              onPressed: () {
                                setState(() {
                                  _isRequestedAltreInfo = !_isRequestedAltreInfo;
                                  _altreInfo = Provider.getInfoAppello(widget.urlInfo);
                                });
                              }),
                      // Visibility(
                      //   visible: _isRequestedAltreInfo,
                      //   child: Flexible(
                      //     child: MaterialButton(
                      //       padding: const EdgeInsets.all(0),
                      //       minWidth: double.infinity,
                      //       color: Colors.green,
                      //       shape: RoundedRectangleBorder(
                      //         borderRadius: BorderRadius.circular(50),
                      //       ),
                      //       child: Text("PRENOTA", style: TextStyle(color: Colors.white)),
                      //       onLongPress: (){
                      //         showDialog(
                      //           context: context,
                      //           child: AlertDialog(
                      //             title: Text("Prenotazione appello"),
                      //             content: Text("Sei sicuro di volerti prenotare?"),
                      //             actions: [
                      //               FlatButton(
                      //                 child: Text("SI", style: TextStyle(color: Colors.black87),),
                      //                 onPressed: (){
                      //
                      //                 },
                      //               ),
                      //               MaterialButton(
                      //                 color: Colors.redAccent,
                      //                 shape: RoundedRectangleBorder(
                      //                   borderRadius: BorderRadius.circular(50),
                      //                 ),
                      //                 child: Text("NO"),
                      //                 onPressed: (){
                      //                   Navigator.of(context).pop();
                      //                 },
                      //               ),
                      //             ],
                      //           ),
                      //         );
                      //
                      //       },
                      //     ),
                      //   ),
                      // ),
                      // Visibility(
                      //   visible: _isRequestedAltreInfo,
                      //   child: const SizedBox(width: 10),
                      // ),
                      _isRequestedAltreInfo
                          ? SizedBox.shrink()
                          : MaterialButton(
                            padding: const EdgeInsets.all(0),
                            minWidth: double.infinity,
                            color: kMainColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Text("PROMEMORIA", style: TextStyle(color: Colors.white)),
                            onPressed: () {
                              var giorno = widget.dataAppello.substring(0, 2);
                              var mese = widget.dataAppello.substring(3, 5);
                              int anno = int.parse(widget.dataAppello.substring(6));

                              final Event event = Event(
                                title: widget.nomeMateria,
                                description: widget.desc,
                                location: 'Università di Modena e Reggio Emilia',
                                startDate: DateTime.parse("$anno-$mese-$giorno"),
                                endDate: DateTime.parse("$anno-$mese-$giorno"),
                                allDay: true,
                              );

                              Add2Calendar.addEvent2Cal(event);
                            },
                          )
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CardTassa extends StatelessWidget {
  final String desc;
  final String euro;
  final String scadenza;
  final String pagamento;

  CardTassa({this.desc, this.euro, this.pagamento, this.scadenza});

  @override
  Widget build(BuildContext context) {
    String descBreve = desc.length <= 20 ? desc : desc.substring(0, 19) + "...";

    return Stack(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(bottom: 15),
          width: double.infinity,
          decoration: BoxDecoration(
            color: pagamento == "PAGATO" ? Colors.white : pagamento == "NON PAGATO" ? Colors.redAccent : Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(10)),
            boxShadow: [
              BoxShadow(color: Colors.black12, offset: Offset(0, 2), spreadRadius: 1, blurRadius: 3),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            descBreve,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                              color: pagamento == "PAGATO"
                                  ? Color(0xFF40916c)
                                  : pagamento == "NON PAGATO" ? Colors.white : Colors.yellowAccent,
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            "Scadenza $scadenza",
                            style: TextStyle(
                                fontSize: 14,
                                color: pagamento == "PAGATO"
                                    ? Colors.black87
                                    : pagamento == "NON PAGATO" ? Colors.white : Colors.black87),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            euro,
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: pagamento == "NON PAGATO" ? Colors.white : Colors.black87),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      color: Colors.black12,
                      width: 1,
                      height: 30,
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: <Widget>[
                          Text(
                            "stato",
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: pagamento == "PAGATO"
                                    ? Colors.black87
                                    : pagamento == "NON PAGATO" ? Colors.white : Colors.black87),
                          ),
                          SizedBox(height: 5),
                          Text(
                            pagamento,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              color: pagamento == "PAGATO"
                                  ? Colors.greenAccent
                                  : pagamento == "NON PAGATO" ? Colors.white : Colors.yellowAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                pagamento == "NON PAGATO" ? SizedBox(height: 16) : SizedBox.shrink(),
                pagamento == "NON PAGATO"
                    ? MaterialButton(
                        elevation: 0,
                        minWidth: double.infinity,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text("IMPOSTA PROMEMORIA", style: TextStyle(color: Colors.redAccent)),
                        ),
                        onPressed: () {
                          var giorno = scadenza.substring(0, 2);
                          var mese = scadenza.substring(3, 5);
                          int anno = int.parse(scadenza.substring(6));

                          final Event event = Event(
                            title: descBreve,
                            description: desc,
                            location: 'Tassa Universitaria',
                            startDate: DateTime.parse("$anno-$mese-$giorno"),
                            endDate: DateTime.parse("$anno-$mese-$giorno"),
                            allDay: true,
                          );

                          Add2Calendar.addEvent2Cal(event);
                        },
                      )
                    : SizedBox.shrink()
              ],
            ),
          ),
        ),
        pagamento == "PAGATO"
            ? Positioned(
                top: 5,
                right: 5,
                child: Icon(
                  Icons.check_circle,
                  size: 30,
                  color: Colors.greenAccent,
                ),
              )
            : SizedBox.shrink(),
      ],
    );
  }
}

class ProiezioniConCFU extends StatelessWidget {
  final int votoLaureaInt;
  final double votoLaureaDouble;
  final int cfuAccumulati;

  const ProiezioniConCFU({
    Key key,
    @required this.votoLaureaInt,
    @required this.votoLaureaDouble,
    @required this.cfuAccumulati,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Proiezione"),
            Text(
              "Voto di Laurea: ",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(width: 5),
        Text(
          votoLaureaInt == 0 ? "NaN" : votoLaureaDouble.toStringAsPrecision(4),
          textAlign: TextAlign.end,
          style: TextStyle(
            fontSize: 25,
            height: 1,
            fontWeight: FontWeight.w600,
            color: votoLaureaInt >= 100 ? Colors.yellow[700] : votoLaureaInt >= 85 ? Colors.green[700] : Colors.black87,
          ),
        ),
        Spacer(),
        Text(
          "CFU totali: ",
          style: const TextStyle(fontSize: 16),
        ),
        Text(
          "$cfuAccumulati",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        )
      ],
    );
  }
}

class BottonePaginaDrawer extends StatelessWidget {
  final String testoBottone;
  final IconData icona;
  final Function onPressed;
  final Color textColor;

  const BottonePaginaDrawer({
    Key key,
    @required this.testoBottone,
    @required this.onPressed,
    this.textColor = Colors.black87,
    this.icona = null,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: onPressed,
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icona != null ? Icon(icona, color: textColor, size: 15) : SizedBox.shrink(),
            icona != null ? SizedBox(width: 10) : SizedBox.shrink(),
            Text(
              testoBottone,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BottoneMaterialCustom extends StatelessWidget {
  final Function onPressed;
  final Color textColor;
  final Color backgroundColor;
  final String text;
  final double minWidth;
  final double height;
  final FontWeight fontWeight;

  const BottoneMaterialCustom(
      {Key key,
      @required this.onPressed,
      this.backgroundColor = Colors.redAccent,
      this.textColor = Colors.white,
      @required this.text,
      this.minWidth = double.infinity,
      this.height = 40,
      this.fontWeight = FontWeight.bold})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      minWidth: minWidth,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(50)),
      ),
      height: height,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text(
          text,
          style: TextStyle(fontWeight: fontWeight, fontSize: 16),
        ),
      ),
      elevation: 1,
      textColor: textColor,
      color: backgroundColor,
      onPressed: onPressed,
    );
  }
}

class OrarioSettimanaleView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      decoration: BoxDecoration(
        color: Colors.yellow[300],
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                IconButton(
                    padding: EdgeInsets.all(0),
                    alignment: Alignment.centerLeft,
                    icon: Icon(Icons.arrow_back, color: kMainColor_extraDark),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }),
                const SizedBox(width: 5),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              "Orario settimanale",
              style: TextStyle(
                fontSize: 32,
                color: kMainColor_extraDark,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              "Crea e modifica il tuo orario settimanale delle lezioni.",
              style: TextStyle(fontSize: 18, color: kMainColor_extraDark),
            ),
          ),
        ],
      ),
    );
  }
}

class OrarioSettimanaleDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  OrarioSettimanaleDelegate(this.tabBar);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    // TODO: implement build
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}

class TabOrarioSettimanale extends StatefulWidget {
  final int indiceGiorno;
  final List<List<Widget>> listaOrario;

  const TabOrarioSettimanale({Key key, @required this.indiceGiorno, @required this.listaOrario}) : super(key: key);

  @override
  _TabOrarioSettimanaleState createState() => _TabOrarioSettimanaleState();
}

class _TabOrarioSettimanaleState extends State<TabOrarioSettimanale> {
  @override
  Widget build(BuildContext context) {
    if (widget.listaOrario[widget.indiceGiorno - 1].isEmpty) {
      return Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/img/nolezioni_${widget.indiceGiorno}.png'),
            SizedBox(height: 20),
            Text(
              "Non ci sono lezioni registrate!",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 20),
            BottoneMaterialCustom(
              onPressed: () {},
              text: "Inserisci lezioni",
              backgroundColor: kMainColor_extraDark,
              minWidth: null,
              fontWeight: FontWeight.normal,
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      itemCount: widget.listaOrario[widget.indiceGiorno - 1].length + 1,
      itemBuilder: (context, index) {
        if (index == widget.listaOrario[widget.indiceGiorno - 1].length) {
          return Container(
            margin: const EdgeInsets.only(top: 20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: BottoneMaterialCustom(
                onPressed: () {},
                text: "Aggiungi lezione",
                backgroundColor: kMainColor_extraDark,
                minWidth: null,
                fontWeight: FontWeight.normal,
              ),
            ),
          );
        }
        return widget.listaOrario[widget.indiceGiorno - 1][index];
      },
    );
  }
}

class CardOrario extends StatefulWidget {
  final int index;
  final bool isTutorial;

  const CardOrario({Key key, this.index, this.isTutorial = false}) : super(key: key);

  @override
  _CardOrarioState createState() => _CardOrarioState();
}

class _CardOrarioState extends State<CardOrario> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        margin: EdgeInsets.only(top: 10, bottom: 5),
        width: double.infinity,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "13:00",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const SizedBox(height: 5),
                Container(
                  width: 20,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 35,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 20,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "15:00",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Flexible(
              child: InkWell(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                onLongPress: () {
                  //return ExpandableBottomSheet(expandableContent: Container(), background: Container());
                  showBottomSheet(
                    backgroundColor: Colors.white,
                    elevation: 10,
                    context: context,
                    builder: (context){
                      return Container(
                        height: 300,
                      );
                    }
                  );
                  // showModalBottomSheet(
                  //     context: context,
                  //     builder: (builderContext) {
                  //       return Container(
                  //         color: Colors.transparent,
                  //         child: Container(
                  //           decoration: BoxDecoration(
                  //             color: Colors.white,
                  //             borderRadius:
                  //                 BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                  //           ),
                  //           child: Padding(
                  //             padding: const EdgeInsets.all(8.0),
                  //             child: Padding(
                  //               padding: const EdgeInsets.all(12.0),
                  //               child: Column(
                  //                 crossAxisAlignment: CrossAxisAlignment.start,
                  //                 children: [
                  //                   Row(
                  //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //                     children: [
                  //                       Text(
                  //                         "Modifica orario",
                  //                         style: const TextStyle(
                  //                             color: Colors.grey, fontSize: 25, fontWeight: FontWeight.w600),
                  //                       ),
                  //                       Container(
                  //                         padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  //                         decoration: BoxDecoration(
                  //                           color: Colors.redAccent,
                  //                           borderRadius: BorderRadius.all(Radius.circular(30)),
                  //                         ),
                  //                         child: Row(
                  //                           children: [
                  //                             Icon(
                  //                               Icons.delete,
                  //                               color: Colors.white,
                  //                               size: 13,
                  //                             ),
                  //                             const SizedBox(width: 5),
                  //                             Text(
                  //                               "Elimina",
                  //                               style: const TextStyle(color: Colors.white),
                  //                             ),
                  //                           ],
                  //                         ),
                  //                       )
                  //                     ],
                  //                   ),
                  //                   const SizedBox(height: 20),
                  //                   Theme(
                  //                     data: ThemeData(
                  //                       primaryColor: kMainColor_extraDark,
                  //                       fontFamily: 'Proxima Nova',
                  //                     ),
                  //                     child: TextField(
                  //                       maxLength: 50,
                  //                       decoration: InputDecoration(
                  //                         labelText: "Nome corso",
                  //                       ),
                  //                     ),
                  //                   ),
                  //                   Expanded(
                  //                     child: Container(),
                  //                   ),
                  //                   BottoneMaterialCustom(
                  //                     onPressed: () {},
                  //                     text: "Salva",
                  //                     textColor: Colors.white,
                  //                     backgroundColor: Colors.green,
                  //                     fontWeight: FontWeight.normal,
                  //                     height: 40,
                  //                   ),
                  //                 ],
                  //               ),
                  //             ),
                  //           ),
                  //         ),
                  //       );
                  //     });
                },
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      boxShadow: [BoxShadow(color: Colors.grey[300], offset: Offset(2, 2), blurRadius: 5)]),
                  child: ClipRRect(
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          border: Border(top: BorderSide(color: Colors.deepPurpleAccent, width: 5)),
                          color: Colors.white),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Pozioni magiche",
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5),
                          Text("Prof. Severus Piton"),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 15),
                              Row(
                                children: [
                                  Icon(Icons.star, color: Colors.grey[600], size: 13),
                                  const SizedBox(width: 3),
                                  Text(
                                    "Link utile:",
                                    style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              RichText(
                                text: TextSpan(
                                    style:
                                        const TextStyle(color: Colors.blueAccent, decoration: TextDecoration.underline),
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: "https://flutter.dev/",
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () async {
                                              const url = 'https://flutter.dev';
                                              if (await canLaunch(url)) {
                                                await launch(url);
                                              } else {
                                                throw 'Could not launch $url';
                                              }
                                            }),
                                    ]),
                              ),
                            ],
                          ),
                          widget.isTutorial
                              ? Container(
                                  margin: const EdgeInsets.only(top: 10),
                                  child: Text(
                                    "Tienimi premuto per modificarmi o eliminarmi!",
                                    style: TextStyle(
                                        color: kMainColor_extraDark, fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                )
                              : SizedBox.shrink(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class CardAppelloPrenotato extends StatelessWidget {
  final String esame;
  final String iscrizione;
  final String giorno;
  final String ora;
  final String docente;
  final Map formHiddens;
  final int index;

  const CardAppelloPrenotato({Key key, this.esame, this.iscrizione, this.giorno, this.ora, this.docente, this.formHiddens, this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> _nomeEsame = esame.split(" - ");
    String numIsc = iscrizione.replaceFirst("Numero Iscrizione: ", "");
    Map internalHiddens = new Map();
    formHiddens.forEach((key, value) {
      if(key.toString().startsWith(index.toString())){
        internalHiddens[key.toString().replaceFirst(index.toString() + "_", "")] = value;
      }
    });
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              kMainColor_darker,
              kMainColor_lighter
            ]),
        borderRadius:
        BorderRadius.all(Radius.circular(10)),
      ),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  _nomeEsame[0],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                _nomeEsame[1],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          Text(
            _nomeEsame[2],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          RichText(
            text: TextSpan(
                text: "Giorno: ",
                style: DefaultTextStyle.of(context).style.copyWith(color: Colors.white),
                children: [
                  TextSpan(
                    text: giorno,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16,),
                  )
                ]
            ),
          ),
          RichText(
            text: TextSpan(
                text: "Ora: ",
                style: DefaultTextStyle.of(context).style.copyWith(color: Colors.white),
                children: [
                  TextSpan(
                    text: ora,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16,),
                  )
                ]
            ),
          ),
          RichText(
            text: TextSpan(
                text: "Numero iscrizione: ",
                style: DefaultTextStyle.of(context).style.copyWith(color: Colors.white),
                children: [
                  TextSpan(
                    text: numIsc,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16,),
                  )
                ]
            ),
          ),
          const SizedBox(height: 10),
          RichText(
            text: TextSpan(
                text: "Docente: ",
                style: DefaultTextStyle.of(context).style.copyWith(color: Colors.white),
                children: [
                  TextSpan(
                    text: docente,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold,),
                  )
                ]
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Flexible(
                child: MaterialButton(
                  elevation: 2,
                  minWidth: double.infinity,
                  color: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text("CANCELLATI", style: const TextStyle(color: Colors.white)),
                  onLongPress: () {
                    showDialog(
                      context: context,
                      child: AlertDialog(
                        title: Text("Annulla prenotazione"),
                        content: Text("Sei sicuro di voler cancellare la prenotazione?"),
                        actions: [
                          FlatButton(
                            child: Text("SI", style: const TextStyle(color: Colors.black87),),
                            onPressed: (){
                              Navigator.of(context).pop();
                              showDialog(
                                context: context,
                                child: WillPopScope(
                                  onWillPop: () async => null,
                                  child: AlertDialog(
                                    content: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent),
                                        ),
                                        const SizedBox(width: 10),
                                        Text("Aspetta un secondo..."),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                              Provider.cancellaAppello(internalHiddens).then((value){
                                if(value != null && value){
                                  Navigator.of(context).pop();
                                  showDialog(
                                    context: context,
                                    child: WillPopScope(
                                      onWillPop: () async => null,
                                      child: AlertDialog(
                                        content: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Icon(Icons.check, color: Colors.green,),
                                            const SizedBox(width: 10),
                                            Text("Prenotazione cancellata!"),
                                          ],
                                        ),
                                      ),
                                    )
                                  );
                                  Future.delayed(Duration(seconds: 1), (){
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop();
                                  });
                                } else {
                                  Navigator.of(context).pop();
                                  showDialog(
                                    context: context,
                                    child: WillPopScope(
                                      onWillPop: () async => null,
                                      child: AlertDialog(
                                        content: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                          Icon(Icons.cancel, color: Colors.redAccent,),
                                        const SizedBox(width: 10),
                                        Text("Errore cancellazione!"),
                                        ],
                                      ),
                                    ),
                                  )
                                );
                                  Future.delayed(Duration(seconds: 1), (){
                                    Navigator.of(context).pop();
                                  });
                                }

                              });
                            },
                          ),
                          MaterialButton(
                            elevation: 0,
                            color: Colors.redAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Text("NO", style: TextStyle(color: Colors.white)),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      )
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: MaterialButton(
                  elevation: 3,
                  minWidth: double.infinity,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text("PROMEMORIA", style: TextStyle(color: kMainColor_darker)),
                  onPressed: () {
                    var giornoEv = giorno.substring(0, 2);
                    var mese = giorno.substring(3, 5);
                    int anno = int.parse(giorno.substring(6));

                    final Event event = Event(
                      title: _nomeEsame[0],
                      description: _nomeEsame[2],
                      location: 'Università di Modena e Reggio Emilia',
                      startDate: DateTime.parse("$anno-$mese-$giornoEv"),
                      endDate: DateTime.parse("$anno-$mese-$giornoEv"),
                      allDay: true,
                    );

                    Add2Calendar.addEvent2Cal(event);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

