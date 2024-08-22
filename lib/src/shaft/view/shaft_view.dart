import 'dart:developer';

// import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hy_tutorial/common/component/custom_navigator.dart';
import 'package:hy_tutorial/generated/assets.dart';
import 'package:hy_tutorial/src/data/view/data_add_view.dart';
import 'package:hy_tutorial/src/home/view/home_admin_view.dart';
import 'package:hy_tutorial/src/home/view/home_view.dart';
import 'package:hy_tutorial/src/home/view/main_home.dart';
import 'package:hy_tutorial/src/turbine/view/turbine_view.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../common/component/custom_appbar.dart';
import '../../../common/component/custom_container.dart';
import '../../../common/helper/constant.dart';
import '../../../utils/utils.dart';
import 'sample_chart_view.dart';
import "package:provider/provider.dart";
import '../../../common/component/custom_textfield.dart';
import '../../data/provider/data_add_provider.dart';
import 'bolt_chart_view.dart';
import 'upper_chart_view.dart';

class ShaftView extends StatefulWidget {
  ShaftView({super.key});
  @override
  State<ShaftView> createState() => _ShaftViewState();
}

class _ShaftViewState extends State<ShaftView> with TickerProviderStateMixin {
  int currentIndex = 0;
  late TabController tabController;
  late TabController tabController1;
  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    final p = context.read<DataAddProvider>();
    tabController = TabController(length: 4, vsync: this, initialIndex: 3);
    tabController1 = TabController(length: 3, vsync: this);
    tabController.addListener(() {
      log("INDEX ACTIVE : ${tabController.index}");
      setState(() {});
    });
    tabController1.addListener(() {
      log("INDEX ACTIVE : ${tabController.index}");
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final d = context.watch<DataAddProvider>();
    final data = context.watch<DataAddProvider>().turbineCreateModel.data;
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
      return Center(
        child: TabBar(
          isScrollable: false,
          controller: tabController,
          indicatorWeight: 2,
          tabAlignment: TabAlignment.center,
          indicatorSize: TabBarIndicatorSize.tab,
          unselectedLabelColor: Constant.grayColor,
          labelColor: Constant.textColorBlack2,
          labelStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          unselectedLabelStyle: TextStyle(color: Color(0xff525252)),
          indicatorColor: Constant.primaryColor,
          tabs: [
            _buildTab("A-C"),
            _buildTab("B-D"),
            _buildTab("Resultan"),
            _buildTab("Baut")
          ],
        ),
      );
    }

    Widget toggleTab1() {
      return Center(
        child: TabBar(
          isScrollable: false,
          controller: tabController1,
          indicatorWeight: 2,
          tabAlignment: TabAlignment.fill,
          indicatorSize: TabBarIndicatorSize.tab,
          unselectedLabelColor: Constant.grayColor,
          labelColor: Constant.textColorBlack2,
          labelStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          unselectedLabelStyle: TextStyle(color: Color(0xff525252)),
          indicatorColor: Constant.primaryColor,
          tabs: [
            _buildTab("Upper"),
            _buildTab("Clutch"),
            _buildTab("Turbine"),
          ],
        ),
      );
    }

    TableRow tableRowItem({
      required String title,
      required String value,
      bool isGray = false,
    }) {
      return TableRow(
        decoration:
            !isGray ? null : BoxDecoration(color: Constant.tableGrayColor),
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child:
                Text(title, style: TextStyle(color: Constant.textColorBlack)),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Text(
              textAlign: TextAlign.center,
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Constant.textColorBlack2,
              ),
            ),
          ),
        ],
      );
    }

    Widget acBdActive() {
      return Table(
        border: TableBorder.all(
          color: Constant.borderSearchColor,
          width: 0.25,
          borderRadius: BorderRadius.circular(5),
        ),
        columnWidths: {
          0: FlexColumnWidth(6),
          1: FlexColumnWidth(2),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          tableRowItem(
            title: 'Total Baut',
            value: '${data?.totalBolts ?? 0}',
            isGray: true,
          ),
          tableRowItem(
            title: 'Torsi Terkini',
            value: '${data?.currentTorque ?? 0}',
          ),
          tableRowItem(
            title: 'Max Torsi',
            value: '${data?.maxTorque ?? 0}',
            isGray: true,
          ),
          tableRowItem(
            title: 'Selisih Torsi',
            value: '${data?.torqueGap ?? 0}',
          ),
          tableRowItem(
            title: 'Gen. Bearing-Kopling',
            value: '${shaft?.genBearingToCoupling ?? 0}',
            isGray: true,
          ),
          tableRowItem(
            title: 'Kopling - Turbin',
            value: '${shaft?.couplingToTurbine ?? 0}',
          ),
          tableRowItem(
            title: 'Total',
            value: '${shaft?.total ?? 0}',
            isGray: true,
          ),
          tableRowItem(
            title: 'Rasio',
            value: (shaft?.ratio ?? 0).toStringAsFixed(2),
          ),
        ],
      );
    }

    Widget clutchActive() => Table(
          border: TableBorder.all(
            color: Constant.borderSearchColor,
            width: 0.25,
            borderRadius: BorderRadius.circular(5),
          ),
          columnWidths: const <int, TableColumnWidth>{
            0: FlexColumnWidth(),
            1: FlexColumnWidth(),
            2: FlexColumnWidth(),
            3: FlexColumnWidth(),
            4: FlexColumnWidth(),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(
                decoration: BoxDecoration(color: Constant.tableGrayColor),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      'No.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Constant.textColorBlack2,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      'A',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Constant.textColorBlack2,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      'B',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Constant.textColorBlack2,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      'C',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Constant.textColorBlack2,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      'D',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Constant.textColorBlack2,
                      ),
                    ),
                  ),
                ]),
            TableRow(children: [
              Text('1', textAlign: TextAlign.center),
              CustomTextField.tableTextField(
                  borderColor: Colors.transparent,
                  readOnly: true,
                  controller: TextEditingController()
                    ..text = '${clutchData?.a?['1'] ?? 0}'),
              CustomTextField.tableTextField(
                  borderColor: Colors.transparent,
                  readOnly: true,
                  controller: TextEditingController()
                    ..text = '${clutchData?.b?['1'] ?? 0}'),
              CustomTextField.tableTextField(
                  borderColor: Colors.transparent,
                  readOnly: true,
                  controller: TextEditingController()
                    ..text = '${clutchData?.c?['1'] ?? 0}'),
              CustomTextField.tableTextField(
                  borderColor: Colors.transparent,
                  readOnly: true,
                  controller: TextEditingController()
                    ..text = '${clutchData?.d?['1'] ?? 0}'),
            ]),
            TableRow(
              decoration: BoxDecoration(color: Constant.tableGrayColor),
              children: [
                Text('2', textAlign: TextAlign.center),
                CustomTextField.tableTextField(
                    borderColor: Colors.transparent,
                    fillColor: Constant.tableGrayColor,
                    readOnly: true,
                    controller: TextEditingController()
                      ..text = '${clutchData?.a?['2'] ?? 0}'),
                CustomTextField.tableTextField(
                    borderColor: Colors.transparent,
                    fillColor: Constant.tableGrayColor,
                    readOnly: true,
                    controller: TextEditingController()
                      ..text = '${clutchData?.b?['2'] ?? 0}'),
                CustomTextField.tableTextField(
                    borderColor: Colors.transparent,
                    fillColor: Constant.tableGrayColor,
                    readOnly: true,
                    controller: TextEditingController()
                      ..text = '${clutchData?.c?['2'] ?? 0}'),
                CustomTextField.tableTextField(
                    borderColor: Colors.transparent,
                    fillColor: Constant.tableGrayColor,
                    readOnly: true,
                    controller: TextEditingController()
                      ..text = '${clutchData?.d?['2'] ?? 0}'),
              ],
            ),
            TableRow(
              children: [
                Text('3', textAlign: TextAlign.center),
                CustomTextField.tableTextField(
                    borderColor: Colors.transparent,
                    readOnly: true,
                    controller: TextEditingController()
                      ..text = '${clutchData?.a?['3'] ?? 0}'),
                CustomTextField.tableTextField(
                    borderColor: Colors.transparent,
                    readOnly: true,
                    controller: TextEditingController()
                      ..text = '${clutchData?.b?['3'] ?? 0}'),
                CustomTextField.tableTextField(
                    borderColor: Colors.transparent,
                    readOnly: true,
                    controller: TextEditingController()
                      ..text = '${clutchData?.c?['3'] ?? 0}'),
                CustomTextField.tableTextField(
                    borderColor: Colors.transparent,
                    readOnly: true,
                    controller: TextEditingController()
                      ..text = '${clutchData?.d?['3'] ?? 0}'),
              ],
            ),
            TableRow(
              decoration: BoxDecoration(color: Constant.tableGrayColor),
              children: [
                Text('4', textAlign: TextAlign.center),
                CustomTextField.tableTextField(
                    borderColor: Colors.transparent,
                    fillColor: Constant.tableGrayColor,
                    readOnly: true,
                    controller: TextEditingController()
                      ..text = '${clutchData?.a?['4'] ?? 0}'),
                CustomTextField.tableTextField(
                    borderColor: Colors.transparent,
                    fillColor: Constant.tableGrayColor,
                    readOnly: true,
                    controller: TextEditingController()
                      ..text = '${clutchData?.b?['4'] ?? 0}'),
                CustomTextField.tableTextField(
                    borderColor: Colors.transparent,
                    fillColor: Constant.tableGrayColor,
                    readOnly: true,
                    controller: TextEditingController()
                      ..text = '${clutchData?.c?['4'] ?? 0}'),
                CustomTextField.tableTextField(
                    borderColor: Colors.transparent,
                    fillColor: Constant.tableGrayColor,
                    readOnly: true,
                    controller: TextEditingController()
                      ..text = '${clutchData?.d?['4'] ?? 0}'),
              ],
            ),
          ],
        );

    Widget turbineActive() => Table(
          border: TableBorder.all(
            color: Constant.borderSearchColor,
            width: 0.25,
            borderRadius: BorderRadius.circular(5),
          ),
          columnWidths: const <int, TableColumnWidth>{
            0: FlexColumnWidth(),
            1: FlexColumnWidth(),
            2: FlexColumnWidth(),
            3: FlexColumnWidth(),
            4: FlexColumnWidth(),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(
                decoration: BoxDecoration(color: Constant.tableGrayColor),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      'No.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Constant.textColorBlack2,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      'A',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Constant.textColorBlack2,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      'B',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Constant.textColorBlack2,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      'C',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Constant.textColorBlack2,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      'D',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Constant.textColorBlack2,
                      ),
                    ),
                  ),
                ]),
            TableRow(children: [
              Text('1', textAlign: TextAlign.center),
              CustomTextField.tableTextField(
                  borderColor: Colors.transparent,
                  readOnly: true,
                  controller: TextEditingController()
                    ..text = '${turbineData?.a?['1'] ?? 0}'),
              CustomTextField.tableTextField(
                  borderColor: Colors.transparent,
                  readOnly: true,
                  controller: TextEditingController()
                    ..text = '${turbineData?.b?['1'] ?? 0}'),
              CustomTextField.tableTextField(
                  borderColor: Colors.transparent,
                  readOnly: true,
                  controller: TextEditingController()
                    ..text = '${turbineData?.c?['1'] ?? 0}'),
              CustomTextField.tableTextField(
                  borderColor: Colors.transparent,
                  readOnly: true,
                  controller: TextEditingController()
                    ..text = '${turbineData?.d?['1'] ?? 0}'),
            ]),
            TableRow(
              decoration: BoxDecoration(color: Constant.tableGrayColor),
              children: [
                Text('2', textAlign: TextAlign.center),
                CustomTextField.tableTextField(
                    borderColor: Colors.transparent,
                    fillColor: Constant.tableGrayColor,
                    readOnly: true,
                    controller: TextEditingController()
                      ..text = '${turbineData?.a?['2'] ?? 0}'),
                CustomTextField.tableTextField(
                    borderColor: Colors.transparent,
                    fillColor: Constant.tableGrayColor,
                    readOnly: true,
                    controller: TextEditingController()
                      ..text = '${turbineData?.b?['2'] ?? 0}'),
                CustomTextField.tableTextField(
                    borderColor: Colors.transparent,
                    fillColor: Constant.tableGrayColor,
                    readOnly: true,
                    controller: TextEditingController()
                      ..text = '${turbineData?.c?['2'] ?? 0}'),
                CustomTextField.tableTextField(
                    borderColor: Colors.transparent,
                    fillColor: Constant.tableGrayColor,
                    readOnly: true,
                    controller: TextEditingController()
                      ..text = '${turbineData?.d?['2'] ?? 0}'),
              ],
            ),
            TableRow(
              children: [
                Text('3', textAlign: TextAlign.center),
                CustomTextField.tableTextField(
                    borderColor: Colors.transparent,
                    readOnly: true,
                    controller: TextEditingController()
                      ..text = '${turbineData?.a?['3'] ?? 0}'),
                CustomTextField.tableTextField(
                    borderColor: Colors.transparent,
                    readOnly: true,
                    controller: TextEditingController()
                      ..text = '${turbineData?.b?['3'] ?? 0}'),
                CustomTextField.tableTextField(
                    borderColor: Colors.transparent,
                    readOnly: true,
                    controller: TextEditingController()
                      ..text = '${turbineData?.c?['3'] ?? 0}'),
                CustomTextField.tableTextField(
                    borderColor: Colors.transparent,
                    readOnly: true,
                    controller: TextEditingController()
                      ..text = '${turbineData?.d?['3'] ?? 0}'),
              ],
            ),
            TableRow(
              decoration: BoxDecoration(color: Constant.tableGrayColor),
              children: [
                Text('4', textAlign: TextAlign.center),
                CustomTextField.tableTextField(
                    borderColor: Colors.transparent,
                    fillColor: Constant.tableGrayColor,
                    readOnly: true,
                    controller: TextEditingController()
                      ..text = '${turbineData?.a?['4'] ?? 0}'),
                CustomTextField.tableTextField(
                    borderColor: Colors.transparent,
                    fillColor: Constant.tableGrayColor,
                    readOnly: true,
                    controller: TextEditingController()
                      ..text = '${turbineData?.b?['4'] ?? 0}'),
                CustomTextField.tableTextField(
                    borderColor: Colors.transparent,
                    fillColor: Constant.tableGrayColor,
                    readOnly: true,
                    controller: TextEditingController()
                      ..text = '${turbineData?.c?['4'] ?? 0}'),
                CustomTextField.tableTextField(
                    borderColor: Colors.transparent,
                    fillColor: Constant.tableGrayColor,
                    readOnly: true,
                    controller: TextEditingController()
                      ..text = '${turbineData?.d?['4'] ?? 0}'),
              ],
            ),
          ],
        );

    Widget upperActive() => Table(
          border: TableBorder.all(
            color: Constant.borderSearchColor,
            width: 0.25,
            borderRadius: BorderRadius.circular(5),
          ),
          columnWidths: const <int, TableColumnWidth>{
            0: FlexColumnWidth(),
            1: FlexColumnWidth(),
            2: FlexColumnWidth(),
            3: FlexColumnWidth(),
            4: FlexColumnWidth(),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(
                decoration: BoxDecoration(color: Constant.tableGrayColor),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      'No.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Constant.textColorBlack2,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      'A',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Constant.textColorBlack2,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      'B',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Constant.textColorBlack2,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      'C',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Constant.textColorBlack2,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      'D',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Constant.textColorBlack2,
                      ),
                    ),
                  ),
                ]),
            TableRow(children: [
              Text('1', textAlign: TextAlign.center),
              CustomTextField.tableTextField(
                  borderColor: Colors.transparent,
                  readOnly: true,
                  controller: TextEditingController()
                    ..text = '${upperData?.a?['1'] ?? 0}'),
              CustomTextField.tableTextField(
                  borderColor: Colors.transparent,
                  readOnly: true,
                  controller: TextEditingController()
                    ..text = '${upperData?.b?['1'] ?? 0}'),
              CustomTextField.tableTextField(
                  borderColor: Colors.transparent,
                  readOnly: true,
                  controller: TextEditingController()
                    ..text = '${upperData?.c?['1'] ?? 0}'),
              CustomTextField.tableTextField(
                  borderColor: Colors.transparent,
                  readOnly: true,
                  controller: TextEditingController()
                    ..text = '${upperData?.d?['1'] ?? 0}'),
            ]),
            TableRow(
              decoration: BoxDecoration(color: Constant.tableGrayColor),
              children: [
                Text('2', textAlign: TextAlign.center),
                CustomTextField.tableTextField(
                    borderColor: Colors.transparent,
                    fillColor: Constant.tableGrayColor,
                    readOnly: true,
                    controller: TextEditingController()
                      ..text = '${upperData?.a?['2'] ?? 0}'),
                CustomTextField.tableTextField(
                    borderColor: Colors.transparent,
                    fillColor: Constant.tableGrayColor,
                    readOnly: true,
                    controller: TextEditingController()
                      ..text = '${upperData?.b?['2'] ?? 0}'),
                CustomTextField.tableTextField(
                    borderColor: Colors.transparent,
                    fillColor: Constant.tableGrayColor,
                    readOnly: true,
                    controller: TextEditingController()
                      ..text = '${upperData?.c?['2'] ?? 0}'),
                CustomTextField.tableTextField(
                    borderColor: Colors.transparent,
                    fillColor: Constant.tableGrayColor,
                    readOnly: true,
                    controller: TextEditingController()
                      ..text = '${upperData?.d?['2'] ?? 0}'),
              ],
            ),
            TableRow(
              children: [
                Text('3', textAlign: TextAlign.center),
                CustomTextField.tableTextField(
                    borderColor: Colors.transparent,
                    readOnly: true,
                    controller: TextEditingController()
                      ..text = '${upperData?.a?['3'] ?? 0}'),
                CustomTextField.tableTextField(
                    borderColor: Colors.transparent,
                    readOnly: true,
                    controller: TextEditingController()
                      ..text = '${upperData?.b?['3'] ?? 0}'),
                CustomTextField.tableTextField(
                    borderColor: Colors.transparent,
                    readOnly: true,
                    controller: TextEditingController()
                      ..text = '${upperData?.c?['3'] ?? 0}'),
                CustomTextField.tableTextField(
                    borderColor: Colors.transparent,
                    readOnly: true,
                    controller: TextEditingController()
                      ..text = '${upperData?.d?['3'] ?? 0}'),
              ],
            ),
            TableRow(
              decoration: BoxDecoration(color: Constant.tableGrayColor),
              children: [
                Text('4', textAlign: TextAlign.center),
                CustomTextField.tableTextField(
                    borderColor: Colors.transparent,
                    fillColor: Constant.tableGrayColor,
                    readOnly: true,
                    controller: TextEditingController()
                      ..text = '${upperData?.a?['4'] ?? 0}'),
                CustomTextField.tableTextField(
                    borderColor: Colors.transparent,
                    fillColor: Constant.tableGrayColor,
                    readOnly: true,
                    controller: TextEditingController()
                      ..text = '${upperData?.b?['4'] ?? 0}'),
                CustomTextField.tableTextField(
                    borderColor: Colors.transparent,
                    fillColor: Constant.tableGrayColor,
                    readOnly: true,
                    controller: TextEditingController()
                      ..text = '${upperData?.c?['4'] ?? 0}'),
                CustomTextField.tableTextField(
                    borderColor: Colors.transparent,
                    fillColor: Constant.tableGrayColor,
                    readOnly: true,
                    controller: TextEditingController()
                      ..text = '${upperData?.d?['4'] ?? 0}'),
              ],
            ),
          ],
        );

    return Scaffold(
      appBar: CustomAppBar.appBar(
        context,
        'Detail Laporan',
        color: Constant.primaryColor,
        foregroundColor: Colors.white,
        leading: InkWell(
          onTap: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            final isAdmin = prefs.getBool(Constant.kSetPrefIsAdmin) ?? false;
            if (isAdmin) {
              // await CusNav.nPopUntil(context,
              //     predicate: (route) => route is MainHome);
              //CusNav.nPop(context);
              CusNav.nPop(context);
              CusNav.nPop(context);
              CusNav.nPush(context, TurbineView());
            } else {
              CusNav.nPushAndRemoveUntil(context, HomeView());
            }
          },
          child: Icon(Icons.keyboard_arrow_left),
        ),
        action: [
          InkWell(
            onTap: () async {
              Utils.showYesNoDialogWithWarning(
                  context: context,
                  title: "Konfirmasi Penghapusan",
                  desc: "Apakah anda yakin ingin\nmenghapus turbine ini?",
                  yesCallback: () async {
                    Navigator.pop(context);
                    await context
                        .read<DataAddProvider>()
                        .deleteTurbine(context, id: data?.id ?? "0");

                    getData();
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    final isAdmin =
                        prefs.getBool(Constant.kSetPrefIsAdmin) ?? false;
                    if (isAdmin) {
                      await CusNav.nPopUntil(context,
                          predicate: (route) => route is MainHome);
                      CusNav.nPush(context, TurbineView());
                    } else {
                      CusNav.nPushAndRemoveUntil(context, HomeView());
                    }
                  },
                  noCallback: () async {
                    Navigator.pop(context);
                  });
            },
            child: Container(
              margin: EdgeInsets.only(right: 20),
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Constant.redColor,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    Icons.delete_forever_rounded,
                    size: 15,
                  ),
                  Text(
                    "Hapus",
                    style:
                        Constant.iPrimaryMedium12.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        shrinkWrap: true,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Constant.primaryColor,
              image: DecorationImage(
                alignment: Alignment.bottomCenter,
                image: AssetImage(Assets.imagesImgHomeTop),
                fit: BoxFit.fitWidth,
              ),
            ),
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(20, 8, 20, 15),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            data?.createdBy ?? '',
                            style: Constant.iBlackMedium16.copyWith(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Constant.xSizedBox4,
                          Text(
                            data?.title ?? '',
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      flex: 5,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          margin: EdgeInsets.only(top: 8),
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Text(
                            '${DateFormat('dd/MM/yyyy  |  HH : mm').format(DateFormat('yyyy-MM-dd HH:mm:ss').parse(d.turbineCreateModel.data?.createdAt ?? '${DateTime.now()}'))}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                CustomContainer.mainCard(
                  margin: EdgeInsets.only(top: 16),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  color: Colors.white12,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: status == true
                                ? Image.asset(Assets.iconsIcSmile)
                                : Image.asset(Assets.iconsIcSad),
                          ),
                          Constant.xSizedBox12,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Run Out : ',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                                Constant.xSizedBox4,
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      flex: 8,
                                      child: Text(
                                        '${totalCrockedness ?? 0}',
                                        textAlign: TextAlign.left,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Constant.xSizedBox4,
                                    Expanded(
                                      flex: 4,
                                      child: Text(
                                        'X 0,01 mm',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          Constant.xSizedBox16,
          CustomContainer.mainCard(
            margin: EdgeInsets.symmetric(horizontal: 16),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  tabController.index == 2 ? 'Grafik Resultan' : 'Grafik Shaft',
                  style: TextStyle(
                    color: Constant.textColorBlack2,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Constant.xSizedBox12,
                toggleTab(),
                Container(
                    child: tabController.index == 2
                        ? UpperChartView()
                        : tabController.index == 3
                            ? BoltChartView()
                            : SampleChartView(
                                activeIndex: tabController.index,
                                typePage: 'detail')),
              ],
            ),
          ),
          Constant.xSizedBox16,
          CustomContainer.mainCard(
            margin: EdgeInsets.symmetric(horizontal: 16),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Detail Data',
                      style: TextStyle(
                        color: Constant.textColorBlack2,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        border:
                            Border.all(width: 1, color: Constant.primaryColor),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: InkWell(
                        onTap: () async {
                          if (data?.id != null) {
                            await context
                                .read<DataAddProvider>()
                                .downloadTurbine(context, id: data?.id ?? '-');
                          } else {
                            await Utils.showFailed(
                                msg: 'ID Laporan tidak diketahui');
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(
                              Icons.save_alt_rounded,
                              size: 15,
                              color: Constant.primaryColor,
                            ),
                            Constant.xSizedBox4,
                            Text(
                              "Unduh",
                              style: Constant.iPrimaryMedium12,
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                Constant.xSizedBox12,
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
          Constant.xSizedBox16,
        ],
      ),
    );
  }
}
