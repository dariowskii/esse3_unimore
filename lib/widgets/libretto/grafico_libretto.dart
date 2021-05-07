import 'package:Esse3/constants.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class GraficoLibretto extends StatelessWidget {
  static const List<Color> _gradientColorsDark = [Constants.mainColorLighter];
  static final List<Color> _gradientColorsLight = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a),
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
            bottomTitles: SideTitles(
              showTitles: false,
              reservedSize: 15,
              getTextStyles: (value) => TextStyle(
                  color: darkModeOn ? const Color(0xff68737d) : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 10),
              getTitles: (value) {
                return '';
              },
            ),
            leftTitles: SideTitles(
              showTitles: true,
              getTextStyles: (value) => TextStyle(
                color: darkModeOn ? const Color(0xff67727d) : Colors.white,
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
                final index = puntiGrafico.indexOf(punto);
                return FlSpot(
                    index.toDouble(), double.parse(punto['voto'].toString()));
              }).toList(),
              isCurved: true,
              colors: darkModeOn ? _gradientColorsDark : _gradientColorsLight,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
              ),
              belowBarData: BarAreaData(
                show: true,
                colors: darkModeOn
                    ? _gradientColorsDark
                        .map((color) => color.withOpacity(0.3))
                        .toList()
                    : _gradientColorsLight
                        .map((color) => color.withOpacity(0.3))
                        .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
