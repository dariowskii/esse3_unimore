import 'dart:convert';
import 'dart:typed_data';

import 'package:Esse3/constants.dart';
import 'package:Esse3/extensions/string_extension.dart';
import 'package:Esse3/models/residenza_studente.dart';
import 'package:Esse3/utils/interfaces/codable.dart';
import 'package:html/dom.dart';

class DatiPersonaliStudente extends Codable {
  static String get sharedKey => 'datiPersonaliStudente';

  String? _nomeCompleto;
  String? _matricola;
  ResidenzaStudente? _residenza;
  ResidenzaStudente? _domicilio;
  String? _emailPersonale;
  String? _emailAteneo;
  String? _profilePicture;

  String? get nomeCompleto => _nomeCompleto;
  String? get matricola => _matricola;
  ResidenzaStudente? get residenza => _residenza;
  ResidenzaStudente? get domicilio => _domicilio;
  String? get emailPersonale => _emailPersonale;
  String? get emailAteneo => _emailAteneo;
  String? get profilePicture => _profilePicture;

  Uint8List? get profilePictureBytes {
    if (profilePicture != null) {
      return base64Decode(profilePicture!);
    }

    return null;
  }

  String get textAvatar {
    final buffer = _nomeCompleto!.split(' ');
    if (buffer.length > 1) {
      return buffer[0].substring(0, 2) + buffer[1].substring(0, 2);
    }

    return buffer[0].substring(0, 2);
  }

  @override
  void decode(String data) {
    final jsonData = json.decode(data) as Map<String, dynamic>?;
    if (jsonData != null) {
      _nomeCompleto = jsonData['nomeCompleto'] as String?;
      _matricola = jsonData['matricola'] as String?;
      _residenza = ResidenzaStudente()..decode(jsonData['residenza'] as String);
      _domicilio = ResidenzaStudente()..decode(jsonData['domicilio'] as String);
      _emailPersonale = jsonData['emailPersonale'] as String?;
      _emailAteneo = jsonData['emailAteneo'] as String?;
      _profilePicture = jsonData['profilePicture'] as String?;
    }
  }

  @override
  Map<String, dynamic> toJson() => {
        'nomeCompleto': _nomeCompleto,
        'matricola': _matricola,
        'residenza': _residenza?.toJson(),
        'domicilio': _domicilio?.toJson(),
        'emailPersonale': _emailPersonale,
        'emailAteneo': _emailAteneo,
        'profilePicture': _profilePicture,
      };

  @override
  void fromJson(Map<String, dynamic> json) {
    _nomeCompleto = json['nomeCompleto'] as String?;
    _matricola = json['matricola'] as String?;
    final residenza = json['residenza'] as Map<String, dynamic>?;
    if (residenza != null) {
      _residenza = ResidenzaStudente()..fromJson(residenza);
    }
    final domicilio = json['domicilio'] as Map<String, dynamic>?;
    if (domicilio != null) {
      _domicilio = ResidenzaStudente()..fromJson(domicilio);
    }
    _emailPersonale = json['emailPersonale'] as String?;
    _emailAteneo = json['emailAteneo'] as String?;
    _profilePicture = json['profilePicture'] as String?;
  }

  void fromHtmlElement({
    required Element element,
    String? matricola,
    String? profilePicture,
  }) {
    final nomeCognomeElement = element.children
        .firstWhere((element) => element.innerHtml.contains('Nome Cognome'))
        .nextElementSibling;
    _nomeCompleto = _buildNomeCognome(element: nomeCognomeElement);
    _matricola = matricola;

    final residenzaElement = element.children
        .firstWhere((element) => element.innerHtml.contains('Residenza'))
        .nextElementSibling;
    _residenza = _buildResidenza(element: residenzaElement);

    final domicilioElement = element.children
        .firstWhere((element) => element.innerHtml.contains('Domicilio'))
        .nextElementSibling;
    _domicilio = _buildResidenza(element: domicilioElement);

    final emailPersonaleElement = element.children
        .firstWhere((element) => element.innerHtml.contains('E-Mail'))
        .nextElementSibling;
    _emailPersonale = _buildEmail(element: emailPersonaleElement);

    final emailAteneoElement = element.children
        .firstWhere((element) => element.innerHtml.contains('E-Mail di Ateneo'))
        .nextElementSibling;
    _emailAteneo = _buildEmail(element: emailAteneoElement);

    _profilePicture = profilePicture;
  }

  String? _buildNomeCognome({Element? element}) {
    if (element == null) {
      return null;
    }

    final nome = element.innerHtml.cleanFromEntities();

    final alphaRegex = RegExp('[A-Z]{1,}');
    final buffer = <String>[];
    for (final match in alphaRegex.allMatches(nome)) {
      buffer.add(match.group(0)!.toLowerCase().camelCase());
    }

    return buffer.join(' ');
  }

  ResidenzaStudente? _buildResidenza({Element? element}) {
    if (element == null) {
      return null;
    }

    return ResidenzaStudente()..fromHtmlElement(residenza: element);
  }

  String? _buildEmail({Element? element}) {
    if (element == null) {
      return null;
    }

    final buffer = element.innerHtml.split(Constants.emptyHtmlSpecialChar);
    buffer.removeLast();
    return buffer.first;
  }
}
