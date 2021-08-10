import 'package:Esse3/constants.dart';
import 'package:Esse3/models/tassa_model.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter/material.dart';

/// Widget rappresentativo della tassa visualizzata in [TasseScreen].
class TassaExpansionTile extends StatelessWidget {
  final bool darkModeOn;
  final TassaModel tassa;
  String _statoPagamento;
  Color _themeColor;
  Icon _icon;

  TassaExpansionTile({
    Key key,
    @required this.tassa,
    @required this.darkModeOn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (tassa.stato) {
      case StatoPagamento.nonPagato:
        _statoPagamento = "NON PAGATO";
        _themeColor = Colors.redAccent;
        _icon = const Icon(Icons.error, color: Colors.redAccent);
        break;
      case StatoPagamento.inAttesa:
        _statoPagamento = "IN ATTESA";
        _themeColor = Colors.yellow[700];
        _icon = Icon(Icons.help, color: _themeColor);
        break;
      case StatoPagamento.pagato:
        _statoPagamento = "PAGATO";
        _themeColor = Colors.lightGreen;
        break;
    }

    final _textColor = Theme.of(context).textTheme.bodyText1.color;

    return Theme(
      data: Theme.of(context).copyWith(
        accentColor: _themeColor,
      ),
      child: ExpansionTile(
        maintainState: true,
        backgroundColor: Theme.of(context).cardColor,
        leading: _icon,
        childrenPadding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
        tilePadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
        title: Text(
          tassa.titolo,
          style: Constants.fontBold20.copyWith(
            fontFamily: 'SF Pro',
          ),
        ),
        textColor: _themeColor,
        iconColor: _themeColor,
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        expandedAlignment: Alignment.centerLeft,
        children: [
          RichText(
            text: TextSpan(
                text: 'Descrizione: ',
                style: Constants.fontBold
                    .copyWith(color: _textColor, fontFamily: 'SF Pro'),
                children: [
                  TextSpan(
                      text: tassa.descrizione,
                      style: Constants.font14
                          .copyWith(fontWeight: FontWeight.normal))
                ]),
          ),
          const SizedBox(height: 15),
          RichText(
            text: TextSpan(
                text: 'Importo: ',
                style: Constants.font18
                    .copyWith(color: _textColor, fontFamily: 'SF Pro'),
                children: [
                  TextSpan(text: tassa.importo, style: Constants.fontBold18)
                ]),
          ),
          const SizedBox(height: 5),
          RichText(
            text: TextSpan(
                text: 'Scadenza: ',
                style: Constants.font18
                    .copyWith(color: _textColor, fontFamily: 'SF Pro'),
                children: [
                  TextSpan(text: tassa.scadenza, style: Constants.fontBold18)
                ]),
          ),
          const SizedBox(height: 5),
          RichText(
            text: TextSpan(
                text: 'Stato: ',
                style: Constants.font18
                    .copyWith(color: _textColor, fontFamily: 'SF Pro'),
                children: [
                  TextSpan(text: _statoPagamento, style: Constants.fontBold18)
                ]),
          ),
          if (tassa.stato == StatoPagamento.nonPagato)
            _PromemoriaTassa(tassa: tassa),
        ],
      ),
    );
  }
}

class _PromemoriaTassa extends StatelessWidget {
  const _PromemoriaTassa({Key key, @required this.tassa}) : super(key: key);

  final TassaModel tassa;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 15),
        MaterialButton(
          minWidth: double.infinity,
          disabledColor: Theme.of(context).disabledColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(30)),
          ),
          color: Colors.redAccent,
          textColor: Colors.white,
          onPressed: () {
            final event = Event(
              title: 'Pagare ${tassa.titolo} entro il ${tassa.scadenza}!',
              description: 'Non dimenticarti di pagare la tassa!',
              location: 'Esse3',
              startDate: DateTime.parse(tassa.scadenza.substring(6) +
                      tassa.scadenza.substring(3, 5) +
                      tassa.scadenza.substring(0, 2))
                  .subtract(const Duration(days: 7))
                  .add(const Duration(hours: 10)),
              endDate: DateTime.parse(tassa.scadenza.substring(6) +
                      tassa.scadenza.substring(3, 5) +
                      tassa.scadenza.substring(0, 2))
                  .subtract(const Duration(days: 6)),
            );
            Add2Calendar.addEvent2Cal(event);
          },
          child: const Text('AGGIUNGI PROMEMORIA'),
        ),
      ],
    );
  }
}
