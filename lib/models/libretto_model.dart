import 'package:Esse3/models/esame_model.dart';

class LibrettoModel {
  final String? mediaAritmetica;
  final String? mediaPonderata;
  final int esamiTotali;
  final List<EsameModel> esami = [];

  int _esamiSuperati = 0;
  int _cfuTotali = 0;

  double? get mediaAritmeticaDouble {
    return double.tryParse(mediaAritmetica!);
  }

  double? get mediaPonderataDouble {
    return double.tryParse(mediaAritmetica!);
  }

  int get esamiSuperati => _esamiSuperati;
  int get cfuTotali => _cfuTotali;

  void aggiungiCfuAlTotale({required int cfu}) {
    if (cfu > 0) {
      _cfuTotali += cfu;
    }
  }

  void incrementaEsamiSuperati() {
    _esamiSuperati++;
  }

  LibrettoModel({
    required this.mediaAritmetica,
    required this.mediaPonderata,
    required this.esamiTotali,
  });
}
