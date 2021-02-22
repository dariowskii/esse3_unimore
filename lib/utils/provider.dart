import 'dart:convert';

import 'package:Esse3/screens/bacheca_prenotazioni_screen.dart';
import 'package:Esse3/screens/prossimi_appelli_screen.dart';
import 'package:Esse3/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as parser;
import 'package:shared_preferences/shared_preferences.dart';

/// Questa classe effettua lo scraping su esse3.unimore.it
class Provider {
  /// Serve sostanzialmente ad estrarre l'`idStud` per mandare le
  /// request in caso di scelta carriera iniziale.
  static Future<Map> _isSceltaCarriera(dom.Element tableCarriere,
      String jsessionId, String basicAuth64, Map mapInfo) async {
    mapInfo["sceltaCarriera"] = true;

    dom.Element tableScelta = tableCarriere.querySelector(".table-1-body");
    if (tableScelta == null) {
      mapInfo["error"] = "tableScelta not found";
      mapInfo["success"] = false;
      return mapInfo;
    }

    int lengthScelta = tableScelta.children.length;

    try {
      for (int i = 0; i < lengthScelta; i++) {
        if (tableScelta.children[i].children[3].text == "Attivo") {
          String idStud = tableScelta.children[i].children[4].children[0]
              .children[0].attributes["href"];
          idStud = idStud
              .replaceAll("auth/studente/SceltaCarrieraStudente.do", "")
              .replaceAll("?", "?&");

          //Salvo idStud
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setBool("isSceltaCarriera", true);
          prefs.setString("idStud", idStud);

          String newRequestUrl =
              "https://www.esse3.unimore.it/auth/studente/AreaStudente.do;jsessionid=" +
                  jsessionId +
                  idStud;
          //Get the response
          http.Response response = await http.get(
            newRequestUrl,
            headers: {"Authorization": basicAuth64, "jsessionid": jsessionId},
          ).catchError((e) {
            mapInfo["error"] = e;
            mapInfo["success"] = false;
            return mapInfo;
          });

          mapInfo["success"] = response.statusCode == 200;
          if (!mapInfo["success"]) {
            mapInfo["error"] =
                "response isSceltaCarriera => ${response.statusCode}: ${response.reasonPhrase}";
            return mapInfo;
          }

          dom.Document documentTmp = parser.parse(response.body);
          List<String> nomeMatricola = [];

          try {
            nomeMatricola = documentTmp
                .querySelector(".pagetitle_title")
                .innerHtml
                .replaceAll("Area Studente ", "")
                .split(" - ");
          } catch (e) {
            mapInfo["error"] = ".pagetitle_title (isSceltaCarriera) not found";
            mapInfo["success"] = false;
            return mapInfo;
          }

          String nomeStudente = nomeMatricola[0];
          String matricolaStudente =
              nomeMatricola[1].replaceFirst("[MAT. ", "").replaceFirst("]", "");

          dom.Element info = documentTmp.querySelector(".record-riga");
          if (info == null) {
            mapInfo["error"] = ".record-riga (isSceltaCarriera) not found";
            mapInfo["success"] = false;
            return mapInfo;
          }

          int lengthInfo = info.children.length;

          mapInfo["nome"] = nomeStudente;
          String _nomeCompletoCamel = "";
          mapInfo["nome"].split(" ").forEach((str) {
            _nomeCompletoCamel +=
                "${str.toString()[0]}${str.toString().substring(1).toLowerCase()} ";
          });
          mapInfo["nome"] =
              _nomeCompletoCamel.substring(0, _nomeCompletoCamel.length - 1);
          mapInfo["matricola"] = matricolaStudente;
          List<String> bufferNome = nomeStudente.split(" ");
          mapInfo["text_avatar"] =
              "${bufferNome[0].substring(0, 1)}${bufferNome[1].substring(0, 1)}";

          for (int i = 1; i < lengthInfo; i += 2) {
            int index = info.children[i].innerHtml.indexOf("&");
            String key = _getNomeInfo(i);
            if (key == "part_time") {
              mapInfo[key] = info.children[i].children[0].innerHtml.trim();
            } else {
              mapInfo[key] = info.children[i].innerHtml
                  .replaceRange(
                      index, info.children[i].innerHtml.length - 1, "")
                  .trim();
            }
          }

          //Recupero l'immagine del profilo
          mapInfo["profile_pic"] = "";

          final http.Response responsePhoto = await http.get(
            "https://www.esse3.unimore.it/auth/AddressBook/DownloadFoto.do?r=" +
                jsessionId.substring(3, 13),
            headers: {
              "Authorization": basicAuth64,
              "cookie": "JSESSIONID=" + jsessionId
            },
          ).catchError((e) {
            debugPrint("Errore response foto profilo getAccess: $e");
            mapInfo["profile_pic"] = "error";
          });

          if (mapInfo["profile_pic"] != "error")
            mapInfo["profile_pic"] = base64Encode(responsePhoto.bodyBytes);
          else
            mapInfo["profile_pic"] = "no";

          return mapInfo;
        }
      }
    } catch (e) {
      mapInfo["error"] = e;
      mapInfo["success"] = false;
      return mapInfo;
    }

    mapInfo["error"] = "unknown error (isSceltaCarriera)";
    mapInfo["success"] = false;
    return mapInfo;
  }

  /// Serve ad ottenere le prime informazioni iniziali della home.
  static Future<Map> getAccess(String basicAuth64, String username) async {
    Map mapInfo = new Map();
    //Ottengo il cookie di sessione per la request
    String urlCookie =
        "https://www.esse3.unimore.it/auth/studente/AreaStudente.do";
    http.Response getCookie = await http.head(urlCookie).catchError((e) {
      mapInfo["success"] = false;
      mapInfo["error"] = e;
      return mapInfo;
    });
    String jsessionId = "";

    try {
      jsessionId = getCookie.headers["set-cookie"]
          .split(";")[0]
          .replaceAll("JSESSIONID=", "");
    } catch (e) {
      mapInfo["success"] = false;
      mapInfo["error"] = e;
      return mapInfo;
    }

    String requestUrl = urlCookie + ";jsessionid=" + jsessionId;

    //Ottengo la response
    final http.Response response = await http.get(
      requestUrl,
      headers: {"Authorization": basicAuth64, "jsessionid": jsessionId},
    ).catchError((e) {
      mapInfo["success"] = false;
      mapInfo["error"] = e;
      return mapInfo;
    });

    mapInfo["success"] = response.statusCode == 200;
    if (!mapInfo["success"]) {
      mapInfo["error"] =
          "{responseCode: ${response.statusCode}, responseBody: ${response.body}, responseHeader: ${response.headers}}";
      return mapInfo;
    }
    //Scraping home page
    dom.Document documentHome = parser.parse(response.body);

    //Controllo se hai una scelta della carriera da effettuare
    dom.Element sceltaCarriera =
        documentHome.querySelector("#gu_table_sceltacarriera");
    if (sceltaCarriera != null) {
      return await _isSceltaCarriera(
          sceltaCarriera, jsessionId, basicAuth64, mapInfo);
    }

    //Recupero l'immagine del profilo
    mapInfo["profile_pic"] = "";

    final http.Response responsePhoto = await http.get(
      "https://www.esse3.unimore.it/auth/AddressBook/DownloadFoto.do?r=" +
          jsessionId.substring(3, 13),
      headers: {
        "Authorization": basicAuth64,
        "cookie": "JSESSIONID=" + jsessionId
      },
    ).catchError((e) {
      debugPrint("Errore response foto profilo getAccess: $e");
      mapInfo["profile_pic"] = "error";
    });

    if (mapInfo["profile_pic"] != "error")
      mapInfo["profile_pic"] = base64Encode(responsePhoto.bodyBytes);
    else
      mapInfo["profile_pic"] = "no";

    List<String> scrapingNomeMatricola = [];
    try {
      scrapingNomeMatricola = documentHome
          .querySelector(".pagetitle_title")
          .innerHtml
          .replaceAll("Area Studente ", "")
          .split(" - ");
    } catch (e) {
      mapInfo["error"] = ".pagetitle_title not found";
      mapInfo["success"] = false;
      return mapInfo;
    }

    String nomeStudente = scrapingNomeMatricola[0];
    String matricolaStudente = scrapingNomeMatricola[1]
        .replaceFirst("[MAT. ", "")
        .replaceFirst("]", "");

    dom.Element info = documentHome.querySelector(".record-riga");
    if (info == null) {
      mapInfo["error"] = ".record-riga not found";
      mapInfo["success"] = false;
      return mapInfo;
    }
    int lengthInfo = info.children.length;

    mapInfo["nome"] = nomeStudente;
    String _nomeCompletoCamel = "";
    mapInfo["nome"].split(" ").forEach((str) {
      _nomeCompletoCamel +=
          "${str.toString()[0]}${str.toString().substring(1).toLowerCase()} ";
    });
    mapInfo["nome"] =
        _nomeCompletoCamel.substring(0, _nomeCompletoCamel.length - 1);
    mapInfo["matricola"] = matricolaStudente;
    List<String> bufferNome = nomeStudente.split(" ");
    mapInfo["text_avatar"] =
        "${bufferNome[0].substring(0, 1)}${bufferNome[1].substring(0, 1)}";
    mapInfo["username"] = username;

    //Scraping info
    try {
      for (int i = 1; i < lengthInfo; i += 2) {
        int index = info.children[i].innerHtml.indexOf("&");
        String key = _getNomeInfo(i);
        if (key == "part_time") {
          mapInfo[key] = info.children[i].children[0].innerHtml.trim();
        } else {
          mapInfo[key] = info.children[i].innerHtml
              .replaceRange(index, info.children[i].innerHtml.length - 1, "")
              .trim();
        }
      }
      mapInfo["corso_stud"] = mapInfo["corso_stud"].toString().split(" (")[0];
    } catch (e) {
      mapInfo["error"] = e;
      mapInfo["success"] = false;
      return mapInfo;
    }

    return mapInfo;
  }

  /// Aiuta a prelevare le info in [getAccess].
  static String _getNomeInfo(int n) {
    switch (n) {
      case 1:
        return "tipo_corso";
      case 3:
        return "profilo_studente";
      case 5:
        return "anno_corso";
      case 7:
        return "data_imm";
      case 9:
        return "corso_stud";
      case 11:
        return "ordinamento";
      case 13:
        return "part_time";
      default:
        return "null";
    }
  }

  /// Serve a scaricare le informazioni del libretto universitario per [LibrettoScreen].
  static Future<Map> getLibretto() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String basicAuth64 = prefs.getString("auth64Cred");

    Map mapLibretto = new Map();

    if (basicAuth64 == null) {
      mapLibretto["success"] = false;
      mapLibretto["error"] = "noCredential";
      return mapLibretto;
    }

    bool isSceltaCarriera = prefs.getBool("isSceltaCarriera") ?? false;

    String urlCookie =
        "https://www.esse3.unimore.it/auth/studente/AreaStudente.do";
    http.Response getCookie = await http.head(urlCookie).catchError((e) {
      mapLibretto["success"] = false;
      mapLibretto["error"] = e;
      return mapLibretto;
    });

    String jsessionId = "";

    try {
      jsessionId = getCookie.headers["set-cookie"]
          .split(";")[0]
          .replaceAll("JSESSIONID=", "");
    } catch (e) {
      mapLibretto["success"] = false;
      mapLibretto["error"] = e;
      return mapLibretto;
    }

    //Libretto
    String requestUrl =
        "https://www.esse3.unimore.it/auth/studente/Libretto/LibrettoHome.do;jsessionid=" +
            jsessionId +
            "?&menu_opened_cod=menu_link-navbox_studenti_Area_Studente";

    if (isSceltaCarriera) {
      String idStud = prefs.getString("idStud");
      requestUrl = requestUrl + idStud;
    }

    final http.Response response = await http.get(
      requestUrl,
      headers: {"Authorization": basicAuth64, "jsessionid": jsessionId},
    ).catchError((e) {
      debugPrint("Errore richiesta libretto: $e");
      mapLibretto["success"] = false;
      mapLibretto["error"] = e;
      return mapLibretto;
    });

    mapLibretto["success"] = response.statusCode == 200;
    if (!mapLibretto["success"]) {
      mapLibretto["error"] =
          "{responseCode: ${response.statusCode}, responseBody: ${response.body}, responseHeader: ${response.headers}";
      return mapLibretto;
    }

    dom.Document documentLibretto = parser.parse(response.body);

    dom.Element boxMedie = documentLibretto.querySelector("#boxMedie");

    try {
      if (boxMedie != null) {
        mapLibretto["media_arit"] = boxMedie.children[0].children[0].innerHtml
            .split("&nbsp;​")[1]
            .replaceAll(" / 30", "");
        mapLibretto["media_pond"] = boxMedie.children[0].children[1].innerHtml
            .split("&nbsp;​")[1]
            .replaceAll(" / 30", "");
        mapLibretto["media_arit"] =
            double.tryParse(mapLibretto["media_arit"]) ??
                mapLibretto["media_arit"];
        mapLibretto["media_pond"] =
            double.tryParse(mapLibretto["media_pond"]) ??
                mapLibretto["media_pond"];
      } else {
        mapLibretto["media_arit"] = "NaN";
        mapLibretto["media_pond"] = "NaN";
      }
    } catch (e) {
      mapLibretto["success"] = false;
      mapLibretto["error"] = e;
      return mapLibretto;
    }

    dom.Element tableLibretto =
        documentLibretto.querySelector("#tableLibretto");
    if (tableLibretto == null) {
      mapLibretto["success"] = false;
      mapLibretto["error"] = "#tableLibretto = null";
      return mapLibretto;
    }

    tableLibretto = tableLibretto.querySelector(".table-1-body");
    int lengthLibretto = tableLibretto.children.length;

    mapLibretto["materie"] = new Map();
    mapLibretto["crediti"] = new Map();
    mapLibretto["voti"] = new Map();
    mapLibretto["data_esame"] = new Map();
    mapLibretto["cod_materia"] = new Map();
    mapLibretto["superati"] = 0;
    mapLibretto["totali"] = lengthLibretto;

    //Scraping libretto
    try {
      for (int i = 0; i < lengthLibretto; i++) {
        List<String> materia =
            tableLibretto.children[i].children[0].children[0].text.split(" - ");
        mapLibretto["cod_materia"][i] = materia[0];
        mapLibretto["materie"][i] = materia[1];
        mapLibretto["crediti"][i] =
            tableLibretto.children[i].children[2].innerHtml;
        mapLibretto["voti"][i] =
            tableLibretto.children[i].children[5].innerHtml;

        if (mapLibretto["voti"][i] != "") {
          List<String> tempVoto = mapLibretto["voti"][i].split("&nbsp;-&nbsp;");
          mapLibretto["voti"][i] = tempVoto[0];
          mapLibretto["data_esame"][i] = tempVoto[1];
          mapLibretto["superati"]++;
          if (tempVoto[0].contains("ID", 0)) {
            mapLibretto["voti"][i] = "IDONEO";
          } else if (tempVoto[0].contains("30L", 0) ||
              tempVoto[0].contains("30 L", 0)) {
            mapLibretto["voti"][i] = "30 LODE";
          }
        } else {
          mapLibretto["data_esame"][i] = "";
        }
      }
    } catch (e) {
      mapLibretto["success"] = false;
      mapLibretto["error"] = e;
      return mapLibretto;
    }

    return mapLibretto;
  }

  /// Serve a scaricare le informazioni delle tasse per [TasseScreen].
  static Future<Map> getTasse() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String basicAuth64 = prefs.getString("auth64Cred");

    Map mapTasse = new Map();

    if (basicAuth64 == null) {
      mapTasse["success"] = false;
      mapTasse["error"] = "noCredential";
      return mapTasse;
    }

    bool isSceltaCarriera = prefs.getBool("isSceltaCarriera") ?? false;

    String urlCookie =
        "https://www.esse3.unimore.it/auth/studente/AreaStudente.do";
    http.Response getCookie = await http.head(urlCookie).catchError((e) {
      mapTasse["success"] = false;
      mapTasse["error"] = e;
      return mapTasse;
    });

    String jsessionId = "";

    try {
      jsessionId = getCookie.headers["set-cookie"]
          .split(";")[0]
          .replaceAll("JSESSIONID=", "");
    } catch (e) {
      mapTasse["success"] = false;
      mapTasse["error"] = e;
      return mapTasse;
    }

    //Tasse
    String requestUrl =
        "https://www.esse3.unimore.it/auth/studente/Tasse/ListaFatture.do;jsessionid=" +
            jsessionId +
            "?&menu_opened_cod=menu_link-navbox_studenti_Area_Studente";

    if (isSceltaCarriera) {
      String idStud = prefs.getString("idStud");
      requestUrl = requestUrl + idStud;
    }

    final http.Response response = await http.get(
      requestUrl,
      headers: {"Authorization": basicAuth64, "jsessionid": jsessionId},
    ).catchError((e) {
      debugPrint("Errore richiesta tasse: $e");
      mapTasse["success"] = false;
      mapTasse["error"] = e;
      return mapTasse;
    });

    mapTasse["success"] = response.statusCode == 200;
    if (!mapTasse["success"]) {
      mapTasse["error"] =
          "{responseCode: ${response.statusCode}, responseBody: ${response.body}, responseHeader: ${response.headers}";
      return mapTasse;
    }

    dom.Document document = parser.parse(response.body);

    dom.Element tableTasse = document.querySelector("#tasse-tableFatt");
    if (tableTasse == null) {
      mapTasse["success"] = false;
      mapTasse["error"] = "#tasse-tableFatt = null";
      return mapTasse;
    }
    tableTasse = tableTasse.querySelector(".table-1-body");
    if (tableTasse == null) {
      mapTasse["success"] = false;
      mapTasse["error"] = ".table-1-body = null";
      return mapTasse;
    }
    int lenghtTasse = tableTasse.children.length;

    mapTasse["importi"] = new Map();
    mapTasse["scadenza"] = new Map();
    mapTasse["desc"] = new Map();
    mapTasse["stato_pagamento"] = new Map();
    mapTasse["totali"] = lenghtTasse;
    mapTasse["da_pagare"] = 0;

    //Scraping tasse
    try {
      for (int i = 0; i < lenghtTasse; i++) {
        mapTasse["desc"][i] = tableTasse.children[i].children[3].children[0]
            .children[0].children[1].innerHtml
            .replaceAll("&nbsp;", "")
            .substring(2);
        mapTasse["scadenza"][i] = tableTasse.children[i].children[4].innerHtml;
        mapTasse["importi"][i] = tableTasse.children[i].children[5].innerHtml;
        String buff = tableTasse.children[i].children[6].innerHtml;
        if (buff.contains("non")) {
          mapTasse["stato_pagamento"][i] = "NON PAGATO";
          mapTasse["da_pagare"]++;
        } else if (buff.contains("pagato"))
          mapTasse["stato_pagamento"][i] = "PAGATO";
        else if (buff.contains("pagamen"))
          mapTasse["stato_pagamento"][i] = "IN ATTESA";
      }
    } catch (e) {
      mapTasse["success"] = false;
      mapTasse["error"] = e;
      return mapTasse;
    }

    return mapTasse;
  }

  /// Serve a scaricare le informazioni dei prossimi appelli per [ProssimiAppelliScreen].
  static Future<Map> getAppelli() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String basicAuth64 = prefs.getString("auth64Cred");

    Map mapAppelli = new Map();

    if (basicAuth64 == null) {
      mapAppelli["success"] = false;
      mapAppelli["error"] = "noCredential";
      return mapAppelli;
    }

    bool isSceltaCarriera = prefs.getBool("isSceltaCarriera") ?? false;

    String urlCookie =
        "https://www.esse3.unimore.it/auth/studente/AreaStudente.do";
    http.Response getCookie = await http.head(urlCookie).catchError((e) {
      mapAppelli["success"] = false;
      mapAppelli["error"] = e;
      return mapAppelli;
    });

    String jsessionId = "";

    try {
      jsessionId = getCookie.headers["set-cookie"]
          .split(";")[0]
          .replaceAll("JSESSIONID=", "");
    } catch (e) {
      mapAppelli["success"] = false;
      mapAppelli["error"] = e;
      return mapAppelli;
    }

    String requestUrl =
        "https://www.esse3.unimore.it/auth/studente/Appelli/AppelliF.do;jsessionid=" +
            jsessionId +
            "?&menu_opened_cod=menu_link-navbox_studenti_Area_Studente";

    if (isSceltaCarriera) {
      String idStud = prefs.getString("idStud");
      requestUrl = requestUrl + idStud;
    }

    final http.Response response = await http.get(
      requestUrl,
      headers: {"Authorization": basicAuth64, "jsessionid": jsessionId},
    ).catchError((e) {
      debugPrint("Errore richiesta appelli: $e");
      mapAppelli["success"] = false;
      mapAppelli["error"] = e;
      return mapAppelli;
    });

    //Appelli
    mapAppelli["success"] = response.statusCode == 200;
    if (!mapAppelli["success"]) {
      mapAppelli["error"] =
          "{responseCode: ${response.statusCode}, responseBody: ${response.body}, responseHeader: ${response.headers}";
      return mapAppelli;
    }

    dom.Document document = parser.parse(response.body);
    dom.Element tableAppelli = document.querySelector("tbody.table-1-body");

    if (tableAppelli == null) {
      mapAppelli["success"] = false;
      mapAppelli["error"] = "tbody.table-1-body = null";
      return mapAppelli;
    }

    int lenghtAppelli = tableAppelli.children.length;
    mapAppelli["totali"] = lenghtAppelli;

    mapAppelli["materia"] = new Map();
    mapAppelli["data_appello"] = new Map();
    mapAppelli["periodo_iscrizione"] = new Map();
    mapAppelli["desc"] = new Map();
    mapAppelli["sessione"] = new Map();
    mapAppelli["link_info"] = new Map();

    try {
      for (int i = 0; i < lenghtAppelli; i++) {
        mapAppelli["link_info"][i] = tableAppelli
            .children[i].children[0].children[0].children[0].attributes["href"];
        mapAppelli["materia"][i] = tableAppelli.children[i].children[1].text;
        mapAppelli["data_appello"][i] =
            tableAppelli.children[i].children[2].text.substring(0, 10);
        mapAppelli["periodo_iscrizione"][i] = tableAppelli
            .children[i].children[3].innerHtml
            .replaceAll("<br>", " - ");
        mapAppelli["desc"][i] = tableAppelli.children[i].children[4].text;
        mapAppelli["sessione"][i] =
            tableAppelli.children[i].children[6].innerHtml.substring(0, 9);
      }
    } catch (e) {
      mapAppelli["success"] = false;
      mapAppelli["error"] = e;
      return mapAppelli;
    }

    return mapAppelli;
  }

  /// Serve a scaricare le informazioni nascoste dell'appello per poter prenotarsi.
  static Future<Map> getInfoAppello(String urlInfo) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String basicAuth64 = prefs.getString("auth64Cred");

    Map mapInfoAppello = new Map();

    if (basicAuth64 == null) {
      mapInfoAppello["success"] = false;
      mapInfoAppello["error"] = "noCredential";
      return mapInfoAppello;
    }

    bool isSceltaCarriera = prefs.getBool("isSceltaCarriera") ?? false;

    String urlCookie =
        "https://www.esse3.unimore.it/auth/studente/AreaStudente.do";
    http.Response getCookie = await http.head(urlCookie).catchError((e) {
      mapInfoAppello["success"] = false;
      mapInfoAppello["error"] = e;
      return mapInfoAppello;
    });

    String jsessionId = "";

    try {
      jsessionId = getCookie.headers["set-cookie"]
          .split(";")[0]
          .replaceAll("JSESSIONID=", "");
    } catch (e) {
      mapInfoAppello["success"] = false;
      mapInfoAppello["error"] = e;
      return mapInfoAppello;
    }

    urlInfo = urlInfo.replaceAll(
        "auth/studente/Appelli/DatiPrenotazioneAppello.do?", "");

    //Appelli
    String requestUrl =
        "https://www.esse3.unimore.it/auth/studente/Appelli/DatiPrenotazioneAppello.do;jsessionid=" +
            jsessionId +
            "?&" +
            urlInfo;

    if (isSceltaCarriera) {
      String idStud = prefs.getString("idStud");
      requestUrl = requestUrl + idStud;
    }

    final http.Response response = await http.get(
      requestUrl,
      headers: {"Authorization": basicAuth64, "jsessionid": jsessionId},
    ).catchError((e) {
      debugPrint("Errore getInfoAppello: $e");
      mapInfoAppello["success"] = false;
      mapInfoAppello["error"] = e;
      return mapInfoAppello;
    });

    mapInfoAppello["success"] = response.statusCode == 200;
    if (!mapInfoAppello["success"]) {
      mapInfoAppello["error"] =
          "{responseCode: ${response.statusCode}, responseBody: ${response.body}, responseHeader: ${response.headers}";
      return mapInfoAppello;
    }

    dom.Document document = parser.parse(response.body);

    dom.Element tableAppello;
    dom.Element tabellaTurni;
    dom.Element tabellaHidden;

    try {
      tableAppello = document.querySelector("#app-box_dati_pren");
      tabellaHidden = document.querySelector("#app-form_dati_pren").children[5];
      tabellaTurni = document
          .querySelector("#app-tabella_turni")
          .querySelector(".table-1-body");
    } catch (e) {
      mapInfoAppello["success"] = false;
      mapInfoAppello["error"] = e;
      return mapInfoAppello;
    }

    mapInfoAppello["tabellaHidden"] = true;
    int lunghezzaHidden = tabellaHidden.children.length;
    mapInfoAppello["lunghezzaHidden"] = lunghezzaHidden;
    mapInfoAppello["hiddens_name"] = new Map();
    mapInfoAppello["hiddens_value"] = new Map();

    try {
      for (int i = 0; i < lunghezzaHidden; i++) {
        if (i < lunghezzaHidden - 1) {
          mapInfoAppello["hiddens_name"][i] = tabellaHidden.children[i].id;
          mapInfoAppello["hiddens_value"][i] =
              tabellaHidden.children[i].attributes["value"];
        } else {
          mapInfoAppello["hiddens_name"][i] = "form_id_app-form_dati_pren";
          mapInfoAppello["hiddens_value"][i] = "app-form_dati_pren";
        }
      }
      mapInfoAppello["tipo_esame"] =
          tableAppello.children[1].children[7].text.trim();
      mapInfoAppello["verbalizzazione"] =
          tableAppello.children[1].children[9].text.trim();
      mapInfoAppello["docente"] = tableAppello
          .children[1].children[11].innerHtml
          .replaceAll("<br>", " ")
          .replaceAll("&nbsp;", "")
          .trim();
      mapInfoAppello["num_iscritti"] =
          tabellaTurni.children[0].children[2].text.trim();
      mapInfoAppello["aula"] = tabellaTurni.children[0].children[1].text;
    } catch (e) {
      mapInfoAppello["success"] = false;
      mapInfoAppello["error"] = e;
      return mapInfoAppello;
    }

    return mapInfoAppello;
  }

  /// Serve a scaricare la lista degli appelli prenotati per la [BachecaPrenotazioniScreen].
  static Future<Map> getAppelliPrenotati() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String basicAuth64 = prefs.getString("auth64Cred");
    bool isSceltaCarriera = prefs.getBool("isSceltaCarriera") ?? false;

    Map mapPrenotati = new Map();

    if (basicAuth64 == null) {
      mapPrenotati["success"] = false;
      mapPrenotati["error"] = "noCredential";
      return mapPrenotati;
    }

    String urlCookie =
        "https://www.esse3.unimore.it/auth/studente/AreaStudente.do";
    http.Response getCookie = await http.head(urlCookie).catchError((e) {
      mapPrenotati["success"] = false;
      mapPrenotati["error"] = e;
      return mapPrenotati;
    });

    String jsessionId = "";

    try {
      jsessionId = getCookie.headers["set-cookie"]
          .split(";")[0]
          .replaceAll("JSESSIONID=", "");
    } catch (e) {
      mapPrenotati["success"] = false;
      mapPrenotati["error"] = e;
      return mapPrenotati;
    }

    String requestUrl =
        "https://www.esse3.unimore.it/auth/studente/Appelli/BachecaPrenotazioni.do;jsessionid=" +
            jsessionId +
            "?menu_opened_cod=menu_link-navbox_studenti_Area_Studente";

    if (isSceltaCarriera) {
      String idStud = prefs.getString("idStud");
      requestUrl = requestUrl + idStud;
    }

    final http.Response response = await http.get(
      requestUrl,
      headers: {"Authorization": basicAuth64, "jsessionid": jsessionId},
    ).catchError((e) {
      debugPrint("Errore getAppelliPrenotati: $e");
      mapPrenotati["success"] = false;
      mapPrenotati["error"] = e;
      return mapPrenotati;
    });

    mapPrenotati["success"] = response.statusCode == 200;
    if (!mapPrenotati["success"]) {
      mapPrenotati["error"] = "responseCode: ${response.statusCode}";
      return mapPrenotati;
    }

    dom.Document document = parser.parse(response.body);

    dom.Element divPrenotati = document.querySelector("#esse3old");

    if (divPrenotati == null) {
      mapPrenotati["success"] = false;
      mapPrenotati["error"] = "div#esse3old not found";
      return mapPrenotati;
    }

    List<dom.Element> arrayPrenotati =
        divPrenotati.querySelectorAll('table.detail_table');

    if (arrayPrenotati == null) {
      mapPrenotati["totali"] = 0;
      return mapPrenotati;
    }

    int lengthPrenotati = arrayPrenotati.length;
    mapPrenotati["totali"] = 0;
    mapPrenotati["esame"] = new Map();
    mapPrenotati["iscrizione"] = new Map();
    mapPrenotati["tipo_esame"] = new Map();
    mapPrenotati["giorno"] = new Map();
    mapPrenotati["ora"] = new Map();
    mapPrenotati["docente"] = new Map();
    mapPrenotati["formHiddens"] = new Map();

    try {
      for (int i = 0; i < lengthPrenotati; i++) {
        dom.Element tablePrenotazione = arrayPrenotati[i].children[0];
        if (tablePrenotazione == null || tablePrenotazione.children.length < 2)
          break;

        mapPrenotati["esame"][mapPrenotati["totali"]] =
            tablePrenotazione.children[0].children[0].text;
        mapPrenotati["iscrizione"][mapPrenotati["totali"]] =
            tablePrenotazione.children[2].children[0].text;

        mapPrenotati["tipo_esame"][mapPrenotati["totali"]] =
            tablePrenotazione.children[3].children[0].text;

        mapPrenotati["giorno"][mapPrenotati["totali"]] =
            tablePrenotazione.children[6].children[0].text;
        mapPrenotati["ora"][mapPrenotati["totali"]] =
            tablePrenotazione.children[6].children[1].text;
        mapPrenotati["docente"][mapPrenotati["totali"]] =
            tablePrenotazione.children[6].children[6].text;

        int lenHiddens = tablePrenotazione
            .children[6].children[7].children[0].children.length;
        mapPrenotati["lenHiddens"] = lenHiddens - 1;
        dom.Element hiddens =
            tablePrenotazione.children[6].children[7].children[0];
        for (int j = 1; j < lenHiddens; j++) {
          String key = mapPrenotati["totali"].toString() +
              "_" +
              hiddens.children[j].attributes["name"].toString();
          mapPrenotati["formHiddens"][key] =
              hiddens.children[j].attributes["value"];
        }
        mapPrenotati["totali"]++;
      }
    } catch (e) {
      print(e);
      mapPrenotati["success"] = false;
      mapPrenotati["error"] = e;
      return mapPrenotati;
    }
    return mapPrenotati;
  }

  /// Serve a prenotare un appello grazie alle [infoAppello] scaricate da [getInfoAppello].
  static Future<Map> prenotaAppello(Map infoAppello) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String basicAuth64 = prefs.getString("auth64Cred");

    Map mapHiddens = new Map();

    if (basicAuth64 == null) {
      mapHiddens["success"] = false;
      mapHiddens["error"] = "noCredential";
      return mapHiddens;
    }

    bool isSceltaCarriera = prefs.getBool("isSceltaCarriera") ?? false;

    String urlCookie =
        "https://www.esse3.unimore.it/auth/studente/AreaStudente.do";
    http.Response getCookie = await http.head(urlCookie).catchError((e) {
      mapHiddens["success"] = false;
      mapHiddens["error"] = e;
      return mapHiddens;
    });

    String jsessionId = "";

    try {
      jsessionId = getCookie.headers["set-cookie"]
          .split(";")[0]
          .replaceAll("JSESSIONID=", "");
    } catch (e) {
      mapHiddens["success"] = false;
      mapHiddens["error"] = e;
      return mapHiddens;
    }

    String requestUrl =
        "https://www.esse3.unimore.it/auth/studente/Appelli/EffettuaPrenotazioneAppello.do;jsessionid=" +
            jsessionId +
            "?TIPO_ATTIVITA=1";

    if (isSceltaCarriera) {
      String idStud = prefs.getString("idStud");
      requestUrl = requestUrl + idStud;
    }

    int lunghezzaHidden = infoAppello["lunghezzaHidden"];

    for (int i = 0; i < lunghezzaHidden; i++) {
      mapHiddens[infoAppello["hiddens_name"][i]] =
          infoAppello["hiddens_value"][i];
    }

    final http.Response response = await http.post(
      requestUrl,
      body: mapHiddens,
      headers: {"Authorization": basicAuth64, "jsessionid": jsessionId},
    ).catchError((e) {
      debugPrint("Errore prenotazione appello: $e");
      mapHiddens["success"] = false;
      mapHiddens["error"] = e;
      return mapHiddens;
    });

    if (response.statusCode == 302) {
      String location =
          "https://www.esse3.unimore.it" + response.headers.values.elementAt(2);
      if (location.endsWith("TIPO_ATTIVITA=1")) {
        location =
            location.substring(0, location.lastIndexOf("TIPO_ATTIVITA=1"));
      }

      http.Response responseAppello = await http.post(
        location,
        body: mapHiddens,
        headers: {"Authorization": basicAuth64, "jsessionid": jsessionId},
      ).catchError((e) {
        print("error: $e");
        mapHiddens["success"] = false;
        mapHiddens["error"] = e;
        return mapHiddens;
      });

      mapHiddens["success"] = responseAppello.statusCode == 302;
      if (!mapHiddens["success"]) {
        dom.Document document = parser.parse(responseAppello.body);
        if (document.querySelector("#app-text_esito_pren_msg") != null) {
          try {
            mapHiddens["success"] = document
                .querySelector("#app-text_esito_pren_msg")
                .text
                .contains("PRENOTAZIONE EFFETTUATA");
          } catch (e) {
            mapHiddens["success"] = false;
            mapHiddens["error"] = e;
            return mapHiddens;
          }

          if (!mapHiddens["success"]) {
            try {
              mapHiddens["error"] = document
                  .querySelector("#app-text_esito_pren_msg")
                  .innerHtml
                  .replaceFirst(
                      "PRENOTAZIONE NON EFFETTUATA<br>Questo messaggio può presentarsi se:",
                      "");
              mapHiddens["error"] =
                  mapHiddens["error"].toString().replaceAll(";", ";\n");
            } catch (e) {
              mapHiddens["error"] = e;
            }
          }
        } else {
          mapHiddens["success"] = false;
          mapHiddens["error"] = "#app-text_esito_pren_msg = null";
        }
      }
    } else {
      mapHiddens["success"] = false;
      mapHiddens["error"] = "responseCode: ${response.statusCode}";
    }

    return mapHiddens;
  }

  /// Serve a cancellare un appello grazie alle [infoAppello] scaricate da [getInfoAppello].
  static Future<bool> cancellaAppello(Map infoAppello) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String basicAuth64 = prefs.getString("auth64Cred");
    bool isSceltaCarriera = prefs.getBool("isSceltaCarriera") ?? false;

    if (basicAuth64 == null) return false;

    String urlCookie =
        "https://www.esse3.unimore.it/auth/studente/AreaStudente.do";
    http.Response getCookie =
        await http.head(urlCookie).catchError((e) => false);

    String jsessionId = "";

    try {
      jsessionId = getCookie.headers["set-cookie"]
          .split(";")[0]
          .replaceAll("JSESSIONID=", "");
    } catch (e) {
      return false;
    }

    String requestUrl =
        "https://www.esse3.unimore.it/auth/studente/Appelli/ConfermaCancellaAppello.do;jsessionid=" +
            jsessionId;
    String idStud;

    if (isSceltaCarriera) {
      idStud = prefs.getString("idStud");
      requestUrl = requestUrl + idStud;
    }

    http.Response response = await http.post(
      requestUrl,
      body: infoAppello,
      headers: {
        "Authorization": basicAuth64,
        "JSESSIONID": jsessionId,
        "origin": "https://www.esse3.unimore.it"
      },
    ).catchError((e) {
      debugPrint("Errore cancellazione appello: $e");
      return false;
    });

    if (response.statusCode == 302) {
      http.Response response2 = await http.post(
        requestUrl,
        body: infoAppello,
        headers: {"Authorization": basicAuth64, "JSESSIONID": jsessionId},
      ).catchError((e) {
        debugPrint("Errore cancellazione appello: $e");
        return false;
      });

      dom.Document document = parser.parse(response2.body);
      dom.Element formHiddens = document.querySelector("#esse3old");
      if (formHiddens == null) return false;

      formHiddens = formHiddens.querySelector('form').children[0];

      Map newBodyRequest = new Map();
      int lenBody = formHiddens.children.length - 1;

      try {
        for (int i = 0; i < lenBody; i++) {
          newBodyRequest[formHiddens.children[i].attributes["name"]] =
              formHiddens.children[i].attributes["value"];
        }
      } catch (e) {
        return false;
      }

      requestUrl =
          "https://www.esse3.unimore.it/auth/studente/Appelli/CancellaAppello.do;jsessionid=" +
              jsessionId;

      if (isSceltaCarriera) {
        requestUrl = requestUrl + idStud;
      }

      final finalResponse = await http.post(
        requestUrl,
        body: newBodyRequest,
        headers: {"Authorization": basicAuth64, "JSESSIONID": jsessionId},
      ).catchError((e) {
        debugPrint("Errore finalResponse cancellazione apppello: $e");
        return false;
      });

      return finalResponse.statusCode == 302;
    } else if (response.statusCode == 200) {
      dom.Document document = parser.parse(response.body);
      dom.Element formHiddens = document.querySelector("#esse3old");
      if (formHiddens == null) return false;

      formHiddens = formHiddens.querySelector('form').children[0];

      Map newBodyRequest = new Map();
      int lenBody = formHiddens.children.length - 1;

      try {
        for (int i = 0; i < lenBody; i++) {
          newBodyRequest[formHiddens.children[i].attributes["name"]] =
              formHiddens.children[i].attributes["value"];
        }
      } catch (e) {
        return false;
      }

      requestUrl =
          "https://www.esse3.unimore.it/auth/studente/Appelli/CancellaAppello.do;jsessionid=" +
              jsessionId;

      if (isSceltaCarriera) {
        requestUrl = requestUrl + idStud;
      }

      http.Response finalResponse = await http.post(
        requestUrl,
        body: newBodyRequest,
        headers: {"Authorization": basicAuth64, "jsessionid": jsessionId},
      ).catchError((e) {
        debugPrint("Errore finalResponse cancellazione apppello: $e");
        return false;
      });

      return finalResponse.statusCode == 302;
    } else
      return false;
  }
}
