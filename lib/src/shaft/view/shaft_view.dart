import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hy_tutorial/common/component/custom_container.dart';
import 'package:hy_tutorial/src/home/view/home_view.dart';
import 'package:hy_tutorial/src/home/view/main_home.dart';
import '../../../common/component/custom_appbar.dart';
import '../../../common/helper/constant.dart';
import 'sample_chart_view.dart';
import "package:provider/provider.dart";
import '../../../common/component/custom_textfield.dart';
import '../../data/provider/data_add_provider.dart';
import 'bolt_chart_view.dart';
import 'upper_chart_view.dart';

class ShaftView extends StatefulWidget {
  const ShaftView({super.key});

  @override
  State<ShaftView> createState() => _ShaftViewState();
}

class _ShaftViewState extends State<ShaftView> with TickerProviderStateMixin {
  int currentIndex = 0;
  late TabController tabController;
  late TabController tabController1;
  @override
  void initState() {
    final p = context.read<DataAddProvider>();
    tabController = TabController(length: 4, vsync: this);

    tabController1 = TabController(length: 3, vsync: this);
    tabController.addListener(() {
      log("INDEX ACTIVE : ${tabController.index}");
      setState(() {});
    });

    tabController1.addListener(() {
      log("INDEX ACTIVE : ${tabController.index}");
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final d = context.watch<DataAddProvider>();
    final data = context.watch<DataAddProvider>().turbineDetailModel.data;
    final shaft =
        context.watch<DataAddProvider>().turbineCreateModel.data?.shaft;
    final status =
        context.watch<DataAddProvider>().turbineCreateModel.data?.status;
    final totalCrockedness = context
        .watch<DataAddProvider>()
        .turbineCreateModel
        .data
        ?.totalCrockedness;
    final upperData = context
        .watch<DataAddProvider>()
        .turbineCreateModel
        .data
        ?.detailData
        ?.upper;
    final clutchData = context
        .watch<DataAddProvider>()
        .turbineCreateModel
        .data
        ?.detailData
        ?.clutch;
    final turbineData = context
        .watch<DataAddProvider>()
        .turbineCreateModel
        .data
        ?.detailData
        ?.turbine;
    Widget _buildTab(String tag) {
      return Tab(child: Text(tag, style: TextStyle(fontSize: 18)));
    }

    Widget toggleTab() {
      return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: Constant.primaryColor, width: 0.5)),
        child: Center(
          child: TabBar(
            isScrollable: true,
            controller: tabController,
            indicatorWeight: 4,
            unselectedLabelColor: Constant.grayColor,
            labelColor: Constant.primaryColor,
            unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w300),

            indicatorColor: Constant.primaryColor,
            // width: 91, // width in percent
            // borderRadius: 30,
            // height: 50,
            // selectedIndex: currentIndex,
            // selectedBackgroundColors: [Constant.primaryColor],
            // unSelectedBackgroundColors: [Color(0xffffffff)],
            // selectedTextStyle:
            //     TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            // unSelectedTextStyle: TextStyle(color: Colors.black87),
            tabs: [
              _buildTab("A-C"),
              _buildTab("B-D"),
              _buildTab("Resultan"),
              _buildTab("Bolt")
            ],
            // selectedLabelIndex: (index) {
            //   setState(() {
            //     currentIndex = index;
            //     tabController.index = index;
            //   });
            // },
            // isScroll: false,
          ),
        ),
      );
    }

    Widget toggleTab1() {
      return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: Constant.primaryColor, width: 0.5)),
        child: Center(
          child: TabBar(
            isScrollable: true,
            controller: tabController1,
            indicatorWeight: 4,
            unselectedLabelColor: Constant.grayColor,
            labelColor: Constant.primaryColor,
            unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w300),
            indicatorColor: Constant.primaryColor,
            tabs: [
              _buildTab("Upper"),
              _buildTab("Clutch"),
              _buildTab("Turbine"),
            ],
          ),
        ),
      );
    }

    Widget acBdActive() => Column(
          children: [
            Container(
              color: Color(0xffEFEFEF),
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Text(
                      'Total Baut',
                      style: TextStyle(color: Constant.textColorBlack),
                    ),
                  ),
                  Constant.xSizedBox8,
                  Expanded(
                    flex: 5,
                    child: Text(
                      '${data?.totalBolts ?? 0}',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Text(
                      'Torsi Saat Ini',
                      style: TextStyle(color: Constant.textColorBlack),
                    ),
                  ),
                  Constant.xSizedBox8,
                  Expanded(
                    flex: 5,
                    child: Text(
                      '${data?.currentTorque ?? 0}',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: Color(0xffEFEFEF),
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Text(
                      'Max Torsi',
                      style: TextStyle(color: Constant.textColorBlack),
                    ),
                  ),
                  Constant.xSizedBox8,
                  Expanded(
                    flex: 5,
                    child: Text(
                      '${data?.maxTorque ?? 0}',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Text(
                      'Selisih Torsi',
                      style: TextStyle(color: Constant.textColorBlack),
                    ),
                  ),
                  Constant.xSizedBox8,
                  Expanded(
                    flex: 5,
                    child: Text(
                      '${data?.torqueGap ?? 0}',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: Color(0xffEFEFEF),
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Text(
                      'Gen. Bearing-Kopling',
                      style: TextStyle(color: Constant.textColorBlack),
                    ),
                  ),
                  Constant.xSizedBox8,
                  Expanded(
                    flex: 5,
                    child: Text(
                      '${shaft?.genBearingToCoupling ?? 0}',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Text(
                      'Kopling - Turbin',
                      style: TextStyle(color: Constant.textColorBlack),
                    ),
                  ),
                  Constant.xSizedBox8,
                  Expanded(
                    flex: 5,
                    child: Text(
                      '${shaft?.couplingToTurbine ?? 0}',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: Color(0xffEFEFEF),
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Text(
                      'Total',
                      style: TextStyle(color: Constant.textColorBlack),
                    ),
                  ),
                  Constant.xSizedBox8,
                  Expanded(
                    flex: 5,
                    child: Text(
                      '${shaft?.total ?? 0}',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Text(
                      'Rasio',
                      style: TextStyle(color: Constant.textColorBlack),
                    ),
                  ),
                  Constant.xSizedBox8,
                  Expanded(
                    flex: 5,
                    child: Text(
                      (shaft?.ratio ?? 0).toStringAsFixed(2),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );

    Widget clutchActive() => Table(
          border: TableBorder.all(
              color: Constant.borderSearchColor,
              borderRadius: BorderRadius.circular(5)),
          columnWidths: const <int, TableColumnWidth>{
            0: FlexColumnWidth(),
            1: FlexColumnWidth(),
            2: FlexColumnWidth(),
            3: FlexColumnWidth(),
            4: FlexColumnWidth(),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(children: [
              Text('\n\n', textAlign: TextAlign.center),
              Text('\nA\n', textAlign: TextAlign.center),
              Text('\nB\n', textAlign: TextAlign.center),
              Text('\nC\n', textAlign: TextAlign.center),
              Text('\nD\n', textAlign: TextAlign.center),
            ]),
            TableRow(children: [
              Text('1', textAlign: TextAlign.center),
              CustomTextField.tableTextField(
                  readOnly: true,
                  controller: TextEditingController()
                    ..text = '${clutchData?.a?['1'] ?? 0}'),
              CustomTextField.tableTextField(
                  readOnly: true,
                  controller: TextEditingController()
                    ..text = '${clutchData?.b?['1'] ?? 0}'),
              CustomTextField.tableTextField(
                  readOnly: true,
                  controller: TextEditingController()
                    ..text = '${clutchData?.c?['1'] ?? 0}'),
              CustomTextField.tableTextField(
                  readOnly: true,
                  controller: TextEditingController()
                    ..text = '${clutchData?.d?['1'] ?? 0}'),
            ]),
            TableRow(children: [
              Text('2', textAlign: TextAlign.center),
              CustomTextField.tableTextField(
                  readOnly: true,
                  controller: TextEditingController()
                    ..text = '${clutchData?.a?['2'] ?? 0}'),
              CustomTextField.tableTextField(
                  readOnly: true,
                  controller: TextEditingController()
                    ..text = '${clutchData?.b?['2'] ?? 0}'),
              CustomTextField.tableTextField(
                  readOnly: true,
                  controller: TextEditingController()
                    ..text = '${clutchData?.c?['2'] ?? 0}'),
              CustomTextField.tableTextField(
                  readOnly: true,
                  controller: TextEditingController()
                    ..text = '${clutchData?.d?['2'] ?? 0}'),
            ]),
            TableRow(children: [
              Text('3', textAlign: TextAlign.center),
              CustomTextField.tableTextField(
                  readOnly: true,
                  controller: TextEditingController()
                    ..text = '${clutchData?.a?['3'] ?? 0}'),
              CustomTextField.tableTextField(
                  readOnly: true,
                  controller: TextEditingController()
                    ..text = '${clutchData?.b?['3'] ?? 0}'),
              CustomTextField.tableTextField(
                  readOnly: true,
                  controller: TextEditingController()
                    ..text = '${clutchData?.c?['3'] ?? 0}'),
              CustomTextField.tableTextField(
                  readOnly: true,
                  controller: TextEditingController()
                    ..text = '${clutchData?.d?['3'] ?? 0}'),
            ]),
            TableRow(children: [
              Text('4', textAlign: TextAlign.center),
              CustomTextField.tableTextField(
                  readOnly: true,
                  controller: TextEditingController()
                    ..text = '${clutchData?.a?['4'] ?? 0}'),
              CustomTextField.tableTextField(
                  readOnly: true,
                  controller: TextEditingController()
                    ..text = '${clutchData?.b?['4'] ?? 0}'),
              CustomTextField.tableTextField(
                  readOnly: true,
                  controller: TextEditingController()
                    ..text = '${clutchData?.c?['4'] ?? 0}'),
              CustomTextField.tableTextField(
                  readOnly: true,
                  controller: TextEditingController()
                    ..text = '${clutchData?.d?['4'] ?? 0}'),
            ]),
          ],
        );

    Widget turbineActive() => Table(
          border: TableBorder.all(
              color: Constant.borderSearchColor,
              borderRadius: BorderRadius.circular(5)),
          columnWidths: const <int, TableColumnWidth>{
            0: FlexColumnWidth(),
            1: FlexColumnWidth(),
            2: FlexColumnWidth(),
            3: FlexColumnWidth(),
            4: FlexColumnWidth(),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(children: [
              Text('\n\n', textAlign: TextAlign.center),
              Text('\nA\n', textAlign: TextAlign.center),
              Text('\nB\n', textAlign: TextAlign.center),
              Text('\nC\n', textAlign: TextAlign.center),
              Text('\nD\n', textAlign: TextAlign.center),
            ]),
            TableRow(children: [
              Text('1', textAlign: TextAlign.center),
              CustomTextField.tableTextField(
                  readOnly: true,
                  controller: TextEditingController()
                    ..text = '${turbineData?.a?['1'] ?? 0}'),
              CustomTextField.tableTextField(
                  readOnly: true,
                  controller: TextEditingController()
                    ..text = '${turbineData?.b?['1'] ?? 0}'),
              CustomTextField.tableTextField(
                  readOnly: true,
                  controller: TextEditingController()
                    ..text = '${turbineData?.c?['1'] ?? 0}'),
              CustomTextField.tableTextField(
                  readOnly: true,
                  controller: TextEditingController()
                    ..text = '${turbineData?.d?['1'] ?? 0}'),
            ]),
            TableRow(children: [
              Text('2', textAlign: TextAlign.center),
              CustomTextField.tableTextField(
                  readOnly: true,
                  controller: TextEditingController()
                    ..text = '${turbineData?.a?['2'] ?? 0}'),
              CustomTextField.tableTextField(
                  readOnly: true,
                  controller: TextEditingController()
                    ..text = '${turbineData?.b?['2'] ?? 0}'),
              CustomTextField.tableTextField(
                  readOnly: true,
                  controller: TextEditingController()
                    ..text = '${turbineData?.c?['2'] ?? 0}'),
              CustomTextField.tableTextField(
                  readOnly: true,
                  controller: TextEditingController()
                    ..text = '${turbineData?.d?['2'] ?? 0}'),
            ]),
            TableRow(children: [
              Text('3', textAlign: TextAlign.center),
              CustomTextField.tableTextField(
                  readOnly: true,
                  controller: TextEditingController()
                    ..text = '${turbineData?.a?['3'] ?? 0}'),
              CustomTextField.tableTextField(
                  readOnly: true,
                  controller: TextEditingController()
                    ..text = '${turbineData?.b?['3'] ?? 0}'),
              CustomTextField.tableTextField(
                  readOnly: true,
                  controller: TextEditingController()
                    ..text = '${turbineData?.c?['3'] ?? 0}'),
              CustomTextField.tableTextField(
                  readOnly: true,
                  controller: TextEditingController()
                    ..text = '${turbineData?.d?['3'] ?? 0}'),
            ]),
            TableRow(children: [
              Text('4', textAlign: TextAlign.center),
              CustomTextField.tableTextField(
                  readOnly: true,
                  controller: TextEditingController()
                    ..text = '${turbineData?.a?['4'] ?? 0}'),
              CustomTextField.tableTextField(
                  readOnly: true,
                  controller: TextEditingController()
                    ..text = '${turbineData?.b?['4'] ?? 0}'),
              CustomTextField.tableTextField(
                  readOnly: true,
                  controller: TextEditingController()
                    ..text = '${turbineData?.c?['4'] ?? 0}'),
              CustomTextField.tableTextField(
                  readOnly: true,
                  controller: TextEditingController()
                    ..text = '${turbineData?.d?['4'] ?? 0}'),
            ]),
          ],
        );

    Widget upperActive() => Table(
          border: TableBorder.all(
              color: Constant.borderSearchColor,
              borderRadius: BorderRadius.circular(5)),
          columnWidths: const <int, TableColumnWidth>{
            0: FlexColumnWidth(),
            1: FlexColumnWidth(),
            2: FlexColumnWidth(),
            3: FlexColumnWidth(),
            4: FlexColumnWidth(),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(children: [
              Text('\n\n', textAlign: TextAlign.center),
              Text('\nA\n', textAlign: TextAlign.center),
              Text('\nB\n', textAlign: TextAlign.center),
              Text('\nC\n', textAlign: TextAlign.center),
              Text('\nD\n', textAlign: TextAlign.center),
            ]),
            TableRow(children: [
              Text('1', textAlign: TextAlign.center),
              CustomTextField.tableTextField(
                  readOnly: true,
                  controller: TextEditingController()
                    ..text = '${upperData?.a?['1'] ?? 0}'),
              CustomTextField.tableTextField(
                  readOnly: true,
                  controller: TextEditingController()
                    ..text = '${upperData?.b?['1'] ?? 0}'),
              CustomTextField.tableTextField(
                  readOnly: true,
                  controller: TextEditingController()
                    ..text = '${upperData?.c?['1'] ?? 0}'),
              CustomTextField.tableTextField(
                  readOnly: true,
                  controller: TextEditingController()
                    ..text = '${upperData?.d?['1'] ?? 0}'),
            ]),
            TableRow(children: [
              Text('2', textAlign: TextAlign.center),
              CustomTextField.tableTextField(
                  readOnly: true,
                  controller: TextEditingController()
                    ..text = '${upperData?.a?['2'] ?? 0}'),
              CustomTextField.tableTextField(
                  readOnly: true,
                  controller: TextEditingController()
                    ..text = '${upperData?.b?['2'] ?? 0}'),
              CustomTextField.tableTextField(
                  readOnly: true,
                  controller: TextEditingController()
                    ..text = '${upperData?.c?['2'] ?? 0}'),
              CustomTextField.tableTextField(
                  readOnly: true,
                  controller: TextEditingController()
                    ..text = '${upperData?.d?['2'] ?? 0}'),
            ]),
            TableRow(children: [
              Text('3', textAlign: TextAlign.center),
              CustomTextField.tableTextField(
                  readOnly: true,
                  controller: TextEditingController()
                    ..text = '${upperData?.a?['3'] ?? 0}'),
              CustomTextField.tableTextField(
                  readOnly: true,
                  controller: TextEditingController()
                    ..text = '${upperData?.b?['3'] ?? 0}'),
              CustomTextField.tableTextField(
                  readOnly: true,
                  controller: TextEditingController()
                    ..text = '${upperData?.c?['3'] ?? 0}'),
              CustomTextField.tableTextField(
                  readOnly: true,
                  controller: TextEditingController()
                    ..text = '${upperData?.d?['3'] ?? 0}'),
            ]),
            TableRow(children: [
              Text('4', textAlign: TextAlign.center),
              CustomTextField.tableTextField(
                  readOnly: true,
                  controller: TextEditingController()
                    ..text = '${upperData?.a?['4'] ?? 0}'),
              CustomTextField.tableTextField(
                  readOnly: true,
                  controller: TextEditingController()
                    ..text = '${upperData?.b?['4'] ?? 0}'),
              CustomTextField.tableTextField(
                  readOnly: true,
                  controller: TextEditingController()
                    ..text = '${upperData?.c?['4'] ?? 0}'),
              CustomTextField.tableTextField(
                  readOnly: true,
                  controller: TextEditingController()
                    ..text = '${upperData?.d?['4'] ?? 0}'),
            ]),
          ],
        );

    return Scaffold(
      appBar: CustomAppBar.appBar(
        context,
        tabController.index == 2 ? 'Upper' : 'Shaft',
        leading: InkWell(
          onTap: () async {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => MainHome()),
                (route) => false);
          },
          child: Icon(Icons.arrow_back),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: ListView(
          shrinkWrap: true,
          children: [
            Text(
              tabController.index == 2 ? 'Grafik Resultan' : 'Grafik Shaft',
              style: Constant.iBlackMedium16,
            ),
            Constant.xSizedBox8,
            Row(
              children: [
                Expanded(
                    child: Text(
                  tabController.index == 2
                      ? 'Tampilan grafik dari data upper'
                      : 'Tampilan grafik dari data shaft',
                  style: TextStyle(fontSize: 12, color: Constant.grayColor),
                )),
                Constant.xSizedBox4,
                Text(
                  '${DateFormat('dd/MM/yyyy  |  HH : mm').format(DateFormat('yyyy-MM-dd HH:mm:ss').parse(d.turbineCreateModel.data?.createdAt ?? '${DateTime.now()}'))}',
                  style: TextStyle(color: Constant.textColorBlack),
                ),
              ],
            ),
            Constant.xSizedBox16,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: CustomContainer.mainCard(
                child: Column(
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 50,
                          height: 50,
                          child: status == true
                              ? Image.asset(
                                  width: 50,
                                  height: 50,
                                  'assets/icons/ic-smile.png',
                                )
                              : Image.asset(
                                  width: 50,
                                  height: 50,
                                  'assets/icons/ic-sad.png',
                                ),
                        ),
                        Constant.xSizedBox16,
                        Expanded(
                          child: Text(
                            'Total Run Out : ${totalCrockedness ?? 0}',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            Constant.xSizedBox16,
            toggleTab(),
            Container(
                child: tabController.index == 2
                    ? UpperChartView()
                    : tabController.index == 3
                        ? BoltChartView()
                        : SampleChartView(
                            activeIndex: tabController.index,
                            typePage: 'create')),
            Constant.xSizedBox16,
            Text('Detail Data', style: Constant.iBlackMedium16),
            Constant.xSizedBox8,
            Text(
              tabController1.index == 2
                  ? 'Detail data clutch yang telah di input'
                  : tabController1.index == 1
                      ? 'Detail data turbine yang telah di input'
                      : 'Detail data upper yang telah di input',
              style: TextStyle(fontSize: 12, color: Constant.grayColor),
            ),
            Constant.xSizedBox16,
            toggleTab1(),
            Constant.xSizedBox16,
            Container(
              child: tabController1.index == 2
                  ? turbineActive()
                  : tabController1.index == 1
                      ? clutchActive()
                      : upperActive(),
            ),
            Constant.xSizedBox16,
            acBdActive(),
            Constant.xSizedBox18,
          ],
        ),
      ),
    );
  }
}
