import 'dart:developer';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hy_tutorial/common/helper/constant.dart';
import 'package:provider/provider.dart';
import 'package:powers/powers.dart';
import '../../data/provider/data_add_provider.dart';

double divideUntilTwoDigits(double val) {
  double num = val.abs(); // Use abs() to work with positive value
  // log("DTWO VAL : $val");
  // log("DTWO NUM : $num");
  int substract = 1;
  if (num < 11 && num % 10 != 0) substract = 1;
  var floor = num.floor();
  var divide1 = floor / 10;
  var mod1 = divide1 % 10;
  if ((num.floor() % 10 == 0) && num < (num + 1) && mod1 == 0)
    substract = num.floor().toString().length;
  // log("DTWO SUBSTRACT : $substract");
  // log("DTWO NUM LENGTH : ${num.toInt().toString().length}");
  int num2 = 10.pow(num.toInt().toString().length - substract).toInt();
  // log("DTWO NUM2 : $num2");
  if (val < 0) num2 = num2 * (-1);
  // log("DTWO NUM/NUM2 ${num / num2}");
  // log("DTWO ==================");
  return num / num2;
}

double getBiggestScaleMain(double value) {
  double val = value;
  if (value < 1) {
    val = val * (-1);
  }
  log("BIGG VAL : ${val.toInt()}");
  if (val > 0 && val <= 10)
    val = val;
  // dibagi sampai interval 1-10
  else if (val > 10)
    val = val * (50 * (10.pow(val.toInt().toString().length - 2).toInt()));
  log("BIGG VAL : ${val.toInt()}");
  val = val + 0.8;
  // adjust biar pas abu2
  if (val >= 6)
    val = val + 3;
  else if (val > 2) val = val - 2;

  log("GET BIGGEST SCALE BOLT VAL : $val");
  if (val > 10)
    val = 10;
  else if (val > 0 && val < 1)
    val = 1;
  else if (val >= 1 && val < 2) val = 1.5;
  log("GET BIGGEST SCALE BOLT : $val");
  return val;
}

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
    final upper = d.upper.map((e) => divideUntilTwoDigits(e)).toList();
    final upperCrockedLine = d.upperCrockedLine;
    final listBolts = d.listBolts;
    final listTorqueSuggestions = d.listTorqueSuggestions;

    double getBiggestXY() {
      double upper0 = upper[0];
      double upper1 = upper[1];
      // // log("UPPER 0 : $upper0");
      // // log("UPPER 1 : $upper1");
      double result = 0;
      upper0 = upper0.abs();
      upper1 = upper1.abs();
      if (upper0 <= upper1)
        result = upper1;
      else
        result = upper0;
      // // log("BIGGEST UPPER : $result");
      result = divideUntilTwoDigits(result);
      // // log("BIGGEST UPPER 2 : $result");
      return result;
    }

    double getBiggestScale(double value) {
      double val = value;
      if (value < 1) {
        val = val * (-1);
      }
      if (val > 0 && val <= 10)
        val = val;
      else if (val > 10)
        val = val * (50 * (10.pow(val.toInt().toString().length - 2).toInt()));
      val = val + 0.8;
      if (val >= 6)
        val = val + 3;
      else {
        if (val > 2) val = val - 2;
      }

      if (val > 10) val = 10;
      if (val >= 1 && val < 2) val = 1.8;
      if (val < 2) val = 2;
      log("GET BIGGEST SCALE BOLT BLUE : $val");
      return val;
    }

    // log("GET BIGGEST XY ${getBiggestXY()}");
    // log("GET BIGGEST SCALE ${getBiggestScale(getBiggestXY())}");

    double curveSmoothness() {
      log("PANJANG BAUT : ${listBolts.length}");
      // bolts 2 = 0.7
      // bolts 4 = 0.55
      // bolts 8 = 0.4
      // bolts 10 = 0.25
      // bolts 12 = 0.1
      // bolts 14 = 0;
      if (listBolts.length > 12) return 0;
      double val = 0.7;
      double p = val - (0.15 * (listBolts.length / 4));
      return p;
    }

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
              if (listBolts.isNotEmpty)
                FlSpot(listBolts[0][0], listBolts[0][1]),
            ],
            isCurved: true,
            curveSmoothness: curveSmoothness(),
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
        minY: -(getBiggestScaleMain(getBiggestXY()) * 2) - 3,
        maxY: (getBiggestScaleMain(getBiggestXY()) * 2) + 3,
        minX: -(getBiggestScaleMain(getBiggestXY()) * 2) - 3,
        maxX: (getBiggestScaleMain(getBiggestXY()) * 2) + 3,
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
    final upper = d.upper.map((e) => divideUntilTwoDigits(e)).toList();
    final upperCrockedLine = d.upperCrockedLine;
    final listBolts = d.listBolts;
    final listTorqueSuggestions = d.listTorqueSuggestions;

    double getBiggestXY() {
      double upper0 = upper[0];
      double upper1 = upper[1];
      // // log("UPPER 0 : $upper0");
      // // log("UPPER 1 : $upper1");
      double result = 0;
      upper0 = upper0.abs();
      upper1 = upper1.abs();
      if (upper0 <= upper1)
        result = upper1;
      else
        result = upper0;
      // // log("BIGGEST UPPER : $result");
      result = divideUntilTwoDigits(result);
      // // log("BIGGEST UPPER 2 : $result");
      return result;
    }

    double getBiggestScale(double value) {
      double val = value;
      if (value < 1) {
        val = val * (-1);
      }
      if (val > 0 && val <= 10)
        val = val;
      else if (val > 10)
        val = val * (50 * (10.pow(val.toInt().toString().length - 2).toInt()));
      val = val + 0.8;
      if (val >= 6)
        val = val + 3;
      else {
        if (val > 2) val = val - 2;
      }

      if (val > 10) val = 10;
      if (val >= 1 && val < 2)
        val = 1.8;
      else if (val > 0 && val < 1)
        val = 0;
      else if (val < 2) val = 1.3;
      log("GET BIGGEST SCALE BOLT BG : $val");
      return val;
    }

    // log("GET BIGGEST XY ${getBiggestXY()}");
    // log("GET BIGGEST SCALE ${getBiggestScale(getBiggestXY())}");

    double curveSmoothness() {
      // bolts 2 = 0.7
      // bolts 4 = 0.55
      // bolts 8 = 0.4
      // bolts 10 = 0.25
      // bolts 12 = 0.1
      // bolts 14 = 0;
      if (listBolts.length > 12) return 0.35;
      double val = 0.7;
      double p = val - (0.15 * (listBolts.length / 4));
      return p;
    }

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
              if (listBolts.isNotEmpty)
                FlSpot(listBolts[0][0], listBolts[0][1]),
            ],
            isCurved: true,
            curveSmoothness: curveSmoothness(),
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
        minY: -(getBiggestScaleMain(getBiggestXY())) - 3,
        maxY: (getBiggestScaleMain(getBiggestXY())) + 3,
        minX: -(getBiggestScaleMain(getBiggestXY())) - 3,
        maxX: (getBiggestScaleMain(getBiggestXY())) + 3,
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
    final upper = d.upper.map((e) => divideUntilTwoDigits(e)).toList();
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
      upper0 = upper0.abs();
      upper1 = upper1.abs();
      if (upper0 <= upper1)
        result = upper1;
      else
        result = upper0;
      // log("BIGGEST UPPER : $result");
      result = divideUntilTwoDigits(result);
      // log("BIGGEST UPPER 2 : $result");
      return result;
    }

    double getBiggestScale(double value) {
      double val = value;
      if (value < 1) {
        val = val * (-1);
      }
      log("BIGG VAL : ${val.toInt()}");
      if (val > 0 && val <= 10)
        val = val;
      // dibagi sampai interval 1-10
      else if (val > 10)
        val = val * (50 * (10.pow(val.toInt().toString().length - 2).toInt()));
      log("BIGG VAL : ${val.toInt()}");
      val = val + 0.8;
      // adjust biar pas abu2
      if (val >= 6)
        val = val + 3;
      else if (val > 2) val = val - 2;

      log("GET BIGGEST SCALE BOLT VAL : $val");
      if (val > 10)
        val = 10;
      else if (val < 1)
        val = 1;
      else if (val > 0 && val < 1)
        val = 0;
      else if (val >= 1 && val < 2) val = 2;
      log("GET BIGGEST SCALE BOLT : $val");
      return val;
    }

    double getBoltRadius() {
      if (listBolts.length >= 16) return 6;
      if (listBolts.length >= 14) return 8;
      if (listBolts.length >= 12) return 10;
      var number = getBiggestScaleMain(getBiggestXY());
      if (number < 1) return 6;
      if (number <= 2.1) return 8;
      return 12;
    }

    double getFontSize() {
      if (listBolts.length >= 12) return 9;
      var number = getBiggestScaleMain(getBiggestXY());
      if (number < 1) return 8;
      if (number <= 2.1) return 10;
      return 14;
    }

    return ScatterChart(
      ScatterChartData(
        scatterSpots: List.generate(
          listBolts.length,
          (index) => ScatterSpot(
            listBolts[index][0],
            listBolts[index][1],
            show: true,
            radius: getBoltRadius(),
            // radius:
            //     listBolts.length > 12 || getBiggestScaleMain(getBiggestXY()) < 2
            //         ? 6
            //         : 12,
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
                return '\t\t\t\t\t\t\t\t${listTorqueSuggestionsY[index]}';
            }
            return '';
          },
          getLabelTextStyleFunction: (spotIndex, spot) => TextStyle(
            height: 1,
            fontWeight: FontWeight.bold,
            fontSize: getFontSize(),
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
        minY: -(getBiggestScaleMain(getBiggestXY()) * 1.4) - 3,
        maxY: (getBiggestScaleMain(getBiggestXY()) * 1.4) + 3,
        minX: -(getBiggestScaleMain(getBiggestXY()) * 1.4) - 3,
        maxX: (getBiggestScaleMain(getBiggestXY()) * 1.4) + 3,
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
    final upper = d.upper.map((e) => divideUntilTwoDigits(e)).toList();
    final upperCrockedLine = d.upperCrockedLine;
    final listBolts = d.listBolts;
    final listTorqueSuggestions = d.listTorqueSuggestions;

    double getBiggestXY() {
      double upper0 = upper[0];
      double upper1 = upper[1];
      // // log("UPPER 0 : $upper0");
      // // log("UPPER 1 : $upper1");
      double result = 0;
      upper0 = upper0.abs();
      upper1 = upper1.abs();
      if (upper0 <= upper1)
        result = upper1;
      else
        result = upper0;
      // // log("BIGGEST UPPER : $result");
      result = divideUntilTwoDigits(result);
      // // log("BIGGEST UPPER 2 : $result");
      return result;
    }

    double getBiggestScale(double value) {
      double val = value;
      if (value < 1) {
        val = val * (-1);
      }
      if (val > 0 && val <= 10)
        val = val;
      else if (val > 10)
        val = val * (50 * (10.pow(val.toInt().toString().length - 2).toInt()));
      val = val + 0.8;
      if (val >= 6)
        val = val + 3;
      else {
        if (val > 2) val = val - 2;
      }

      if (val > 10) val = 10;
      if (val >= 1 && val < 2) val = 1.8;
      // else if (val > 0 && val < 1) val = 0;
      if (val < 2) val = 2.4;
      log("GET BIGGEST SCALE SCATTER NUMBER : $val");
      return val;
    }

    double getFontSize() {
      if (listBolts.length >= 12) return 10;
      var number = getBiggestScaleMain(getBiggestXY());
      if (number < 1) return 8;
      if (number <= 2.1) return 10;
      return 14;
    }

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
              fontSize: getFontSize(),
              // fontSize: listBolts.length > 12 ||
              //         getBiggestScaleMain(getBiggestXY()) < 2
              //     ? 10
              //     : 14,
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
        minY: -(getBiggestScaleMain(getBiggestXY()) * 2.5) - 3,
        maxY: (getBiggestScaleMain(getBiggestXY()) * 2.5) + 3,
        minX: -(getBiggestScaleMain(getBiggestXY()) * 2.5) - 3,
        maxX: (getBiggestScaleMain(getBiggestXY()) * 2.5) + 3,
        baselineX: baselineX,
        baselineY: baselineY,
      ),
    );
  }
}
