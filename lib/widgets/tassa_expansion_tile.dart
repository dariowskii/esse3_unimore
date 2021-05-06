import 'package:Esse3/constants.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter/material.dart';

/// Widget rappresentativo della tassa visualizzata in [TasseScreen].
class TassaExpansionTile extends StatefulWidget {
  final String descTassa;
  final String importo;
  final String scadenza;
  final String stato;
  final bool darkModeOn;

  const TassaExpansionTile(
      {Key key,
      this.descTassa,
      this.importo,
      this.scadenza,
      this.stato,
      this.darkModeOn})
      : super(key: key);

  @override
  _TassaExpansionTileState createState() => _TassaExpansionTileState();
}

class _TassaExpansionTileState extends State<TassaExpansionTile> {
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
          accentColor: widget.stato == 'IN ATTESA'
              ? Colors.yellow[700]
              : widget.stato == 'NON PAGATO'
                  ? Colors.redAccent
                  : Theme.of(context).textTheme.bodyText1.color),
      child: ExpansionTile(
        maintainState: true,
        backgroundColor: Theme.of(context).cardColor,
        leading: widget.stato == 'NON PAGATO'
            ? Icon(Icons.error, color: Colors.redAccent)
            : widget.stato == 'IN ATTESA'
                ? Icon(Icons.help, color: Colors.yellow[700])
                : null,
        childrenPadding: EdgeInsets.only(bottom: 16, left: 16, right: 16),
        tilePadding: EdgeInsets.symmetric(vertical: 5, horizontal: 16),
        title: Text(
          widget.descTassa.substring(0, 30) + '...',
          style: Constants.fontBold20.copyWith(
            fontFamily: 'SF Pro',
          ),
        ),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
                text: 'Descrizione: ',
                style: Constants.fontBold.copyWith(
                    color: Theme.of(context).textTheme.bodyText1.color,
                    fontFamily: 'SF Pro'),
                children: [
                  TextSpan(
                      text: widget.descTassa,
                      style: Constants.font14
                          .copyWith(fontWeight: FontWeight.normal))
                ]),
          ),
          const SizedBox(height: 15),
          RichText(
            text: TextSpan(
                text: 'Importo: ',
                style: Constants.font18.copyWith(
                    color: Theme.of(context).textTheme.bodyText1.color,
                    fontFamily: 'SF Pro'),
                children: [
                  TextSpan(text: widget.importo, style: Constants.fontBold18)
                ]),
          ),
          const SizedBox(height: 5),
          RichText(
            text: TextSpan(
                text: 'Scadenza: ',
                style: Constants.font18.copyWith(
                    color: Theme.of(context).textTheme.bodyText1.color,
                    fontFamily: 'SF Pro'),
                children: [
                  TextSpan(text: widget.scadenza, style: Constants.fontBold18)
                ]),
          ),
          const SizedBox(height: 5),
          RichText(
            text: TextSpan(
                text: 'Stato: ',
                style: Constants.font18.copyWith(
                    color: Theme.of(context).textTheme.bodyText1.color,
                    fontFamily: 'SF Pro'),
                children: [
                  TextSpan(text: widget.stato, style: Constants.fontBold18)
                ]),
          ),
          widget.stato == 'NON PAGATO'
              ? Column(
                  children: [
                    const SizedBox(height: 15),
                    MaterialButton(
                      minWidth: double.infinity,
                      disabledColor: Theme.of(context).disabledColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                      ),
                      color: Colors.redAccent,
                      textColor: Colors.white,
                      onPressed: () {
                        final event = Event(
                          title:
                              'Pagare ${widget.descTassa.substring(0, 30)}... entro il ${widget.scadenza}!',
                          description: 'Non dimenticarti di pagare la tassa!',
                          location: 'Esse3',
                          startDate: DateTime.parse(
                                  widget.scadenza.substring(6) +
                                      widget.scadenza.substring(3, 5) +
                                      widget.scadenza.substring(0, 2))
                              .subtract(Duration(days: 7))
                              .add(Duration(hours: 10)),
                          endDate: DateTime.parse(widget.scadenza.substring(6) +
                                  widget.scadenza.substring(3, 5) +
                                  widget.scadenza.substring(0, 2))
                              .subtract(Duration(days: 6)),
                        );
                        Add2Calendar.addEvent2Cal(event);
                      },
                      child: Text('AGGIUNGI PROMEMORIA'),
                    ),
                  ],
                )
              : SizedBox.shrink(),
        ],
      ),
    );
  }
}
