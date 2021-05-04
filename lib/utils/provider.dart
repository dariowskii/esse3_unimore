import 'dart:convert';

import 'package:Esse3/screens/bacheca_prenotazioni_screen.dart';
import 'package:Esse3/screens/prossimi_appelli_screen.dart';
import 'package:Esse3/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:shared_preferences/shared_preferences.dart';

/// Questa classe effettua lo scraping su esse3.unimore.it
class Provider {
  static const String _urlJSessionCookie =
      'https://www.esse3.unimore.it/LoginInfo.do?menu_opened_cod=';
  static const String _urlJSessionCookie2 =
      'https://www.esse3.unimore.it/auth/Logon.do';
  static const String _urlShibSession =
      'https://idp.unimore.it/idp/profile/SAML2/Redirect/SSO?execution=e1s1';
  static const String _userAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.128 Safari/537.36';

  /// Serve sostanzialmente ad estrarre l'`idStud` per mandare le
  /// request in caso di scelta carriera iniziale.
  // static Future<Map> _isSceltaCarriera(
  //     var tableCarriere, var jsessionId, var basicAuth64, var mapInfo) async {
  //   mapInfo['sceltaCarriera'] = true;

  //   var tableScelta = tableCarriere.querySelector('.table-1-body');
  //   if (tableScelta == null) {
  //     mapInfo['error'] = 'tableScelta not found';
  //     mapInfo['success'] = false;
  //     return mapInfo as Map;
  //   }

  //   var lengthScelta = tableScelta.children.length as int;

  //   try {
  //     for (var i = 0; i < lengthScelta; i++) {
  //       if (tableScelta.children[i].children[3].text == 'Attivo') {
  //         var idStud = tableScelta.children[i].children[4].children[0]
  //             .children[0].attributes['href'] as String;
  //         idStud = idStud
  //             .replaceAll('auth/studente/SceltaCarrieraStudente.do', '')
  //             .replaceAll('?', '?&');

  //         //Salvo idStud
  //         var prefs = await SharedPreferences.getInstance();
  //         await prefs.setBool('isSceltaCarriera', true);
  //         await prefs.setString('idStud', idStud);

  //         var newRequestUrl =
  //             'https://www.esse3.unimore.it/auth/studente/AreaStudente.do;jsessionid=' +
  //                 jsessionId +
  //                 idStud;
  //         //Get the response
  //         var response;
  //         try {
  //           response = await http.get(
  //             newRequestUrl,
  //             headers: {'Authorization': basicAuth64, 'jsessionid': jsessionId},
  //           );
  //         } catch (e) {
  //           mapInfo['error'] = e;
  //           mapInfo['success'] = false;
  //           return mapInfo;
  //         }
  //         ;

  //         mapInfo['success'] = response.statusCode == 200;
  //         if (!mapInfo['success']) {
  //           mapInfo['error'] =
  //               'response isSceltaCarriera => ${response.statusCode}: ${response.reasonPhrase}';
  //           return mapInfo;
  //         }

  //         var documentTmp = parser.parse(response.body);
  //         var nomeMatricola = [];

  //         try {
  //           nomeMatricola = documentTmp
  //               .querySelector('.pagetitle_title')
  //               .innerHtml
  //               .replaceAll('Area Studente ', '')
  //               .split(' - ');
  //         } catch (e) {
  //           mapInfo['error'] = '.pagetitle_title (isSceltaCarriera) not found';
  //           mapInfo['success'] = false;
  //           return mapInfo;
  //         }

  //         var nomeStudente = nomeMatricola[0];
  //         var matricolaStudente =
  //             nomeMatricola[1].replaceFirst('[MAT. ', '').replaceFirst(']', '');

  //         var info = documentTmp.querySelector('.record-riga');
  //         if (info == null) {
  //           mapInfo['error'] = '.record-riga (isSceltaCarriera) not found';
  //           mapInfo['success'] = false;
  //           return mapInfo;
  //         }

  //         var lengthInfo = info.children.length;

  //         mapInfo['nome'] = nomeStudente;
  //         var _nomeCompletoCamel = '';
  //         mapInfo['nome'].split(' ').forEach((str) {
  //           _nomeCompletoCamel +=
  //               '${str.toString()[0]}${str.toString().substring(1).toLowerCase()} ';
  //         });
  //         mapInfo['nome'] =
  //             _nomeCompletoCamel.substring(0, _nomeCompletoCamel.length - 1);
  //         mapInfo['matricola'] = matricolaStudente;
  //         var bufferNome = nomeStudente.split(' ');
  //         mapInfo['text_avatar'] =
  //             '${bufferNome[0].substring(0, 1)}${bufferNome[1].substring(0, 1)}';

  //         for (var i = 1; i < lengthInfo; i += 2) {
  //           var index = info.children[i].innerHtml.indexOf('&');
  //           var key = _getNomeInfo(i);
  //           if (key == 'part_time') {
  //             mapInfo[key] = info.children[i].children[0].innerHtml.trim();
  //           } else {
  //             mapInfo[key] = info.children[i].innerHtml
  //                 .replaceRange(
  //                     index, info.children[i].innerHtml.length - 1, '')
  //                 .trim();
  //           }
  //         }

  //         //Recupero l'immagine del profilo
  //         mapInfo['profile_pic'] = '';

  //         final responsePhoto = await http.get(
  //           'https://www.esse3.unimore.it/auth/AddressBook/DownloadFoto.do?r=' +
  //               jsessionId.substring(3, 13),
  //           headers: {
  //             'Authorization': basicAuth64,
  //             'cookie': 'JSESSIONID=' + jsessionId
  //           },
  //         ).catchError((e) {
  //           debugPrint('Errore response foto profilo getAccess: $e');
  //           mapInfo['profile_pic'] = 'error';
  //         });

  //         if (mapInfo['profile_pic'] != 'error') {
  //           mapInfo['profile_pic'] = base64Encode(responsePhoto.bodyBytes);
  //         } else {
  //           mapInfo['profile_pic'] = 'no';
  //         }

  //         return mapInfo;
  //       }
  //     }
  //   } catch (e) {
  //     mapInfo['error'] = e;
  //     mapInfo['success'] = false;
  //     return mapInfo;
  //   }

  //   mapInfo['error'] = 'unknown error (isSceltaCarriera)';
  //   mapInfo['success'] = false;
  //   return mapInfo;
  // }

  /// Serve ad ottenere le prime informazioni iniziali della home.
  static Future<Map> getAccess(String username, String password) async {
    var mapInfo = {};
    //Ottengo il cookie di sessione per la request
    final client = http.Client();
    var requestUrl = _urlJSessionCookie2;
    //Ottengo la response
    http.Response homeResponse;
    String homeBody;
    try {
      var customRequest = http.Request('HEAD', Uri.parse(requestUrl));
      customRequest.followRedirects = false;
      var streamedResponse = await client.send(customRequest);
      final shibStateCookie =
          streamedResponse.headers['set-cookie'].toString().split(';')[0];
      final location = streamedResponse.headers['location'];
      customRequest = http.Request('HEAD', Uri.parse(location));
      streamedResponse = await client.send(customRequest);
      final firstJsessionCookie =
          streamedResponse.headers['set-cookie'].toString().split(';')[0];
      customRequest = http.Request('GET', Uri.parse(location));
      customRequest.headers['cookie'] = firstJsessionCookie;
      streamedResponse = await client.send(customRequest);
      // Mando la POST
      var documentIdp =
          parser.parse(await streamedResponse.stream.bytesToString());
      final formAction = documentIdp.querySelector('form').attributes['action'];
      final newRequestUrl = 'https://idp.unimore.it$formAction';
      customRequest = http.Request('POST', Uri.parse(newRequestUrl));
      customRequest.headers['cookie'] = firstJsessionCookie;
      customRequest.headers['content-type'] =
          'application/x-www-form-urlencoded';
      customRequest.followRedirects = false;
      customRequest.body =
          'j_username=$username&j_password=$password&_eventId_proceed=';
      final responsePost = await client.send(customRequest);

      final shibCookieSession =
          responsePost.headers['set-cookie'].toString().split(';')[0];
      var documentLogin =
          parser.parse(await responsePost.stream.bytesToString());
      final relayState = documentLogin
          .querySelector('input[name="RelayState"]')
          .attributes['value'];

      final samlResponse = documentLogin
          .querySelector('input[name="SAMLResponse"]')
          .attributes['value'];
      final postAction =
          documentLogin.querySelector('form').attributes['action'];
      final shibStateCookieLogin =
          '_shibstate_${relayState.replaceFirst('cookie&#x3a;', '')}';

      customRequest = http.Request('POST', Uri.parse(postAction));
      customRequest.headers['cookie'] = shibStateCookieLogin;
      customRequest.headers['content-type'] =
          'application/x-www-form-urlencoded';
      customRequest.body = 'RelayState=$relayState&SAMLResponse=$samlResponse'
          .replaceAll('+', '%2B');
      final finalResponse = await client.send(customRequest);
      final shibSessionCookie =
          finalResponse.headers['set-cookie'].toString().split(';')[0];

      homeResponse = await client.get(Uri.parse(requestUrl), headers: {
        'cookie': shibSessionCookie,
      });
      homeBody = homeResponse.body;
    } on FormatException catch (e) {
      print(e.message);
      print(e.source);

      mapInfo['success'] = false;
      mapInfo['error'] = e;
      return mapInfo;
    }
    mapInfo['success'] = homeResponse.statusCode == 200;
    if (!(mapInfo['success'] as bool)) {
      mapInfo['error'] =
          '{responseCode: ${homeResponse.statusCode}, responseBody: ${homeResponse.body}, responseHeader: ${homeResponse.headers}}';
      return mapInfo;
    }
    //Scraping home page
    var documentHome = parser.parse(homeBody);

    //Controllo se hai una scelta della carriera da effettuare
    // var sceltaCarriera = documentHome.querySelector('#gu_table_sceltacarriera');
    // if (sceltaCarriera != null) {
    //   return await _isSceltaCarriera(
    //       sceltaCarriera, jsessionId, basicAuth64, mapInfo);
    // }

    //Recupero l'immagine del profilo
    mapInfo['profile_pic'] = '';

    // final responsePhoto = await http.get(
    //   'https://www.esse3.unimore.it/auth/AddressBook/DownloadFoto.do?r=' +
    //       jsessionId.substring(3, 13),
    //   headers: {
    //     'Authorization': basicAuth64,
    //     'cookie': 'JSESSIONID=' + jsessionId
    //   },
    // ).catchError((e) {
    //   debugPrint('Errore response foto profilo getAccess: $e');
    //   mapInfo['profile_pic'] = 'error';
    // });

    if (mapInfo['profile_pic'] != 'error') {
      //mapInfo['profile_pic'] = base64Encode(responsePhoto.bodyBytes);
    } else {
      mapInfo['profile_pic'] = 'no';
    }

    var scrapingNomeMatricola = [];
    try {
      scrapingNomeMatricola = documentHome
          .querySelector('.pagetitle_title')
          .innerHtml
          .replaceAll('Area Studente ', '')
          .split(' - ');
    } catch (e) {
      mapInfo['error'] = '.pagetitle_title not found';
      mapInfo['success'] = false;
      return mapInfo;
    }

    // debugPrint('respose: ${response.body}');
    assert(scrapingNomeMatricola.length == 2);

    var nomeStudente = scrapingNomeMatricola[0];
    var matricolaStudente = scrapingNomeMatricola[1]
        .replaceFirst('[MAT. ', '')
        .replaceFirst(']', '');

    var info = documentHome.querySelector('.record-riga');
    if (info == null) {
      mapInfo['error'] = '.record-riga not found';
      mapInfo['success'] = false;
      return mapInfo;
    }
    var lengthInfo = info.children.length;

    mapInfo['nome'] = nomeStudente;
    var _nomeCompletoCamel = '';
    mapInfo['nome'].split(' ').forEach((str) {
      _nomeCompletoCamel +=
          '${str.toString()[0]}${str.toString().substring(1).toLowerCase()} ';
    });
    mapInfo['nome'] =
        _nomeCompletoCamel.substring(0, _nomeCompletoCamel.length - 1);
    mapInfo['matricola'] = matricolaStudente;
    var bufferNome = nomeStudente.split(' ');
    mapInfo['text_avatar'] =
        '${bufferNome[0].substring(0, 1)}${bufferNome[1].substring(0, 1)}';
    mapInfo['username'] = username;

    //Scraping info
    try {
      for (var i = 1; i < lengthInfo; i += 2) {
        var index = info.children[i].innerHtml.indexOf('&');
        var key = _getNomeInfo(i);
        if (key == 'part_time') {
          mapInfo[key] = info.children[i].children[0].innerHtml.trim();
        } else {
          mapInfo[key] = info.children[i].innerHtml
              .replaceRange(index, info.children[i].innerHtml.length - 1, '')
              .trim();
        }
      }
      mapInfo['corso_stud'] = mapInfo['corso_stud'].toString().split(' (')[0];
    } catch (e) {
      mapInfo['error'] = e;
      mapInfo['success'] = false;
      return mapInfo;
    }

    return mapInfo;
  }

  /// Aiuta a prelevare le info in [getAccess].
  static String _getNomeInfo(int n) {
    switch (n) {
      case 1:
        return 'tipo_corso';
      case 3:
        return 'profilo_studente';
      case 5:
        return 'anno_corso';
      case 7:
        return 'data_imm';
      case 9:
        return 'corso_stud';
      case 11:
        return 'ordinamento';
      case 13:
        return 'part_time';
      default:
        return 'null';
    }
  }

  /// Serve a scaricare le informazioni del libretto universitario per [LibrettoScreen].
  static Future<Map> getLibretto() async {
    var prefs = await SharedPreferences.getInstance();
    var basicAuth64 = prefs.getString('auth64Cred');

    var mapLibretto = {};

    if (basicAuth64 == null) {
      mapLibretto['success'] = false;
      mapLibretto['error'] = 'noCredential';
      return mapLibretto;
    }

    var isSceltaCarriera = prefs.getBool('isSceltaCarriera') ?? false;

    var getCookie;
    try {
      getCookie = await http.head(Uri.parse(_urlJSessionCookie));
    } catch (e) {
      mapLibretto['success'] = false;
      mapLibretto['error'] = e;
      return mapLibretto;
    }
    ;

    var jsessionId = '';

    try {
      jsessionId = getCookie.headers['set-cookie']
          .toString()
          .split(';')[0]
          .replaceAll('JSESSIONID=', '');
    } catch (e) {
      mapLibretto['success'] = false;
      mapLibretto['error'] = e;
      return mapLibretto;
    }

    //Libretto
    var requestUrl =
        'https://www.esse3.unimore.it/auth/studente/Libretto/LibrettoHome.do;jsessionid=' +
            jsessionId +
            '?&menu_opened_cod=menu_link-navbox_studenti_Area_Studente';

    if (isSceltaCarriera) {
      var idStud = prefs.getString('idStud');
      requestUrl = requestUrl + idStud;
    }
    var response;
    try {
      response = await http.get(
        Uri.parse(requestUrl),
        headers: {'Authorization': basicAuth64, 'jsessionid': jsessionId},
      );
    } catch (e) {
      debugPrint('Errore richiesta libretto: $e');
      mapLibretto['success'] = false;
      mapLibretto['error'] = e;
      return mapLibretto;
    }
    ;

    mapLibretto['success'] = response.statusCode == 200;
    if (!(mapLibretto['success'] as bool)) {
      mapLibretto['error'] =
          '{responseCode: ${response.statusCode}, responseBody: ${response.body}, responseHeader: ${response.headers}';
      return mapLibretto;
    }

    var documentLibretto = parser.parse(response.body);

    var boxMedie = documentLibretto.querySelector('#boxMedie');

    try {
      if (boxMedie != null) {
        mapLibretto['media_arit'] = boxMedie.children[0].children[0].innerHtml
            .split('&nbsp;​')[1]
            .replaceAll(' / 30', '');
        mapLibretto['media_pond'] = boxMedie.children[0].children[1].innerHtml
            .split('&nbsp;​')[1]
            .replaceAll(' / 30', '');
        mapLibretto['media_arit'] =
            double.tryParse(mapLibretto['media_arit'].toString()) ??
                mapLibretto['media_arit'];
        mapLibretto['media_pond'] =
            double.tryParse(mapLibretto['media_pond'].toString()) ??
                mapLibretto['media_pond'];
      } else {
        mapLibretto['media_arit'] = 'NaN';
        mapLibretto['media_pond'] = 'NaN';
      }
    } catch (e) {
      mapLibretto['success'] = false;
      mapLibretto['error'] = e;
      return mapLibretto;
    }

    var tableLibretto = documentLibretto.querySelector('#tableLibretto');
    if (tableLibretto == null) {
      mapLibretto['success'] = false;
      mapLibretto['error'] = '#tableLibretto = null';
      return mapLibretto;
    }

    tableLibretto = tableLibretto.querySelector('.table-1-body');
    var lengthLibretto = tableLibretto.children.length;

    mapLibretto['materie'] = {};
    mapLibretto['crediti'] = {};
    mapLibretto['voti'] = {};
    mapLibretto['data_esame'] = {};
    mapLibretto['cod_materia'] = {};
    mapLibretto['superati'] = 0;
    mapLibretto['totali'] = lengthLibretto;

    //Scraping libretto
    try {
      for (var i = 0; i < lengthLibretto; i++) {
        var materia =
            tableLibretto.children[i].children[0].children[0].text.split(' - ');
        mapLibretto['cod_materia'][i] = materia[0];
        mapLibretto['materie'][i] = materia[1];
        mapLibretto['crediti'][i] =
            tableLibretto.children[i].children[2].innerHtml;
        mapLibretto['voti'][i] =
            tableLibretto.children[i].children[5].innerHtml;

        if (mapLibretto['voti'][i] != '') {
          var tempVoto = mapLibretto['voti'][i].split('&nbsp;-&nbsp;');
          mapLibretto['voti'][i] = tempVoto[0];
          mapLibretto['data_esame'][i] = tempVoto[1];
          mapLibretto['superati']++;
          if (tempVoto[0].contains('ID', 0) as bool) {
            mapLibretto['voti'][i] = 'IDONEO';
          } else if ((tempVoto[0].contains('30L', 0) as bool) ||
              (tempVoto[0].contains('30 L', 0) as bool)) {
            mapLibretto['voti'][i] = '30 LODE';
          }
        } else {
          mapLibretto['data_esame'][i] = '';
        }
      }
    } catch (e) {
      mapLibretto['success'] = false;
      mapLibretto['error'] = e;
      return mapLibretto;
    }

    return mapLibretto;
  }

  /// Serve a scaricare le informazioni delle tasse per [TasseScreen].
  static Future<Map> getTasse() async {
    var prefs = await SharedPreferences.getInstance();
    var basicAuth64 = prefs.getString('auth64Cred');

    var mapTasse = {};

    if (basicAuth64 == null) {
      mapTasse['success'] = false;
      mapTasse['error'] = 'noCredential';
      return mapTasse;
    }

    var isSceltaCarriera = prefs.getBool('isSceltaCarriera') ?? false;

    var getCookie;
    try {
      getCookie = await http.head(Uri.parse(_urlJSessionCookie));
    } catch (e) {
      mapTasse['success'] = false;
      mapTasse['error'] = e;
      return mapTasse;
    }
    ;

    var jsessionId = '';

    try {
      jsessionId = getCookie.headers['set-cookie']
          .toString()
          .split(';')[0]
          .replaceAll('JSESSIONID=', '');
    } catch (e) {
      mapTasse['success'] = false;
      mapTasse['error'] = e;
      return mapTasse;
    }

    //Tasse
    var requestUrl =
        'https://www.esse3.unimore.it/auth/studente/Tasse/ListaFatture.do;jsessionid=' +
            jsessionId +
            '?&menu_opened_cod=menu_link-navbox_studenti_Area_Studente';

    if (isSceltaCarriera) {
      var idStud = prefs.getString('idStud');
      requestUrl = requestUrl + idStud;
    }
    var response;
    try {
      response = await http.get(
        Uri.parse(requestUrl),
        headers: {'Authorization': basicAuth64, 'jsessionid': jsessionId},
      );
    } catch (e) {
      debugPrint('Errore richiesta tasse: $e');
      mapTasse['success'] = false;
      mapTasse['error'] = e;
      return mapTasse;
    }
    ;

    mapTasse['success'] = response.statusCode == 200;
    if (!(mapTasse['success'] as bool)) {
      mapTasse['error'] =
          '{responseCode: ${response.statusCode}, responseBody: ${response.body}, responseHeader: ${response.headers}';
      return mapTasse;
    }

    var document = parser.parse(response.body);

    var tableTasse = document.querySelector('#tasse-tableFatt');
    if (tableTasse == null) {
      mapTasse['success'] = false;
      mapTasse['error'] = '#tasse-tableFatt = null';
      return mapTasse;
    }
    tableTasse = tableTasse.querySelector('.table-1-body');
    if (tableTasse == null) {
      mapTasse['success'] = false;
      mapTasse['error'] = '.table-1-body = null';
      return mapTasse;
    }
    var lenghtTasse = tableTasse.children.length;

    mapTasse['importi'] = {};
    mapTasse['scadenza'] = {};
    mapTasse['desc'] = {};
    mapTasse['stato_pagamento'] = {};
    mapTasse['totali'] = lenghtTasse;
    mapTasse['da_pagare'] = 0;

    //Scraping tasse
    try {
      for (var i = 0; i < lenghtTasse; i++) {
        mapTasse['desc'][i] = tableTasse.children[i].children[3].children[0]
            .children[0].children[1].innerHtml
            .replaceAll('&nbsp;', '')
            .substring(2);
        mapTasse['scadenza'][i] = tableTasse.children[i].children[4].innerHtml;
        mapTasse['importi'][i] = tableTasse.children[i].children[5].innerHtml;
        var buff = tableTasse.children[i].children[6].innerHtml;
        if (buff.contains('non')) {
          mapTasse['stato_pagamento'][i] = 'NON PAGATO';
          mapTasse['da_pagare']++;
        } else if (buff.contains('pagato')) {
          mapTasse['stato_pagamento'][i] = 'PAGATO';
        } else if (buff.contains('pagamen')) {
          mapTasse['stato_pagamento'][i] = 'IN ATTESA';
        }
      }
    } catch (e) {
      mapTasse['success'] = false;
      mapTasse['error'] = e;
      return mapTasse;
    }

    return mapTasse;
  }

  /// Serve a scaricare le informazioni dei prossimi appelli per [ProssimiAppelliScreen].
  static Future<Map> getAppelli() async {
    var prefs = await SharedPreferences.getInstance();
    var basicAuth64 = prefs.getString('auth64Cred');

    var mapAppelli = {};

    if (basicAuth64 == null) {
      mapAppelli['success'] = false;
      mapAppelli['error'] = 'noCredential';
      return mapAppelli;
    }

    var isSceltaCarriera = prefs.getBool('isSceltaCarriera') ?? false;

    var getCookie;

    try {
      getCookie = await http.head(Uri.parse(_urlJSessionCookie));
    } catch (e) {
      mapAppelli['success'] = false;
      mapAppelli['error'] = e;
      return mapAppelli;
    }
    ;

    var jsessionId = '';

    try {
      jsessionId = getCookie.headers['set-cookie']
          .toString()
          .split(';')[0]
          .replaceAll('JSESSIONID=', '');
    } catch (e) {
      mapAppelli['success'] = false;
      mapAppelli['error'] = e;
      return mapAppelli;
    }

    var requestUrl =
        'https://www.esse3.unimore.it/auth/studente/Appelli/AppelliF.do;jsessionid=' +
            jsessionId +
            '?&menu_opened_cod=menu_link-navbox_studenti_Area_Studente';

    if (isSceltaCarriera) {
      var idStud = prefs.getString('idStud');
      requestUrl = requestUrl + idStud;
    }
    var response;
    try {
      response = await http.get(
        Uri.parse(requestUrl),
        headers: {'Authorization': basicAuth64, 'jsessionid': jsessionId},
      );
    } catch (e) {
      debugPrint('Errore richiesta appelli: $e');
      mapAppelli['success'] = false;
      mapAppelli['error'] = e;
      return mapAppelli;
    }
    ;

    //Appelli
    mapAppelli['success'] = response.statusCode == 200;
    if (!(mapAppelli['success'] as bool)) {
      mapAppelli['error'] =
          '{responseCode: ${response.statusCode}, responseBody: ${response.body}, responseHeader: ${response.headers}';
      return mapAppelli;
    }

    var document = parser.parse(response.body);
    var tableAppelli = document.querySelector('tbody.table-1-body');

    if (tableAppelli == null) {
      mapAppelli['success'] = true;
      mapAppelli['error'] = 'tbody.table-1-body = null';
      mapAppelli['totali'] = 0;
      return mapAppelli;
    }

    var lenghtAppelli = tableAppelli.children.length;
    mapAppelli['totali'] = lenghtAppelli;

    mapAppelli['materia'] = {};
    mapAppelli['data_appello'] = {};
    mapAppelli['periodo_iscrizione'] = {};
    mapAppelli['desc'] = {};
    mapAppelli['sessione'] = {};
    mapAppelli['link_info'] = {};

    try {
      for (var i = 0; i < lenghtAppelli; i++) {
        mapAppelli['link_info'][i] = tableAppelli
            .children[i].children[0].children[0].children[0].attributes['href'];
        mapAppelli['materia'][i] = tableAppelli.children[i].children[1].text;
        mapAppelli['data_appello'][i] =
            tableAppelli.children[i].children[2].text.substring(0, 10);
        mapAppelli['periodo_iscrizione'][i] = tableAppelli
            .children[i].children[3].innerHtml
            .replaceAll('<br>', ' - ');
        mapAppelli['desc'][i] = tableAppelli.children[i].children[4].text;
        mapAppelli['sessione'][i] =
            tableAppelli.children[i].children[6].innerHtml.substring(0, 9);
      }
    } catch (e) {
      mapAppelli['success'] = false;
      mapAppelli['error'] = e;
      return mapAppelli;
    }

    return mapAppelli;
  }

  /// Serve a scaricare le informazioni nascoste dell'appello per poter prenotarsi.
  static Future<Map> getInfoAppello(String urlInfo) async {
    var prefs = await SharedPreferences.getInstance();
    var basicAuth64 = prefs.getString('auth64Cred');

    var mapInfoAppello = {};

    if (basicAuth64 == null) {
      mapInfoAppello['success'] = false;
      mapInfoAppello['error'] = 'noCredential';
      return mapInfoAppello;
    }

    var isSceltaCarriera = prefs.getBool('isSceltaCarriera') ?? false;

    var getCookie;

    try {
      getCookie = await http.head(Uri.parse(_urlJSessionCookie));
    } catch (e) {
      mapInfoAppello['success'] = false;
      mapInfoAppello['error'] = e;
      return mapInfoAppello;
    }

    var jsessionId = '';

    try {
      jsessionId = getCookie.headers['set-cookie']
          .toString()
          .split(';')[0]
          .replaceAll('JSESSIONID=', '');
    } catch (e) {
      mapInfoAppello['success'] = false;
      mapInfoAppello['error'] = e;
      return mapInfoAppello;
    }

    urlInfo = urlInfo.replaceAll(
        'auth/studente/Appelli/DatiPrenotazioneAppello.do?', '');

    //Appelli
    var requestUrl =
        'https://www.esse3.unimore.it/auth/studente/Appelli/DatiPrenotazioneAppello.do;jsessionid=' +
            jsessionId +
            '?&' +
            urlInfo;

    if (isSceltaCarriera) {
      var idStud = prefs.getString('idStud');
      requestUrl = requestUrl + idStud;
    }
    var response;
    try {
      response = await http.get(
        Uri.parse(requestUrl),
        headers: {'Authorization': basicAuth64, 'jsessionid': jsessionId},
      );
    } catch (e) {
      debugPrint('Errore getInfoAppello: $e');
      mapInfoAppello['success'] = false;
      mapInfoAppello['error'] = e;
      return mapInfoAppello;
    }
    ;

    mapInfoAppello['success'] = response.statusCode == 200;
    if (!(mapInfoAppello['success'] as bool)) {
      mapInfoAppello['error'] =
          '{responseCode: ${response.statusCode}, responseBody: ${response.body}, responseHeader: ${response.headers}';
      return mapInfoAppello;
    }

    var document = parser.parse(response.body);

    var tableAppello;
    var tabellaTurni;
    var tabellaHidden;

    try {
      tableAppello = document.querySelector('#app-box_dati_pren');
      tabellaHidden = document.querySelector('#app-form_dati_pren').children[5];
      tabellaTurni = document
          .querySelector('#app-tabella_turni')
          .querySelector('.table-1-body');
    } catch (e) {
      mapInfoAppello['success'] = false;
      mapInfoAppello['error'] = e;
      return mapInfoAppello;
    }

    mapInfoAppello['tabellaHidden'] = true;
    var lunghezzaHidden = tabellaHidden.children.length as int;
    mapInfoAppello['lunghezzaHidden'] = lunghezzaHidden;
    mapInfoAppello['hiddens_name'] = {};
    mapInfoAppello['hiddens_value'] = {};

    try {
      for (var i = 0; i < lunghezzaHidden; i++) {
        if (i < lunghezzaHidden - 1) {
          mapInfoAppello['hiddens_name'][i] = tabellaHidden.children[i].id;
          mapInfoAppello['hiddens_value'][i] =
              tabellaHidden.children[i].attributes['value'];
        } else {
          mapInfoAppello['hiddens_name'][i] = 'form_id_app-form_dati_pren';
          mapInfoAppello['hiddens_value'][i] = 'app-form_dati_pren';
        }
      }
      mapInfoAppello['tipo_esame'] =
          tableAppello.children[1].children[7].text.trim();
      mapInfoAppello['verbalizzazione'] =
          tableAppello.children[1].children[9].text.trim();
      mapInfoAppello['docente'] = tableAppello
          .children[1].children[11].innerHtml
          .replaceAll('<br>', ' ')
          .replaceAll('&nbsp;', '')
          .trim();
      mapInfoAppello['num_iscritti'] =
          tabellaTurni.children[0].children[2].text.trim();
      mapInfoAppello['aula'] = tabellaTurni.children[0].children[1].text;
    } catch (e) {
      mapInfoAppello['success'] = false;
      mapInfoAppello['error'] = e;
      return mapInfoAppello;
    }

    return mapInfoAppello;
  }

  /// Serve a scaricare la lista degli appelli prenotati per la [BachecaPrenotazioniScreen].
  static Future<Map> getAppelliPrenotati() async {
    var prefs = await SharedPreferences.getInstance();
    var basicAuth64 = prefs.getString('auth64Cred');
    var isSceltaCarriera = prefs.getBool('isSceltaCarriera') ?? false;

    var mapPrenotati = {};

    if (basicAuth64 == null) {
      mapPrenotati['success'] = false;
      mapPrenotati['error'] = 'noCredential';
      return mapPrenotati;
    }
    var getCookie;
    try {
      getCookie = await http.head(Uri.parse(_urlJSessionCookie));
    } catch (e) {
      mapPrenotati['success'] = false;
      mapPrenotati['error'] = e;
      return mapPrenotati;
    }
    ;

    var jsessionId = '';

    try {
      jsessionId = getCookie.headers['set-cookie']
          .toString()
          .split(';')[0]
          .replaceAll('JSESSIONID=', '');
    } catch (e) {
      mapPrenotati['success'] = false;
      mapPrenotati['error'] = e;
      return mapPrenotati;
    }

    var requestUrl =
        'https://www.esse3.unimore.it/auth/studente/Appelli/BachecaPrenotazioni.do;jsessionid=' +
            jsessionId +
            '?menu_opened_cod=menu_link-navbox_studenti_Area_Studente';

    if (isSceltaCarriera) {
      var idStud = prefs.getString('idStud');
      requestUrl = requestUrl + idStud;
    }

    var response;
    try {
      response = await http.get(
        Uri.parse(requestUrl),
        headers: {'Authorization': basicAuth64, 'jsessionid': jsessionId},
      );
    } catch (e) {
      debugPrint('Errore getAppelliPrenotati: $e');
      mapPrenotati['success'] = false;
      mapPrenotati['error'] = e;
      return mapPrenotati;
    }
    ;

    mapPrenotati['success'] = response.statusCode == 200;
    if (!(mapPrenotati['success'] as bool)) {
      mapPrenotati['error'] = 'responseCode: ${response.statusCode}';
      return mapPrenotati;
    }

    var document = parser.parse(response.body);

    var divPrenotati = document.querySelector('#esse3old');

    if (divPrenotati == null) {
      mapPrenotati['success'] = false;
      mapPrenotati['error'] = 'div#esse3old not found';
      return mapPrenotati;
    }

    var arrayPrenotati = divPrenotati.querySelectorAll('table.detail_table');

    if (arrayPrenotati == null) {
      mapPrenotati['totali'] = 0;
      return mapPrenotati;
    }

    var lengthPrenotati = arrayPrenotati.length;
    mapPrenotati['totali'] = 0;
    mapPrenotati['esame'] = {};
    mapPrenotati['iscrizione'] = {};
    mapPrenotati['tipo_esame'] = {};
    mapPrenotati['giorno'] = {};
    mapPrenotati['ora'] = {};
    mapPrenotati['docente'] = {};
    mapPrenotati['formHiddens'] = {};

    try {
      for (var i = 0; i < lengthPrenotati; i++) {
        var tablePrenotazione = arrayPrenotati[i].children[0];
        if (tablePrenotazione == null ||
            tablePrenotazione.children.length < 2) {
          break;
        }

        mapPrenotati['esame'][mapPrenotati['totali']] =
            tablePrenotazione.children[0].children[0].text;
        mapPrenotati['iscrizione'][mapPrenotati['totali']] =
            tablePrenotazione.children[2].children[0].text;

        mapPrenotati['tipo_esame'][mapPrenotati['totali']] =
            tablePrenotazione.children[3].children[0].text;

        mapPrenotati['giorno'][mapPrenotati['totali']] =
            tablePrenotazione.children[6].children[0].text;
        mapPrenotati['ora'][mapPrenotati['totali']] =
            tablePrenotazione.children[6].children[1].text;
        mapPrenotati['docente'][mapPrenotati['totali']] =
            tablePrenotazione.children[6].children[6].text;

        var lenHiddens = tablePrenotazione
            .children[6].children[7].children[0].children.length;
        mapPrenotati['lenHiddens'] = lenHiddens - 1;
        var hiddens = tablePrenotazione.children[6].children[7].children[0];
        for (var j = 1; j < lenHiddens; j++) {
          var key = mapPrenotati['totali'].toString() +
              '_' +
              hiddens.children[j].attributes['name'].toString();
          mapPrenotati['formHiddens'][key] =
              hiddens.children[j].attributes['value'];
        }
        mapPrenotati['totali']++;
      }
    } catch (e) {
      print(e);
      mapPrenotati['success'] = false;
      mapPrenotati['error'] = e;
      return mapPrenotati;
    }
    return mapPrenotati;
  }

  /// Serve a prenotare un appello grazie alle [infoAppello] scaricate da [getInfoAppello].
  static Future<Map> prenotaAppello(var infoAppello) async {
    var prefs = await SharedPreferences.getInstance();
    var basicAuth64 = prefs.getString('auth64Cred');

    var mapHiddens = {};

    if (basicAuth64 == null) {
      mapHiddens['success'] = false;
      mapHiddens['error'] = 'noCredential';
      return mapHiddens;
    }

    var isSceltaCarriera = prefs.getBool('isSceltaCarriera') ?? false;

    var getCookie;
    try {
      getCookie = await http.head(Uri.parse(_urlJSessionCookie));
    } catch (e) {
      mapHiddens['success'] = false;
      mapHiddens['error'] = e;
      return mapHiddens;
    }
    ;

    var jsessionId = '';

    try {
      jsessionId = getCookie.headers['set-cookie']
          .toString()
          .split(';')[0]
          .replaceAll('JSESSIONID=', '');
    } catch (e) {
      mapHiddens['success'] = false;
      mapHiddens['error'] = e;
      return mapHiddens;
    }

    var requestUrl =
        'https://www.esse3.unimore.it/auth/studente/Appelli/EffettuaPrenotazioneAppello.do;jsessionid=' +
            jsessionId +
            '?TIPO_ATTIVITA=1';

    if (isSceltaCarriera) {
      var idStud = prefs.getString('idStud');
      requestUrl = requestUrl + idStud;
    }

    var lunghezzaHidden = infoAppello['lunghezzaHidden'] as int;

    for (var i = 0; i < lunghezzaHidden; i++) {
      mapHiddens[infoAppello['hiddens_name'][i]] =
          infoAppello['hiddens_value'][i];
    }

    var response;
    try {
      response = await http.post(
        Uri.parse(requestUrl),
        body: mapHiddens,
        headers: {'Authorization': basicAuth64, 'jsessionid': jsessionId},
      );
    } catch (e) {
      debugPrint('Errore prenotazione appello: $e');
      mapHiddens['success'] = false;
      mapHiddens['error'] = e;
      return mapHiddens;
    }
    ;

    if (response.statusCode == 302) {
      var location =
          'https://www.esse3.unimore.it${response.headers.values.elementAt(2)}';
      if (location.endsWith('TIPO_ATTIVITA=1')) {
        location =
            location.substring(0, location.lastIndexOf('TIPO_ATTIVITA=1'));
      }

      var responseAppello;
      try {
        responseAppello = await http.post(
          Uri.parse(location),
          body: mapHiddens,
          headers: {'Authorization': basicAuth64, 'jsessionid': jsessionId},
        );
      } catch (e) {
        print('error: $e');
        mapHiddens['success'] = false;
        mapHiddens['error'] = e;
        return mapHiddens;
      }
      ;

      mapHiddens['success'] = responseAppello.statusCode == 302;
      if (!(mapHiddens['success'] as bool)) {
        var document = parser.parse(responseAppello.body);
        if (document.querySelector('#app-text_esito_pren_msg') != null) {
          try {
            mapHiddens['success'] = document
                .querySelector('#app-text_esito_pren_msg')
                .text
                .contains('PRENOTAZIONE EFFETTUATA');
          } catch (e) {
            mapHiddens['success'] = false;
            mapHiddens['error'] = e;
            return mapHiddens;
          }

          if (!(mapHiddens['success'] as bool)) {
            try {
              mapHiddens['error'] = document
                  .querySelector('#app-text_esito_pren_msg')
                  .innerHtml
                  .replaceFirst(
                      'PRENOTAZIONE NON EFFETTUATA<br>Questo messaggio può presentarsi se:',
                      '');
              mapHiddens['error'] =
                  mapHiddens['error'].toString().replaceAll(';', ';\n');
            } catch (e) {
              mapHiddens['error'] = e;
            }
          }
        } else {
          mapHiddens['success'] = false;
          mapHiddens['error'] = '#app-text_esito_pren_msg = null';
        }
      }
    } else {
      mapHiddens['success'] = false;
      mapHiddens['error'] = 'responseCode: ${response.statusCode}';
    }

    return mapHiddens;
  }

  /// Serve a cancellare un appello grazie alle [infoAppello] scaricate da [getInfoAppello].
  static Future<bool> cancellaAppello(var infoAppello) async {
    var prefs = await SharedPreferences.getInstance();
    var basicAuth64 = prefs.getString('auth64Cred');
    var isSceltaCarriera = prefs.getBool('isSceltaCarriera') ?? false;

    if (basicAuth64 == null) return false;

    var getCookie;
    try {
      getCookie = await http.head(Uri.parse(_urlJSessionCookie));
    } catch (e) {
      return false;
    }
    ;

    var jsessionId = '';

    try {
      jsessionId = getCookie.headers['set-cookie']
          .toString()
          .split(';')[0]
          .replaceAll('JSESSIONID=', '');
    } catch (e) {
      return false;
    }

    var requestUrl =
        'https://www.esse3.unimore.it/auth/studente/Appelli/ConfermaCancellaAppello.do;jsessionid=' +
            jsessionId;
    String idStud;

    if (isSceltaCarriera) {
      idStud = prefs.getString('idStud');
      requestUrl = requestUrl + idStud;
    }

    var response;
    try {
      response = await http.post(
        Uri.parse(requestUrl),
        body: infoAppello,
        headers: {
          'Authorization': basicAuth64,
          'JSESSIONID': jsessionId,
          'origin': 'https://www.esse3.unimore.it'
        },
      );
    } catch (e) {
      debugPrint('Errore cancellazione appello: $e');
      return false;
    }
    ;

    if (response.statusCode == 302) {
      var response2;
      try {
        response2 = await http.post(
          Uri.parse(requestUrl),
          body: infoAppello,
          headers: {'Authorization': basicAuth64, 'JSESSIONID': jsessionId},
        );
      } catch (e) {
        debugPrint('Errore cancellazione appello: $e');
        return false;
      }
      ;

      var document = parser.parse(response2.body);
      var formHiddens = document.querySelector('#esse3old');
      if (formHiddens == null) return false;

      formHiddens = formHiddens.querySelector('form').children[0];

      var newBodyRequest = {};
      var lenBody = formHiddens.children.length - 1;

      try {
        for (var i = 0; i < lenBody; i++) {
          newBodyRequest[formHiddens.children[i].attributes['name']] =
              formHiddens.children[i].attributes['value'];
        }
      } catch (e) {
        return false;
      }

      requestUrl =
          'https://www.esse3.unimore.it/auth/studente/Appelli/CancellaAppello.do;jsessionid=' +
              jsessionId;

      if (isSceltaCarriera) {
        requestUrl = requestUrl + idStud;
      }

      var finalResponse;
      try {
        finalResponse = await http.post(
          Uri.parse(requestUrl),
          body: newBodyRequest,
          headers: {'Authorization': basicAuth64, 'JSESSIONID': jsessionId},
        );
      } catch (e) {
        debugPrint('Errore finalResponse cancellazione apppello: $e');
        return false;
      }
      ;

      return finalResponse.statusCode == 302;
    } else if (response.statusCode == 200) {
      var document = parser.parse(response.body);
      var formHiddens = document.querySelector('#esse3old');
      if (formHiddens == null) return false;

      formHiddens = formHiddens.querySelector('form').children[0];

      var newBodyRequest = {};
      var lenBody = formHiddens.children.length - 1;

      try {
        for (var i = 0; i < lenBody; i++) {
          newBodyRequest[formHiddens.children[i].attributes['name']] =
              formHiddens.children[i].attributes['value'];
        }
      } catch (e) {
        return false;
      }

      requestUrl =
          'https://www.esse3.unimore.it/auth/studente/Appelli/CancellaAppello.do;jsessionid=' +
              jsessionId;

      if (isSceltaCarriera) {
        requestUrl = requestUrl + idStud;
      }

      var finalResponse;
      try {
        finalResponse = await http.post(
          Uri.parse(requestUrl),
          body: newBodyRequest,
          headers: {'Authorization': basicAuth64, 'jsessionid': jsessionId},
        );
      } catch (e) {
        debugPrint('Errore finalResponse cancellazione apppello: $e');
        return false;
      }
      ;

      return finalResponse.statusCode == 302;
    } else {
      return false;
    }
  }
}
