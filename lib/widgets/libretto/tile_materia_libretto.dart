import 'package:Esse3/constants.dart';
import 'package:Esse3/models/esame_model.dart';
import 'package:flutter/material.dart';

class TileMateriaLibretto extends StatelessWidget {
  final EsameModel esame;

  const TileMateriaLibretto({
    Key? key,
    required this.esame,
  })  : assert(esame != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      child: ListTileTheme(
        dense: true,
        child: IgnorePointer(
          ignoring: !esame.esameIdoneo,
          child: ExpansionTile(
            iconColor: Theme.of(context).textTheme.bodyText1!.color,
            trailing: esame.esameIdoneo ? null : const SizedBox.shrink(),
            leading: esame.esameIdoneo
                ? Padding(
                    padding: EdgeInsets.zero,
                    child: Icon(Icons.star, color: Colors.yellow[700]),
                  )
                : null,
            title: Text(
              esame.nome,
              style: Constants.fontBold20
                  .copyWith(color: Theme.of(context).primaryColorLight),
            ),
            subtitle: Text(
              'CFU: ${esame.crediti}',
              style: Constants.fontBold
                  .copyWith(color: Theme.of(context).textTheme.bodyText1!.color),
            ),
            backgroundColor: Theme.of(context).cardColor,
            children: [
              if (esame.esameIdoneo)
                Container(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  width: double.maxFinite,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: 'Voto: ',
                          style: Constants.font18.copyWith(
                            color: Theme.of(context).textTheme.bodyText1!.color,
                            fontFamily: 'SF Pro',
                          ),
                          children: [
                            TextSpan(
                              text: "${esame.altroVoto ?? esame.voto}",
                              style: Constants.fontBold18.copyWith(
                                color:
                                    Theme.of(context).textTheme.bodyText1!.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 5),
                      RichText(
                        text: TextSpan(
                          text: 'Data esame: ',
                          style: Constants.font16.copyWith(
                            color: Theme.of(context).textTheme.bodyText1!.color,
                            fontFamily: 'SF Pro',
                          ),
                          children: [
                            TextSpan(
                              text: esame.dataEsame,
                              style: Constants.fontBold.copyWith(
                                color:
                                    Theme.of(context).textTheme.bodyText1!.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                )
              else
                const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
