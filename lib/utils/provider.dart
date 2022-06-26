import 'dart:convert';

import 'package:Esse3/models/altre_info_appello_model.dart';
import 'package:Esse3/models/appello_model.dart';
import 'package:Esse3/models/appello_prenotato_model.dart';
import 'package:Esse3/models/auth_credential_model.dart';
import 'package:Esse3/models/esame_model.dart';
import 'package:Esse3/models/libretto_model.dart';
import 'package:Esse3/models/studente_model.dart';
import 'package:Esse3/models/tassa_model.dart';
import 'package:Esse3/screens/bacheca_prenotazioni_screen.dart';
import 'package:Esse3/screens/prossimi_appelli_screen.dart';
import 'package:Esse3/utils/shared_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:shared_preferences/shared_preferences.dart';

/// Questa classe effettua lo scraping su esse3.unimore.it
class Provider {
  static const String _urlLoginEsse3 =
      'https://www.esse3.unimore.it/auth/Logon.do';

  static String _shibSessionCookie = "";
  static String get shibSessionCookie => _shibSessionCookie;
  static String _jSessionId = "";
  static String get jSessionId => _jSessionId;
  static void cleanSession() {
    _jSessionId = '';
    _shibSessionCookie = '';
  }

  /// Serve sostanzialmente ad estrarre l'`idStud` per mandare le
  /// request in caso di scelta carriera iniziale.
  static Future<Map<String, dynamic>> _isSceltaCarriera(
      var tableCarriere, Map<String, dynamic> mapInfo) async {
    mapInfo['sceltaCarriera'] = true;

    final tableScelta = tableCarriere.querySelector('.table-1-body');
    if (tableScelta == null) {
      mapInfo['error'] = 'tableScelta not found';
      mapInfo['success'] = false;
      return mapInfo;
    }

    final lengthScelta = tableScelta.children.length as int;

    try {
      for (var i = 0; i < lengthScelta; i++) {
        if (tableScelta.children[i].children[3].text == 'Attivo') {
          var idStud = tableScelta.children[i].children[4].children[0]
              .children[0].attributes['href'] as String;
          idStud = idStud
              .replaceAll('auth/studente/SceltaCarrieraStudente.do', '')
              .replaceAll('?', '?&');

          //Salvo idStud
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isSceltaCarriera', true);
          await prefs.setString('idStud', idStud);

          final newRequestUrl =
              'https://www.esse3.unimore.it/auth/studente/AreaStudente.do;$idStud';
          //Get the response
          http.Response response;
          try {
            response = await http.get(
              Uri.parse(newRequestUrl),
              headers: {
                'cookie': _shibSessionCookie,
              },
            );
          } catch (e) {
            mapInfo['error'] = e;
            mapInfo['success'] = false;
            return mapInfo;
          }

          mapInfo['success'] = response.statusCode == 200;
          if (!(mapInfo['success'] as bool)) {
            mapInfo['error'] =
                'response isSceltaCarriera => ${response.statusCode}: ${response.reasonPhrase}';
            return mapInfo;
          }

          final documentSceltaCarriera = parser.parse(response.body);
          var nomeMatricola = [];

          try {
            nomeMatricola = documentSceltaCarriera
                .querySelector('.pagetitle_title')
                .innerHtml
                .replaceAll('Area Studente ', '')
                .split(' - ');
          } catch (e) {
            mapInfo['error'] = '.pagetitle_title (isSceltaCarriera) not found';
            mapInfo['success'] = false;
            return mapInfo;
          }

          final nomeStudente = nomeMatricola[0];
          final matricolaStudente =
              nomeMatricola[1].replaceFirst('[MAT. ', '').replaceFirst(']', '');

          final info = documentSceltaCarriera.querySelector('.record-riga');
          if (info == null) {
            mapInfo['error'] = '.record-riga (isSceltaCarriera) not found';
            mapInfo['success'] = false;
            return mapInfo;
          }

          final lengthInfo = info.children.length;

          mapInfo['nome'] = nomeStudente;
          var _nomeCompletoCamel = '';
          mapInfo['nome'].split(' ').forEach((str) {
            _nomeCompletoCamel +=
                '${str.toString()[0]}${str.toString().substring(1).toLowerCase()} ';
          });
          mapInfo['nome'] =
              _nomeCompletoCamel.substring(0, _nomeCompletoCamel.length - 1);
          mapInfo['matricola'] = matricolaStudente;
          final bufferNome = nomeStudente.split(' ');
          mapInfo['text_avatar'] =
              '${bufferNome[0].substring(0, 1)}${bufferNome[1].substring(0, 1)}';

          for (var i = 1; i < lengthInfo; i += 2) {
            final index = info.children[i].innerHtml.indexOf('&');
            final key = _getNomeInfo(i);
            if (key == 'part_time') {
              mapInfo[key] = info.children[i].children[0].innerHtml.trim();
            } else {
              mapInfo[key] = info.children[i].innerHtml
                  .replaceRange(
                      index, info.children[i].innerHtml.length - 1, '')
                  .trim();
            }
          }

          //Recupero l'immagine del profilo
          mapInfo['profile_pic'] = await _getProfilePic(documentSceltaCarriera);

          return mapInfo;
        }
      }
    } catch (e) {
      mapInfo['error'] = e;
      mapInfo['success'] = false;
      return mapInfo;
    }

    mapInfo['error'] = 'unknown error (isSceltaCarriera)';
    mapInfo['success'] = false;
    return mapInfo;
  }

  /// Serve ad ottenere le prime informazioni iniziali della home.
  static Future<Map<String, dynamic>> getSession(
      String username, String password) async {
    final escapedPassword = Uri.encodeFull(password);
    final Map<String, dynamic> mapSession = {};
    //Ottengo il cookie di sessione per la request
    final client = http.Client();
    const requestUrl = _urlLoginEsse3;
    try {
      var customRequest = http.Request('HEAD', Uri.parse(requestUrl));
      customRequest.followRedirects = false;
      var streamedResponse = await client.send(customRequest);
      final location = streamedResponse.headers['location'];
      customRequest = http.Request('HEAD', Uri.parse(location));
      streamedResponse = await client.send(customRequest);
      final firstJsessionCookie =
          streamedResponse.headers['set-cookie'].toString().split(';')[0];
      customRequest = http.Request('GET', Uri.parse(location));
      customRequest.headers['cookie'] = firstJsessionCookie;
      streamedResponse = await client.send(customRequest);

      // Mando la POST
      final documentIdp =
          parser.parse(await streamedResponse.stream.bytesToString());
      // Prelevo l'action dal form
      final formAction = documentIdp.querySelector('form').attributes['action'];
      // Creo la request
      final newRequestUrl = 'https://idp.unimore.it$formAction';
      customRequest = http.Request('POST', Uri.parse(newRequestUrl));
      customRequest.headers['cookie'] = firstJsessionCookie;
      customRequest.headers['content-type'] =
          'application/x-www-form-urlencoded';
      customRequest.followRedirects = false;
      customRequest.body =
          'j_username=$username&j_password=$escapedPassword&_eventId_proceed=';
      final responsePost = await client.send(customRequest);
      // Elaboro la prima request
      final documentLogin =
          parser.parse(await responsePost.stream.bytesToString());
      // Ottengo il RelayState
      final relayState = documentLogin
          .querySelector('input[name="RelayState"]')
          .attributes['value'];
      // Ottengo SamlResponse
      final samlResponse = documentLogin
          .querySelector('input[name="SAMLResponse"]')
          .attributes['value'];
      // Ottengo il primo shibStateCookie
      final shibStateCookieLogin =
          '_shibstate_${relayState.replaceFirst('cookie&#x3a;', '')}';

      // Inizio la recondo request per il shibSessionCookie
      // prelevo la prossima action
      final postAction =
          documentLogin.querySelector('form').attributes['action'];
      // Creo la seconda request
      customRequest = http.Request('POST', Uri.parse(postAction));
      customRequest.headers['cookie'] = shibStateCookieLogin;
      customRequest.headers['content-type'] =
          'application/x-www-form-urlencoded';
      customRequest.body = 'RelayState=$relayState&SAMLResponse=$samlResponse'
          .replaceAll('+', '%2B');
      final finalResponse = await client.send(customRequest);
      // Ottengo il cookie
      _shibSessionCookie =
          finalResponse.headers['set-cookie'].toString().split(';')[0];
      // Preparo la request finale per il jSessionId cookie
      customRequest = http.Request('GET', Uri.parse(_urlLoginEsse3));
      customRequest.followRedirects = false;
      customRequest.headers['cookie'] = _shibSessionCookie;
      final jSessionResponse = await client.send(customRequest);
      _jSessionId =
          jSessionResponse.headers['set-cookie'].toString().split(';')[0];
      // Se non riesco ad ottenerli entrambi, la sessione fallisce
      if (_shibSessionCookie.isEmpty || _jSessionId.isEmpty) {
        mapSession['success'] = false;
        mapSession['error'] = 'Non riesco a creare una sessione.';
        return mapSession;
      }
    } catch (e) {
      // In caso di eventuali eccezioni, la sessione fallisce
      mapSession['success'] = false;
      mapSession['error'] = e;
      return mapSession;
    }
    mapSession['success'] = true;
    return mapSession;
  }

  static Future<String> _getProfilePic(dom.Document document) async {
    String photoBase64 = '';
    final fotoUrl =
        document.querySelector('img[alt="Foto Utente"]').attributes['src'];
    http.Response responsePhoto;
    try {
      responsePhoto = await http.get(
        Uri.parse('https://www.esse3.unimore.it/$fotoUrl'),
        headers: {
          'cookie': _shibSessionCookie,
        },
      );
    } catch (e) {
      debugPrint('Errore response foto profilo getAccess: $e');
      photoBase64 = 'no';
    }

    if (photoBase64 != 'no') {
      return base64Encode(responsePhoto.bodyBytes);
    }

    return photoBase64;
  }

  static Future<Map<String, dynamic>> getHomeInfo() async {
    final authCredential = await SharedWrapper.shared.getUserCreditentials();

    if (_shibSessionCookie.isEmpty) {
      await getSession(authCredential.username, authCredential.password);
    }
    http.Response homeResponse;
    final Map<String, dynamic> mapInfo = {};

    final client = http.Client();

    homeResponse = await client.get(Uri.parse(_urlLoginEsse3), headers: {
      'cookie': _shibSessionCookie,
    });

    final homeBody = homeResponse.body;

    //Scraping home page
    final documentHome = parser.parse(homeBody);

    //Controllo se hai una scelta della carriera da effettuare
    final sceltaCarriera =
        documentHome.querySelector('#gu_table_sceltacarriera');
    if (sceltaCarriera != null) {
      return _isSceltaCarriera(sceltaCarriera, mapInfo);
    }

    //Recupero l'immagine del profilo
    mapInfo['profile_pic'] = await _getProfilePic(documentHome);

    var scrapingNomeMatricola = <String>[];
    try {
      scrapingNomeMatricola = documentHome
          .querySelector('.pagetitle_title')
          .innerHtml
          .replaceAll('&nbsp;', ' ')
          .replaceFirst('Benvenuto', '')
          .replaceFirst(')', '')
          .split('(');
    } catch (e) {
      mapInfo['error'] = '.pagetitle_title not found';
      mapInfo['success'] = false;
      return mapInfo;
    }

    // debugPrint('respose: ${response.body}');
    assert(scrapingNomeMatricola.length == 2);

    final studente = StudenteModel()..fromHtmlBody(document: documentHome);

    final nomeStudente = scrapingNomeMatricola[0].trim();
    final matricolaStudente =
        scrapingNomeMatricola[1].replaceFirst('Matricola N. ', '');

    final info = documentHome.querySelector('.record-riga');
    if (info == null) {
      mapInfo['error'] = '.record-riga not found';
      mapInfo['success'] = false;
      return mapInfo;
    }
    final lengthInfo = info.children.length;

    mapInfo['nome'] = nomeStudente;
    var _nomeCompletoCamel = '';
    nomeStudente.split(' ').forEach((str) {
      _nomeCompletoCamel +=
          '${str.substring(0, 2)}${str.substring(2).toLowerCase()} ';
    });
    mapInfo['nome'] =
        _nomeCompletoCamel.substring(0, _nomeCompletoCamel.length - 1);
    mapInfo['matricola'] = matricolaStudente;
    final bufferNome = nomeStudente.split(' ');
    mapInfo['text_avatar'] =
        '${bufferNome[0].substring(0, 2)}${bufferNome[1].substring(0, 2)}';
    mapInfo['username'] = authCredential.username;

    mapInfo['tipo_corso'] = info.children[0].innerHtml;

    //Scraping info
    try {
      for (var i = 1; i < lengthInfo; i += 2) {
        final index = info.children[i].innerHtml.indexOf('&');
        final key = _getNomeInfo(i);
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
    mapInfo['success'] = true;
    return mapInfo;
  }

  /// Aiuta a prelevare le info in [getSession].
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
  static Future<Map<String, dynamic>> getLibretto() async {
    final prefs = await SharedPreferences.getInstance();
    final authCredential = await SharedWrapper.shared.getUserCreditentials();

    if (_shibSessionCookie.isEmpty) {
      await getSession(authCredential.username, authCredential.password);
    }

    final Map<String, dynamic> mapLibretto = {};

    final isSceltaCarriera = prefs.getBool('isSceltaCarriera') ?? false;

    //Libretto
    var requestUrl =
        'https://www.esse3.unimore.it/auth/studente/Libretto/LibrettoHome.do?&menu_opened_cod=menu_link-navbox_studenti_Area_Studente';

    if (isSceltaCarriera) {
      final idStud = prefs.getString('idStud');
      requestUrl = requestUrl + idStud;
    }
    http.Response response;
    try {
      response = await http.get(
        Uri.parse(requestUrl),
        headers: {
          'cookie': _shibSessionCookie,
        },
      );
    } catch (e) {
      debugPrint('Errore richiesta libretto: $e');
      mapLibretto['success'] = false;
      mapLibretto['error'] = e;
      return mapLibretto;
    }

    mapLibretto['success'] = response.statusCode == 200;
    if (!(mapLibretto['success'] as bool)) {
      mapLibretto['error'] =
          '{responseCode: ${response.statusCode}, responseBody: ${response.body}, responseHeader: ${response.headers}';
      return mapLibretto;
    }

    final documentLibretto = parser.parse(response.body);

    final boxMedie = documentLibretto.querySelector('#boxMedie');

    try {
      if (boxMedie != null) {
        mapLibretto['media_arit'] = boxMedie.children[0].children[0].innerHtml
            .split('&nbsp;')[1]
            .replaceFirst(' / 30', '')
            .substring(1);
        mapLibretto['media_pond'] = boxMedie.children[0].children[1].innerHtml
            .split('&nbsp;')[1]
            .replaceFirst(' / 30', '')
            .substring(1);
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
    final lengthLibretto = tableLibretto.children.length;

    //Scraping libretto

    final libretto = LibrettoModel(
      mediaAritmetica: mapLibretto['media_arit'] as String,
      mediaPonderata: mapLibretto['media_pond'] as String,
      esamiTotali: lengthLibretto,
    );

    try {
      for (var i = 0; i < lengthLibretto; i++) {
        final materia =
            tableLibretto.children[i].children[0].children[0].text.split(' - ');
        final codiceEsame = materia[0];
        final nomeEsame = materia[1];

        final crediti =
            int.tryParse(tableLibretto.children[i].children[2].innerHtml) ?? 0;

        final tempVoto = tableLibretto.children[i].children[5].innerHtml;
        String dataEsame = "";
        String altroVoto;
        int votoEsame = 0;
        if (tempVoto != '') {
          final box = tempVoto.split('&nbsp;-&nbsp;');
          dataEsame = box[1];
          libretto.aggiungiCfuAlTotale(cfu: crediti);
          libretto.incrementaEsamiSuperati();
          if ((box[0].contains('30L', 0)) || (box[0].contains('30 L', 0))) {
            votoEsame = 31;
          } else {
            votoEsame = int.tryParse(box[0]) ?? 0;
            altroVoto = box[0];
          }
        }

        final esame = EsameModel(
          nome: nomeEsame,
          codiceEsame: codiceEsame,
          dataEsame: dataEsame,
          crediti: crediti,
          voto: votoEsame,
          altroVoto: altroVoto,
        );

        libretto.esami.add(esame);
      }
      libretto.esami.sort((a, b) => a.esameIdoneo ? 0 : 1);
      mapLibretto['item'] = libretto;
    } catch (e) {
      mapLibretto['success'] = false;
      mapLibretto['error'] = e;
      return mapLibretto;
    }

    return mapLibretto;
  }

  /// Serve a scaricare le informazioni delle tasse per [TasseScreen].
  static Future<Map<String, dynamic>> getTasse() async {
    final prefs = await SharedPreferences.getInstance();
    final authCredential = await SharedWrapper.shared.getUserCreditentials();

    if (_shibSessionCookie.isEmpty) {
      await getSession(authCredential.username, authCredential.password);
    }

    final Map<String, dynamic> mapTasse = {};

    final isSceltaCarriera = prefs.getBool('isSceltaCarriera') ?? false;

    //Tasse
    var requestUrl =
        'https://www.esse3.unimore.it/auth/studente/Tasse/ListaFatture.do;menu_opened_cod=menu_link-navbox_studenti_Area_Studente';

    if (isSceltaCarriera) {
      final idStud = prefs.getString('idStud');
      requestUrl = requestUrl + idStud;
    }
    http.Response response;
    try {
      response = await http.get(
        Uri.parse(requestUrl),
        headers: {
          'cookie': _shibSessionCookie,
        },
      );
    } catch (e) {
      debugPrint('Errore richiesta tasse: $e');
      mapTasse['success'] = false;
      mapTasse['error'] = e;
      return mapTasse;
    }

    mapTasse['success'] = response.statusCode == 200;
    if (!(mapTasse['success'] as bool)) {
      mapTasse['error'] =
          '{responseCode: ${response.statusCode}, responseBody: ${response.body}, responseHeader: ${response.headers}';
      return mapTasse;
    }

    final document = parser.parse(response.body);

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
    final lenghtTasse = tableTasse.children.length;
    mapTasse['da_pagare'] = 0;

    //Scraping tasse
    try {
      final List<TassaModel> tasse = [];

      for (var i = 0; i < lenghtTasse; i++) {
        final descrizioneTassa = tableTasse.children[i].children[3].children[0]
            .children[0].children[1].innerHtml
            .replaceAll('&nbsp;', '')
            .substring(2);

        final scadenza = tableTasse.children[i].children[4].innerHtml;
        final importo = tableTasse.children[i].children[5].innerHtml;
        final tempStatoString = tableTasse.children[i].children[6].innerHtml;

        StatoPagamento stato;

        if (tempStatoString.contains('non')) {
          stato = StatoPagamento.nonPagato;
          mapTasse['da_pagare']++;
        } else if (tempStatoString.contains('pagato')) {
          stato = StatoPagamento.pagato;
        } else if (tempStatoString.contains('pagamen')) {
          stato = StatoPagamento.inAttesa;
        }

        final tassa = TassaModel(
          titolo: descrizioneTassa.length > 30
              ? '${descrizioneTassa.substring(0, 30)}...'
              : descrizioneTassa,
          descrizione: descrizioneTassa,
          importo: importo,
          scadenza: scadenza,
          stato: stato,
        );

        tasse.add(tassa);
      }

      mapTasse['item'] = tasse;
    } catch (e) {
      mapTasse['success'] = false;
      mapTasse['error'] = e;
      return mapTasse;
    }

    return mapTasse;
  }

  /// Serve a scaricare le informazioni dei prossimi appelli per [ProssimiAppelliScreen].
  static Future<Map<String, dynamic>> getAppelli() async {
    final prefs = await SharedPreferences.getInstance();
    final authCredential = await SharedWrapper.shared.getUserCreditentials();

    if (_shibSessionCookie.isEmpty) {
      await getSession(authCredential.username, authCredential.password);
    }

    final Map<String, dynamic> mapAppelli = {};

    final isSceltaCarriera = prefs.getBool('isSceltaCarriera') ?? false;

    var requestUrl =
        'https://www.esse3.unimore.it/auth/studente/Appelli/AppelliF.do;&menu_opened_cod=menu_link-navbox_studenti_Area_Studente';

    if (isSceltaCarriera) {
      final idStud = prefs.getString('idStud');
      requestUrl = requestUrl + idStud;
    }

    http.Response response;
    try {
      response = await http.get(
        Uri.parse(requestUrl),
        headers: {
          'cookie': _shibSessionCookie,
        },
      );
    } catch (e) {
      debugPrint('Errore richiesta appelli: $e');
      mapAppelli['success'] = false;
      mapAppelli['error'] = e;
      return mapAppelli;
    }

    //Appelli
    mapAppelli['success'] = response.statusCode == 200;
    if (!(mapAppelli['success'] as bool)) {
      mapAppelli['error'] =
          '{responseCode: ${response.statusCode}, responseBody: ${response.body}, responseHeader: ${response.headers}';
      return mapAppelli;
    }

    final document = parser.parse(response.body);
    final tableAppelli = document.querySelector('tbody.table-1-body');

    if (tableAppelli == null) {
      mapAppelli['success'] = true;
      mapAppelli['error'] = 'tbody.table-1-body = null';
      mapAppelli['item'] = AppelliWrapper(totaleApelli: 0);
      return mapAppelli;
    }

    final lenghtAppelli = tableAppelli.children.length;

    try {
      final appelliWrapper = AppelliWrapper(totaleApelli: lenghtAppelli);

      for (var i = 0; i < lenghtAppelli; i++) {
        final linkInfo = tableAppelli
            .children[i].children[0].children[0].children[0].attributes['href'];

        final nomeMateria = tableAppelli.children[i].children[1].text;

        final dataAppello =
            tableAppelli.children[i].children[2].text.substring(0, 10);

        final periodoIscrizione = tableAppelli.children[i].children[3].innerHtml
            .replaceAll('<br>', ' - ');

        final descrizione = tableAppelli.children[i].children[4].text;

        final sessione =
            tableAppelli.children[i].children[6].innerHtml.substring(0, 9);

        final appello = AppelloModel(
          nomeMateria: nomeMateria,
          dataAppello: dataAppello,
          periodoIscrizione: periodoIscrizione,
          descrizione: descrizione,
          sessione: sessione,
          linkInfo: linkInfo,
        );

        appelliWrapper.appelli.add(appello);
      }

      mapAppelli['item'] = appelliWrapper;
    } catch (e) {
      mapAppelli['success'] = false;
      mapAppelli['error'] = e;
      return mapAppelli;
    }

    return mapAppelli;
  }

  /// Serve a scaricare le informazioni nascoste dell'appello per poter prenotarsi.
  static Future<Map<String, dynamic>> getInfoAppello(String urlInfo) async {
    final prefs = await SharedPreferences.getInstance();
    final authCredential = await SharedWrapper.shared.getUserCreditentials();

    if (_shibSessionCookie.isEmpty) {
      await getSession(authCredential.username, authCredential.password);
    }

    final Map<String, dynamic> mapInfoAppello = {};

    final isSceltaCarriera = prefs.getBool('isSceltaCarriera') ?? false;

    // ignore: parameter_assignments
    urlInfo = urlInfo.replaceAll(
        'auth/studente/Appelli/DatiPrenotazioneAppello.do?', '');

    //Appelli
    var requestUrl =
        'https://www.esse3.unimore.it/auth/studente/Appelli/DatiPrenotazioneAppello.do;?$urlInfo';

    if (isSceltaCarriera) {
      final idStud = prefs.getString('idStud');
      requestUrl = requestUrl + idStud;
    }
    http.Response response;
    try {
      response = await http.get(
        Uri.parse(requestUrl),
        headers: {
          'cookie': _shibSessionCookie,
        },
      );
    } catch (e) {
      debugPrint('Errore getInfoAppello: $e');
      mapInfoAppello['success'] = false;
      mapInfoAppello['error'] = e;
      return mapInfoAppello;
    }

    mapInfoAppello['success'] = response.statusCode == 200;
    if (!(mapInfoAppello['success'] as bool)) {
      mapInfoAppello['error'] =
          '{responseCode: ${response.statusCode}, responseBody: ${response.body}, responseHeader: ${response.headers}';
      return mapInfoAppello;
    }

    final document = parser.parse(response.body);

    dom.Element tableAppello;
    dom.Element tabellaTurni;
    dom.Element tabellaHidden;

    try {
      tableAppello = document.querySelector('#app-box_dati_pren');
      tabellaHidden = document.querySelector('#app-form_dati_pren').children[6];
      tabellaTurni = document
          .querySelector('#app-tabella_turni')
          .querySelector('.table-1-body');
    } catch (e) {
      mapInfoAppello['success'] = false;
      mapInfoAppello['error'] = e;
      return mapInfoAppello;
    }

    try {
      final altreInfoWrapper =
          AltreInfoAppelloWrapper(numHiddens: tabellaHidden.children.length);

      for (var i = 0; i < altreInfoWrapper.numHiddens; i++) {
        if (i < altreInfoWrapper.numHiddens - 1) {
          final name = tabellaHidden.children[i].id;
          final value = tabellaHidden.children[i].attributes['value'];
          altreInfoWrapper.hiddens[name] = value;
        } else {
          altreInfoWrapper.hiddens['form_id_app-form_dati_pren'] =
              'app-form_dati_pren';
        }
      }

      final tipoEsame = tableAppello.children[1].children[7].text.trim();
      final verbalizzazione = tableAppello.children[1].children[9].text.trim();
      final docente = tableAppello.children[1].children[11].innerHtml
          .replaceAll('<br>', ' ')
          .replaceAll('&nbsp;', '')
          .trim();
      final numIscritti = tabellaTurni.children[0].children[2].text.trim();
      final aula = tabellaTurni.children[0].children[1].text;

      final altreInfo = AltreInfoAppelloModel(
        tipoEsame: tipoEsame,
        verbalizzazione: verbalizzazione,
        docente: docente,
        numIscritti: numIscritti,
        aula: aula,
      );

      altreInfoWrapper.altreInfo = altreInfo;
      mapInfoAppello['item'] = altreInfoWrapper;
    } catch (e) {
      mapInfoAppello['success'] = false;
      mapInfoAppello['error'] = e;
      return mapInfoAppello;
    }

    return mapInfoAppello;
  }

  /// Serve a scaricare la lista degli appelli prenotati per la [BachecaPrenotazioniScreen].
  static Future<Map<String, dynamic>> getAppelliPrenotati() async {
    final prefs = await SharedPreferences.getInstance();
    final authCredential = await SharedWrapper.shared.getUserCreditentials();

    if (_shibSessionCookie.isEmpty) {
      await getSession(authCredential.username, authCredential.password);
    }
    final isSceltaCarriera = prefs.getBool('isSceltaCarriera') ?? false;

    final Map<String, dynamic> mapPrenotati = {};

    var requestUrl =
        'https://www.esse3.unimore.it/auth/studente/Appelli/BachecaPrenotazioni.do;?menu_opened_cod=menu_link-navbox_studenti_Area_Studente';

    if (isSceltaCarriera) {
      final idStud = prefs.getString('idStud');
      requestUrl = requestUrl + idStud;
    }

    http.Response response;
    try {
      response = await http.get(
        Uri.parse(requestUrl),
        headers: {
          'cookie': _shibSessionCookie,
        },
      );
    } catch (e) {
      debugPrint('Errore getAppelliPrenotati: $e');
      mapPrenotati['success'] = false;
      mapPrenotati['error'] = e;
      return mapPrenotati;
    }

    mapPrenotati['success'] = response.statusCode == 200;
    if (!(mapPrenotati['success'] as bool)) {
      mapPrenotati['error'] = 'responseCode: ${response.statusCode}';
      return mapPrenotati;
    }

    final document = parser.parse(response.body);

    final divPrenotati = document.querySelector('#esse3');

    if (divPrenotati == null) {
      mapPrenotati['success'] = false;
      mapPrenotati['error'] = 'div#esse3 not found';
      return mapPrenotati;
    }

    final arrayPrenotati = divPrenotati.querySelectorAll('#boxPrenotazione');
    final arrayAzioni = divPrenotati.querySelectorAll('#toolbarAzioni');

    if (arrayPrenotati == null) {
      mapPrenotati['item'] = AppelliPrenotatiWrapper(appelliTotali: 0);
      return mapPrenotati;
    }

    final lengthPrenotati = arrayPrenotati.length;

    try {
      final appelliPrenotati =
          AppelliPrenotatiWrapper(appelliTotali: lengthPrenotati);
      for (int i = 0; i < lengthPrenotati; i++) {
        final tablePrenotazione =
            arrayPrenotati[i].querySelector('dl.record-riga');

        if (tablePrenotazione == null) {
          break;
        }
        final nomeMateriaFull =
            arrayPrenotati[i].querySelector('h2.record-h2').text;
        final nomeMateria = nomeMateriaFull.split(' [')[0];
        final codiceMateria = "[${nomeMateriaFull.split(' [')[1]}";

        final dataEsame = arrayPrenotati[i]
            .querySelector('dt.app-box_dati_data_esame')
            .innerHtml
            .split('&nbsp;');
        final dataAppello = dataEsame[0];
        final oraAppello = dataEsame[1].trim();

        // Recupero info principali appello
        final arrayInfo = tablePrenotazione.querySelectorAll('dd');
        arrayInfo.removeAt(0);

        final iscrizione = arrayInfo[2]
            .innerHtml
            .replaceFirst('&nbsp;', '')
            .trim()
            .replaceFirst('<br>', '');

        final tipoEsame = arrayInfo[3].innerHtml.split('&nbsp;')[0];

        final svolgimento = arrayInfo[4]
            .innerHtml
            .replaceFirst('&nbsp;', '')
            .trim()
            .replaceFirst('<br>', '');

        final docenti = arrayInfo[10].innerHtml.split('<br>');
        docenti.removeLast();

        final docentiBuffer = StringBuffer();
        for (final docente in docenti) {
          docentiBuffer.write("${docente.replaceFirst('&nbsp;', '')}, ");
        }

        final nomeDocentiComposto =
            docentiBuffer.toString().substring(0, docentiBuffer.length - 3);

        final btnCancella = arrayAzioni[i].querySelector('#btnCancella');
        String linkCancellazione;
        if (btnCancella != null) {
          linkCancellazione = btnCancella.attributes['href'];
        }

        final appello = AppelloPrenotatoModel(
          nomeMateria: nomeMateria,
          codiceEsame: codiceMateria,
          iscrizione: iscrizione,
          tipoEsame: tipoEsame,
          svolgimento: svolgimento,
          dataAppello: dataAppello,
          oraAppello: oraAppello,
          docenti: nomeDocentiComposto,
          linkCancellazione: linkCancellazione,
        );

        appelliPrenotati.appelli.add(appello);
      }
      mapPrenotati['item'] = appelliPrenotati;
    } catch (e) {
      mapPrenotati['success'] = false;
      mapPrenotati['error'] = e;
      return mapPrenotati;
    }
    return mapPrenotati;
  }

  /// Serve a prenotare un appello grazie alle [infoAppello] scaricate da [getInfoAppello].
  static Future<Map<String, dynamic>> prenotaAppello(
      AltreInfoAppelloWrapper altreInfoWrapper) async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    final password = prefs.getString('password');

    if (_shibSessionCookie.isEmpty) {
      await getSession(username, password);
    }

    final Map<String, dynamic> mapHiddens = {};

    final isSceltaCarriera = prefs.getBool('isSceltaCarriera') ?? false;

    var requestUrl =
        'https://www.esse3.unimore.it/auth/studente/Appelli/EffettuaPrenotazioneAppello.do;TIPO_ATTIVITA=1';

    if (isSceltaCarriera) {
      final idStud = prefs.getString('idStud');
      requestUrl = requestUrl + idStud;
    }

    altreInfoWrapper.hiddens['btnSalva'] = "Prenotati all'appello >>";

    http.Response response;
    try {
      response = await http.post(
        Uri.parse(requestUrl),
        body: altreInfoWrapper.hiddens,
        headers: {
          'cookie': _shibSessionCookie,
        },
      );
    } catch (e) {
      debugPrint('Errore prenotazione appello: $e');
      mapHiddens['success'] = false;
      mapHiddens['error'] = e;
      return mapHiddens;
    }

    if (response.statusCode == 302) {
      var location =
          'https://www.esse3.unimore.it${response.headers['location']}';
      if (location.endsWith('TIPO_ATTIVITA=1')) {
        location =
            location.substring(0, location.lastIndexOf('TIPO_ATTIVITA=1'));
      }

      http.Response responseAppello;
      try {
        responseAppello = await http.post(
          Uri.parse(location),
          body: altreInfoWrapper.hiddens,
          headers: {
            'cookie': _shibSessionCookie,
          },
        );
      } catch (e) {
        mapHiddens['success'] = false;
        mapHiddens['error'] = e;
        return mapHiddens;
      }

      mapHiddens['success'] = responseAppello.statusCode == 302;
      if (!(mapHiddens['success'] as bool)) {
        final document = parser.parse(responseAppello.body);
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
              mapHiddens['error_readable'] = mapHiddens['error_readable']
                  .toString()
                  .replaceAll(';', ';\n');
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
  static Future<bool> cancellaAppello(
      Map<String, dynamic> infoAppello, String linkCancellazione) async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    final password = prefs.getString('password');

    if (_shibSessionCookie.isEmpty) {
      await getSession(username, password);
    }

    final client = http.Client();

    final isSceltaCarriera = prefs.getBool('isSceltaCarriera') ?? false;

    var requestUrl = 'https://www.esse3.unimore.it/$linkCancellazione';
    String idStud;

    if (isSceltaCarriera) {
      idStud = prefs.getString('idStud');
      requestUrl = requestUrl + idStud;
    }
    http.StreamedResponse response;

    final customRequest = http.Request('GET', Uri.parse(requestUrl));
    customRequest.followRedirects = true;

    customRequest.headers['cookie'] = _shibSessionCookie;
    customRequest.body = infoAppello.toString();

    try {
      response = await client.send(customRequest);
    } catch (e) {
      debugPrint('Errore cancellazione appello: $e');
      return false;
    }

    final document = parser.parse(await response.stream.bytesToString());

    final form = document.querySelector('form');

    if (form != null) {
      final formHiddens = form.children[2];

      final newBodyRequest = {};
      final lenBody = formHiddens.children.length - 1;

      newBodyRequest['form_id_formCancellazioneAppello'] =
          'formCancellazioneAppello';

      try {
        for (var i = 0; i < lenBody; i++) {
          newBodyRequest[formHiddens.children[i].attributes['name']] =
              formHiddens.children[i].attributes['value'];
        }
      } catch (e) {
        return false;
      }

      final action = form.attributes['action'];

      requestUrl = 'https://www.esse3.unimore.it/$action';

      if (isSceltaCarriera) {
        requestUrl = requestUrl + idStud;
      }

      http.Response finalResponse;
      try {
        finalResponse = await http.post(
          Uri.parse(requestUrl),
          body: newBodyRequest,
          headers: {
            'cookie': _shibSessionCookie,
          },
        );
      } catch (e) {
        debugPrint('Errore finalResponse cancellazione apppello: $e');
        return false;
      }
      return finalResponse.statusCode == 302;
    }
    return false;
  }
}
