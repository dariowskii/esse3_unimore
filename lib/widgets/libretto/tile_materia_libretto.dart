import 'package:Esse3/constants.dart';
import 'package:flutter/material.dart';

class TileMateriaLibretto extends StatelessWidget {
  const TileMateriaLibretto({
    Key key,
    @required this.libretto,
    @required this.index,
  })  : assert(libretto != null),
        assert(index != null),
        super(key: key);
  final Map<String, dynamic> libretto;
  final int index;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      child: ListTileTheme(
        dense: true,
        child: IgnorePointer(
          ignoring: libretto['voti'][index] == '',
          child: ExpansionTile(
            key: UniqueKey(),
            trailing:
                libretto['voti'][index] != '' ? null : const SizedBox.shrink(),
            leading: libretto['voti'][index] != ''
                ? Padding(
                    padding: const EdgeInsets.only(right: 0),
                    child: Icon(Icons.star, color: Colors.yellow[700]),
                  )
                : null,
            title: Text(
              libretto['materie'][index] as String,
              style: Constants.fontBold20
                  .copyWith(color: Theme.of(context).primaryColorLight),
            ),
            subtitle: Text(
              'CFU: ${libretto['crediti'][index]}',
              style: Constants.fontBold
                  .copyWith(color: Theme.of(context).textTheme.bodyText1.color),
            ),
            backgroundColor: Theme.of(context).cardColor,
            children: [
              if (libretto['voti'][index] != '')
                Container(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: 'Voto: ',
                          style: Constants.font18.copyWith(
                            color: Theme.of(context).textTheme.bodyText1.color,
                            fontFamily: 'SF Pro',
                          ),
                          children: [
                            TextSpan(
                              text: libretto['voti'][index] as String,
                              style: Constants.fontBold18.copyWith(
                                color:
                                    Theme.of(context).textTheme.bodyText1.color,
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
                            color: Theme.of(context).textTheme.bodyText1.color,
                            fontFamily: 'SF Pro',
                          ),
                          children: [
                            TextSpan(
                              text: libretto['data_esame'][index] as String,
                              style: Constants.fontBold.copyWith(
                                color:
                                    Theme.of(context).textTheme.bodyText1.color,
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
