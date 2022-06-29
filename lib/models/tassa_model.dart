class TassaModel {
  final String titolo;
  final String descrizione;
  final String importo;
  final String scadenza;
  final StatoPagamento? stato;

  TassaModel({
    required this.titolo,
    required this.descrizione,
    required this.importo,
    required this.scadenza,
    required this.stato,
  });
}

enum StatoPagamento { pagato, nonPagato, inAttesa }
