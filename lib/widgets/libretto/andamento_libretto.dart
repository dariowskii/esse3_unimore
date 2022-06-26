import 'package:Esse3/constants.dart';
import 'package:flutter/material.dart';

class AndamentoLibretto extends StatelessWidget {
  final String? mediaAritmetica;
  final String? mediaPonderata;
  final int cfu;
  final double votoLaurea;

  const AndamentoLibretto({
    Key? key,
    required this.mediaAritmetica,
    required this.mediaPonderata,
    required this.cfu,
    required this.votoLaurea,
  })  : assert(cfu != null),
        assert(votoLaurea != null),
        super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Il tuo andamento',
          style: Constants.fontBold20,
        ),
        const Divider(),
        const SizedBox(height: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        text: 'Media Aritmetica: ',
                        style: Constants.font16.copyWith(
                          fontFamily: 'SF Pro',
                          color: Theme.of(context).textTheme.bodyText1!.color,
                        ),
                        children: [
                          TextSpan(
                              text: mediaAritmetica,
                              style: Constants.fontBold20)
                        ],
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        text: 'Media Ponderata: ',
                        style: Constants.font16.copyWith(
                          fontFamily: 'SF Pro',
                          color: Theme.of(context).textTheme.bodyText1!.color,
                        ),
                        children: [
                          TextSpan(
                              text: mediaPonderata, style: Constants.fontBold20)
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                        color: Theme.of(context).textTheme.bodyText1!.color!,
                        width: 2),
                  ),
                  child: RichText(
                    text: TextSpan(
                        text: 'CFU: ',
                        style: Constants.font20.copyWith(
                          fontFamily: 'SF Pro',
                          color: Theme.of(context).textTheme.bodyText1!.color,
                        ),
                        children: [
                          TextSpan(
                            text: cfu.toString(),
                            style: Constants.fontBold,
                          )
                        ]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            const Text(
              'Voto di Laurea: ',
              style: Constants.font16,
            ),
            const SizedBox(height: 10),
            Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Container(
                      height: 30,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: Theme.of(context).primaryColorLight,
                            width: 2),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20)),
                        color: Colors.transparent,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: LayoutBuilder(
                          builder: (BuildContext context,
                              BoxConstraints constraints) {
                            return Container(
                              height: 22,
                              width: votoLaurea > 72
                                  ? (constraints.maxWidth / 44) *
                                      (44 - (110 - votoLaurea))
                                  : 56,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColorLight,
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(20)),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: AnimatedOpacity(
                                    duration: const Duration(seconds: 2),
                                    curve: Curves.decelerate,
                                    opacity: 1,
                                    child: Text(
                                      votoLaurea == 0
                                          ? 'NaN'
                                          : votoLaurea.toStringAsPrecision(4),
                                      style: Constants.fontBold
                                          .copyWith(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '66',
                      style: Constants.fontBold.copyWith(fontSize: 13),
                    ),
                    Text(
                      '110',
                      style: Constants.fontBold.copyWith(fontSize: 13),
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ],
    );
  }
}
