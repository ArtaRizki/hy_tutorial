import 'dart:developer';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hy_tutorial/common/helper/constant.dart';
import 'package:provider/provider.dart';
import 'package:powers/powers.dart';
import '../../data/provider/data_add_provider.dart';

class BoltChartView extends StatefulWidget {
  BoltChartView({super.key});

  @override
  State<BoltChartView> createState() => _BoltChartViewState();
}

class _BoltChartViewState extends State<BoltChartView> {
  var baselineX = 0.0;
  var baselineY = 0.0;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.95,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
        child: Stack(
          children: [
            _ChartBG(
              baselineX,
              (20 - (baselineY + 10)) - 10,
            ),
            _Chart(
              baselineX,
              (20 - (baselineY + 10)) - 10,
            ),
            _ScatterChartS(
              baselineX,
              (20 - (baselineY + 10)) - 10,
            ),
            _ScatterChart(
              baselineX,
              (20 - (baselineY + 10)) - 10,
            ),
          ],
        ),
      ),
    );
  }
}

class _Chart extends StatelessWidget {
  final double baselineX;
  final double baselineY;

  const _Chart(this.baselineX, this.baselineY) : super();

  Widget getTTitles(value, TitleMeta meta) {
    TextStyle style;
    if ((value - baselineX).abs() <= 0.1) {
      style = const TextStyle(
        color: Color(0xff303030),
        fontSize: 18,
        fontWeight: FontWeight.bold,
      );
    } else {
      style = const TextStyle(
        color: Colors.white,
        fontSize: 14,
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text('B', style: style),
      // child: Text(meta.formattedValue, style: style),
    );
  }

  Widget getBTitles(value, TitleMeta meta) {
    TextStyle style;
    if ((value - baselineX).abs() <= 0.1) {
      style = const TextStyle(
        color: Color(0xff303030),
        fontSize: 18,
        fontWeight: FontWeight.bold,
      );
    } else {
      style = const TextStyle(
        color: Colors.white,
        fontSize: 14,
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text('D', style: style),
      // child: Text(meta.formattedValue, style: style),
    );
  }

  Widget getLTitles(value, TitleMeta meta) {
    TextStyle style;
    if ((value - baselineY).abs() <= 0.1) {
      style = const TextStyle(
        color: Color(0xff303030),
        fontSize: 18,
        fontWeight: FontWeight.bold,
      );
    } else {
      style = const TextStyle(
        color: Colors.white,
        fontSize: 14,
      );
    }

    return Padding(
      padding: const EdgeInsets.only(right: 0),
      child: Text('C', style: style),
      // child: Text(meta.formattedValue, style: style),
    );
  }

  Widget getRTitles(value, TitleMeta meta) {
    TextStyle style;
    if ((value - baselineY).abs() <= 0.1) {
      style = const TextStyle(
        color: Color(0xff303030),
        fontSize: 18,
        fontWeight: FontWeight.bold,
      );
    } else {
      style = const TextStyle(
        color: Colors.white,
        fontSize: 14,
      );
    }

    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 0),
      child: Text('A', style: style),
      // child: Text(meta.formattedValue, style: style),
    );
  }

  FlLine getHorizontalVerticalLine(double value) {
    if ((value - baselineY).abs() <= 0.1) {
      return FlLine(
        color: Color(0xff576778),
        strokeWidth: 2,
        // dashArray: [8, 4],
      );
    } else {
      return FlLine(
        color: Color.fromARGB(176, 230, 231, 233),
        strokeWidth: 1,
        // dashArray: [8, 4],
      );
    }
  }

  FlLine getVerticalVerticalLine(double value) {
    if ((value - baselineX).abs() <= 0.1) {
      return FlLine(
        color: Color(0xff576778),
        strokeWidth: 2,
        // dashArray: [8, 4],
      );
    } else {
      return FlLine(
        color: Color.fromARGB(176, 230, 231, 233),
        strokeWidth: 1,
        // dashArray: [8, 4],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = context.watch<DataAddProvider>();
    // UPPER
    final upper = d.upper;
    final upperCrockedLine = d.upperCrockedLine;
    final listBolts = d.listBolts;
    final listTorqueSuggestions = d.listTorqueSuggestions;

    double getBiggestXY() {
      double upper0 = upper[0];
      double upper1 = upper[1];
      // log("UPPER 0 : $upper0");
      // log("UPPER 1 : $upper1");
      double result = 0;
      if (upper0 < 0) upper0 * (-1);
      if (upper1 < 0) upper1 * (-1);
      if (upper0 <= upper1)
        result = upper1;
      else
        result = upper0;
      // log("BIGGEST XY : $result");
      return result;
    }

    double getBiggestScale(double value) {
      double val = value;
      if (value < 1) {
        val = val * (-1);
      }
      if (val > 0 && val <= 5) val = val;

      if (val > 5 && val <= 10)
        val = val * 10;
      else if (val > 10 /*&& val <= 100*/)
        val = val * (50 * (10.pow(val.toInt().toString().length - 2).toInt()));
      // val = val * 50;
      // else if (val > 100 && val <= 1000)
      //   val = val * 500;
      // else if (val > 1000 && val <= 10000)
      //   val = val * 5000;
      // else if (val > 10000 && val <= 100000)
      //   val = val * 50000;
      // else if (val > 100000 && val <= 1000000)
      //   val = val * 500000;
      // else if (val > 1000000 && val <= 10000000) val = val * 5000000;
      return val + 1;
    }

    // log("GET BIGGEST XY ${getBiggestXY()}");
    // log("GET BIGGEST SCALE ${getBiggestScale(getBiggestXY())}");

    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((LineBarSpot touchedSpot) {
                final textStyle = TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                );
                return LineTooltipItem(
                  '${touchedSpot.x.toStringAsFixed(0)},${touchedSpot.y.toStringAsFixed(0)}',
                  textStyle,
                );
              }).toList();
            },
            tooltipBgColor: Constant.primaryColor,
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            barWidth: 1,
            show: true,
            spots: [
              ...List.generate(
                listBolts.length,
                (index) {
                  return FlSpot(listBolts[index][0], listBolts[index][1]);
                },
              ),
              ...List.generate(
                listBolts.length,
                (index) {
                  return FlSpot(listBolts[index][0], listBolts[index][1]);
                },
              ),
              FlSpot(listBolts[0][0], listBolts[0][1]),
            ],
            isCurved: true,
            curveSmoothness: 0.4,
            belowBarData: BarAreaData(
              show: true,
              spotsLine: BarAreaSpotsLine(show: false),
              color: Constant.primaryColor,
            ),
            color: Constant.primaryColor,
            dotData: FlDotData(show: false),
          ),
          LineChartBarData(
            barWidth: 4,
            show: true,
            spots: [
              FlSpot(upper[0], upper[1]),
              FlSpot(0, 0),
            ],
            isCurved: true,
            belowBarData: BarAreaData(show: false),
            color: Colors.amber,
            dotData: FlDotData(show: true),
          ),
          // LineChartBarData(
          //   barWidth: 4,
          //   show: true,
          //   // isStepLineChart: true,
          //   spots: [
          //     ...List.generate(
          //       listBolts.length,
          //       (index) => FlSpot(listBolts[index][0], listBolts[index][1]),
          //     ),
          //     FlSpot(listBolts[0][0], listBolts[0][1])
          //   ],
          //   isCurved: true,
          //   belowBarData: BarAreaData(show: false),
          //   color: Colors.grey,
          //   dotData: FlDotData(show: true),
          // )
          // GANTI PAKE SCATTER
          // ...List.generate(
          //   listBolts.length,
          //   (index) => LineChartBarData(
          //     barWidth: 4,
          //     show: true,
          //     isCurved: true,
          //     spots: [FlSpot(listBolts[index][0], listBolts[index][1])],
          //     belowBarData: BarAreaData(show: false),
          //     color: Colors.grey,
          //     dotData: FlDotData(show: true),
          //   ),
          // ),
          // LineChartBarData(
          //   barWidth: 2,
          //   show: true,
          //   spots: [
          //     FlSpot(upperCrockedLine, 0),
          //     // FlSpot(0, 0),
          //   ],
          //   belowBarData: BarAreaData(show: false),
          //   color: Colors.red,
          //   dotData: FlDotData(show: true),
          // ),
        ],
        // betweenBarsData: [BetweenBarsData(fromIndex: 0, toIndex: 2)],
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: getLTitles,
              reservedSize: 24,
            ),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: getTTitles,
                reservedSize: 28),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: getRTitles,
              reservedSize: 24,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: getBTitles,
                reservedSize: 24),
          ),
        ),
        borderData: FlBorderData(
            show: true, border: Border.all(color: Color(0xffE6E7E9B0))),
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: false,
          drawVerticalLine: false,
          getDrawingHorizontalLine: getHorizontalVerticalLine,
          getDrawingVerticalLine: getVerticalVerticalLine,
        ),
        // minY: -10,
        // maxY: 10,
        // minX: -10,
        // maxX: 10,
        // minY: -getBiggestScale(getBiggestXY()) - 0.5,
        // maxY: getBiggestScale(getBiggestXY()) + 0.5,
        // minX: -getBiggestScale(getBiggestXY()) - 0.5,
        // maxX: getBiggestScale(getBiggestXY()) + 0.5,
        minY: -getBiggestScale(getBiggestXY()) * 1.4,
        maxY: getBiggestScale(getBiggestXY()) * 1.4,
        minX: -getBiggestScale(getBiggestXY()) * 1.4,
        maxX: getBiggestScale(getBiggestXY()) * 1.4,
        baselineX: baselineX,
        baselineY: baselineY,
      ),
      duration: Duration.zero,
    );
  }
}

class _ChartBG extends StatelessWidget {
  final double baselineX;
  final double baselineY;

  const _ChartBG(this.baselineX, this.baselineY) : super();

  Widget getTTitles(value, TitleMeta meta) {
    TextStyle style;
    if ((value - baselineX).abs() <= 0.1) {
      style = const TextStyle(
        color: Color(0xff303030),
        fontSize: 18,
        fontWeight: FontWeight.bold,
      );
    } else {
      style = const TextStyle(
        color: Colors.white,
        fontSize: 14,
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text('B', style: style),
      // child: Text(meta.formattedValue, style: style),
    );
  }

  Widget getBTitles(value, TitleMeta meta) {
    TextStyle style;
    if ((value - baselineX).abs() <= 0.1) {
      style = const TextStyle(
        color: Color(0xff303030),
        fontSize: 18,
        fontWeight: FontWeight.bold,
      );
    } else {
      style = const TextStyle(
        color: Colors.white,
        fontSize: 14,
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text('D', style: style),
      // child: Text(meta.formattedValue, style: style),
    );
  }

  Widget getLTitles(value, TitleMeta meta) {
    TextStyle style;
    if ((value - baselineY).abs() <= 0.1) {
      style = const TextStyle(
        color: Color(0xff303030),
        fontSize: 18,
        fontWeight: FontWeight.bold,
      );
    } else {
      style = const TextStyle(
        color: Colors.white,
        fontSize: 14,
      );
    }

    return Padding(
      padding: const EdgeInsets.only(right: 0),
      child: Text('C', style: style),
      // child: Text(meta.formattedValue, style: style),
    );
  }

  Widget getRTitles(value, TitleMeta meta) {
    TextStyle style;
    if ((value - baselineY).abs() <= 0.1) {
      style = const TextStyle(
        color: Color(0xff303030),
        fontSize: 18,
        fontWeight: FontWeight.bold,
      );
    } else {
      style = const TextStyle(
        color: Colors.white,
        fontSize: 14,
      );
    }

    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 0),
      child: Text('A', style: style),
      // child: Text(meta.formattedValue, style: style),
    );
  }

  FlLine getHorizontalVerticalLine(double value) {
    if ((value - baselineY).abs() <= 0.1) {
      return FlLine(
        color: Color(0xff576778),
        strokeWidth: 2,
        // dashArray: [8, 4],
      );
    } else {
      return FlLine(
        color: Color.fromARGB(176, 230, 231, 233),
        strokeWidth: 1,
        // dashArray: [8, 4],
      );
    }
  }

  FlLine getVerticalVerticalLine(double value) {
    if ((value - baselineX).abs() <= 0.1) {
      return FlLine(
        color: Color(0xff576778),
        strokeWidth: 2,
        // dashArray: [8, 4],
      );
    } else {
      return FlLine(
        color: Color.fromARGB(176, 230, 231, 233),
        strokeWidth: 1,
        // dashArray: [8, 4],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = context.watch<DataAddProvider>();
    // UPPER
    final upper = d.upper;
    final upperCrockedLine = d.upperCrockedLine;
    final listBolts = d.listBolts;
    final listTorqueSuggestions = d.listTorqueSuggestions;

    double getBiggestXY() {
      double upper0 = upper[0];
      double upper1 = upper[1];
      // log("UPPER 0 : $upper0");
      // log("UPPER 1 : $upper1");
      double result = 0;
      if (upper0 < 0) upper0 * (-1);
      if (upper1 < 0) upper1 * (-1);
      if (upper0 <= upper1)
        result = upper1;
      else
        result = upper0;
      // log("BIGGEST XY : $result");
      return result;
    }

    double getBiggestScale(double value) {
      double val = value;
      if (value < 1) {
        val = val * (-1);
      }
      if (val > 0 && val <= 5) val = val;

      if (val > 5 && val <= 10)
        val = val * 10;
      else if (val > 10 /*&& val <= 100*/)
        val = val * (50 * (10.pow(val.toInt().toString().length - 2).toInt()));
      // val = val * 50;
      // else if (val > 100 && val <= 1000)
      //   val = val * 500;
      // else if (val > 1000 && val <= 10000)
      //   val = val * 5000;
      // else if (val > 10000 && val <= 100000)
      //   val = val * 50000;
      // else if (val > 100000 && val <= 1000000)
      //   val = val * 500000;
      // else if (val > 1000000 && val <= 10000000) val = val * 5000000;
      return val + 1;
    }

    // log("GET BIGGEST XY ${getBiggestXY()}");
    // log("GET BIGGEST SCALE ${getBiggestScale(getBiggestXY())}");

    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((LineBarSpot touchedSpot) {
                final textStyle = TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                );
                return LineTooltipItem(
                  '${touchedSpot.x.toStringAsFixed(0)},${touchedSpot.y.toStringAsFixed(0)}',
                  textStyle,
                );
              }).toList();
            },
            tooltipBgColor: Constant.primaryColor,
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            barWidth: 1,
            show: true,
            spots: [
              ...List.generate(
                listBolts.length,
                (index) {
                  return FlSpot(listBolts[index][0], listBolts[index][1]);
                },
              ),
              ...List.generate(
                listBolts.length,
                (index) {
                  return FlSpot(listBolts[index][0], listBolts[index][1]);
                },
              ),
              FlSpot(listBolts[0][0], listBolts[0][1]),
            ],
            isCurved: true,
            // curveSmoothness: 0.4,
            belowBarData: BarAreaData(
              show: true,
              spotsLine: BarAreaSpotsLine(show: false),
              color: Colors.grey.shade400,
            ),
            color: Colors.grey.shade400,
            dotData: FlDotData(show: false),
          ),
          // LineChartBarData(
          //   barWidth: 4,
          //   show: true,
          //   // isStepLineChart: true,
          //   spots: [
          //     ...List.generate(
          //       listBolts.length,
          //       (index) => FlSpot(listBolts[index][0], listBolts[index][1]),
          //     ),
          //     FlSpot(listBolts[0][0], listBolts[0][1])
          //   ],
          //   isCurved: true,
          //   belowBarData: BarAreaData(show: false),
          //   color: Colors.grey,
          //   dotData: FlDotData(show: true),
          // )
          // GANTI PAKE SCATTER
          // ...List.generate(
          //   listBolts.length,
          //   (index) => LineChartBarData(
          //     barWidth: 4,
          //     show: true,
          //     isCurved: true,
          //     spots: [FlSpot(listBolts[index][0], listBolts[index][1])],
          //     belowBarData: BarAreaData(show: false),
          //     color: Colors.grey,
          //     dotData: FlDotData(show: true),
          //   ),
          // ),
          // LineChartBarData(
          //   barWidth: 2,
          //   show: true,
          //   spots: [
          //     FlSpot(upperCrockedLine, 0),
          //     // FlSpot(0, 0),
          //   ],
          //   belowBarData: BarAreaData(show: false),
          //   color: Colors.red,
          //   dotData: FlDotData(show: true),
          // ),
        ],
        // betweenBarsData: [BetweenBarsData(fromIndex: 0, toIndex: 2)],
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: getLTitles,
              reservedSize: 24,
            ),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: getTTitles,
                reservedSize: 28),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: getRTitles,
              reservedSize: 24,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: getBTitles,
                reservedSize: 24),
          ),
        ),
        borderData: FlBorderData(
            show: true, border: Border.all(color: Color(0xffE6E7E9B0))),
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          drawVerticalLine: true,
          getDrawingHorizontalLine: getHorizontalVerticalLine,
          getDrawingVerticalLine: getVerticalVerticalLine,
        ),
        // minY: -10,
        // maxY: 10,
        // minX: -10,
        // maxX: 10,
        // minY: -getBiggestScale(getBiggestXY()) - 0.5,
        // maxY: getBiggestScale(getBiggestXY()) + 0.5,
        // minX: -getBiggestScale(getBiggestXY()) - 0.5,
        // maxX: getBiggestScale(getBiggestXY()) + 0.5,
        minY: -getBiggestScale(getBiggestXY()) * 0.9,
        maxY: getBiggestScale(getBiggestXY()) * 0.9,
        minX: -getBiggestScale(getBiggestXY()) * 0.9,
        maxX: getBiggestScale(getBiggestXY()) * 0.9,
        baselineX: baselineX,
        baselineY: baselineY,
      ),
      duration: Duration.zero,
    );
  }
}

class _ScatterChart extends StatelessWidget {
  final double baselineX;
  final double baselineY;

  const _ScatterChart(this.baselineX, this.baselineY) : super();

  Widget getTTitles(value, TitleMeta meta) {
    TextStyle style;
    if ((value - baselineX).abs() <= 0.1) {
      style = const TextStyle(
        color: Color(0xff303030),
        fontSize: 18,
        fontWeight: FontWeight.bold,
      );
    } else {
      style = const TextStyle(
        color: Colors.white,
        fontSize: 14,
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text('', style: style),
      // child: Text(meta.formattedValue, style: style),
    );
  }

  Widget getBTitles(value, TitleMeta meta) {
    TextStyle style;
    if ((value - baselineX).abs() <= 0.1) {
      style = const TextStyle(
        color: Color(0xff303030),
        fontSize: 18,
        fontWeight: FontWeight.bold,
      );
    } else {
      style = const TextStyle(
        color: Colors.white,
        fontSize: 14,
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text('', style: style),
      // child: Text(meta.formattedValue, style: style),
    );
  }

  Widget getLTitles(value, TitleMeta meta) {
    TextStyle style;
    if ((value - baselineY).abs() <= 0.1) {
      style = const TextStyle(
        color: Color(0xff303030),
        fontSize: 18,
        fontWeight: FontWeight.bold,
      );
    } else {
      style = const TextStyle(
        color: Colors.white,
        fontSize: 14,
      );
    }

    return Padding(
      padding: const EdgeInsets.only(right: 0),
      child: Text('', style: style),
      // child: Text(meta.formattedValue, style: style),
    );
  }

  Widget getRTitles(value, TitleMeta meta) {
    TextStyle style;
    if ((value - baselineY).abs() <= 0.1) {
      style = const TextStyle(
        color: Color(0xff303030),
        fontSize: 18,
        fontWeight: FontWeight.bold,
      );
    } else {
      style = const TextStyle(
        color: Colors.white,
        fontSize: 14,
      );
    }

    return Padding(
      padding: const EdgeInsets.only(left: 0, right: 0),
      child: Text('', style: style),
      // child: Text(meta.formattedValue, style: style),
    );
  }

  FlLine getHorizontalVerticalLine(double value) {
    if ((value - baselineY).abs() <= 0.1) {
      return FlLine(
        color: Color(0xff576778),
        strokeWidth: 0,
        // dashArray: [8, 4],
      );
    } else {
      return FlLine(
        color: Color.fromARGB(176, 230, 231, 233),
        strokeWidth: 0,
        // dashArray: [8, 4],
      );
    }
  }

  FlLine getVerticalVerticalLine(double value) {
    if ((value - baselineX).abs() <= 0.1) {
      return FlLine(
        color: Color(0xff576778),
        strokeWidth: 0,
        // dashArray: [8, 4],
      );
    } else {
      return FlLine(
        color: Color.fromARGB(176, 230, 231, 233),
        strokeWidth: 0,
        // dashArray: [8, 4],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = context.watch<DataAddProvider>();
    // UPPER
    final upper = d.upper;
    final upperCrockedLine = d.upperCrockedLine;
    final listBolts = d.listBolts;
    final listTorqueSuggestions = d.listTorqueSuggestions;
    final listBoltsKey = d.listBoltsKey;
    final listTorqueSuggestionsKey = d.listTorqueSuggestionsKey;
    final listTorqueSuggestionsY = d.listTorqueSuggestionsY;

    double getBiggestXY() {
      double upper0 = upper[0];
      double upper1 = upper[1];
      // log("UPPER 0 : $upper0");
      // log("UPPER 1 : $upper1");
      double result = 0;
      if (upper0 < 0) upper0 * (-1);
      if (upper1 < 0) upper1 * (-1);
      if (upper0 <= upper1)
        result = upper1;
      else
        result = upper0;
      // log("BIGGEST XY : $result");
      return result;
    }

    double getBiggestScale(double value) {
      double val = value;
      if (value < 1) {
        val = val * (-1);
      }
      if (val > 0 && val <= 5)
        val = val;
      else if (val > 5 && val <= 10)
        val = val * 10;
      else if (val > 10 /*&& val <= 100*/)
        val = val * (50 * (10.pow(val.toInt().toString().length - 2).toInt()));
      // val = val * 50;
      // else if (val > 100 && val <= 1000)
      //   val = val * 500;
      // else if (val > 1000 && val <= 10000)
      //   val = val * 5000;
      // else if (val > 10000 && val <= 100000)
      //   val = val * 50000;
      // else if (val > 100000 && val <= 1000000)
      //   val = val * 500000;
      // else if (val > 1000000 && val <= 10000000) val = val * 5000000;
      return val + 0.8;
    }

    // log("GET BIGGEST XY ${getBiggestXY()}");
    // log("GET BIGGEST SCALE ${getBiggestScale(getBiggestXY())}");

    return ScatterChart(
      ScatterChartData(
        // showingTooltipIndicators:
        //     listTorqueSuggestions.map((e) => e.toInt()).toList(),
        scatterTouchData: ScatterTouchData(
          enabled: false,
          // handleBuiltInTouches: false,
          // touchCallback: (FlTouchEvent event, ScatterTouchResponse? response) {
          //   if (response == null || response.touchedSpot == null) {
          //     return;
          //   }
          //   // if (event is FlTapUpEvent) {
          //   //   final spotIndex = response.touchedSpot?.spotIndex;
          //   //   var listDouble =
          //   //       listTorqueSuggestions.map((e) => e.toInt()).toList();
          //   //   // setState(() {
          //   //   //   if (listDouble.contains(spotIndex)) {
          //   //   //     listDouble.remove(spotIndex);
          //   //   //   } else {
          //   //   //     listDouble.add(spotIndex);
          //   //   //   }
          //   //   // });
          //   // }
          // },
          touchTooltipData: ScatterTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              // log("TOUCHED SPOTS X : ${touchedSpots.x}");
              // log("TOUCHED SPOTS X CONTAIN : ${listTorqueSuggestionsY.contains(touchedSpots.y)}");
              if (listTorqueSuggestionsY.contains(touchedSpots.y)) {
                final item = listTorqueSuggestionsY
                    .firstWhere((element) => element == touchedSpots.y);
                return ScatterTooltipItem(
                  '$item',
                  textStyle: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                );
              }
              return ScatterTooltipItem(
                '${touchedSpots.x.toStringAsFixed(0)},${touchedSpots.y.toStringAsFixed(0)}',
                textStyle: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              );
            },
            tooltipBgColor: Constant.textHintColor2,
          ),
        ),
        scatterSpots: List.generate(
          listBolts.length,
          (index) => ScatterSpot(
            listBolts[index][0],
            listBolts[index][1],
            show: true,
            radius: 12,
            // radius: 18.7,
            color: listTorqueSuggestionsKey.contains(listBoltsKey[index])
                ? Colors.red
                : Colors.grey.shade600,
          ),
        ),
        scatterLabelSettings: ScatterLabelSettings(
          showLabel: true,
          getLabelFunction: (spotIndex, spot) {
            if (listTorqueSuggestionsKey.contains(listBoltsKey[spotIndex])) {
              final index =
                  listTorqueSuggestionsKey.indexOf(listBoltsKey[spotIndex]);
              if (listBoltsKey[spotIndex] == listTorqueSuggestionsKey[index])
                return '          ${listTorqueSuggestionsY[index]}';
            }
            return '';
          },
          getLabelTextStyleFunction: (spotIndex, spot) => TextStyle(
            height: 1.2,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.red,
            shadows: [
              Shadow(
                  // bottomLeft
                  offset: Offset(-1.5, -1.5),
                  color: Colors.white),
              Shadow(
                  // bottomRight
                  offset: Offset(1.5, -1.5),
                  color: Colors.white),
              Shadow(
                  // topRight
                  offset: Offset(1.5, 1.5),
                  color: Colors.white),
              Shadow(
                  // topLeft
                  offset: Offset(-1.5, 1.5),
                  color: Colors.white),
            ],
          ),
        ),
        // betweenBarsData: [BetweenBarsData(fromIndex: 0, toIndex: 2)],
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: getLTitles,
              reservedSize: 24,
            ),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: getTTitles,
                reservedSize: 28),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: getRTitles,
              reservedSize: 24,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: getBTitles,
                reservedSize: 24),
          ),
        ),
        borderData: FlBorderData(
            show: true, border: Border.all(color: Color(0xffE6E7E9B0))),
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          drawVerticalLine: true,
          getDrawingHorizontalLine: getHorizontalVerticalLine,
          getDrawingVerticalLine: getVerticalVerticalLine,
        ),
        // minY: -10,
        // maxY: 10,
        // minX: -10,
        // maxX: 10,
        // minY: -getBiggestScale(getBiggestXY()) - 0.5,
        // maxY: getBiggestScale(getBiggestXY()) + 0.5,
        // minX: -getBiggestScale(getBiggestXY()) - 0.5,
        // maxX: getBiggestScale(getBiggestXY()) + 0.5,
        minY: -getBiggestScale(getBiggestXY()) * 1.2,
        maxY: getBiggestScale(getBiggestXY()) * 1.2,
        minX: -getBiggestScale(getBiggestXY()) * 1.2,
        maxX: getBiggestScale(getBiggestXY()) * 1.2,
        baselineX: baselineX,
        baselineY: baselineY,
      ),
      // duration: Duration.zero,
    );
  }
}

class _ScatterChartS extends StatelessWidget {
  final double baselineX;
  final double baselineY;

  const _ScatterChartS(this.baselineX, this.baselineY) : super();

  Widget getTTitles(value, TitleMeta meta) {
    TextStyle style;
    if ((value - baselineX).abs() <= 0.1) {
      style = const TextStyle(
        color: Color(0xff303030),
        fontSize: 18,
        fontWeight: FontWeight.bold,
      );
    } else {
      style = const TextStyle(
        color: Colors.white,
        fontSize: 14,
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text('', style: style),
      // child: Text(meta.formattedValue, style: style),
    );
  }

  Widget getBTitles(value, TitleMeta meta) {
    TextStyle style;
    if ((value - baselineX).abs() <= 0.1) {
      style = const TextStyle(
        color: Color(0xff303030),
        fontSize: 18,
        fontWeight: FontWeight.bold,
      );
    } else {
      style = const TextStyle(
        color: Colors.white,
        fontSize: 14,
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text('', style: style),
      // child: Text(meta.formattedValue, style: style),
    );
  }

  Widget getLTitles(value, TitleMeta meta) {
    TextStyle style;
    if ((value - baselineY).abs() <= 0.1) {
      style = const TextStyle(
        color: Color(0xff303030),
        fontSize: 18,
        fontWeight: FontWeight.bold,
      );
    } else {
      style = const TextStyle(
        color: Colors.white,
        fontSize: 14,
      );
    }

    return Padding(
      padding: const EdgeInsets.only(right: 0),
      child: Text('', style: style),
      // child: Text(meta.formattedValue, style: style),
    );
  }

  Widget getRTitles(value, TitleMeta meta) {
    TextStyle style;
    if ((value - baselineY).abs() <= 0.1) {
      style = const TextStyle(
        color: Color(0xff303030),
        fontSize: 18,
        fontWeight: FontWeight.bold,
      );
    } else {
      style = const TextStyle(
        color: Colors.white,
        fontSize: 14,
      );
    }

    return Padding(
      padding: const EdgeInsets.only(left: 0, right: 0),
      child: Text('', style: style),
      // child: Text(meta.formattedValue, style: style),
    );
  }

  FlLine getHorizontalVerticalLine(double value) {
    if ((value - baselineY).abs() <= 0.1) {
      return FlLine(
        color: Color(0xff576778),
        strokeWidth: 0,
        // dashArray: [8, 4],
      );
    } else {
      return FlLine(
        color: Color.fromARGB(176, 230, 231, 233),
        strokeWidth: 0,
        // dashArray: [8, 4],
      );
    }
  }

  FlLine getVerticalVerticalLine(double value) {
    if ((value - baselineX).abs() <= 0.1) {
      return FlLine(
        color: Color(0xff576778),
        strokeWidth: 0,
        // dashArray: [8, 4],
      );
    } else {
      return FlLine(
        color: Color.fromARGB(176, 230, 231, 233),
        strokeWidth: 0,
        // dashArray: [8, 4],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = context.watch<DataAddProvider>();
    // UPPER
    final upper = d.upper;
    final upperCrockedLine = d.upperCrockedLine;
    final listBolts = d.listBolts;
    final listTorqueSuggestions = d.listTorqueSuggestions;

    double getBiggestXY() {
      double upper0 = upper[0];
      double upper1 = upper[1];
      // log("UPPER 0 : $upper0");
      // log("UPPER 1 : $upper1");
      double result = 0;
      if (upper0 < 0) upper0 * (-1);
      if (upper1 < 0) upper1 * (-1);
      if (upper0 <= upper1)
        result = upper1;
      else
        result = upper0;
      // log("BIGGEST XY : $result");
      return result;
    }

    double getBiggestScale(double value) {
      double val = value;
      if (value < 1) {
        val = val * (-1);
      }
      if (val > 0 && val <= 5)
        val = val;
      else if (val > 5 && val <= 10)
        val = val * 10;
      else if (val > 10 /*&& val <= 100*/)
        val = val * (50 * (10.pow(val.toInt().toString().length - 2).toInt()));
      // val = val * 50;
      // else if (val > 100 && val <= 1000)
      //   val = val * 500;
      // else if (val > 1000 && val <= 10000)
      //   val = val * 5000;
      // else if (val > 10000 && val <= 100000)
      //   val = val * 50000;
      // else if (val > 100000 && val <= 1000000)
      //   val = val * 500000;
      // else if (val > 1000000 && val <= 10000000) val = val * 5000000;
      return val + 0.8;
    }

    // log("GET BIGGEST XY ${getBiggestXY()}");
    // log("GET BIGGEST SCALE ${getBiggestScale(getBiggestXY())}");

    return ScatterChart(
      ScatterChartData(
        scatterTouchData: ScatterTouchData(
          enabled: true,
          touchTooltipData: ScatterTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return ScatterTooltipItem(
                '${touchedSpots.x.toStringAsFixed(0)},${touchedSpots.y.toStringAsFixed(0)}',
                textStyle: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              );
            },
            tooltipBgColor: Constant.textHintColor2,
          ),
        ),
        scatterSpots: List.generate(
          listBolts.length,
          (index) => ScatterSpot(
            listBolts[index][0],
            listBolts[index][1],
            show: true,
            radius: 18.7,
            color: Colors.transparent,
          ),
        ),
        scatterLabelSettings: ScatterLabelSettings(
          showLabel: true,
          getLabelFunction: (spotIndex, spot) => '${spotIndex + 1}',
          getLabelTextStyleFunction: (spotIndex, spot) => TextStyle(
              height: 1.3,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.white,
              shadows: [
                Shadow(
                    // bottomLeft
                    offset: Offset(-1.5, -1.5),
                    color: Constant.primaryColor),
                Shadow(
                    // bottomRight
                    offset: Offset(1.5, -1.5),
                    color: Constant.primaryColor),
                Shadow(
                    // topRight
                    offset: Offset(1.5, 1.5),
                    color: Constant.primaryColor),
                Shadow(
                    // topLeft
                    offset: Offset(-1.5, 1.5),
                    color: Constant.primaryColor),
              ]),
        ),
        // betweenBarsData: [BetweenBarsData(fromIndex: 0, toIndex: 2)],
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: getLTitles,
              reservedSize: 24,
            ),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: getTTitles,
                reservedSize: 28),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: getRTitles,
              reservedSize: 24,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: getBTitles,
                reservedSize: 24),
          ),
        ),
        borderData: FlBorderData(
            show: true, border: Border.all(color: Color(0xffE6E7E9B0))),
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          drawVerticalLine: true,
          getDrawingHorizontalLine: getHorizontalVerticalLine,
          getDrawingVerticalLine: getVerticalVerticalLine,
        ),
        // minY: -10,
        // maxY: 10,
        // minX: -10,
        // maxX: 10,
        // minY: -getBiggestScale(getBiggestXY()) - 0.5,
        // maxY: getBiggestScale(getBiggestXY()) + 0.5,
        // minX: -getBiggestScale(getBiggestXY()) - 0.5,
        // maxX: getBiggestScale(getBiggestXY()) + 0.5,
        minY: -getBiggestScale(getBiggestXY()) * 2,
        maxY: getBiggestScale(getBiggestXY()) * 2,
        minX: -getBiggestScale(getBiggestXY()) * 2,
        maxX: getBiggestScale(getBiggestXY()) * 2,
        baselineX: baselineX,
        baselineY: baselineY,
      ),
      // duration: Duration.zero,
    );
  }
}
