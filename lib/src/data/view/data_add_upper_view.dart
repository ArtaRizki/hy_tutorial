import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hy_tutorial/common/base/base_state.dart';
import 'package:hy_tutorial/common/component/custom_textfield.dart';
import 'package:hy_tutorial/common/helper/constant.dart';
import 'package:hy_tutorial/src/data/model/create_data_param.dart';
import 'package:hy_tutorial/src/data/view/data_add_clutch_view.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../utils/utils.dart';
import '../provider/data_add_provider.dart';
import '../../../common/component/custom_appbar.dart';
import '../../../common/component/custom_button.dart';

class DataAddUpperView extends StatefulWidget {
  const DataAddUpperView({super.key});

  @override
  State<DataAddUpperView> createState() => _DataAddUpperViewState();
}

class _DataAddUpperViewState extends BaseState<DataAddUpperView>
    with TickerProviderStateMixin {
  late TabController tabController;
  @override
  void initState() {
    setData();
    super.initState();
  }

  setData() async {
    tabController = TabController(length: 3, vsync: this);
    tabController.addListener(() {
      log("INDEX ACTIVE : ${tabController.index}");
      setState(() {});
    });
  }

  generateAllData() async {
    final p = context.read<DataAddProvider>();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString(Constant.kSetPrefParamCreateTurbine);
    log('CREATE DATA PARAM : $data');
    if (data != null) {
      p.createDataParam = CreateDataParam.fromJson(jsonDecode(data));
      generateShaftLocalData(p.createDataParam);
      generateDataUpperRowLocal();
      generateDataClutchRowLocal();
      generateDataTurbineRowLocal();
      setState(() {});
    } else {
      generateDataUpperRow();
      generateDataClutchRow();
      generateDataTurbineRow();
    }
  }

  generateShaftLocalData(CreateDataParam? data) {
    final p = context.read<DataAddProvider>();
    if (data != null) {
      p.selectedPlta = data.TowerId;
      if (data.GenBearingToCoupling != null)
        p.genBearingKoplingC.text = data.GenBearingToCoupling ?? '';
      if (data.CouplingToTurbine != null)
        p.koplingTurbinC.text = data.CouplingToTurbine ?? '';
      if ((data.CouplingToTurbine == null || data.CouplingToTurbine == '') &&
          (data.GenBearingToCoupling == '' ||
              data.GenBearingToCoupling == '')) {
        p.totalC.text = '0';
        p.rasioC.text = '0';
      } else {
        if (data.CouplingToTurbine?.trim() != '') {
          double value = double.tryParse(data.CouplingToTurbine ?? '0') ?? 0;
          if (p.genBearingKoplingC.text.isEmpty) {
            p.totalC.text = "$value";
            p.rasioC.text = '0';
          } else {
            p.totalC.text =
                "${value + (double.tryParse(p.genBearingKoplingC.text) ?? 0)}";
            p.rasioC.text =
                "${(double.tryParse(p.koplingTurbinC.text) ?? 0 / (double.tryParse(p.totalC.text) ?? 0)).toStringAsFixed(2)}";
          }
        } else {
          p.totalC.text = "${double.tryParse(p.genBearingKoplingC.text)}";
          p.rasioC.text = '0';
        }
      }
    }
  }

  generateDataUpperRowLocal() {
    final p = context.read<DataAddProvider>();
    for (int i = 0; i < 5; i++) {
      if (i == 0) {
        p.wDataUpperRow.add(TableRow(children: [
          Text('\n\n', textAlign: TextAlign.center),
          Text('\nA\n', textAlign: TextAlign.center),
          Text('\nB\n', textAlign: TextAlign.center),
          Text('\nC\n', textAlign: TextAlign.center),
          Text('\nD\n', textAlign: TextAlign.center),
        ]));
      } else {
        if (i == 1) {
          p.dataUpperC.add([
            TextEditingController()
              ..text = (p.createDataParam?.Data?.Upper?.A?[0]).toString(),
            TextEditingController()
              ..text = (p.createDataParam?.Data?.Upper?.A?[1]).toString(),
            TextEditingController()
              ..text = (p.createDataParam?.Data?.Upper?.A?[2]).toString(),
            TextEditingController()
              ..text = (p.createDataParam?.Data?.Upper?.A?[3]).toString(),
          ]);
        }
        if (i == 2) {
          p.dataUpperC.add([
            TextEditingController()
              ..text = (p.createDataParam?.Data?.Upper?.B?[0]).toString(),
            TextEditingController()
              ..text = (p.createDataParam?.Data?.Upper?.B?[1]).toString(),
            TextEditingController()
              ..text = (p.createDataParam?.Data?.Upper?.B?[2]).toString(),
            TextEditingController()
              ..text = (p.createDataParam?.Data?.Upper?.B?[3]).toString(),
          ]);
        }
        if (i == 3) {
          p.dataUpperC.add([
            TextEditingController()
              ..text = (p.createDataParam?.Data?.Upper?.C?[0]).toString(),
            TextEditingController()
              ..text = (p.createDataParam?.Data?.Upper?.C?[1]).toString(),
            TextEditingController()
              ..text = (p.createDataParam?.Data?.Upper?.C?[2]).toString(),
            TextEditingController()
              ..text = (p.createDataParam?.Data?.Upper?.C?[3]).toString(),
          ]);
        }
        if (i == 4) {
          p.dataUpperC.add([
            TextEditingController()
              ..text = (p.createDataParam?.Data?.Upper?.D?[0]).toString(),
            TextEditingController()
              ..text = (p.createDataParam?.Data?.Upper?.D?[1]).toString(),
            TextEditingController()
              ..text = (p.createDataParam?.Data?.Upper?.D?[2]).toString(),
            TextEditingController()
              ..text = (p.createDataParam?.Data?.Upper?.D?[3]).toString(),
          ]);
        }
        p.wDataUpperRow.add(TableRow(children: [
          Text('$i', textAlign: TextAlign.center),
          CustomTextField.tableTextField(
            controller: p.dataUpperC[i - 1][0],
            onChange: (_) => setState(() {}),
          ),
          CustomTextField.tableTextField(
            controller: p.dataUpperC[i - 1][1],
            onChange: (_) => setState(() {}),
          ),
          CustomTextField.tableTextField(
            controller: p.dataUpperC[i - 1][2],
            onChange: (_) => setState(() {}),
          ),
          CustomTextField.tableTextField(
            controller: p.dataUpperC[i - 1][3],
            onChange: (_) => setState(() {}),
          ),
        ]));
      }
    }
  }

  generateDataClutchRowLocal() {
    final p = context.read<DataAddProvider>();
    for (int i = 0; i < 5; i++) {
      if (i == 0) {
        p.wDataClutchRow.add(TableRow(children: [
          Text('\n\n', textAlign: TextAlign.center),
          Text('\nA\n', textAlign: TextAlign.center),
          Text('\nB\n', textAlign: TextAlign.center),
          Text('\nC\n', textAlign: TextAlign.center),
          Text('\nD\n', textAlign: TextAlign.center),
        ]));
      } else {
        if (i == 1) {
          p.dataClutchC.add([
            TextEditingController()
              ..text = (p.createDataParam?.Data?.Clutch?.A?[0]).toString(),
            TextEditingController()
              ..text = (p.createDataParam?.Data?.Clutch?.A?[1]).toString(),
            TextEditingController()
              ..text = (p.createDataParam?.Data?.Clutch?.A?[2]).toString(),
            TextEditingController()
              ..text = (p.createDataParam?.Data?.Clutch?.A?[3]).toString(),
          ]);
        }
        if (i == 2) {
          p.dataClutchC.add([
            TextEditingController()
              ..text = (p.createDataParam?.Data?.Clutch?.B?[0]).toString(),
            TextEditingController()
              ..text = (p.createDataParam?.Data?.Clutch?.B?[1]).toString(),
            TextEditingController()
              ..text = (p.createDataParam?.Data?.Clutch?.B?[2]).toString(),
            TextEditingController()
              ..text = (p.createDataParam?.Data?.Clutch?.B?[3]).toString(),
          ]);
        }
        if (i == 3) {
          p.dataClutchC.add([
            TextEditingController()
              ..text = (p.createDataParam?.Data?.Clutch?.C?[0]).toString(),
            TextEditingController()
              ..text = (p.createDataParam?.Data?.Clutch?.C?[1]).toString(),
            TextEditingController()
              ..text = (p.createDataParam?.Data?.Clutch?.C?[2]).toString(),
            TextEditingController()
              ..text = (p.createDataParam?.Data?.Clutch?.C?[3]).toString(),
          ]);
        }
        if (i == 4) {
          p.dataClutchC.add([
            TextEditingController()
              ..text = (p.createDataParam?.Data?.Clutch?.D?[0]).toString(),
            TextEditingController()
              ..text = (p.createDataParam?.Data?.Clutch?.D?[1]).toString(),
            TextEditingController()
              ..text = (p.createDataParam?.Data?.Clutch?.D?[2]).toString(),
            TextEditingController()
              ..text = (p.createDataParam?.Data?.Clutch?.D?[3]).toString(),
          ]);
        }
        p.wDataClutchRow.add(TableRow(children: [
          Text('$i', textAlign: TextAlign.center),
          CustomTextField.tableTextField(
            controller: p.dataClutchC[i - 1][0],
            onChange: (_) => setState(() {}),
          ),
          CustomTextField.tableTextField(
            controller: p.dataClutchC[i - 1][1],
            onChange: (_) => setState(() {}),
          ),
          CustomTextField.tableTextField(
            controller: p.dataClutchC[i - 1][2],
            onChange: (_) => setState(() {}),
          ),
          CustomTextField.tableTextField(
            controller: p.dataClutchC[i - 1][3],
            onChange: (_) => setState(() {}),
          ),
        ]));
      }
    }
  }

  generateDataTurbineRowLocal() {
    final p = context.read<DataAddProvider>();
    for (int i = 0; i < 5; i++) {
      if (i == 0) {
        p.wDataTurbineRow.add(TableRow(children: [
          Text('\n\n', textAlign: TextAlign.center),
          Text('\nA\n', textAlign: TextAlign.center),
          Text('\nB\n', textAlign: TextAlign.center),
          Text('\nC\n', textAlign: TextAlign.center),
          Text('\nD\n', textAlign: TextAlign.center),
        ]));
      } else {
        if (i == 1) {
          p.dataTurbineC.add([
            TextEditingController()
              ..text = (p.createDataParam?.Data?.Turbine?.A?[0]).toString(),
            TextEditingController()
              ..text = (p.createDataParam?.Data?.Turbine?.A?[1]).toString(),
            TextEditingController()
              ..text = (p.createDataParam?.Data?.Turbine?.A?[2]).toString(),
            TextEditingController()
              ..text = (p.createDataParam?.Data?.Turbine?.A?[3]).toString(),
          ]);
        }
        if (i == 2) {
          p.dataTurbineC.add([
            TextEditingController()
              ..text = (p.createDataParam?.Data?.Turbine?.B?[0]).toString(),
            TextEditingController()
              ..text = (p.createDataParam?.Data?.Turbine?.B?[1]).toString(),
            TextEditingController()
              ..text = (p.createDataParam?.Data?.Turbine?.B?[2]).toString(),
            TextEditingController()
              ..text = (p.createDataParam?.Data?.Turbine?.B?[3]).toString(),
          ]);
        }
        if (i == 3) {
          p.dataTurbineC.add([
            TextEditingController()
              ..text = (p.createDataParam?.Data?.Turbine?.C?[0]).toString(),
            TextEditingController()
              ..text = (p.createDataParam?.Data?.Turbine?.C?[1]).toString(),
            TextEditingController()
              ..text = (p.createDataParam?.Data?.Turbine?.C?[2]).toString(),
            TextEditingController()
              ..text = (p.createDataParam?.Data?.Turbine?.C?[3]).toString(),
          ]);
        }
        if (i == 4) {
          p.dataTurbineC.add([
            TextEditingController()
              ..text = (p.createDataParam?.Data?.Turbine?.D?[0]).toString(),
            TextEditingController()
              ..text = (p.createDataParam?.Data?.Turbine?.D?[1]).toString(),
            TextEditingController()
              ..text = (p.createDataParam?.Data?.Turbine?.D?[2]).toString(),
            TextEditingController()
              ..text = (p.createDataParam?.Data?.Turbine?.D?[3]).toString(),
          ]);
        }
        p.wDataTurbineRow.add(TableRow(children: [
          Text('$i', textAlign: TextAlign.center),
          CustomTextField.tableTextField(
            controller: p.dataTurbineC[i - 1][0],
            onChange: (_) => setState(() {}),
          ),
          CustomTextField.tableTextField(
            controller: p.dataTurbineC[i - 1][1],
            onChange: (_) => setState(() {}),
          ),
          CustomTextField.tableTextField(
            controller: p.dataTurbineC[i - 1][2],
            onChange: (_) => setState(() {}),
          ),
          CustomTextField.tableTextField(
            controller: p.dataTurbineC[i - 1][3],
            onChange: (_) => setState(() {}),
          ),
        ]));
      }
    }
  }

  generateDataUpperRow() {
    final p = context.read<DataAddProvider>();
    for (int i = 0; i < 5; i++) {
      if (i == 0) {
        p.wDataUpperRow.add(TableRow(children: [
          Text('\n\n', textAlign: TextAlign.center),
          Text('\nA\n', textAlign: TextAlign.center),
          Text('\nB\n', textAlign: TextAlign.center),
          Text('\nC\n', textAlign: TextAlign.center),
          Text('\nD\n', textAlign: TextAlign.center),
        ]));
      } else {
        p.dataUpperC.add([
          TextEditingController(),
          TextEditingController(),
          TextEditingController(),
          TextEditingController()
        ]);
        p.wDataUpperRow.add(TableRow(children: [
          Text('$i', textAlign: TextAlign.center),
          CustomTextField.tableTextField(
            controller: p.dataUpperC[i - 1][0],
            onChange: (_) => setState(() {}),
          ),
          CustomTextField.tableTextField(
            controller: p.dataUpperC[i - 1][1],
            onChange: (_) => setState(() {}),
          ),
          CustomTextField.tableTextField(
            controller: p.dataUpperC[i - 1][2],
            onChange: (_) => setState(() {}),
          ),
          CustomTextField.tableTextField(
            controller: p.dataUpperC[i - 1][3],
            onChange: (_) => setState(() {}),
          ),
        ]));
      }
    }
  }

  generateDataClutchRow() {
    final p = context.read<DataAddProvider>();
    for (int i = 0; i < 5; i++) {
      if (i == 0) {
        p.wDataClutchRow.add(TableRow(children: [
          Text('\n\n', textAlign: TextAlign.center),
          Text('\nA\n', textAlign: TextAlign.center),
          Text('\nB\n', textAlign: TextAlign.center),
          Text('\nC\n', textAlign: TextAlign.center),
          Text('\nD\n', textAlign: TextAlign.center),
        ]));
      } else {
        p.dataClutchC.add([
          TextEditingController(),
          TextEditingController(),
          TextEditingController(),
          TextEditingController()
        ]);
        p.wDataClutchRow.add(TableRow(children: [
          Text('$i', textAlign: TextAlign.center),
          CustomTextField.tableTextField(
            controller: p.dataClutchC[i - 1][0],
            onChange: (_) => setState(() {}),
          ),
          CustomTextField.tableTextField(
            controller: p.dataClutchC[i - 1][1],
            onChange: (_) => setState(() {}),
          ),
          CustomTextField.tableTextField(
            controller: p.dataClutchC[i - 1][2],
            onChange: (_) => setState(() {}),
          ),
          CustomTextField.tableTextField(
            controller: p.dataClutchC[i - 1][3],
            onChange: (_) => setState(() {}),
          ),
        ]));
      }
    }
  }

  generateDataTurbineRow() {
    final p = context.read<DataAddProvider>();
    for (int i = 0; i < 5; i++) {
      if (i == 0) {
        p.wDataTurbineRow.add(TableRow(children: [
          Text('\n\n', textAlign: TextAlign.center),
          Text('\nA\n', textAlign: TextAlign.center),
          Text('\nB\n', textAlign: TextAlign.center),
          Text('\nC\n', textAlign: TextAlign.center),
          Text('\nD\n', textAlign: TextAlign.center),
        ]));
      } else {
        p.dataTurbineC.add([
          TextEditingController(),
          TextEditingController(),
          TextEditingController(),
          TextEditingController()
        ]);
        p.wDataTurbineRow.add(TableRow(children: [
          Text('$i', textAlign: TextAlign.center),
          CustomTextField.tableTextField(
            controller: p.dataTurbineC[i - 1][0],
            onChange: (_) => setState(() {}),
          ),
          CustomTextField.tableTextField(
            controller: p.dataTurbineC[i - 1][1],
            onChange: (_) => setState(() {}),
          ),
          CustomTextField.tableTextField(
            controller: p.dataTurbineC[i - 1][2],
            onChange: (_) => setState(() {}),
          ),
          CustomTextField.tableTextField(
            controller: p.dataTurbineC[i - 1][3],
            onChange: (_) => setState(() {}),
          ),
        ]));
      }
    }
  }

  Widget _buildTab(String tag) {
    return Tab(
        child: Text(
      tag,
      style: TextStyle(fontSize: 18),
      textAlign: TextAlign.left,
    ));
  }

  Widget toggleTab() {
    return TabBar(
      isScrollable: false,
      controller: tabController,
      indicatorWeight: 4,
      tabAlignment: TabAlignment.fill,
      indicatorSize: TabBarIndicatorSize.tab,
      unselectedLabelColor: Constant.grayColor,
      labelColor: Constant.primaryColor,
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w300),
      indicatorColor: Constant.primaryColor,
      tabs: [
        _buildTab("Upper"),
        _buildTab("Clutch"),
        _buildTab("Turbine"),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<DataAddProvider>();

    Widget tableFormUpper() {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Table(
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
              children: p.wDataUpperRow,
            ),
          ),
        ],
      );
    }

    Widget upperForm() {
      return ListView(
        shrinkWrap: true,
        children: [
          Text("Upper", style: Constant.blackBold20),
          Constant.xSizedBox8,
          Text("Masukan data upper pada tabel", style: Constant.grayMedium),
          Constant.xSizedBox16,
          tableFormUpper(),
          Constant.xSizedBox16,
        ],
      );
    }

    Widget tableFormClutch() {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Table(
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
              children: p.wDataClutchRow,
            ),
          ),
        ],
      );
    }

    Widget clutchForm() {
      return ListView(
        children: [
          Text("Clutch", style: Constant.blackBold20),
          Constant.xSizedBox8,
          Text("Masukan data upper pada tabel", style: Constant.grayMedium),
          Constant.xSizedBox16,
          tableFormClutch(),
          Constant.xSizedBox16,
        ],
      );
    }

    Widget tableFormTurbine() {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Table(
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
              children: p.wDataTurbineRow,
            ),
          ),
        ],
      );
    }

    Widget turbineForm() {
      return ListView(
        children: [
          Text("Turbine", style: Constant.blackBold20),
          Constant.xSizedBox8,
          Text("Masukan data upper pada tabel", style: Constant.grayMedium),
          Constant.xSizedBox16,
          tableFormTurbine(),
          Constant.xSizedBox16,
        ],
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar.appBar(context, "Tambah Data Shaft",
          color: Constant.primaryColor, foregroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
        child: Column(
          children: [
            toggleTab(),
            Constant.xSizedBox16,
            Expanded(
              child: TabBarView(
                physics: NeverScrollableScrollPhysics(),
                controller: tabController,
                children: [upperForm(), clutchForm(), turbineForm()],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
              child: CustomButton.mainButton(
                'Selanjutnya',
                enabled: p.validateAddShaft(),
                () async {
                  final dataP = context.read<DataAddProvider>();
                  FocusManager.instance.primaryFocus?.unfocus();
                  if (dataP.validateAddShaft()) {
                    await Utils.showYesNoDialog(
                      context: context,
                      title: "Konfirmasi",
                      desc: "Apakah Data Anda Sudah Benar?",
                      yesCallback: () => handleTap(() async {
                        Navigator.pop(context);
                        p.sendCreateTurbines(context);
                      }),
                      noCallback: () => Navigator.pop(context),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
