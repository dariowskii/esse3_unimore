import 'package:Esse3/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class RicaricaBachecaPrenotazioni extends StatelessWidget {
  const RicaricaBachecaPrenotazioni(
      {Key key, @required this.refreshBacheca, @required this.svgAsset})
      : assert(refreshBacheca != null),
        assert(svgAsset != null),
        super(key: key);

  final Future<void> Function() refreshBacheca;
  final SvgPicture svgAsset;

  @override
  Widget build(BuildContext context) {
    return LiquidPullToRefresh(
      animSpeedFactor: 1.5,
      height: 80,
      color: Theme.of(context).primaryColorLight,
      onRefresh: refreshBacheca,
      showChildOpacityTransition: false,
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bacheca prenotazioni',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                ),
                const Divider(),
                const SizedBox(height: 50),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      svgAsset,
                      Constants.sized20H,
                      const Text(
                        'Nessuna prenotazione',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 32),
                      ),
                      Constants.sized10H,
                      const Text(
                        'È tempo di preparare qualche esame e prenotarsi!',
                        softWrap: true,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 20,
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
