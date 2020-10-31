import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as parser;
import 'package:shared_preferences/shared_preferences.dart';


class Provider {

  static Future<Map> _isSceltaCarrieraAccess(
      var sceltaCarriera, var jsessionid, var basicAuth64, var map_info, var username) async {
    var tableScelta = sceltaCarriera.querySelector(".table-1-body");
    int lengthScelta = tableScelta.children.length;
    for (int i = 0; i < lengthScelta; i++) {
      if (tableScelta.children[i].children[3].text == "Attivo") {
        String idStud = tableScelta.children[i].children[4].children[0].children[0].attributes["href"];
        idStud = idStud.replaceAll("auth/studente/SceltaCarrieraStudente.do", "").replaceAll("?", "?&");
        var newRequestUrl =
            "https://www.esse3.unimore.it/auth/studente/AreaStudente.do;jsessionid=" + jsessionid + idStud;
        //TODO: verificare cosa succede nella request, da li risolvere
        //Get the response
        final response = await http.get(
          newRequestUrl,
          headers: {"Authorization": basicAuth64, "jsessionid": jsessionid},
        ).catchError((e){
          return null;
        });
        map_info["success"] = response.statusCode == 200 ? true : false;
        if (!map_info["success"]) return map_info;

        dom.Document documentTmp = parser.parse(response.body);

        var scrapingNomeMatricola =
            documentTmp.querySelector(".pagetitle_title").innerHtml.replaceAll("Area Studente ", "").split(" - ");
        var nomeStudente = scrapingNomeMatricola[0];
        var matricolaStudente = scrapingNomeMatricola[1].replaceFirst("[MAT. ", "").replaceFirst("]", "");

        var info = documentTmp.querySelector(".record-riga");
        int lengthInfo = info.children.length;

        //Save info home as map

        map_info["nome"] = nomeStudente;
        map_info["matricola"] = matricolaStudente;
        List<String> prov = nomeStudente.split(" ");
        map_info["text_avatar"] = "${prov[0].substring(0, 1)}${prov[1].substring(0, 1)}";
        map_info["username"] = username;

        for (int i = 1; i < lengthInfo; i += 2) {
          int index = info.children[i].innerHtml.indexOf("&");
          String key = getNomeInfo(i);
          if (key == "part_time") {
            map_info[key] = info.children[i].children[0].innerHtml.trim();
          } else {
            map_info[key] =
                info.children[i].innerHtml.replaceRange(index, info.children[i].innerHtml.length - 1, "").trim();
          }
        }

        return map_info;
      }
    }
  }

  static Future<Map> _isSceltaCarrieraLibretto(var sceltaCarriera, var basicAuth64, var map_info) async {
    var tableScelta = sceltaCarriera.querySelector(".table-1-body");
    int lengthScelta = tableScelta.children.length;
    for (int i = 0; i < lengthScelta; i++) {
      if (tableScelta.children[i].children[3].text == "Attivo") {
        var urlCookie = "https://www.esse3.unimore.it/auth/studente/AreaStudente.do";
        var getCookie = await http.get(urlCookie);
        var jsessionCookie = getCookie.headers.values.toList();
        String jsessionid = jsessionCookie.sublist(1, 2).toString();
        List<String> jSession = jsessionid.split(";");
        jsessionid = jSession[0].replaceAll("[JSESSIONID=", "");

        String newUrl = tableScelta.children[i].children[4].children[0].children[0].attributes["href"];
        newUrl = newUrl.replaceAll("auth/studente/SceltaCarrieraStudente.do", "").replaceAll("?", "&");
        var newRequestUrl = "https://www.esse3.unimore.it/auth/studente/Libretto/LibrettoHome.do;jsessionid=" +
            jsessionid +
            "?&menu_opened_cod=menu_link-navbox_studenti_Area_Studente" +
            newUrl;

        //Get the response
        newUrl = newUrl.replaceAll("&stu_id=", "");
        final response = await http.get(
          newRequestUrl,
          headers: {"Authorization": basicAuth64, "jsessionid": jsessionid},
        ).catchError((e){
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
          var materia = tableLibretto.children[i].children[0].children[0].innerHtml.split(" - ");
          map_info["materie"][i] = materia[1];
          map_info["cod_materia"][i] = materia[0];
          map_info["crediti"][i] = tableLibretto.children[i].children[2].innerHtml;
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
                map_info["voti"][i].toString().contains("30 L", 0)) map_info["voti"][i] = "30 LODE";
          } else {
            map_info["data_esame"][i] = "";
          }
        }
        print(map_info["superati"]);
        return map_info;
      }
    }
  }

  static Future<Map> _isSceltaCarrieraProssimiAppelli(var sceltaCarriera, var basicAuth64, var map_info) async {
    var tableScelta = sceltaCarriera.querySelector(".table-1-body");
    int lengthScelta = tableScelta.children.length;
    for (int i = 0; i < lengthScelta; i++) {
      if (tableScelta.children[i].children[3].text == "Attivo") {
        var urlCookie = "https://www.esse3.unimore.it/auth/studente/AreaStudente.do";
        var getCookie = await http.get(urlCookie);
        var jsessionCookie = getCookie.headers.values.toList();
        String jsessionid = jsessionCookie.sublist(1, 2).toString();
        List<String> jSession = jsessionid.split(";");
        jsessionid = jSession[0].replaceAll("[JSESSIONID=", "");

        String newUrl = tableScelta.children[i].children[4].children[0].children[0].attributes["href"];
        newUrl = newUrl.replaceAll("auth/studente/SceltaCarrieraStudente.do", "").replaceAll("?", "&");
        var newRequestUrl = "https://www.esse3.unimore.it/auth/studente/Appelli/AppelliF.do;jsessionid=" +
            jsessionid +
            "?&menu_opened_cod=menu_link-navbox_studenti_Area_Studente" +
            newUrl;

        //Get the response
        newUrl = newUrl.replaceAll("&stu_id=", "");
        final response = await http.get(
          newRequestUrl,
          headers: {"Authorization": basicAuth64, "jsessionid": jsessionid},
        ).catchError((e){
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
          map_info["link_info"][i] = tableAppelli.children[i].children[0].children[0].children[0].attributes["href"];
          map_info["materia"][i] = tableAppelli.children[i].children[1].text;
          map_info["data_appello"][i] = tableAppelli.children[i].children[2].text.substring(0, 10);
          map_info["periodo_iscrizione"][i] = tableAppelli.children[i].children[3].innerHtml.replaceAll("<br>", " - ");
          map_info["desc"][i] = tableAppelli.children[i].children[4].text;
          map_info["sessione"][i] = tableAppelli.children[i].children[5].innerHtml.substring(0, 9);
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
        var urlCookie = "https://www.esse3.unimore.it/auth/studente/AreaStudente.do";
        var getCookie = await http.get(urlCookie);
        var jsessionCookie = getCookie.headers.values.toList();
        String jsessionid = jsessionCookie.sublist(1, 2).toString();
        List<String> jSession = jsessionid.split(";");
        jsessionid = jSession[0].replaceAll("[JSESSIONID=", "");

        String newUrl = tableScelta.children[i].children[4].children[0].children[0].attributes["href"];
        newUrl = newUrl.replaceAll("auth/studente/SceltaCarrieraStudente.do", "").replaceAll("?", "&");
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
        ).catchError((e){
          return null;
        });
        map_info["success"] = response.statusCode == 200 ? true : false;
        if (!map_info["success"]) return map_info;

        dom.Document document = parser.parse(response.body);
        var tableAppello = document.querySelector("#app-box_dati_pren");
        var tabellaTurni = document.querySelector("#app-tabella_turni").querySelector(".table-1-body");

        var map_info_appello = new Map();
        map_info_appello["tipo_esame"] = tableAppello.children[1].children[7].text.trim();
        map_info_appello["verbalizzazione"] = tableAppello.children[1].children[9].text.trim();
        map_info_appello["docente"] =
            tableAppello.children[1].children[11].innerHtml.replaceAll("<br>", " ").replaceAll("&nbsp;", "").trim();
        map_info_appello["num_iscritti"] = tabellaTurni.children[0].children[2].text.trim();
        map_info_appello["aula"] = tabellaTurni.children[0].children[1].text;

        // debugPrint(response.body);
        return map_info_appello;
      }
    }
  }

  static Future<Map> _isSceltaCarrieraTasse(var sceltaCarriera, var basicAuth64, var map_info, var prefs) async {
    var tableScelta = sceltaCarriera.querySelector(".table-1-body");
    int lengthScelta = tableScelta.children.length;
    for (int i = 0; i < lengthScelta; i++) {
      if (tableScelta.children[i].children[3].text == "Attivo") {
        var urlCookie = "https://www.esse3.unimore.it/auth/studente/AreaStudente.do";
        var getCookie = await http.get(urlCookie);
        var jsessionCookie = getCookie.headers.values.toList();
        String jsessionid = jsessionCookie.sublist(1, 2).toString();
        List<String> jSession = jsessionid.split(";");
        jsessionid = jSession[0].replaceAll("[JSESSIONID=", "");

        String newUrl = tableScelta.children[i].children[4].children[0].children[0].attributes["href"];
        newUrl = newUrl.replaceAll("auth/studente/SceltaCarrieraStudente.do", "").replaceAll("?", "&");
        var newRequestUrl = "https://www.esse3.unimore.it/auth/studente/Tasse/ListaFatture.do;jsessionid=" +
            jsessionid +
            "?&menu_opened_cod=menu_link-navbox_studenti_Area_Studente" +
            newUrl;

        //Get the response
        newUrl = newUrl.replaceAll("&stu_id=", "");
        final response = await http.get(
          newRequestUrl,
          headers: {"Authorization": basicAuth64, "jsessionid": jsessionid},
        ).catchError((e){
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
          map_info["desc"][i] = tableTasse.children[i].children[3].children[0].children[0].children[1].innerHtml
              .replaceAll("&nbsp;", "")
              .substring(2);
          map_info["scadenza"][i] = tableTasse.children[i].children[4].innerHtml;
          map_info["importi"][i] = tableTasse.children[i].children[5].innerHtml;
          String buff = tableTasse.children[i].children[6].innerHtml;
          if (buff.contains("non")) {
            map_info["stato_pagamento"][i] = "NON PAGATO";
            map_info["da_pagare"]++;
          } else if (buff.contains("pagato"))
            map_info["stato_pagamento"][i] = "PAGATO";
          else if (buff.contains("pagamen")) map_info["stato_pagamento"][i] = "IN ATTESA";
        }
        return map_info;
      }
    }
  }

  static Future<Map> getAccess(String basicAuth64, String username) async {
    //Grab the cookie for the request
    var urlCookie = "https://www.esse3.unimore.it/auth/studente/AreaStudente.do";
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
    ).catchError((e){
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
      //map_info["scelta_carriera"] = true;
      return await _isSceltaCarrieraAccess(sceltaCarriera, jsessionid, basicAuth64, map_info, username);
    }

    List<String> scrapingNomeMatricola =
        documentHome.querySelector(".pagetitle_title").innerHtml.replaceAll("Area Studente ", "").split(" - ");
    var nomeStudente = scrapingNomeMatricola[0];
    var matricolaStudente = scrapingNomeMatricola[1].replaceFirst("[MAT. ", "").replaceFirst("]", "");

    var info = documentHome.querySelector(".record-riga");
    int lengthInfo = info.children.length;

    //Save info home as map

    map_info["nome"] = nomeStudente;
    map_info["matricola"] = matricolaStudente;
    List<String> prov = nomeStudente.split(" ");
    map_info["text_avatar"] = "${prov[0].substring(0, 1)}${prov[1].substring(0, 1)}";
    map_info["username"] = username;

    for (int i = 1; i < lengthInfo; i += 2) {
      int index = info.children[i].innerHtml.indexOf("&");
      String key = getNomeInfo(i);
      if (key == "part_time") {
        map_info[key] = info.children[i].children[0].innerHtml.trim();
      } else {
        map_info[key] =
            info.children[i].innerHtml.replaceRange(index, info.children[i].innerHtml.length - 1, "").trim();
      }
    }

    return map_info;
  }

  static String getNomeInfo(int n) {
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

    var urlCookie = "https://www.esse3.unimore.it/auth/studente/AreaStudente.do";
    var getCookie = await http.get(urlCookie);
    var jsessionCookie = getCookie.headers.values.toList();
    String jsessionid = jsessionCookie.sublist(1, 2).toString();
    List<String> jSession = jsessionid.split(";");
    jsessionid = jSession[0].replaceAll("[JSESSIONID=", "");

    var requestUrlTmp = urlCookie + ";jsessionid=" + jsessionid;
    var basicAuth64 = "Basic " + auth64Cred;

    final responseTmp = await http.get(
      requestUrlTmp,
      headers: {"Authorization": basicAuth64, "jsessionid": jsessionid},
    ).catchError((e){
      return null;
    });

    var map_libretto = new Map();

    dom.Document documentHome = parser.parse(responseTmp.body);

    var sceltaCarriera = documentHome.querySelector("#gu_table_sceltacarriera");
    //TODO: sceltaCarriera != null
    if (sceltaCarriera != null) {
      //map_info["scelta_carriera"] = true;
      return await _isSceltaCarrieraLibretto(sceltaCarriera, basicAuth64, map_libretto);
    }

    //Libretto
    var requestUrl = "https://www.esse3.unimore.it/auth/studente/Libretto/LibrettoHome.do;jsessionid=" +
        jsessionid +
        "?&menu_opened_cod=menu_link-navbox_studenti_Area_Studente";

    final response = await http.get(
      requestUrl,
      headers: {"Authorization": basicAuth64, "jsessionid": jsessionid},
    ).catchError((e){
      return null;
    });

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
      var materia = tableLibretto.children[i].children[0].children[0].text.split(" - ");
      map_libretto["materie"][i] = materia[1];
      map_libretto["cod_materia"][i] = materia[0];
      map_libretto["crediti"][i] = tableLibretto.children[i].children[2].innerHtml;
      map_libretto["voti"][i] = tableLibretto.children[i].children[5].innerHtml;

      String buff = map_libretto["voti"][i].toString();

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
        } else if (map_libretto["voti"][i].toString().contains("APP", 0)){
          map_libretto["voti"][i] = "APPR";
        }
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

    var urlCookie = "https://www.esse3.unimore.it/auth/studente/AreaStudente.do";
    var getCookie = await http.get(urlCookie);
    var jsessionCookie = getCookie.headers.values.toList();
    String jsessionid = jsessionCookie.sublist(1, 2).toString();
    List<String> jSession = jsessionid.split(";");
    jsessionid = jSession[0].replaceAll("[JSESSIONID=", "");

    var requestUrlTmp = urlCookie + ";jsessionid=" + jsessionid;
    var basicAuth64 = "Basic " + auth64Cred;

    final responseTmp = await http.get(
      requestUrlTmp,
      headers: {"Authorization": basicAuth64, "jsessionid": jsessionid},
    ).catchError((e){
      return null;
    });

    var map_tasse = new Map();

    dom.Document documentHome = parser.parse(responseTmp.body);

    var sceltaCarriera = documentHome.querySelector("#gu_table_sceltacarriera");
    //TODO: sceltaCarriera != null
    if (sceltaCarriera != null) {
      //map_info["scelta_carriera"] = true;
      return await _isSceltaCarrieraTasse(sceltaCarriera, basicAuth64, map_tasse, prefs);
    }

    //Tasse
    var requestUrl = "https://www.esse3.unimore.it/auth/studente/Tasse/ListaFatture.do;jsessionid=" +
        jsessionid +
        "?&menu_opened_cod=menu_link-navbox_studenti_Area_Studente";

    final response = await http.get(
      requestUrl,
      headers: {"Authorization": basicAuth64, "jsessionid": jsessionid},
    ).catchError((e){
      return null;
    });

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
      map_tasse["desc"][i] = tableTasse.children[i].children[3].children[0].children[0].children[1].innerHtml
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
      else if (buff.contains("pagamen")) map_tasse["stato_pagamento"][i] = "IN ATTESA";
    }

    return map_tasse;
  }

  static Future<Map> getAppelli() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var auth64Cred = prefs.getString("auth64Cred");

    var urlCookie = "https://www.esse3.unimore.it/auth/studente/AreaStudente.do";
    var getCookie = await http.get(urlCookie);
    var jsessionCookie = getCookie.headers.values.toList();
    String jsessionid = jsessionCookie.sublist(1, 2).toString();
    List<String> jSession = jsessionid.split(";");
    jsessionid = jSession[0].replaceAll("[JSESSIONID=", "");

    var requestUrlTmp = urlCookie + ";jsessionid=" + jsessionid;
    var basicAuth64 = "Basic " + auth64Cred;

    final responseTmp = await http.get(
      requestUrlTmp,
      headers: {"Authorization": basicAuth64, "jsessionid": jsessionid},
    ).catchError((e){
      return null;
    });

    var map_appelli = new Map();

    dom.Document documentHome = parser.parse(responseTmp.body);

    var sceltaCarriera = documentHome.querySelector("#gu_table_sceltacarriera");
    //TODO: sceltaCarriera != null
    if (sceltaCarriera != null) {
      //map_info["scelta_carriera"] = true;
      return await _isSceltaCarrieraProssimiAppelli(sceltaCarriera, basicAuth64, map_appelli);
    }

    //Appelli
    var requestUrl = "https://www.esse3.unimore.it/auth/studente/Appelli/AppelliF.do;jsessionid=" +
        jsessionid +
        "?&menu_opened_cod=menu_link-navbox_studenti_Area_Studente";

    final response = await http.get(
      requestUrl,
      headers: {"Authorization": basicAuth64, "jsessionid": jsessionid},
    ).catchError((e){
      return null;
    });

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
      map_appelli["link_info"][i] = tableAppelli.children[i].children[0].children[0].children[0].attributes["href"];
      map_appelli["materia"][i] = tableAppelli.children[i].children[1].text;
      map_appelli["data_appello"][i] = tableAppelli.children[i].children[2].text.substring(0, 10);
      map_appelli["periodo_iscrizione"][i] = tableAppelli.children[i].children[3].innerHtml.replaceAll("<br>", " - ");
      map_appelli["desc"][i] = tableAppelli.children[i].children[4].text;
      map_appelli["sessione"][i] = tableAppelli.children[i].children[5].innerHtml.substring(0, 9);
    }

    return map_appelli;
  }

  static Future<Map> getInfoAppello(String urlInfo) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var auth64Cred = prefs.getString("auth64Cred");

    var urlCookie = "https://www.esse3.unimore.it/auth/studente/AreaStudente.do";
    var getCookie = await http.get(urlCookie);
    var jsessionCookie = getCookie.headers.values.toList();
    String jsessionid = jsessionCookie.sublist(1, 2).toString();
    List<String> jSession = jsessionid.split(";");
    jsessionid = jSession[0].replaceAll("[JSESSIONID=", "");

    urlInfo = urlInfo.replaceAll("auth/studente/Appelli/DatiPrenotazioneAppello.do?", "");

    var requestUrlTmp = urlCookie + ";jsessionid=" + jsessionid;
    var basicAuth64 = "Basic " + auth64Cred;

    final responseTmp = await http.get(
      requestUrlTmp,
      headers: {"Authorization": basicAuth64, "jsessionid": jsessionid},
    ).catchError((e){
      return null;
    });

    var map_info_appello = new Map();

    dom.Document documentHome = parser.parse(responseTmp.body);

    var sceltaCarriera = documentHome.querySelector("#gu_table_sceltacarriera");
    //TODO: sceltaCarriera != null
    if (sceltaCarriera != null) {
      //map_info["scelta_carriera"] = true;
      return await _isSceltaCarrieraInfoAppello(sceltaCarriera, basicAuth64, map_info_appello, urlInfo);
    }

    //Appelli
    var requestUrl = "https://www.esse3.unimore.it/auth/studente/Appelli/DatiPrenotazioneAppello.do;jsessionid=" +
        jsessionid +
        "?&" +
        urlInfo;

    final response = await http.get(
      requestUrl,
      headers: {"Authorization": basicAuth64, "jsessionid": jsessionid},
    ).catchError((e){
      return null;
    });

    dom.Document document = parser.parse(response.body);
    var tableAppello = document.querySelector("#app-box_dati_pren");
    var tabellaTurni = document.querySelector("#app-tabella_turni").querySelector(".table-1-body");

    //print(tableAppello.innerHtml);

    map_info_appello["tipo_esame"] = tableAppello.children[1].children[7].text.trim();
    map_info_appello["verbalizzazione"] = tableAppello.children[1].children[9].text.trim();
    map_info_appello["docente"] =
        tableAppello.children[1].children[11].innerHtml.replaceAll("<br>", " ").replaceAll("&nbsp;", "").trim();
    map_info_appello["num_iscritti"] = tabellaTurni.children[0].children[2].text.trim();
    map_info_appello["aula"] = tabellaTurni.children[0].children[1].text;

    // debugPrint(response.body);
    return map_info_appello;
  }

//TODO: fare metodo getDatiAnagrafici !!
}
