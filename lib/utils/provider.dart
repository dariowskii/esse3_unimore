import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as parser;
import 'package:shared_preferences/shared_preferences.dart';

class Provider {
  static Future<Map> _isSceltaCarrieraAccess(var sceltaCarriera, var jsessionid,
      var basicAuth64, var map_info, var username) async {
    var tableScelta = sceltaCarriera.querySelector(".table-1-body");
    int lengthScelta = tableScelta.children.length;
    for (int i = 0; i < lengthScelta; i++) {
      if (tableScelta.children[i].children[3].text == "Attivo") {
        String idStud = tableScelta
            .children[i].children[4].children[0].children[0].attributes["href"];
        idStud = idStud
            .replaceAll("auth/studente/SceltaCarrieraStudente.do", "")
            .replaceAll("?", "?&");
        
        //Salvo idStud
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool("isSceltaCarriera", true);
        prefs.setString("idStud", idStud);

        var newRequestUrl =
            "https://www.esse3.unimore.it/auth/studente/AreaStudente.do;jsessionid=" +
                jsessionid +
                idStud;
        //TODO: verificare cosa succede nella request, da li risolvere
        //Get the response
        final response = await http.get(
          newRequestUrl,
          headers: {"Authorization": basicAuth64, "jsessionid": jsessionid},
        ).catchError((e) {
          return null;
        });
        map_info["success"] = response.statusCode == 200 ? true : false;
        if (!map_info["success"]) return map_info;

        dom.Document documentTmp = parser.parse(response.body);

        var scrapingNomeMatricola = documentTmp
            .querySelector(".pagetitle_title")
            .innerHtml
            .replaceAll("Area Studente ", "")
            .split(" - ");
        var nomeStudente = scrapingNomeMatricola[0];
        var matricolaStudente = scrapingNomeMatricola[1]
            .replaceFirst("[MAT. ", "")
            .replaceFirst("]", "");

        var info = documentTmp.querySelector(".record-riga");
        int lengthInfo = info.children.length;

        //Save info home as map

        map_info["nome"] = nomeStudente;
        map_info["matricola"] = matricolaStudente;
        List<String> prov = nomeStudente.split(" ");
        map_info["text_avatar"] =
            "${prov[0].substring(0, 1)}${prov[1].substring(0, 1)}";
        map_info["username"] = username;

        for (int i = 1; i < lengthInfo; i += 2) {
          int index = info.children[i].innerHtml.indexOf("&");
          String key = _getNomeInfo(i);
          if (key == "part_time") {
            map_info[key] = info.children[i].children[0].innerHtml.trim();
          } else {
            map_info[key] = info.children[i].innerHtml
                .replaceRange(index, info.children[i].innerHtml.length - 1, "")
                .trim();
          }
        }

        return map_info;
      }
    }
  }

  static Future<Map> _isSceltaCarrieraLibretto(
      var sceltaCarriera, var basicAuth64, var map_info) async {
    var tableScelta = sceltaCarriera.querySelector(".table-1-body");
    int lengthScelta = tableScelta.children.length;
    for (int i = 0; i < lengthScelta; i++) {
      if (tableScelta.children[i].children[3].text == "Attivo") {
        var urlCookie =
            "https://www.esse3.unimore.it/auth/studente/AreaStudente.do";
        var getCookie = await http.get(urlCookie);
        var jsessionCookie = getCookie.headers.values.toList();
        String jsessionid = jsessionCookie.sublist(1, 2).toString();
        List<String> jSession = jsessionid.split(";");
        jsessionid = jSession[0].replaceAll("[JSESSIONID=", "");

        String newUrl = tableScelta
            .children[i].children[4].children[0].children[0].attributes["href"];
        newUrl = newUrl
            .replaceAll("auth/studente/SceltaCarrieraStudente.do", "")
            .replaceAll("?", "&");
        var newRequestUrl =
            "https://www.esse3.unimore.it/auth/studente/Libretto/LibrettoHome.do;jsessionid=" +
                jsessionid +
                "?&menu_opened_cod=menu_link-navbox_studenti_Area_Studente" +
                newUrl;

        //Get the response
        final response = await http.get(
          newRequestUrl,
          headers: {"Authorization": basicAuth64, "jsessionid": jsessionid},
        ).catchError((e) {
          return null;
        });
        map_info["success"] = response.statusCode == 200 ? true : false;
        if (!map_info["success"]) return map_info;

        dom.Document documentTmp = parser.parse(response.body);

        var tableLibretto = documentTmp.querySelector("#tableLibretto");
        if (tableLibretto == null) return map_info;

        tableLibretto = tableLibretto.querySelector(".table-1-body");
        int lenghtLibretto = tableLibretto.children.length;
        if (lenghtLibretto == null) lenghtLibretto = 0;

        map_info["materie"] = new Map();
        map_info["crediti"] = new Map();
        map_info["voti"] = new Map();
        map_info["data_esame"] = new Map();
        map_info["cod_materia"] = new Map();
        map_info["superati"] = 0;
        map_info["totali"] = lenghtLibretto;

        for (int i = 0; i < lenghtLibretto; i++) {
          var materia = tableLibretto
              .children[i].children[0].children[0].innerHtml
              .split(" - ");
          map_info["materie"][i] = materia[1];
          map_info["cod_materia"][i] = materia[0];
          map_info["crediti"][i] =
              tableLibretto.children[i].children[2].innerHtml;
          map_info["voti"][i] = tableLibretto.children[i].children[5].innerHtml;

          String buff = map_info["voti"][i].toString();

          if (buff != "") {
            List<String> l = buff.split("&nbsp;-&nbsp;");
            //print(l);
            map_info["voti"][i] = l[0];
            map_info["data_esame"][i] = l[1];
            map_info["superati"]++;
            if (map_info["voti"][i].toString().contains("ID", 0)) {
              map_info["voti"][i] = "IDONEO";
            } else if (map_info["voti"][i].toString().contains("30L", 0) ||
                map_info["voti"][i].toString().contains("30 L", 0))
              map_info["voti"][i] = "30 LODE";
          } else {
            map_info["data_esame"][i] = "";
          }
        }
        print(map_info["superati"]);
        return map_info;
      }
    }
  }

  static Future<Map> _isSceltaCarrieraProssimiAppelli(
      var sceltaCarriera, var basicAuth64, var map_info) async {
    var tableScelta = sceltaCarriera.querySelector(".table-1-body");
    int lengthScelta = tableScelta.children.length;
    for (int i = 0; i < lengthScelta; i++) {
      if (tableScelta.children[i].children[3].text == "Attivo") {
        var urlCookie =
            "https://www.esse3.unimore.it/auth/studente/AreaStudente.do";
        var getCookie = await http.get(urlCookie);
        var jsessionCookie = getCookie.headers.values.toList();
        String jsessionid = jsessionCookie.sublist(1, 2).toString();
        List<String> jSession = jsessionid.split(";");
        jsessionid = jSession[0].replaceAll("[JSESSIONID=", "");

        String newUrl = tableScelta
            .children[i].children[4].children[0].children[0].attributes["href"];
        newUrl = newUrl
            .replaceAll("auth/studente/SceltaCarrieraStudente.do", "")
            .replaceAll("?", "&");
        var newRequestUrl =
            "https://www.esse3.unimore.it/auth/studente/Appelli/AppelliF.do;jsessionid=" +
                jsessionid +
                "?&menu_opened_cod=menu_link-navbox_studenti_Area_Studente" +
                newUrl;

        //Get the response
        newUrl = newUrl.replaceAll("&stu_id=", "");
        final response = await http.get(
          newRequestUrl,
          headers: {"Authorization": basicAuth64, "jsessionid": jsessionid},
        ).catchError((e) {
          return null;
        });

        map_info["success"] = response.statusCode == 200 ? true : false;
        if (!map_info["success"]) return map_info;

        dom.Document document = parser.parse(response.body);
        var tableAppelli = document.querySelector("tbody.table-1-body");

        if (tableAppelli == null) {
          map_info["totali"] = 0;
          return map_info;
        }

        int lenghtAppelli = tableAppelli.children.length;
        map_info["totali"] = lenghtAppelli;

        map_info["materia"] = new Map();
        map_info["data_appello"] = new Map();
        map_info["periodo_iscrizione"] = new Map();
        map_info["desc"] = new Map();
        map_info["sessione"] = new Map();
        map_info["link_info"] = new Map();

        for (int i = 0; i < lenghtAppelli; i++) {
          map_info["link_info"][i] = tableAppelli.children[i].children[0]
              .children[0].children[0].attributes["href"];
          map_info["materia"][i] = tableAppelli.children[i].children[1].text;
          map_info["data_appello"][i] =
              tableAppelli.children[i].children[2].text.substring(0, 10);
          map_info["periodo_iscrizione"][i] = tableAppelli
              .children[i].children[3].innerHtml
              .replaceAll("<br>", " - ");
          map_info["desc"][i] = tableAppelli.children[i].children[4].text;
          map_info["sessione"][i] =
              tableAppelli.children[i].children[5].innerHtml.substring(0, 9);
        }

        return map_info;
      }
    }
  }

  static Future<Map> _isSceltaCarrieraInfoAppello(
      var sceltaCarriera, var basicAuth64, var map_info, var urlInfo) async {
    var tableScelta = sceltaCarriera.querySelector(".table-1-body");
    int lengthScelta = tableScelta.children.length;
    for (int i = 0; i < lengthScelta; i++) {
      if (tableScelta.children[i].children[3].text == "Attivo") {
        var urlCookie =
            "https://www.esse3.unimore.it/auth/studente/AreaStudente.do";
        var getCookie = await http.get(urlCookie);
        var jsessionCookie = getCookie.headers.values.toList();
        String jsessionid = jsessionCookie.sublist(1, 2).toString();
        List<String> jSession = jsessionid.split(";");
        jsessionid = jSession[0].replaceAll("[JSESSIONID=", "");

        String newUrl = tableScelta
            .children[i].children[4].children[0].children[0].attributes["href"];
        newUrl = newUrl
            .replaceAll("auth/studente/SceltaCarrieraStudente.do", "")
            .replaceAll("?", "&");
        var newRequestUrl =
            "https://www.esse3.unimore.it/auth/studente/Appelli/DatiPrenotazioneAppello.do;jsessionid=" +
                jsessionid +
                "?&" +
                urlInfo +
                "&menu_opened_cod=menu_link-navbox_studenti_Area_Studente" +
                newUrl;

        //Get the response
        newUrl = newUrl.replaceAll("&stu_id=", "");
        final response = await http.get(
          newRequestUrl,
          headers: {"Authorization": basicAuth64, "jsessionid": jsessionid},
        ).catchError((e) {
          return null;
        });
        map_info["success"] = response.statusCode == 200 ? true : false;
        if (!map_info["success"]) return map_info;

        dom.Document document = parser.parse(response.body);
        var tableAppello = document.querySelector("#app-box_dati_pren");
        var tabellaTurni = document
            .querySelector("#app-tabella_turni")
            .querySelector(".table-1-body");

        var map_info_appello = new Map();
        map_info_appello["tipo_esame"] =
            tableAppello.children[1].children[7].text.trim();
        map_info_appello["verbalizzazione"] =
            tableAppello.children[1].children[9].text.trim();
        map_info_appello["docente"] = tableAppello
            .children[1].children[11].innerHtml
            .replaceAll("<br>", " ")
            .replaceAll("&nbsp;", "")
            .trim();
        map_info_appello["num_iscritti"] =
            tabellaTurni.children[0].children[2].text.trim();
        map_info_appello["aula"] = tabellaTurni.children[0].children[1].text;

        // debugPrint(response.body);
        return map_info_appello;
      }
    }
  }

  static Future<Map> _isSceltaCarrieraTasse(
      var sceltaCarriera, var basicAuth64, var map_info, var prefs) async {
    var tableScelta = sceltaCarriera.querySelector(".table-1-body");
    int lengthScelta = tableScelta.children.length;
    for (int i = 0; i < lengthScelta; i++) {
      if (tableScelta.children[i].children[3].text == "Attivo") {
        var urlCookie =
            "https://www.esse3.unimore.it/auth/studente/AreaStudente.do";
        var getCookie = await http.get(urlCookie);
        var jsessionCookie = getCookie.headers.values.toList();
        String jsessionid = jsessionCookie.sublist(1, 2).toString();
        List<String> jSession = jsessionid.split(";");
        jsessionid = jSession[0].replaceAll("[JSESSIONID=", "");

        String newUrl = tableScelta
            .children[i].children[4].children[0].children[0].attributes["href"];
        newUrl = newUrl
            .replaceAll("auth/studente/SceltaCarrieraStudente.do", "")
            .replaceAll("?", "&");
        var newRequestUrl =
            "https://www.esse3.unimore.it/auth/studente/Tasse/ListaFatture.do;jsessionid=" +
                jsessionid +
                "?&menu_opened_cod=menu_link-navbox_studenti_Area_Studente" +
                newUrl;

        //Get the response
        newUrl = newUrl.replaceAll("&stu_id=", "");
        final response = await http.get(
          newRequestUrl,
          headers: {"Authorization": basicAuth64, "jsessionid": jsessionid},
        ).catchError((e) {
          return null;
        });

        map_info["success"] = response.statusCode == 200 ? true : false;
        if (!map_info["success"]) return map_info;

        dom.Document document = parser.parse(response.body);
        var tableTasse = document.querySelector("#tasse-tableFatt");
        if (tableTasse == null) return map_info;

        tableTasse = tableTasse.querySelector(".table-1-body");
        int lenghtTasse = tableTasse.children.length;

        map_info["importi"] = new Map();
        map_info["scadenza"] = new Map();
        map_info["desc"] = new Map();
        map_info["stato_pagamento"] = new Map();
        map_info["totali"] = lenghtTasse;
        map_info["da_pagare"] = 0;

        for (int i = 0; i < lenghtTasse; i++) {
          map_info["desc"][i] = tableTasse.children[i].children[3].children[0]
              .children[0].children[1].innerHtml
              .replaceAll("&nbsp;", "")
              .substring(2);
          map_info["scadenza"][i] =
              tableTasse.children[i].children[4].innerHtml;
          map_info["importi"][i] = tableTasse.children[i].children[5].innerHtml;
          String buff = tableTasse.children[i].children[6].innerHtml;
          if (buff.contains("non")) {
            map_info["stato_pagamento"][i] = "NON PAGATO";
            map_info["da_pagare"]++;
          } else if (buff.contains("pagato"))
            map_info["stato_pagamento"][i] = "PAGATO";
          else if (buff.contains("pagamen"))
            map_info["stato_pagamento"][i] = "IN ATTESA";
        }
        return map_info;
      }
    }
  }

  static Future<Map> _isSceltaCarrieraPrenotati(
      var sceltaCarriera, var basicAuth64, var map_info) async {
    var tableScelta = sceltaCarriera.querySelector(".table-1-body");
    int lengthScelta = tableScelta.children.length;
    for (int i = 0; i < lengthScelta; i++) {
      if (tableScelta.children[i].children[3].text == "Attivo") {
        var urlCookie =
            "https://www.esse3.unimore.it/auth/studente/AreaStudente.do";
        var getCookie = await http.get(urlCookie);
        var jsessionCookie = getCookie.headers.values.toList();
        String jsessionid = jsessionCookie.sublist(1, 2).toString();
        List<String> jSession = jsessionid.split(";");
        jsessionid = jSession[0].replaceAll("[JSESSIONID=", "");

        String newUrl = tableScelta
            .children[i].children[4].children[0].children[0].attributes["href"];
        newUrl = newUrl
            .replaceAll("auth/studente/SceltaCarrieraStudente.do", "")
            .replaceAll("?", "&");
        var newRequestUrl =
            "https://www.esse3.unimore.it/auth/studente/Appelli/BachecaPrenotazioni.do;jsessionid=" +
                jsessionid +
                "?&menu_opened_cod=menu_link-navbox_studenti_Area_Studente" +
                newUrl;

        //Get the response
        final response = await http.get(
          newRequestUrl,
          headers: {"Authorization": basicAuth64, "jsessionid": jsessionid},
        ).catchError((e) {
          return null;
        });

        map_info["success"] = response.statusCode == 200 ? true : false;
        if (!map_info["success"]) return map_info;

        dom.Document document = parser.parse(response.body);

        var divPrenotati = document.querySelector("#esse3old");
        var arrayPrenotati = divPrenotati.querySelector('tbody');

        if (arrayPrenotati == null) {
          map_info["totali"] = 0;
          return map_info;
        }

        int lengthPrenotati = arrayPrenotati.children.length;
        map_info["totali"] = 0;
        map_info["esame"] = new Map();
        map_info["iscrizione"] = new Map();
        map_info["tipo_esame"] = new Map();
        map_info["giorno"] = new Map();
        map_info["ora"] = new Map();
        map_info["docente"] = new Map();

        for (int i = 0; i < lengthPrenotati; i++) {
          if (i == 0) continue;
          if (i % 2 == 0) {
            var tablePrenotazione =
                arrayPrenotati.children[i].querySelector('tbody');
            if (tablePrenotazione.children.length < 2) break;
            map_info["esame"][map_info["totali"]] =
                tablePrenotazione.children[0].children[0].text;
            map_info["iscrizione"][map_info["totali"]] =
                tablePrenotazione.children[2].children[0].text;
            map_info["tipo_esame"][map_info["totali"]] =
                tablePrenotazione.children[3].children[0].text;
            map_info["giorno"][map_info["totali"]] =
                tablePrenotazione.children[6].children[0].text;
            map_info["ora"][map_info["totali"]] =
                tablePrenotazione.children[6].children[1].text;
            map_info["docente"][map_info["totali"]] =
                tablePrenotazione.children[6].children[5].text;
            map_info["totali"]++;
          }
        }

        return map_info;
      }
    }
  }

  static Future<bool> _isSceltaCarrieraPrenotaAppello(
      var sceltaCarriera, var basicAuth64, var infoAppello) async {
    var tableScelta = sceltaCarriera.querySelector(".table-1-body");
    int lengthScelta = tableScelta.children.length;
    for (int i = 0; i < lengthScelta; i++) {
      if (tableScelta.children[i].children[3].text == "Attivo") {
        var urlCookie =
            "https://www.esse3.unimore.it/auth/studente/AreaStudente.do";
        var getCookie = await http.get(urlCookie);
        var jsessionCookie = getCookie.headers.values.toList();
        String jsessionid = jsessionCookie.sublist(1, 2).toString();
        List<String> jSession = jsessionid.split(";");
        jsessionid = jSession[0].replaceAll("[JSESSIONID=", "");

        String newUrl = tableScelta
            .children[i].children[4].children[0].children[0].attributes["href"];
        newUrl = newUrl
            .replaceAll("auth/studente/SceltaCarrieraStudente.do", "")
            .replaceAll("?", "&");
        var newRequestUrl =
            "https://www.esse3.unimore.it/auth/studente/Appelli/EffettuaPrenotazioneAppello.do;jsessionid=" +
                jsessionid +
                "?TIPO_ATTIVITA=1" +
                newUrl;
        Map mapHiddens = new Map();
        int lunghezzaHidden = infoAppello["lunghezzaHidden"];

        for (int i = 0; i < lunghezzaHidden; i++) {
          mapHiddens[infoAppello["hiddens_name"][i]] =
          infoAppello["hiddens_value"][i];
        }

        final responseTmp = await http.post(
          newRequestUrl,
          body: mapHiddens,
          headers: {"Authorization": basicAuth64, "jsessionid": jsessionid},
        ).catchError((e) {
          print("error: $e");
          return null;
        });
        bool success;
        if (responseTmp.statusCode == 302) {
          String location = "https://www.esse3.unimore.it" +
              responseTmp.headers.values.elementAt(2);
          final responseAppello = await http.post(
            location,
            body: mapHiddens,
            headers: {"Authorization": basicAuth64, "jsessionid": jsessionid},
          ).catchError((e) {
            print("error: $e");
            return null;
          });
          success = responseAppello.statusCode == 302 ? true : false;
        }

        return success;
      }
    }
  }

  static Future<bool> _isSceltaCarrieraCancellaAppello(var sceltaCarriera, var basicAuth64, Map infoAppello) async {
    var tableScelta = sceltaCarriera.querySelector(".table-1-body");
    int lengthScelta = tableScelta.children.length;
    for (int i = 0; i < lengthScelta; i++) {
      if (tableScelta.children[i].children[3].text == "Attivo") {
        var urlCookie =
            "https://www.esse3.unimore.it/auth/studente/AreaStudente.do";
        var getCookie = await http.get(urlCookie);
        var jsessionCookie = getCookie.headers.values.toList();
        String jsessionid = jsessionCookie.sublist(1, 2).toString();
        List<String> jSession = jsessionid.split(";");
        jsessionid = jSession[0].replaceAll("[JSESSIONID=", "");

        String newUrl = tableScelta
            .children[i].children[4].children[0].children[0].attributes["href"];
        newUrl = newUrl
            .replaceAll("auth/studente/SceltaCarrieraStudente.do", "")
            .replaceAll("?", "&");
        var newRequestUrl =
            "https://www.esse3.unimore.it/auth/studente/Appelli/ConfermaCancellaAppello.do;jsessionid=" +
                jsessionid +
                newUrl;

        final getResponse = await http.post(
          newRequestUrl,
          body: infoAppello,
          headers: {"Authorization": basicAuth64, "jsessionid": jsessionid},
        ).catchError((e) {
          return null;
        });

        dom.Document document = parser.parse(getResponse.body);

        var formHiddens = document.querySelector("#esse3old").querySelector('form').children[0];

        Map newBodyRequest = new Map();
        int lenBody = formHiddens.children.length - 1;

        for(int i = 0; i < lenBody; i++){
          newBodyRequest[formHiddens.children[i].attributes["name"]] = formHiddens.children[i].attributes["value"];
        }

        newRequestUrl = "https://www.esse3.unimore.it/auth/studente/Appelli/CancellaAppello.do;jsessionid=" + jsessionid + newUrl;

        final finalResponse = await http.post(
          newRequestUrl,
          body: infoAppello,
          headers: {"Authorization": basicAuth64, "jsessionid": jsessionid},
        ).catchError((e) {
          return null;
        });

        bool success = finalResponse.statusCode == 302;

        return success;
      }
    }
  }

  static Future<Map> getAccess(String basicAuth64, String username) async {
    //Grab the cookie for the request
    var urlCookie =
        "https://www.esse3.unimore.it/auth/studente/AreaStudente.do";
    var getCookie = await http.get(urlCookie);
    var jsessioncookie = getCookie.headers.values.toList();
    String jsessionid = jsessioncookie.sublist(1, 2).toString();
    List<String> jSession = jsessionid.split(";");
    jsessionid = jSession[0].replaceAll("[JSESSIONID=", "");

    //Create the request url
    var requestUrl = urlCookie + ";jsessionid=" + jsessionid;

    //Get the response
    final response = await http.get(
      requestUrl,
      headers: {"Authorization": basicAuth64, "jsessionid": jsessionid},
    ).catchError((e) {
      debugPrint("Errore response getAccess: $e");
      return null;
    });

    var map_info = new Map();
    map_info["success"] = response.statusCode == 200 ? true : false;
    if (!map_info["success"]) return map_info;
    //Scraping home page
    dom.Document documentHome = parser.parse(response.body);

    var sceltaCarriera = documentHome.querySelector("#gu_table_sceltacarriera");
    //TODO: sceltaCarriera != null
    if (sceltaCarriera != null) {
      return await _isSceltaCarrieraAccess(
          sceltaCarriera, jsessionid, basicAuth64, map_info, username);
    }

    List<String> scrapingNomeMatricola = documentHome
        .querySelector(".pagetitle_title")
        .innerHtml
        .replaceAll("Area Studente ", "")
        .split(" - ");
    var nomeStudente = scrapingNomeMatricola[0];
    var matricolaStudente = scrapingNomeMatricola[1]
        .replaceFirst("[MAT. ", "")
        .replaceFirst("]", "");

    var info = documentHome.querySelector(".record-riga");
    int lengthInfo = info.children.length;

    //Save info home as map

    map_info["nome"] = nomeStudente;
    map_info["matricola"] = matricolaStudente;
    List<String> prov = nomeStudente.split(" ");
    map_info["text_avatar"] =
        "${prov[0].substring(0, 1)}${prov[1].substring(0, 1)}";
    map_info["username"] = username;

    for (int i = 1; i < lengthInfo; i += 2) {
      int index = info.children[i].innerHtml.indexOf("&");
      String key = _getNomeInfo(i);
      if (key == "part_time") {
        map_info[key] = info.children[i].children[0].innerHtml.trim();
      } else {
        map_info[key] = info.children[i].innerHtml
            .replaceRange(index, info.children[i].innerHtml.length - 1, "")
            .trim();
      }
    }

    return map_info;
  }

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

  static Future<Map> getLibretto() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var auth64Cred = prefs.getString("auth64Cred");

    if (auth64Cred == null) return null;
    var isSceltaCarriera = prefs.getBool("isSceltaCarriera") ?? false;

    var urlCookie =
        "https://www.esse3.unimore.it/auth/studente/AreaStudente.do";
    var getCookie = await http.get(urlCookie);
    var jsessionCookie = getCookie.headers.values.toList();
    String jsessionid = jsessionCookie.sublist(1, 2).toString();
    List<String> jSession = jsessionid.split(";");
    jsessionid = jSession[0].replaceAll("[JSESSIONID=", "");

    //Libretto

    var requestUrl =
        "https://www.esse3.unimore.it/auth/studente/Libretto/LibrettoHome.do;jsessionid=" +
            jsessionid +
            "?&menu_opened_cod=menu_link-navbox_studenti_Area_Studente";
    //var requestUrlTmp = urlCookie + ";jsessionid=" + jsessionid;
    var basicAuth64 = "Basic " + auth64Cred;

    // final responseTmp = await http.get(
    //   requestUrlTmp,
    //   headers: {"Authorization": basicAuth64, "jsessionid": jsessionid},
    // ).catchError((e) {
    //   return null;
    // });

    if(isSceltaCarriera){
        var idStud = prefs.getString("idStud");
        requestUrl = requestUrl + idStud;
    }

    final response = await http.get(
      requestUrl,
      headers: {"Authorization": basicAuth64, "jsessionid": jsessionid},
    ).catchError((e) {
      debugPrint("Errore richiesta libretto: $e");
      return null;
    });

    var map_libretto = new Map();

    // dom.Document documentHome = parser.parse(responseTmp.body);
    //
    // var sceltaCarriera = documentHome.querySelector("#gu_table_sceltacarriera");
    // //TODO: sceltaCarriera != null
    // if (sceltaCarriera != null) {
    //   return await _isSceltaCarrieraLibretto(
    //       sceltaCarriera, basicAuth64, map_libretto);
    // }

    map_libretto["success"] = response.statusCode == 200;
    if (!map_libretto["success"]) return map_libretto;

    dom.Document documentLibretto = parser.parse(response.body);

    var tableLibretto = documentLibretto.querySelector("#tableLibretto");
    tableLibretto = tableLibretto.querySelector(".table-1-body");
    int lenghtLibretto = tableLibretto.children.length;

    map_libretto["materie"] = new Map();
    map_libretto["crediti"] = new Map();
    map_libretto["voti"] = new Map();
    map_libretto["data_esame"] = new Map();
    map_libretto["cod_materia"] = new Map();
    map_libretto["superati"] = 0;
    map_libretto["totali"] = lenghtLibretto;

    for (int i = 0; i < lenghtLibretto; i++) {
      var materia =
          tableLibretto.children[i].children[0].children[0].text.split(" - ");
      map_libretto["materie"][i] = materia[1];
      map_libretto["cod_materia"][i] = materia[0];
      map_libretto["crediti"][i] =
          tableLibretto.children[i].children[2].innerHtml;
      map_libretto["voti"][i] = tableLibretto.children[i].children[5].innerHtml;

      String buff = map_libretto["voti"][i];

      //print(buff);

      if (buff != "") {
        List<String> l = buff.split("&nbsp;-&nbsp;");
        //print(l);
        map_libretto["voti"][i] = l[0];
        map_libretto["data_esame"][i] = l[1];
        map_libretto["superati"]++;
        if (map_libretto["voti"][i].toString().contains("ID", 0)) {
          map_libretto["voti"][i] = "IDONEO";
        } else if (map_libretto["voti"][i].toString().contains("30L", 0) ||
            map_libretto["voti"][i].toString().contains("30 L", 0)) {
          map_libretto["voti"][i] = "30 LODE";
        }//else if (map_libretto["voti"][i].toString().contains("APP", 0)) {
        //   map_libretto["voti"][i] = "APPR";
        // } else if (map_libretto["voti"][i].toString().contains("DIT", 0)) {
        //   map_libretto["voti"][i] = "DIT";
        // }
      } else {
        map_libretto["data_esame"][i] = "";
      }
    }

    return map_libretto;
  }

  static Future<Map> getTasse() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var auth64Cred = prefs.getString("auth64Cred");

    if (auth64Cred == null) return null;
    var isSceltaCarriera = prefs.getBool("isSceltaCarriera") ?? false;

    var urlCookie =
        "https://www.esse3.unimore.it/auth/studente/AreaStudente.do";
    var getCookie = await http.get(urlCookie);
    var jsessionCookie = getCookie.headers.values.toList();
    String jsessionid = jsessionCookie.sublist(1, 2).toString();
    List<String> jSession = jsessionid.split(";");
    jsessionid = jSession[0].replaceAll("[JSESSIONID=", "");

    //Tasse
    var requestUrl =
        "https://www.esse3.unimore.it/auth/studente/Tasse/ListaFatture.do;jsessionid=" +
            jsessionid +
            "?&menu_opened_cod=menu_link-navbox_studenti_Area_Studente";
    //var requestUrlTmp = urlCookie + ";jsessionid=" + jsessionid;
    var basicAuth64 = "Basic " + auth64Cred;

    if(isSceltaCarriera){
      var idStud = prefs.getString("idStud");
      requestUrl = requestUrl + idStud;
    }

    final response = await http.get(
      requestUrl,
      headers: {"Authorization": basicAuth64, "jsessionid": jsessionid},
    ).catchError((e) {
      debugPrint("Errore richiesta tasse: $e");
      return null;
    });

    // final responseTmp = await http.get(
    //   requestUrlTmp,
    //   headers: {"Authorization": basicAuth64, "jsessionid": jsessionid},
    // ).catchError((e) {
    //   return null;
    // });

    var map_tasse = new Map();

    // dom.Document documentHome = parser.parse(responseTmp.body);
    //
    // var sceltaCarriera = documentHome.querySelector("#gu_table_sceltacarriera");
    // //TODO: sceltaCarriera != null
    // if (sceltaCarriera != null) {
    //   //map_info["scelta_carriera"] = true;
    //   return await _isSceltaCarrieraTasse(
    //       sceltaCarriera, basicAuth64, map_tasse, prefs);
    // }

    map_tasse["success"] = response.statusCode == 200;
    if (!map_tasse["success"]) return map_tasse;

    dom.Document document = parser.parse(response.body);

    var tableTasse = document.querySelector("#tasse-tableFatt");
    tableTasse = tableTasse.querySelector(".table-1-body");
    int lenghtTasse = tableTasse.children.length;

    map_tasse["importi"] = new Map();
    map_tasse["scadenza"] = new Map();
    map_tasse["desc"] = new Map();
    map_tasse["stato_pagamento"] = new Map();
    map_tasse["totali"] = lenghtTasse;
    map_tasse["da_pagare"] = 0;

    for (int i = 0; i < lenghtTasse; i++) {
      map_tasse["desc"][i] = tableTasse
          .children[i].children[3].children[0].children[0].children[1].innerHtml
          .replaceAll("&nbsp;", "")
          .substring(2);
      map_tasse["scadenza"][i] = tableTasse.children[i].children[4].innerHtml;
      map_tasse["importi"][i] = tableTasse.children[i].children[5].innerHtml;
      String buff = tableTasse.children[i].children[6].innerHtml;
      if (buff.contains("non")) {
        map_tasse["stato_pagamento"][i] = "NON PAGATO";
        map_tasse["da_pagare"]++;
      } else if (buff.contains("pagato"))
        map_tasse["stato_pagamento"][i] = "PAGATO";
      else if (buff.contains("pagamen"))
        map_tasse["stato_pagamento"][i] = "IN ATTESA";
    }

    return map_tasse;
  }

  static Future<Map> getAppelli() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var auth64Cred = prefs.getString("auth64Cred");

    var isSceltaCarriera = prefs.getBool("isSceltaCarriera") ?? false;

    var urlCookie =
        "https://www.esse3.unimore.it/auth/studente/AreaStudente.do";
    var getCookie = await http.get(urlCookie);
    var jsessionCookie = getCookie.headers.values.toList();
    String jsessionid = jsessionCookie.sublist(1, 2).toString();
    List<String> jSession = jsessionid.split(";");
    jsessionid = jSession[0].replaceAll("[JSESSIONID=", "");

    //var requestUrlTmp = urlCookie + ";jsessionid=" + jsessionid;
    var basicAuth64 = "Basic " + auth64Cred;

    var requestUrl =
        "https://www.esse3.unimore.it/auth/studente/Appelli/AppelliF.do;jsessionid=" +
            jsessionid +
            "?&menu_opened_cod=menu_link-navbox_studenti_Area_Studente";

    if(isSceltaCarriera){
      var idStud = prefs.getString("idStud");
      requestUrl = requestUrl + idStud;
    }

    final response = await http.get(
      requestUrl,
      headers: {"Authorization": basicAuth64, "jsessionid": jsessionid},
    ).catchError((e) {
      debugPrint("Errore richiesta appelli: $e");
      return null;
    });

    var map_appelli = new Map();

    //dom.Document documentHome = parser.parse(response.body);

    // var sceltaCarriera = documentHome.querySelector("#gu_table_sceltacarriera");
    // //TODO: sceltaCarriera != null
    // if (sceltaCarriera != null) {
    //   //map_info["scelta_carriera"] = true;
    //   return await _isSceltaCarrieraProssimiAppelli(
    //       sceltaCarriera, basicAuth64, map_appelli);
    // }

    //Appelli

    map_appelli["success"] = response.statusCode == 200;
    if (!map_appelli["success"]) return map_appelli;

    dom.Document document = parser.parse(response.body);
    var tableAppelli = document.querySelector("tbody.table-1-body");

    if (tableAppelli == null) {
      map_appelli["totali"] = 0;
      return map_appelli;
    }

    int lenghtAppelli = tableAppelli.children.length;
    map_appelli["totali"] = lenghtAppelli;

    map_appelli["materia"] = new Map();
    map_appelli["data_appello"] = new Map();
    map_appelli["periodo_iscrizione"] = new Map();
    map_appelli["desc"] = new Map();
    map_appelli["sessione"] = new Map();
    map_appelli["link_info"] = new Map();

    for (int i = 0; i < lenghtAppelli; i++) {
      map_appelli["link_info"][i] = tableAppelli
          .children[i].children[0].children[0].children[0].attributes["href"];
      map_appelli["materia"][i] = tableAppelli.children[i].children[1].text;
      map_appelli["data_appello"][i] =
          tableAppelli.children[i].children[2].text.substring(0, 10);
      map_appelli["periodo_iscrizione"][i] = tableAppelli
          .children[i].children[3].innerHtml
          .replaceAll("<br>", " - ");
      map_appelli["desc"][i] = tableAppelli.children[i].children[4].text;
      map_appelli["sessione"][i] =
          tableAppelli.children[i].children[5].innerHtml.substring(0, 9);
    }

    return map_appelli;
  }

  static Future<Map> getInfoAppello(String urlInfo) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var auth64Cred = prefs.getString("auth64Cred");
    var isSceltaCarriera = prefs.getBool("isSceltaCarriera") ?? false;

    var urlCookie =
        "https://www.esse3.unimore.it/auth/studente/AreaStudente.do";
    var getCookie = await http.get(urlCookie);
    var jsessionCookie = getCookie.headers.values.toList();
    String jsessionid = jsessionCookie.sublist(1, 2).toString();
    List<String> jSession = jsessionid.split(";");
    jsessionid = jSession[0].replaceAll("[JSESSIONID=", "");

    urlInfo = urlInfo.replaceAll(
        "auth/studente/Appelli/DatiPrenotazioneAppello.do?", "");

    //Appelli
    var requestUrl =
        "https://www.esse3.unimore.it/auth/studente/Appelli/DatiPrenotazioneAppello.do;jsessionid=" +
            jsessionid +
            "?&" +
            urlInfo;
    //var requestUrlTmp = urlCookie + ";jsessionid=" + jsessionid;
    var basicAuth64 = "Basic " + auth64Cred;

    if(isSceltaCarriera){
      var idStud = prefs.getString("idStud");
      requestUrl = requestUrl + idStud;
    }

    final response = await http.get(
      requestUrl,
      headers: {"Authorization": basicAuth64, "jsessionid": jsessionid},
    ).catchError((e) {
      debugPrint("Errore getInfoAppello: $e");
      return null;
    });

    // final responseTmp = await http.get(
    //   requestUrlTmp,
    //   headers: {"Authorization": basicAuth64, "jsessionid": jsessionid},
    // ).catchError((e) {
    //   return null;
    // });

    var map_info_appello = new Map();

    // dom.Document documentHome = parser.parse(responseTmp.body);
    //
    // var sceltaCarriera = documentHome.querySelector("#gu_table_sceltacarriera");
    // //TODO: sceltaCarriera != null
    // if (sceltaCarriera != null) {
    //   //map_info["scelta_carriera"] = true;
    //   return await _isSceltaCarrieraInfoAppello(
    //       sceltaCarriera, basicAuth64, map_info_appello, urlInfo);
    // }

    dom.Document document = parser.parse(response.body);

    var tableAppello = document.querySelector("#app-box_dati_pren");
    var tabellaTurni = document
        .querySelector("#app-tabella_turni")
        .querySelector(".table-1-body");
    var tabellaHidden =
        document.querySelector("#app-form_dati_pren").children[5];

    if (tabellaHidden != null) {
      map_info_appello["tabellaHidden"] = true;
      int lunghezzaHidden = tabellaHidden.children.length;
      map_info_appello["lunghezzaHidden"] = lunghezzaHidden;
      map_info_appello["hiddens_name"] = new Map();
      map_info_appello["hiddens_value"] = new Map();
      for (int i = 0; i < lunghezzaHidden; i++) {
        if (i < lunghezzaHidden - 1) {
          map_info_appello["hiddens_name"][i] = tabellaHidden.children[i].id;
          map_info_appello["hiddens_value"][i] =
              tabellaHidden.children[i].attributes["value"];
        } else {
          map_info_appello["hiddens_name"][i] = "form_id_app-form_dati_pren";
          map_info_appello["hiddens_value"][i] = "app-form_dati_pren";
        }
      }
    }

    //print(tableAppello.innerHtml);

    map_info_appello["tipo_esame"] =
        tableAppello.children[1].children[7].text.trim();
    map_info_appello["verbalizzazione"] =
        tableAppello.children[1].children[9].text.trim();
    map_info_appello["docente"] = tableAppello
        .children[1].children[11].innerHtml
        .replaceAll("<br>", " ")
        .replaceAll("&nbsp;", "")
        .trim();
    map_info_appello["num_iscritti"] =
        tabellaTurni.children[0].children[2].text.trim();
    map_info_appello["aula"] = tabellaTurni.children[0].children[1].text;

    // debugPrint(response.body);
    return map_info_appello;
  }

  static Future<Map> getAppelliPrenotati() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var auth64Cred = prefs.getString("auth64Cred");
    var isSceltaCarriera = prefs.getBool("isSceltaCarriera") ?? false;

    if (auth64Cred == null) return null;

    var urlCookie =
        "https://www.esse3.unimore.it/auth/studente/AreaStudente.do";
    var getCookie = await http.get(urlCookie);
    var jsessionCookie = getCookie.headers.values.toList();
    String jsessionid = jsessionCookie.sublist(1, 2).toString();
    List<String> jSession = jsessionid.split(";");
    jsessionid = jSession[0].replaceAll("[JSESSIONID=", "");

    var requestUrl =
        "https://www.esse3.unimore.it/auth/studente/Appelli/BachecaPrenotazioni.do;jsessionid=" +
            jsessionid +
            "?menu_opened_cod=menu_link-navbox_studenti_Area_Studente";
    //var requestUrlTmp = urlCookie + ";jsessionid=" + jsessionid;
    var basicAuth64 = "Basic " + auth64Cred;

    if(isSceltaCarriera){
      var idStud = prefs.getString("idStud");
      requestUrl = requestUrl + idStud;
    }

    final response = await http.get(
      requestUrl,
      headers: {"Authorization": basicAuth64, "jsessionid": jsessionid},
    ).catchError((e) {
      debugPrint("Errore getAppelliPrenotati: $e");
      return null;
    });

    // final responseTmp = await http.get(
    //   requestUrlTmp,
    //   headers: {"Authorization": basicAuth64, "jsessionid": jsessionid},
    // ).catchError((e) {
    //   return null;
    // });

    var map_prenotati = new Map();

    // dom.Document documentHome = parser.parse(responseTmp.body);
    //
    // var sceltaCarriera = documentHome.querySelector("#gu_table_sceltacarriera");
    //
    // if (sceltaCarriera != null) {
    //   return await _isSceltaCarrieraPrenotati(
    //       sceltaCarriera, basicAuth64, map_prenotati);
    // }

    map_prenotati["success"] = response.statusCode == 200;
    if (!map_prenotati["success"]) return map_prenotati;

    dom.Document document = parser.parse(response.body);

    var divPrenotati = document.querySelector("#esse3old");
    var arrayPrenotati = divPrenotati.querySelector('tbody');

    if (arrayPrenotati == null) {
      map_prenotati["totali"] = 0;
      return map_prenotati;
    }

    int lengthPrenotati = arrayPrenotati.children.length;
    map_prenotati["totali"] = 0;
    map_prenotati["esame"] = new Map();
    map_prenotati["iscrizione"] = new Map();
    map_prenotati["tipo_esame"] = new Map();
    map_prenotati["giorno"] = new Map();
    map_prenotati["ora"] = new Map();
    map_prenotati["docente"] = new Map();
    map_prenotati["formHiddens"] = new Map();

    for (int i = 0; i < lengthPrenotati; i++) {
      if (i == 0) continue;
      if (i % 2 == 0) {
        var tablePrenotazione =
            arrayPrenotati.children[i].querySelector('tbody');
        if (tablePrenotazione.children.length < 2) break;
        map_prenotati["esame"][map_prenotati["totali"]] =
            tablePrenotazione.children[0].children[0].text;
        map_prenotati["iscrizione"][map_prenotati["totali"]] =
            tablePrenotazione.children[2].children[0].text;
        map_prenotati["tipo_esame"][map_prenotati["totali"]] =
            tablePrenotazione.children[3].children[0].text;
        map_prenotati["giorno"][map_prenotati["totali"]] =
            tablePrenotazione.children[6].children[0].text;
        map_prenotati["ora"][map_prenotati["totali"]] =
            tablePrenotazione.children[6].children[1].text;
        map_prenotati["docente"][map_prenotati["totali"]] =
            tablePrenotazione.children[6].children[5].text;

        int lenHiddens = tablePrenotazione.children[6].children[6].children[0].children.length;
        map_prenotati["lenHiddens"] = lenHiddens - 1;
        var hiddens = tablePrenotazione.children[6].children[6].children[0];
        for(int j = 1; j < lenHiddens; j++){
          String key = map_prenotati["totali"].toString() + "_" + hiddens.children[j].attributes["name"].toString();
          map_prenotati["formHiddens"][key] = hiddens.children[j].attributes["value"];
        }
        map_prenotati["totali"]++;
      }
    }
    return map_prenotati;
  }

  static Future<bool> prenotaAppello(Map infoAppello) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var auth64Cred = prefs.getString("auth64Cred");
    var isSceltaCarriera = prefs.getBool("isSceltaCarriera") ?? false;

    var urlCookie =
        "https://www.esse3.unimore.it/auth/studente/AreaStudente.do";
    var getCookie = await http.get(urlCookie);
    var jsessionCookie = getCookie.headers.values.toList();
    String jsessionid = jsessionCookie.sublist(1, 2).toString();
    List<String> jSession = jsessionid.split(";");
    jsessionid = jSession[0].replaceAll("[JSESSIONID=", "");

    var requestUrl =
        "https://www.esse3.unimore.it/auth/studente/Appelli/EffettuaPrenotazioneAppello.do;jsessionid=" +
            jsessionid +
            "?TIPO_ATTIVITA=1";
    //var requestUrl = urlCookie + ";jsessionid=" + jsessionid;
    var basicAuth64 = "Basic " + auth64Cred;

    if(isSceltaCarriera){
      var idStud = prefs.getString("idStud");
      requestUrl = requestUrl + idStud;
    }

    Map mapHiddens = new Map();
    int lunghezzaHidden = infoAppello["lunghezzaHidden"];

    for (int i = 0; i < lunghezzaHidden; i++) {
      mapHiddens[infoAppello["hiddens_name"][i]] =
      infoAppello["hiddens_value"][i];
    }
    //print(mapHiddens);

    final response = await http.post(
      requestUrl,
      body: mapHiddens,
      headers: {"Authorization": basicAuth64, "jsessionid": jsessionid},
    ).catchError((e) {
      debugPrint("Errore prenotazione appello: $e");
      return null;
    });
    // final getResponseTmp = await http.get(
    //   requestUrl,
    //   headers: {"Authorization": basicAuth64, "jsessionid": jsessionid},
    // ).catchError((e) {
    //   return null;
    // });


    // dom.Document documentHome = parser.parse(getResponseTmp.body);
    //
    // var sceltaCarriera = documentHome.querySelector("#gu_table_sceltacarriera");
    //
    // if (sceltaCarriera != null) {
    //   return await _isSceltaCarrieraPrenotaAppello(
    //       sceltaCarriera, basicAuth64, infoAppello);
    // }
    bool success;
    if (response.statusCode == 302) {
      String location = "https://www.esse3.unimore.it" +
          response.headers.values.elementAt(2);
      final responseAppello = await http.post(
        location,
        body: mapHiddens,
        headers: {"Authorization": basicAuth64, "jsessionid": jsessionid},
      ).catchError((e) {
        print("error: $e");
        return null;
      });
      success = responseAppello.statusCode == 302 ? true : false;
      if(!success){
        dom.Document document = parser.parse(responseAppello.body);
        success = document.querySelector("#app-text_esito_pren_msg").text.contains("PRENOTAZIONE EFFETTUATA");
      }
    }

    return success;
  }

  static Future<bool> cancellaAppello(Map infoAppello) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var auth64Cred = prefs.getString("auth64Cred");
    var isSceltaCarriera = prefs.getBool("isSceltaCarriera") ?? false;

    var urlCookie =
        "https://www.esse3.unimore.it/auth/studente/AreaStudente.do";
    var getCookie = await http.get(urlCookie);
    var jsessionCookie = getCookie.headers.values.toList();
    String jsessionid = jsessionCookie.sublist(1, 2).toString();
    List<String> jSession = jsessionid.split(";");
    jsessionid = jSession[0].replaceAll("[JSESSIONID=", "");

    var requestUrl = "https://www.esse3.unimore.it/auth/studente/Appelli/ConfermaCancellaAppello.do;jsessionid=" + jsessionid;
    //var requestUrl = urlCookie + ";jsessionid=" + jsessionid;
    var basicAuth64 = "Basic " + auth64Cred;

    if(isSceltaCarriera){
      var idStud = prefs.getString("idStud");
      requestUrl = requestUrl + idStud;
    }
    //print(infoAppello);
    // final getResponseTmp = await http.get(
    //   requestUrl,
    //   headers: {"Authorization": basicAuth64, "jsessionid": jsessionid},
    // ).catchError((e) {
    //   return null;
    // });
    //
    // dom.Document documentHome = parser.parse(getResponseTmp.body);
    //
    // var sceltaCarriera = documentHome.querySelector("#gu_table_sceltacarriera");
    //
    // if (sceltaCarriera != null) {
    //   return await _isSceltaCarrieraCancellaAppello(
    //       sceltaCarriera, basicAuth64, infoAppello);
    // }
    final response = await http.post(
      requestUrl,
      body: infoAppello,
      headers: {"Authorization": basicAuth64, "JSESSIONID": jsessionid, "origin": "https://www.esse3.unimore.it"},
    ).catchError((e) {
      debugPrint("Errore cancellazione appello: $e");
      return false;
    });

    if(response.statusCode == 302){
      final response2 = await http.post(
        requestUrl,
        body: infoAppello,
        headers: {"Authorization": basicAuth64, "JSESSIONID": jsessionid},
      ).catchError((e) {
        debugPrint("Errore cancellazione appello: $e");
        return false;
      });

      dom.Document document = parser.parse(response2.body);
      //var formHiddens = document.querySelector("#esse3old").querySelector('form').children[0];
      var formHiddens = document.querySelector("#esse3old");
      if(formHiddens == null) return false;

      formHiddens = formHiddens.querySelector('form').children[0];

      Map newBodyRequest = new Map();
      int lenBody = formHiddens.children.length - 1;

      for(int i = 0; i < lenBody; i++){
        newBodyRequest[formHiddens.children[i].attributes["name"]] = formHiddens.children[i].attributes["value"];
      }

      requestUrl = "https://www.esse3.unimore.it/auth/studente/Appelli/CancellaAppello.do;jsessionid=" + jsessionid;

      if(isSceltaCarriera){
        var idStud = prefs.getString("idStud");
        requestUrl = requestUrl + idStud;
      }

      final finalResponse = await http.post(
        requestUrl,
        body: newBodyRequest,
        headers: {"Authorization": basicAuth64, "JSESSIONID": jsessionid},
      ).catchError((e) {
        debugPrint("Errore finalResponse cancellazione apppello: $e");
        return null;
      });

      bool success = finalResponse.statusCode == 302;

      return success;
    } else if (response.statusCode == 200) {
      dom.Document document = parser.parse(response.body);
      //var formHiddens = document.querySelector("#esse3old").querySelector('form').children[0];
      var formHiddens = document.querySelector("#esse3old");
      if(formHiddens == null) return false;

      formHiddens = formHiddens.querySelector('form').children[0];

      Map newBodyRequest = new Map();
      int lenBody = formHiddens.children.length - 1;

      for(int i = 0; i < lenBody; i++){
        newBodyRequest[formHiddens.children[i].attributes["name"]] = formHiddens.children[i].attributes["value"];
      }

      requestUrl = "https://www.esse3.unimore.it/auth/studente/Appelli/CancellaAppello.do;jsessionid=" + jsessionid;

      if(isSceltaCarriera){
        var idStud = prefs.getString("idStud");
        requestUrl = requestUrl + idStud;
      }

      final finalResponse = await http.post(
        requestUrl,
        body: newBodyRequest,
        headers: {"Authorization": basicAuth64, "JSESSIONID": jsessionid},
      ).catchError((e) {
        debugPrint("Errore finalResponse cancellazione apppello: $e");
        return null;
      });

      bool success = finalResponse.statusCode == 302;

      return success;
    } else return false;


  }

//TODO: fare metodo getDatiAnagrafici !!
}
