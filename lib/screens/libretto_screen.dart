import 'package:Esse3/constants.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// Pagina in cui visualizzare il libretto universitario.
class LibrettoScreen extends StatefulWidget {
  static const id = "librettoScreen";

  /// Map del libretto passatto da [Provider.getLibretto()].
  final Map libretto;

  LibrettoScreen({@required this.libretto});

  @override
  _LibrettoScreenState createState() => _LibrettoScreenState();
}

class _LibrettoScreenState extends State<LibrettoScreen> {
  double _votoLaurea = 0;
  int _cfu = 0;

  List<Color> _gradientColorsDark = [Constants.mainColorLighter];
  List<Color> _gradientColorsLight = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a),
  ];
  List<Map<String, dynamic>> puntiGrafico = [];

  void _initGrafico() {
    for (int i = 0; i < widget.libretto["totali"]; i++) {
      String voto = widget.libretto["voti"][i];
      if (voto != "") {
        _cfu += int.parse(widget.libretto["crediti"][i]);
        if (int.tryParse(voto) != null || voto == "30 LODE") {
          if (voto == "30 LODE") voto = "30";
          puntiGrafico.add({
            "voto": int.parse(voto),
            "data": widget.libretto["data_esame"][i]
          });
        }
      }
    }
    puntiGrafico.sort((a, b) {
      var ad = a["data"].toString().substring(6) +
          "-" +
          a["data"].toString().substring(3, 5) +
          "-" +
          a["data"].toString().substring(0, 2);
      var bd = b["data"].toString().substring(6) +
          "-" +
          b["data"].toString().substring(3, 5) +
          "-" +
          b["data"].toString().substring(0, 2);
      return ad.compareTo(bd);
    });
    if (puntiGrafico.length >= 8) puntiGrafico = puntiGrafico.sublist(0, 8);
  }

  @override
  void initState() {
    super.initState();
    _initGrafico();
    double media = double.tryParse(widget.libretto["media_pond"].toString());
    _votoLaurea = media != null ? ((media * 110) / 30) : 0;
  }

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    bool darkModeOn = Theme.of(context).brightness == Brightness.dark;
    bool isTablet = deviceWidth > Constants.tabletWidth;
    return Scaffold(
      appBar: AppBar(
        title: Text("Esse3"),
        centerTitle: true,
        backgroundColor: darkModeOn
            ? Theme.of(context).cardColor
            : Constants.mainColorLighter,
      ),
      body: Theme(
        data: Theme.of(context)
            .copyWith(accentColor: Theme.of(context).primaryColorLight),
        child: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                overflow: Overflow.visible,
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.vertical(bottom: Radius.circular(20)),
                      color: darkModeOn
                          ? Theme.of(context).cardColor
                          : Constants.mainColorLighter,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 16.0, right: 16, top: 16, bottom: 36),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Libretto",
                            style: Constants.fontBold32.copyWith(
                                color: darkModeOn
                                    ? Theme.of(context).primaryColorLight
                                    : Colors.white),
                          ),
                          Text(
                            "Qui puoi vedere il tuo libretto universitario.",
                            style: darkModeOn
                                ? Constants.font16
                                : Constants.font16
                                    .copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: 20),
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    puntiGrafico.length == 1
                                        ? "Il tuo ultimo esame"
                                        : puntiGrafico.length == 0
                                            ? "Nessun esame con voto ancora"
                                            : "I tuoi ultimi ${puntiGrafico.length} esami",
                                    style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        fontSize: 12,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              AspectRatio(
                                aspectRatio: 3,
                                child: LineChart(
                                  LineChartData(
                                    gridData: FlGridData(
                                      show: true,
                                      drawVerticalLine: true,
                                      getDrawingHorizontalLine: (value) {
                                        return FlLine(
                                          color: Colors.white,
                                          strokeWidth: .3,
                                        );
                                      },
                                      getDrawingVerticalLine: (value) {
                                        return FlLine(
                                          color: Colors.white,
                                          strokeWidth: .1,
                                        );
                                      },
                                    ),
                                    titlesData: FlTitlesData(
                                      show: true,
                                      bottomTitles: SideTitles(
                                        showTitles: false,
                                        reservedSize: 15,
                                        getTextStyles: (value) => TextStyle(
                                            color: darkModeOn
                                                ? Color(0xff68737d)
                                                : Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10),
                                        getTitles: (value) {
                                          return '';
                                        },
                                      ),
                                      leftTitles: SideTitles(
                                        showTitles: true,
                                        getTextStyles: (value) => TextStyle(
                                          color: darkModeOn
                                              ? Color(0xff67727d)
                                              : Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                        reservedSize: 15,
                                        getTitles: (value) {
                                          switch (value.toInt()) {
                                            case 18:
                                              return '18';
                                            case 24:
                                              return '24';
                                            case 30:
                                              return '30';
                                          }
                                          return '';
                                        },
                                      ),
                                    ),
                                    borderData: FlBorderData(
                                      show: false,
                                    ),
                                    minX: 0,
                                    maxX: puntiGrafico.length.toDouble() - 1,
                                    minY: 18,
                                    maxY: 30,
                                    lineBarsData: [
                                      LineChartBarData(
                                        spots: puntiGrafico.map((punto) {
                                          var index =
                                              puntiGrafico.indexOf(punto);
                                          return FlSpot(index.toDouble(),
                                              punto["voto"].toDouble());
                                        }).toList(),
                                        isCurved: true,
                                        colors: darkModeOn
                                            ? _gradientColorsDark
                                            : _gradientColorsLight,
                                        barWidth: 3,
                                        isStrokeCapRound: true,
                                        dotData: FlDotData(
                                          show: true,
                                        ),
                                        belowBarData: BarAreaData(
                                          show: true,
                                          colors: darkModeOn
                                              ? _gradientColorsDark
                                                  .map((color) =>
                                                      color.withOpacity(0.3))
                                                  .toList()
                                              : _gradientColorsLight
                                                  .map((color) =>
                                                      color.withOpacity(0.3))
                                                  .toList(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: (widget.libretto["media_pond"] >= 24) ? -22 : -20,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: widget.libretto["media_pond"] >= 24
                            ? Colors.yellow[700]
                            : widget.libretto["media_pond"] >= 18
                                ? Colors.green[700]
                                : Colors.yellow[700],
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                        boxShadow: [
                          BoxShadow(
                            color: widget.libretto["media_pond"] >= 24
                                ? Colors.black12
                                : Colors.transparent,
                            offset: Offset.zero,
                            blurRadius: 10,
                            spreadRadius: 3,
                          ),
                        ],
                        border: Border.all(
                            color: (widget.libretto["media_pond"] >= 24)
                                ? Colors.white
                                : Colors.transparent,
                            width:
                                (widget.libretto["media_pond"] >= 24) ? 2 : 0),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                              widget.libretto["media_pond"] >= 24
                                  ? Icons.stars
                                  : widget.libretto["media_pond"] >= 18
                                      ? Icons.check_circle
                                      : Icons.warning,
                              color: Colors.white),
                          const SizedBox(width: 5),
                          Text(
                            widget.libretto["media_pond"] >= 24
                                ? "fantastico!".toUpperCase()
                                : widget.libretto["media_pond"] >= 18
                                    ? "vai così".toUpperCase()
                                    : "attenzione".toUpperCase(),
                            style: Constants.fontBold
                                .copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: isTablet
                    ? EdgeInsets.symmetric(
                        horizontal: deviceWidth / 6, vertical: 32)
                    : EdgeInsets.only(
                        left: 16.0, right: 16, bottom: 16, top: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Il tuo andamento",
                      style: Constants.fontBold20,
                    ),
                    Divider(),
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
                                    text: "Media Aritmetica: ",
                                    style: Constants.font16.copyWith(
                                      fontFamily: "SF Pro",
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyText1
                                          .color,
                                    ),
                                    children: [
                                      TextSpan(
                                          text: widget.libretto["media_arit"]
                                              .toString(),
                                          style: Constants.fontBold20)
                                    ],
                                  ),
                                ),
                                RichText(
                                  text: TextSpan(
                                    text: "Media Ponderata: ",
                                    style: Constants.font16.copyWith(
                                      fontFamily: "SF Pro",
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyText1
                                          .color,
                                    ),
                                    children: [
                                      TextSpan(
                                          text: widget.libretto["media_pond"]
                                              .toString(),
                                          style: Constants.fontBold20)
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        .color,
                                    width: 2),
                              ),
                              child: RichText(
                                text: TextSpan(
                                    text: "CFU: ",
                                    style: Constants.font20.copyWith(
                                      fontFamily: "SF Pro",
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyText1
                                          .color,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: _cfu.toString(),
                                        style: Constants.fontBold,
                                      )
                                    ]),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Text(
                          "Voto di Laurea: ",
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
                                        color:
                                            Theme.of(context).primaryColorLight,
                                        width: 2),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20)),
                                    color: Colors.transparent,
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 4),
                                    child: LayoutBuilder(
                                      builder: (BuildContext context,
                                          BoxConstraints constraints) {
                                        return Container(
                                          height: 22,
                                          width: _votoLaurea > 72
                                              ? (constraints.maxWidth / 44) *
                                                  (44 - (110 - _votoLaurea))
                                              : 56,
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .primaryColorLight,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20)),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8),
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: AnimatedOpacity(
                                                duration: Duration(seconds: 2),
                                                curve: Curves.decelerate,
                                                opacity: 1,
                                                child: Text(
                                                  _votoLaurea == 0
                                                      ? "NaN"
                                                      : _votoLaurea
                                                          .toStringAsPrecision(
                                                              4),
                                                  style: Constants.fontBold
                                                      .copyWith(
                                                          color: Colors.white),
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
                                  "66",
                                  style:
                                      Constants.fontBold.copyWith(fontSize: 13),
                                ),
                                Text(
                                  "110",
                                  style:
                                      Constants.fontBold.copyWith(fontSize: 13),
                                ),
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      cacheExtent: 30,
                      itemCount: widget.libretto["totali"],
                      itemBuilder: (context, index) {
                        return Container(
                          margin: EdgeInsets.only(bottom: 5),
                          child: ListTileTheme(
                            dense: true,
                            child: ExpansionTile(
                              maintainState: true,
                              leading: widget.libretto["voti"][index] != ""
                                  ? Padding(
                                      padding: const EdgeInsets.only(right: 0),
                                      child: Icon(Icons.star,
                                          color: Colors.yellow[700]),
                                    )
                                  : null,
                              title: Text(
                                widget.libretto["materie"][index],
                                style: Constants.fontBold20.copyWith(
                                    color: Theme.of(context).primaryColorLight),
                              ),
                              subtitle: Text(
                                "CFU: ${widget.libretto["crediti"][index]}",
                                style: Constants.fontBold.copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        .color),
                              ),
                              backgroundColor: Theme.of(context).cardColor,
                              children: [
                                widget.libretto["voti"][index] != ""
                                    ? Container(
                                        padding: EdgeInsets.only(
                                            left: 16, right: 16),
                                        width: double.infinity,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            RichText(
                                              text: TextSpan(
                                                text: "Voto: ",
                                                style: Constants.font18
                                                    .copyWith(
                                                        color: Theme.of(context)
                                                            .textTheme
                                                            .bodyText1
                                                            .color,
                                                        fontFamily: "SF Pro"),
                                                children: [
                                                  TextSpan(
                                                    text:
                                                        widget.libretto["voti"]
                                                            [index],
                                                    style: Constants.fontBold18
                                                        .copyWith(
                                                            color: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodyText1
                                                                .color),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            RichText(
                                              text: TextSpan(
                                                text: "Data esame: ",
                                                style: Constants.font16
                                                    .copyWith(
                                                        color: Theme.of(context)
                                                            .textTheme
                                                            .bodyText1
                                                            .color,
                                                        fontFamily: "SF Pro"),
                                                children: [
                                                  TextSpan(
                                                    text: widget.libretto[
                                                        "data_esame"][index],
                                                    style: Constants.fontBold
                                                        .copyWith(
                                                            color: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodyText1
                                                                .color),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                          ],
                                        ),
                                      )
                                    : SizedBox.shrink(),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
