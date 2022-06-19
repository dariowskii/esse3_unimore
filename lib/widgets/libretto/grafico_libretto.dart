import 'package:Esse3/constants.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class GraficoLibretto extends StatelessWidget {
  static const List<Color> _gradientColorsDark = [Constants.mainColorLighter];
  static const List<Color> _gradientColorsLight = [
    Color(0xff23b6e6),
    Color(0xff02d39a),
  ];
  final bool darkModeOn;
  final List puntiGrafico;

  const GraficoLibretto({
    Key key,
    this.darkModeOn = false,
    @required this.puntiGrafico,
  })  : assert(puntiGrafico != null),
        super(key: key);
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
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
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
                reservedSize: 15,
                getTitlesWidget: (_, __) => const Text(""),
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 15,
                getTitlesWidget: (value, meta) {
                  var val = '';

                  switch (value.toInt()) {
                    case 18:
                      val = '18';
                      break;
                    case 24:
                      val = '24';
                      break;
                    case 30:
                      val = '30';
                  }

                  return Text(
                    val,
                    style: TextStyle(
                      color:
                          darkModeOn ? const Color(0xff67727d) : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                },
              ),
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
                final index = puntiGrafico.indexOf(punto);
                return FlSpot(
                    index.toDouble(), double.parse(punto['voto'].toString()));
              }).toList(),
              isCurved: true,
              gradient: LinearGradient(
                  colors:
                      darkModeOn ? _gradientColorsDark : _gradientColorsLight),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                    colors: darkModeOn
                        ? _gradientColorsDark
                            .map((color) => color.withOpacity(0.3))
                            .toList()
                        : _gradientColorsLight
                            .map((color) => color.withOpacity(0.3))
                            .toList()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
