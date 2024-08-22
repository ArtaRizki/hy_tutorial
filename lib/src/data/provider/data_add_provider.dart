import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:drop_down_search_field/drop_down_search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hy_tutorial/common/base/base_response.dart';
import 'package:hy_tutorial/common/component/custom_container.dart';
import 'package:hy_tutorial/common/component/custom_dropdown.dart';
import 'package:hy_tutorial/common/component/custom_navigator.dart';
import 'package:hy_tutorial/common/helper/download.dart';
import 'package:hy_tutorial/src/data/view/data_add_view.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:powers/powers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../main.dart';
import '../../../utils/utils.dart';
import '../../shaft/view/shaft_view.dart';
import '../model/create_data_param.dart';
import '../../plta/model/plta_model.dart';
import '../../turbine/model/turbine_create_model.dart';
import '../../../common/base/base_controller.dart';
import '../../../common/helper/constant.dart';
import '../../../common/component/custom_textfield.dart';

class DataAddProvider extends BaseController with ChangeNotifier {
  GlobalKey<FormState> dataAddKey = GlobalKey<FormState>();

  TextEditingController titleC = TextEditingController();
  TextEditingController pltaC = TextEditingController();
  TextEditingController genBearingKoplingC = TextEditingController();
  TextEditingController koplingTurbinC = TextEditingController();
  TextEditingController totalC = TextEditingController();
  TextEditingController rasioC = TextEditingController();

  TextEditingController boltQtyC = TextEditingController();
  TextEditingController currentTorqueC = TextEditingController();
  TextEditingController maxTorqueC = TextEditingController();
  TextEditingController differenceQtyC = TextEditingController();

  List<String> boltList = [
    "2",
    "4",
    "6",
    "8",
    "10",
    "12",
    "14",
    "16",
    "18",
    "20",
    "22",
    "24",
  ];
  String? _selectedBolt;
  String? get selectedBolt => this._selectedBolt;
  set selectedBolt(String? value) => this._selectedBolt = value;

  String? selectedDropdown;
  String? selectedPlta;
  PltaModelData? _selectedPltaModel;
  PltaModelData? get selectedPltaModel => this._selectedPltaModel;
  set selectedPltaModel(PltaModelData? value) {
    this._selectedPltaModel = value;
  }

  PltaModel _pltaModel = PltaModel();
  PltaModel get pltaModel => this._pltaModel;
  set pltaModel(PltaModel value) => this._pltaModel = value;

  List<PltaModelData?>? _pltaList = [];
  List<PltaModelData?>? get pltaList => this._pltaList;

  set pltaList(List<PltaModelData?>? value) {
    this._pltaList = value;
    notifyListeners();
  }

  List<String> dropdownList = [
    "Upper",
    "Clutch",
    "Turbine",
  ];
  List<int> selectedUpper = [];
  DataAddViewState? dataAddViewState;

  resetData() {
    // pltaList.clear();
    titleC.clear();
    selectedPlta = null;
    selectedPltaModel = null;
    selectedBolt = null;
    pltaC.text = '';
    genBearingKoplingC.clear();
    koplingTurbinC.clear();
    totalC.clear();
    rasioC.clear();
    boltQtyC.clear();
    currentTorqueC.clear();
    maxTorqueC.clear();
    differenceQtyC.clear();
    wDataUpperRow.clear();
    wDataClutchRow.clear();
    wDataTurbineRow.clear();
    dataUpperC.clear();
    dataClutchC.clear();
    dataTurbineC.clear();
    selectedPlta = null;
  }

  clearDetailData() {
    // AC
    acClutchTemp.clear();
    acTurbineTemp.clear();
    acUpperTemp.clear();
    acClutch.clear();
    acTurbine.clear();
    acUpper.clear();
    acCrockedLine = 0;
    // BD
    bdClutchTemp.clear();
    bdTurbineTemp.clear();
    bdUpperTemp.clear();
    bdClutch.clear();
    bdTurbine.clear();
    bdUpper.clear();
    bdCrockedLine = 0.0;
    // UPPER
    upper.clear();
    upperBolt.clear();
    listBoltsKey.clear();
    listBolts.clear();
    listTorqueSuggestionsKey.clear();
    listTorqueSuggestions.clear();
    listTorqueSuggestionsY.clear();
    upperCrockedLine = 0.0;
  }

  Future<PltaModel> fetchPlta(BuildContext context) async {
    loading(true);
    pltaModel = PltaModel();
    final response = await get(Constant.BASE_API_FULL + '/plta/master');

    if (response.statusCode == 201 || response.statusCode == 200) {
      final model = PltaModel.fromJson(jsonDecode(response.body));
      pltaList = model.Data;
      // notifyListeners();
      loading(false);
      return model;
    } else {
      final message = jsonDecode(response.body)["Message"];
      loading(false);
      return PltaModel();
      // throw Exception(message);
    }
  }

  TurbineCreateModel _turbineDetailModel = TurbineCreateModel();
  TurbineCreateModel get turbineDetailModel => this._turbineDetailModel;
  set turbineDetailModel(TurbineCreateModel value) =>
      this._turbineDetailModel = value;

  Future<TurbineCreateModel> fetchTurbineDetail(String id) async {
    loading(true);
    try {
      turbineDetailModel = TurbineCreateModel();
      clearDetailData();
      final response = await get(Constant.BASE_API_FULL + '/turbines/$id');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final model = TurbineCreateModel.fromJson(jsonDecode(response.body));
        turbineDetailModel = model;
        notifyListeners();
        setDataChartDetail();
        loading(false);
        return model;
      } else {
        final message = jsonDecode(response.body)["Message"];
        loading(false);
        return TurbineCreateModel();
        // throw Exception(message);
      }
    } catch (e) {
      loading(false);
      Utils.showFailed(msg: "Gagal Mendapatkan Data Turbine");
      return TurbineCreateModel();
    }
  }

  TurbineCreateModel _turbineLatestModel = TurbineCreateModel();
  TurbineCreateModel get turbineLatestModel => this._turbineLatestModel;
  set turbineLatestModel(TurbineCreateModel value) =>
      this._turbineLatestModel = value;

  Future<TurbineCreateModel> fetchTurbineLatest() async {
    loading(true);
    turbineLatestModel = TurbineCreateModel();
    clearDetailData();
    final response = await get(Constant.BASE_API_FULL + '/turbines/latest');

    if (response.statusCode == 201 || response.statusCode == 200) {
      final model = TurbineCreateModel.fromJson(jsonDecode(response.body));
      turbineLatestModel = model;
      notifyListeners();
      setDataChartLatest();
      loading(false);
      return model;
    } else {
      final message = jsonDecode(response.body)["Message"];
      loading(false);
      return TurbineCreateModel();
      // throw Exception(message);
    }
  }

  TurbineCreateModel _turbineCreateModel = TurbineCreateModel();
  TurbineCreateModel get turbineCreateModel => this._turbineCreateModel;
  set turbineCreateModel(TurbineCreateModel value) =>
      this._turbineCreateModel = value;

  CreateDataParam? _createDataParam = CreateDataParam();
  CreateDataParam? get createDataParam => this._createDataParam;
  set createDataParam(CreateDataParam? value) => this._createDataParam = value;

  // AC
  List<double> acClutchTemp = [];
  List<double> acTurbineTemp = [];
  List<double> acUpperTemp = [];
  List<double> acClutch = [];
  List<double> acTurbine = [];
  List<double> acUpper = [];
  double acCrockedLine = 0.0;
  // BD
  List<double> bdClutchTemp = [];
  List<double> bdTurbineTemp = [];
  List<double> bdUpperTemp = [];
  List<double> bdClutch = [];
  List<double> bdTurbine = [];
  List<double> bdUpper = [];
  double bdCrockedLine = 0.0;
  // UPPER
  List<double> upper = [];
  List<double> upperBolt = [];
  List<String> listBoltsKey = [];
  List<List<double>> listBolts = [];
  List<String> listTorqueSuggestionsKey = [];
  List<int> listTorqueSuggestions = [];
  List<int> listTorqueSuggestionsY = [];
  double upperCrockedLine = 0.0;
  double? upperScale = 0;
  double? boltScale = 0;

  double divideUntilTwoDigits(double val) {
    double num = val.abs(); // Use abs() to work with positive value
    // log("DTWO VAL : $val");
    // log("DTWO NUM : $num");
    int substract = 0;
    var floor = num.floor();
    if (num < 10 && num % 10 != 0) substract = 1;
    log("DTWO SUBSTRACT 1 : $substract");
    var divide1 = floor / 10;
    var mod1 = divide1 % 10;
    if ((num.floor() % 10 == 0) && num < (num + 1) && mod1 == 0 && num >= 11)
      substract = num.floor().toString().length - 1;
    if (num >= 10 && num < 11) substract = 2;
    log("DTWO SUBSTRACT 2 : $substract");
    // log("DTWO NUM LENGTH : ${num.toInt().toString().length}");
    int num2 = 10.pow(num.toInt().toString().length - substract).toInt();
    // log("DTWO NUM2 : $num2");
    if (val < 0) num2 = num2 * (-1);
    // log("DTWO NUM/NUM2 ${num / num2}");
    // log("DTWO ==================");
    // if (num >= 10 && num < 11) return (num / num2) - 1;
    return num / num2;
  }

  num getDivideBiggestAC() {
    List<double> list = [];
    list.addAll(acUpperTemp.map((e) {
      if (e < 1) return e * (-1);
      return e;
    }).toList());
    list.addAll(acClutchTemp.map((e) {
      if (e < 1) return e * (-1);
      return e;
    }).toList());
    list.addAll(acTurbineTemp.map((e) {
      if (e < 1) return e * (-1);
      return e;
    }).toList());
    list.removeAt(1);
    list.removeAt(4);
    list.sort();
    list = list.reversed.toList();
    // log("LIST AC : $list");
    num divider = 0;
    double list0 = list[0] < 1 ? list[0] * (-1) : list[0];
    // if (list0 > 10)
    divider = getDivideBiggestAcRecursive(0, list0);
    // divider = 10.pow(num.parse('${list0.round().toString().length - 1}'));
    // log("BIGGEST AC : $divider");
    return divider;
  }

  num getDivideBiggestAcRecursive(num val, num biggestX) {
    if (val > biggestX) {
      // log("RECURSIVE AC X : $val");
      return val;
    }
    return getDivideBiggestAcRecursive(val += 5, biggestX);
  }

  num getDivideBiggestACX() {
    List<double> list = [];
    list.addAll(acUpperTemp.map((e) {
      if (e < 1) return e * (-1);
      return e;
    }).toList());
    list.addAll(acClutchTemp.map((e) {
      if (e < 1) return e * (-1);
      return e;
    }).toList());
    list.addAll(acTurbineTemp.map((e) {
      if (e < 1) return e * (-1);
      return e;
    }).toList());
    list.removeAt(1);
    list.removeAt(4);
    list.sort();
    list = list.reversed.toList();
    double list0 = list[0] < 1 ? list[0] * (-1) : list[0];
    // log("BIGGEST ACX : $list0");
    return list0;
  }

  num getDivideBiggestBD() {
    List<double> list = [];
    list.addAll(bdUpperTemp.map((e) {
      if (e < 1) return e * (-1);
      return e;
    }).toList());
    list.addAll(bdClutchTemp.map((e) {
      if (e < 1) return e * (-1);
      return e;
    }).toList());
    list.addAll(bdTurbineTemp.map((e) {
      if (e < 1) return e * (-1);
      return e;
    }).toList());
    list.removeAt(1);
    list.removeAt(4);
    list.sort();
    list = list.reversed.toList();
    // log("LIST BD : $list");
    num divider = 0;
    double list0 = list[0] < 1 ? list[0] * (-1) : list[0];
    // if (list0 > 10)
    divider = getDivideBiggestBdRecursive(0, list0);
    // divider = 10.pow(num.parse('${list0.round().toString().length - 1}'));
    // log("BIGGEST BD : $divider");
    return divider;
  }

  num getDivideBiggestBdRecursive(num val, num biggestX) {
    if (val > biggestX) {
      // log("RECURSIVE BD X : $val");
      return val;
    }
    return getDivideBiggestBdRecursive(val += 5, biggestX);
  }

  num getDivideBiggestBDX() {
    List<double> list = [];
    list.addAll(bdUpperTemp.map((e) {
      if (e < 1) return e * (-1);
      return e;
    }).toList());
    list.addAll(bdClutchTemp.map((e) {
      if (e < 1) return e * (-1);
      return e;
    }).toList());
    list.addAll(bdTurbineTemp.map((e) {
      if (e < 1) return e * (-1);
      return e;
    }).toList());
    list.removeAt(1);
    list.removeAt(4);
    list.sort();
    list = list.reversed.toList();
    double list0 = list[0] < 1 ? list[0] * (-1) : list[0];
    // log("BIGGEST BDX : $list0");
    return list0;
  }

  double getYBiggest() {
    double biggest = acUpper[1];
    if (biggest < bdTurbine[1]) biggest = bdTurbine[1];
    return biggest;
  }

  num getDividerBiggest() {
    num biggest = getDivideBiggestACX().round();
    if (biggest < getDivideBiggestBDX().round())
      biggest = getDivideBiggestBDX().round();
    // log("BIGGEST DIVIDER : ${biggest}");
    return biggest / (10.pow(biggest.toString().length - 1) * 0.9);
  }

  num getDividerBiggest10() {
    num biggest = getDivideBiggestAC();
    if (biggest < getDivideBiggestBD()) biggest = getDivideBiggestBD();
    // log("BIGGEST DIVIDER : $biggest");
    return biggest;
  }

  setDataChart() {
    // AC
    final acData = turbineCreateModel.data?.chart?.ac;
    final acCrockness = turbineCreateModel.data?.acCrockedness;
    final bdData = turbineCreateModel.data?.chart?.bd;
    final bdCrockness = turbineCreateModel.data?.bdCrockedness;
    final upperData = turbineCreateModel.data?.chart?.upper;
    upperScale = turbineCreateModel.data?.chart?.upperScale?.abs();
    final upperCrockness = turbineCreateModel.data?.totalCrockedness;
    boltScale = turbineCreateModel.data?.torqueCalculation?.scale;
    var boltsData = turbineCreateModel.data?.torqueCalculation?.details;
    var torqueSuggestionsData =
        turbineCreateModel.data?.torqueCalculation?.torqueSuggestions;
    if (acData != null && acData.upper != null)
      acUpperTemp = acData.upper!
          .split('|')
          .map((e) => (double.tryParse(e) ?? 0))
          .toList();
    if (acData != null && acData.clutch != null)
      acClutchTemp = acData.clutch!
          .split('|')
          .map((e) => (double.tryParse(e) ?? 0))
          .toList();
    if (acData != null && acData.turbine != null) {
      acTurbineTemp = acData.turbine!
          .split('|')
          .map((e) => (double.tryParse(e) ?? 0))
          .toList();
      acTurbineTemp[1] = -acTurbineTemp[1];
    }
    if (acData != null && acData.upper != null)
      acUpperTemp = acData.upper!
          .split('|')
          .map((e) => (double.tryParse(e) ?? 0))
          .toList();
    if (acData != null && acData.clutch != null)
      acClutchTemp = acData.clutch!
          .split('|')
          .map((e) => (double.tryParse(e) ?? 0))
          .toList();
    if (acData != null && acData.turbine != null) {
      acTurbineTemp = acData.turbine!
          .split('|')
          .map((e) => (double.tryParse(e) ?? 0))
          .toList();
      acTurbineTemp[1] = -acTurbineTemp[1];
    }
    // log("AC UPPER TEMP : $acUpperTemp");
    acUpper = [
      acUpperTemp[0] /*/getDivideBiggestAC()*/,
      acUpperTemp[1],
    ];
    acClutch = [
      acClutchTemp[0] /*/getDivideBiggestAC()*/,
      acClutchTemp[1] /*/getDivideBiggestAC()*/,
    ];
    acTurbine = [
      acTurbineTemp[0] /*/getDivideBiggestAC()*/,
      acTurbineTemp[1],
    ];
    // BD
    if (bdData != null && bdData.upper != null)
      bdUpperTemp = bdData.upper!
          .split('|')
          .map((e) => (double.tryParse(e) ?? 0))
          .toList();
    if (bdData != null && bdData.clutch != null)
      bdClutchTemp = bdData.clutch!
          .split('|')
          .map((e) => (double.tryParse(e) ?? 0))
          .toList();
    if (bdData != null && bdData.turbine != null) {
      bdTurbineTemp = bdData.turbine!
          .split('|')
          .map((e) => (double.tryParse(e) ?? 0))
          .toList();

      bdTurbineTemp[1] = -bdTurbineTemp[1];
    }

    bdUpper = [
      bdUpperTemp[0] /*/getDivideBiggestBD()*/,
      bdUpperTemp[1],
    ];
    bdClutch = [
      bdClutchTemp[0] /*/getDivideBiggestBD()*/,
      bdClutchTemp[1] /*/getDivideBiggestBD()*/,
    ];
    bdTurbine = [
      bdTurbineTemp[0] /*/getDivideBiggestBD()*/,
      bdTurbineTemp[1],
    ];

    if (upperData != null) {
      upper = upperData
          .split('|')
          .map((e) => double.tryParse(e) ?? 0)
          // .map((e) => divideUntilTwoDigits(double.tryParse(e) ?? 0))
          .toList();
      upperBolt =
          upperData.split('|').map((e) => double.tryParse(e) ?? 0).toList();
    }

    if (boltsData != null && boltsData.isNotEmpty) {
      List<String> listS = [];
      List<String> listSKey = [];
      boltsData = Map.fromEntries(boltsData.entries.toList()
        ..sort((e1, e2) => int.parse(e1.key).compareTo(int.parse(e2.key))));
      log("LIST BOLTS DATA DETAIL : $boltsData");
      boltsData.forEach((key, value) {
        listS.add(value);
        listSKey.add(key);
      });
      log("LIST S : $listS");
      listBolts = listS
          .map((e) => e
              .split('|')
              .map((e) => double.tryParse(e) ?? 0)
              // .map((e) => divideUntilTwoDigits(double.tryParse(e) ?? 0))
              .toList())
          .toList();
      log("LIST S BOLTS : $listBolts");
      listBoltsKey = listSKey.map((e) => e).toList();
    }
    if (torqueSuggestionsData != null && torqueSuggestionsData.isNotEmpty) {
      List<int> listS = [];
      List<String> listSKey = [];

      torqueSuggestionsData = Map.fromEntries(
          torqueSuggestionsData.entries.toList()
            ..sort((e1, e2) => int.parse(e1.key).compareTo(int.parse(e2.key))));
      torqueSuggestionsData.forEach((key, value) {
        listS.add(value);
        listSKey.add(key);
      });
      listTorqueSuggestions = listS.map((e) => e).toList();
      listTorqueSuggestionsKey = listSKey.map((e) => e).toList();
    }
    log("LIST KEY TORQUE SUGGESTION : $listTorqueSuggestionsKey");
    log("LIST KEY BOLTS : $listBoltsKey");

    if (listBoltsKey.isNotEmpty && boltsData != null) {
      listTorqueSuggestionsY.clear();
      List<String> listSKey = [];
      boltsData.forEach((key, value) {
        listSKey.add(key);
      });
      log("LIST S KEY : $listSKey");
      for (int i = 0; i < listTorqueSuggestionsKey.length; i++) {
        listTorqueSuggestionsY.add(listTorqueSuggestions[i]);
      }
      log("LIST TORQUE SUGGESTION Y : $listTorqueSuggestionsY");
    }

    acCrockedLine = (acCrockness ?? 0);
    bdCrockedLine = (bdCrockness ?? 0);
    upperCrockedLine = (upperCrockness ?? 0);
    // acCrockedLine = divideUntilTwoDigits(acCrockness ?? 0);
    // bdCrockedLine = divideUntilTwoDigits(bdCrockness ?? 0);
    // upperCrockedLine = divideUntilTwoDigits(upperCrockness ?? 0);
    log("AC UPPER : $acUpper");
    log("AC CLUTCH : $acClutch");
    log("AC TURBINE : $acTurbine");
    log("AC CROCKED : $acCrockedLine");

    ///
    log("BD UPPER : $bdUpper");
    log("BD CLUTCH : $bdClutch");
    log("BD TURBINE : $bdTurbine");
    log("BD CROCKED : $bdCrockedLine");
    // UPPER
    log("UPPER : $upper");
    log("UPPER CROCKED : $upperCrockedLine");
    // TORQUE AND BOLTS
    log("LIST BOLTS KEY : $listBoltsKey");
    log("LIST BOLTS : $boltsData");
    log("LIST BOLTS DATA : $listBolts");
    log("LIST TORQUE SUGGESTIONS KEY : $listTorqueSuggestionsKey");
    log("LIST TORQUE SUGGESTIONS : $torqueSuggestionsData");
  }

  setDataChartDetail() {
    // AC
    final acData = turbineDetailModel.data?.chart?.ac;
    final acCrockness = turbineDetailModel.data?.acCrockedness;
    final bdData = turbineDetailModel.data?.chart?.bd;
    final bdCrockness = turbineDetailModel.data?.bdCrockedness;
    final upperData = turbineDetailModel.data?.chart?.upper;
    upperScale = turbineDetailModel.data?.chart?.upperScale?.abs();
    final upperCrockness = turbineDetailModel.data?.totalCrockedness;
    boltScale = turbineDetailModel.data?.torqueCalculation?.scale;
    var boltsData = turbineDetailModel.data?.torqueCalculation?.details;
    var torqueSuggestionsData =
        turbineDetailModel.data?.torqueCalculation?.torqueSuggestions;
    if (acData != null && acData.upper != null)
      acUpperTemp = acData.upper!
          .split('|')
          .map((e) => (double.tryParse(e) ?? 0))
          .toList();
    if (acData != null && acData.clutch != null)
      acClutchTemp = acData.clutch!
          .split('|')
          .map((e) => (double.tryParse(e) ?? 0))
          .toList();
    if (acData != null && acData.turbine != null) {
      acTurbineTemp = acData.turbine!
          .split('|')
          .map((e) => (double.tryParse(e) ?? 0))
          .toList();
      acTurbineTemp[1] = -acTurbineTemp[1];
    }
    if (acData != null && acData.upper != null)
      acUpperTemp = acData.upper!
          .split('|')
          .map((e) => (double.tryParse(e) ?? 0))
          .toList();
    if (acData != null && acData.clutch != null)
      acClutchTemp = acData.clutch!
          .split('|')
          .map((e) => (double.tryParse(e) ?? 0))
          .toList();
    if (acData != null && acData.turbine != null) {
      acTurbineTemp = acData.turbine!
          .split('|')
          .map((e) => (double.tryParse(e) ?? 0))
          .toList();
      acTurbineTemp[1] = -acTurbineTemp[1];
    }
    // log("AC UPPER TEMP : $acUpperTemp");
    acUpper = [
      acUpperTemp[0] /*/getDivideBiggestAC()*/,
      acUpperTemp[1],
    ];
    acClutch = [
      acClutchTemp[0] /*/getDivideBiggestAC()*/,
      acClutchTemp[1] /*/getDivideBiggestAC()*/,
    ];
    acTurbine = [
      acTurbineTemp[0] /*/getDivideBiggestAC()*/,
      acTurbineTemp[1],
    ];
    // BD
    if (bdData != null && bdData.upper != null)
      bdUpperTemp = bdData.upper!
          .split('|')
          .map((e) => (double.tryParse(e) ?? 0))
          .toList();
    if (bdData != null && bdData.clutch != null)
      bdClutchTemp = bdData.clutch!
          .split('|')
          .map((e) => (double.tryParse(e) ?? 0))
          .toList();
    if (bdData != null && bdData.turbine != null) {
      bdTurbineTemp = bdData.turbine!
          .split('|')
          .map((e) => (double.tryParse(e) ?? 0))
          .toList();

      bdTurbineTemp[1] = -bdTurbineTemp[1];
    }

    bdUpper = [
      bdUpperTemp[0] /*/getDivideBiggestBD()*/,
      bdUpperTemp[1],
    ];
    bdClutch = [
      bdClutchTemp[0] /*/getDivideBiggestBD()*/,
      bdClutchTemp[1] /*/getDivideBiggestBD()*/,
    ];
    bdTurbine = [
      bdTurbineTemp[0] /*/getDivideBiggestBD()*/,
      bdTurbineTemp[1],
    ];

    if (upperData != null) {
      upper = upperData
          .split('|')
          .map((e) => double.tryParse(e) ?? 0)
          // .map((e) => divideUntilTwoDigits(double.tryParse(e) ?? 0))
          .toList();
      upperBolt =
          upperData.split('|').map((e) => double.tryParse(e) ?? 0).toList();
    }

    if (boltsData != null && boltsData.isNotEmpty) {
      List<String> listS = [];
      List<String> listSKey = [];
      boltsData = Map.fromEntries(boltsData.entries.toList()
        ..sort((e1, e2) => int.parse(e1.key).compareTo(int.parse(e2.key))));
      log("LIST BOLTS DATA DETAIL : $boltsData");
      boltsData.forEach((key, value) {
        listS.add(value);
        listSKey.add(key);
      });
      log("LIST S : $listS");
      listBolts = listS
          .map((e) => e
              .split('|')
              .map((e) => double.tryParse(e) ?? 0)
              // .map((e) => divideUntilTwoDigits(double.tryParse(e) ?? 0))
              .toList())
          .toList();
      log("LIST S BOLTS : $listBolts");
      listBoltsKey = listSKey.map((e) => e).toList();
    }
    if (torqueSuggestionsData != null && torqueSuggestionsData.isNotEmpty) {
      List<int> listS = [];
      List<String> listSKey = [];

      torqueSuggestionsData = Map.fromEntries(
          torqueSuggestionsData.entries.toList()
            ..sort((e1, e2) => int.parse(e1.key).compareTo(int.parse(e2.key))));
      torqueSuggestionsData.forEach((key, value) {
        listS.add(value);
        listSKey.add(key);
      });
      listTorqueSuggestions = listS.map((e) => e).toList();
      listTorqueSuggestionsKey = listSKey.map((e) => e).toList();
    }
    log("LIST KEY TORQUE SUGGESTION : $listTorqueSuggestionsKey");
    log("LIST KEY BOLTS : $listBoltsKey");

    if (listBoltsKey.isNotEmpty && boltsData != null) {
      listTorqueSuggestionsY.clear();
      List<String> listSKey = [];
      boltsData.forEach((key, value) {
        listSKey.add(key);
      });
      log("LIST S KEY : $listSKey");
      for (int i = 0; i < listTorqueSuggestionsKey.length; i++) {
        listTorqueSuggestionsY.add(listTorqueSuggestions[i]);
      }
      log("LIST TORQUE SUGGESTION Y : $listTorqueSuggestionsY");
    }

    acCrockedLine = (acCrockness ?? 0);
    bdCrockedLine = (bdCrockness ?? 0);
    upperCrockedLine = (upperCrockness ?? 0);
    // acCrockedLine = divideUntilTwoDigits(acCrockness ?? 0);
    // bdCrockedLine = divideUntilTwoDigits(bdCrockness ?? 0);
    // upperCrockedLine = divideUntilTwoDigits(upperCrockness ?? 0);
    log("AC UPPER : $acUpper");
    log("AC CLUTCH : $acClutch");
    log("AC TURBINE : $acTurbine");
    log("AC CROCKED : $acCrockedLine");

    ///
    log("BD UPPER : $bdUpper");
    log("BD CLUTCH : $bdClutch");
    log("BD TURBINE : $bdTurbine");
    log("BD CROCKED : $bdCrockedLine");
    // UPPER
    log("UPPER : $upper");
    log("UPPER CROCKED : $upperCrockedLine");
    // TORQUE AND BOLTS
    log("LIST BOLTS KEY : $listBoltsKey");
    log("LIST BOLTS : $boltsData");
    log("LIST BOLTS DATA : $listBolts");
    log("LIST TORQUE SUGGESTIONS KEY : $listTorqueSuggestionsKey");
    log("LIST TORQUE SUGGESTIONS : $torqueSuggestionsData");
  }

  setDataChartLatest() {
    // AC
    final acData = turbineLatestModel.data?.chart?.ac;
    final acCrockness = turbineLatestModel.data?.acCrockedness;
    final bdData = turbineLatestModel.data?.chart?.bd;
    final bdCrockness = turbineLatestModel.data?.bdCrockedness;
    final upperData = turbineLatestModel.data?.chart?.upper;
    upperScale = turbineLatestModel.data?.chart?.upperScale?.abs();
    final upperCrockness = turbineLatestModel.data?.totalCrockedness;
    boltScale = turbineLatestModel.data?.torqueCalculation?.scale;
    var boltsData = turbineLatestModel.data?.torqueCalculation?.details;
    var torqueSuggestionsData =
        turbineLatestModel.data?.torqueCalculation?.torqueSuggestions;
    if (acData != null && acData.upper != null)
      acUpperTemp = acData.upper!
          .split('|')
          .map((e) => (double.tryParse(e) ?? 0))
          .toList();
    if (acData != null && acData.clutch != null)
      acClutchTemp = acData.clutch!
          .split('|')
          .map((e) => (double.tryParse(e) ?? 0))
          .toList();
    if (acData != null && acData.turbine != null) {
      acTurbineTemp = acData.turbine!
          .split('|')
          .map((e) => (double.tryParse(e) ?? 0))
          .toList();
      acTurbineTemp[1] = -acTurbineTemp[1];
    }
    if (acData != null && acData.upper != null)
      acUpperTemp = acData.upper!
          .split('|')
          .map((e) => (double.tryParse(e) ?? 0))
          .toList();
    if (acData != null && acData.clutch != null)
      acClutchTemp = acData.clutch!
          .split('|')
          .map((e) => (double.tryParse(e) ?? 0))
          .toList();
    if (acData != null && acData.turbine != null) {
      acTurbineTemp = acData.turbine!
          .split('|')
          .map((e) => (double.tryParse(e) ?? 0))
          .toList();
      acTurbineTemp[1] = -acTurbineTemp[1];
    }
    // log("AC UPPER TEMP : $acUpperTemp");
    acUpper = [
      acUpperTemp[0] /*/getDivideBiggestAC()*/,
      acUpperTemp[1],
    ];
    acClutch = [
      acClutchTemp[0] /*/getDivideBiggestAC()*/,
      acClutchTemp[1] /*/getDivideBiggestAC()*/,
    ];
    acTurbine = [
      acTurbineTemp[0] /*/getDivideBiggestAC()*/,
      acTurbineTemp[1],
    ];
    // BD
    if (bdData != null && bdData.upper != null)
      bdUpperTemp = bdData.upper!
          .split('|')
          .map((e) => (double.tryParse(e) ?? 0))
          .toList();
    if (bdData != null && bdData.clutch != null)
      bdClutchTemp = bdData.clutch!
          .split('|')
          .map((e) => (double.tryParse(e) ?? 0))
          .toList();
    if (bdData != null && bdData.turbine != null) {
      bdTurbineTemp = bdData.turbine!
          .split('|')
          .map((e) => (double.tryParse(e) ?? 0))
          .toList();

      bdTurbineTemp[1] = -bdTurbineTemp[1];
    }

    bdUpper = [
      bdUpperTemp[0] /*/getDivideBiggestBD()*/,
      bdUpperTemp[1],
    ];
    bdClutch = [
      bdClutchTemp[0] /*/getDivideBiggestBD()*/,
      bdClutchTemp[1] /*/getDivideBiggestBD()*/,
    ];
    bdTurbine = [
      bdTurbineTemp[0] /*/getDivideBiggestBD()*/,
      bdTurbineTemp[1],
    ];

    if (upperData != null) {
      upper = upperData
          .split('|')
          .map((e) => double.tryParse(e) ?? 0)
          // .map((e) => divideUntilTwoDigits(double.tryParse(e) ?? 0))
          .toList();
      upperBolt =
          upperData.split('|').map((e) => double.tryParse(e) ?? 0).toList();
    }

    if (boltsData != null && boltsData.isNotEmpty) {
      List<String> listS = [];
      List<String> listSKey = [];
      boltsData = Map.fromEntries(boltsData.entries.toList()
        ..sort((e1, e2) => int.parse(e1.key).compareTo(int.parse(e2.key))));
      log("LIST BOLTS DATA DETAIL : $boltsData");
      boltsData.forEach((key, value) {
        listS.add(value);
        listSKey.add(key);
      });
      log("LIST S : $listS");
      listBolts = listS
          .map((e) => e
              .split('|')
              .map((e) => double.tryParse(e) ?? 0)
              // .map((e) => divideUntilTwoDigits(double.tryParse(e) ?? 0))
              .toList())
          .toList();
      log("LIST S BOLTS : $listBolts");
      listBoltsKey = listSKey.map((e) => e).toList();
    }
    if (torqueSuggestionsData != null && torqueSuggestionsData.isNotEmpty) {
      List<int> listS = [];
      List<String> listSKey = [];

      torqueSuggestionsData = Map.fromEntries(
          torqueSuggestionsData.entries.toList()
            ..sort((e1, e2) => int.parse(e1.key).compareTo(int.parse(e2.key))));
      torqueSuggestionsData.forEach((key, value) {
        listS.add(value);
        listSKey.add(key);
      });
      listTorqueSuggestions = listS.map((e) => e).toList();
      listTorqueSuggestionsKey = listSKey.map((e) => e).toList();
    }
    log("LIST KEY TORQUE SUGGESTION : $listTorqueSuggestionsKey");
    log("LIST KEY BOLTS : $listBoltsKey");

    if (listBoltsKey.isNotEmpty && boltsData != null) {
      listTorqueSuggestionsY.clear();
      List<String> listSKey = [];
      boltsData.forEach((key, value) {
        listSKey.add(key);
      });
      log("LIST S KEY : $listSKey");
      for (int i = 0; i < listTorqueSuggestionsKey.length; i++) {
        listTorqueSuggestionsY.add(listTorqueSuggestions[i]);
      }
      log("LIST TORQUE SUGGESTION Y : $listTorqueSuggestionsY");
    }

    acCrockedLine = (acCrockness ?? 0);
    bdCrockedLine = (bdCrockness ?? 0);
    upperCrockedLine = (upperCrockness ?? 0);
    // acCrockedLine = divideUntilTwoDigits(acCrockness ?? 0);
    // bdCrockedLine = divideUntilTwoDigits(bdCrockness ?? 0);
    // upperCrockedLine = divideUntilTwoDigits(upperCrockness ?? 0);
    log("AC UPPER : $acUpper");
    log("AC CLUTCH : $acClutch");
    log("AC TURBINE : $acTurbine");
    log("AC CROCKED : $acCrockedLine");

    ///
    log("BD UPPER : $bdUpper");
    log("BD CLUTCH : $bdClutch");
    log("BD TURBINE : $bdTurbine");
    log("BD CROCKED : $bdCrockedLine");
    // UPPER
    log("UPPER : $upper");
    log("UPPER CROCKED : $upperCrockedLine");
    // TORQUE AND BOLTS
    log("LIST BOLTS KEY : $listBoltsKey");
    log("LIST BOLTS : $boltsData");
    log("LIST BOLTS DATA : $listBolts");
    log("LIST TORQUE SUGGESTIONS KEY : $listTorqueSuggestionsKey");
    log("LIST TORQUE SUGGESTIONS : $torqueSuggestionsData");
  }

  bool validatePage1() {
    // Detail Unit
    if (titleC.text.isEmpty) return false;
    if (pltaC.text.isEmpty) return false;
    if (selectedPlta == null) return false;
    if (selectedPltaModel == null) return false;
    // Detail Baut
    // if (boltQtyC.text.isEmpty) return false;
    if (selectedBolt == null) return false;
    if (currentTorqueC.text.isEmpty) return false;
    if (maxTorqueC.text.isEmpty) return false;
    // Shaft
    if (genBearingKoplingC.text.isEmpty) return false;
    if (koplingTurbinC.text.isEmpty) return false;

    return true;
  }

  bool validateAddShaft() {
    // upper
    for (int i = 0; i < dataUpperC.length; i++) {
      for (int j = 0; j < dataUpperC[i].length; j++) {
        if (dataUpperC[i][j].text.isEmpty) return false;
      }
    }
    // clutch
    for (int i = 0; i < dataClutchC.length; i++) {
      for (int j = 0; j < dataClutchC[i].length; j++) {
        if (dataClutchC[i][j].text.isEmpty) return false;
      }
    }
    // turbine
    for (int i = 0; i < dataTurbineC.length; i++) {
      for (int j = 0; j < dataTurbineC[i].length; j++) {
        if (dataTurbineC[i][j].text.isEmpty) return false;
      }
    }
    return true;
  }

  Future<void> sendCreateTurbines(BuildContext context) async {
    try {
      loading(true);
      final response = await createTurbines();
      if (response.success == true) {
        Utils.showSuccess(msg: response.message ?? "Sukses");
        await Future.delayed(Duration(seconds: 2));
        CusNav.nPop(context);
        CusNav.nPushReplace(context, ShaftView());
      } else {
        loading(false);
        Utils.showFailed(msg: response.message ?? '');
        // throw response.message ?? '';
      }
    } catch (e) {
      loading(false);
      Utils.showFailed(
          msg: e.toString().toLowerCase().contains("doctype")
              ? "Maaf, Terjadi Galat!"
              : "$e");
      throw e.toString().toLowerCase().contains("doctype")
          ? "Maaf, Terjadi Galat!"
          : "$e";
    }
  }

  Future<TurbineCreateModel> createTurbines() async {
    loading(true);
    createDataParam = CreateDataParam(
        Title: titleC.text,
        TowerId: selectedPlta,
        GenBearingToCoupling: genBearingKoplingC.text,
        CouplingToTurbine: koplingTurbinC.text,
        TotalBolts: selectedBolt,
        CurrentTorque: currentTorqueC.text,
        MaxTorque: maxTorqueC.text,
        Data: CreateDataParamData(
            Upper: CreateDataParamDataUpper(A: [], B: [], C: [], D: []),
            Clutch: CreateDataParamDataClutch(A: [], B: [], C: [], D: []),
            Turbine: CreateDataParamDataTurbine(A: [], B: [], C: [], D: [])));
    notifyListeners();
    for (int i = 0; i < dataUpperC.length; i++) {
      final itemA = dataUpperC[i][0];
      final itemB = dataUpperC[i][1];
      final itemC = dataUpperC[i][2];
      final itemD = dataUpperC[i][3];
      createDataParam?.Data?.Upper?.A?.add(double.parse(itemA.text));
      createDataParam?.Data?.Upper?.B?.add(double.parse(itemB.text));
      createDataParam?.Data?.Upper?.C?.add(double.parse(itemC.text));
      createDataParam?.Data?.Upper?.D?.add(double.parse(itemD.text));
    }
    for (int i = 0; i < dataClutchC.length; i++) {
      final itemA = dataClutchC[i][0];
      final itemB = dataClutchC[i][1];
      final itemC = dataClutchC[i][2];
      final itemD = dataClutchC[i][3];
      createDataParam?.Data?.Clutch?.A?.add(double.parse(itemA.text));
      createDataParam?.Data?.Clutch?.B?.add(double.parse(itemB.text));
      createDataParam?.Data?.Clutch?.C?.add(double.parse(itemC.text));
      createDataParam?.Data?.Clutch?.D?.add(double.parse(itemD.text));
    }
    for (int i = 0; i < dataTurbineC.length; i++) {
      final itemA = dataTurbineC[i][0];
      final itemB = dataTurbineC[i][1];
      final itemC = dataTurbineC[i][2];
      final itemD = dataTurbineC[i][3];
      createDataParam?.Data?.Turbine?.A?.add(double.parse(itemA.text));
      createDataParam?.Data?.Turbine?.B?.add(double.parse(itemB.text));
      createDataParam?.Data?.Turbine?.C?.add(double.parse(itemC.text));
      createDataParam?.Data?.Turbine?.D?.add(double.parse(itemD.text));
    }
    log('CREATE DATA PARAM : ${createDataParam?.toJson()}');
    log('CREATE DATA PARAM : ${jsonEncode(createDataParam?.toJson())}');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String param = jsonEncode(createDataParam?.toJson());
    prefs.setString(Constant.kSetPrefParamCreateTurbine, param);
    createDataParam = CreateDataParam.fromJson(jsonDecode(param));
    final response = await post(Constant.BASE_API_FULL + '/turbines',
        body: jsonDecode(param));

    if (response.statusCode == 201 || response.statusCode == 200) {
      turbineCreateModel = TurbineCreateModel();
      clearDetailData();
      prefs.remove(Constant.kSetPrefParamCreateTurbine);
      createDataParam = CreateDataParam();
      final model = TurbineCreateModel.fromJson(jsonDecode(response.body));
      turbineCreateModel = model;
      notifyListeners();
      setDataChart();
      loading(false);
      return model;
    } else {
      final model = BaseResponse.from(response);

      final message = model.message;
      loading(false);
      await Utils.showFailed(msg: model.message ?? "Gagal");
      await Future.delayed(Duration(seconds: 2));
      throw Exception(message);
      // return TurbineCreateModel();
    }
  }

  Future<void> downloadTurbine(BuildContext context,
      {required String id}) async {
    try {
      loading(true);
      // requestPermission

      final PermissionStatus status = await Permission.notification.request();
      if (status.isGranted) {
        // Notification permissions granted
        log("NOTIF GRANTED");
      } else if (status.isDenied) {
        // Notification permissions denied
        log("NOTIF DENIED");
      } else if (status.isPermanentlyDenied && Platform.isAndroid) {
        // Notification permissions permanently denied, open app settings
        log("NOTIF PERMANENTLY DENIED");
        await openAppSettings();
      }
      await requestPermission(Permission.notification);
      await Permission.notification.request();
      await requestPermission(Permission.notification);
      await requestPermission(Permission.storage);
      await requestPermission(Permission.manageExternalStorage);
      await requestPermission(Permission.photos);
      await downloadFile(
        context,
        Constant.BASE_API_FULL + '/turbines/$id/report',
        filename: turbineDetailModel.data?.title ?? 'turbine',
        openAfterDownload: true,
        typeFile: 'pdf',
      );
      loading(false);
    } catch (e) {
      loading(false);
      await Utils.showFailed(msg: e.toString());
      throw Exception(e.toString());
    }
  }

  Future<void> deleteTurbine(BuildContext context, {required String id}) async {
    loading(true);
    final response = await delete(Constant.BASE_API_FULL + '/turbines/$id');

    if (response.statusCode == 201 || response.statusCode == 200) {
      final model = BaseResponse.from(response);
      loading(false);
      await Utils.showSuccess(msg: model.message ?? "Sukses");
      await Future.delayed(Duration(seconds: 2));
    } else {
      final message = jsonDecode(response.body)["Message"];
      loading(false);
      await Utils.showFailed(msg: message);
      throw Exception(message);
      // return message;
    }
  }

  onChangedPLTA(String? v) {
    String? selected =
        (pltaList ?? []).firstWhere((element) => element?.Name == v)?.Id;
    if (selected != null) {
      selectedPlta = selected;
      pltaC.text = selected;
    }
  }

  onChangedPLTA2(PltaModelData? v) async {
    if (v != null) {
      selectedPltaModel = v;
      selectedPlta = v.Id ?? '0';
      pltaC.text = v.Name ?? '';
      loading(true);
      // check location
      if (await requestPermission(Permission.location)) {
        if (await Geolocator.isLocationServiceEnabled()) {
          final geo = await Geolocator.getCurrentPosition(
                  desiredAccuracy: LocationAccuracy.high)
              .timeout(
            Duration(seconds: 5),
            onTimeout: () async =>
                Future.value((await Geolocator.getLastKnownPosition())),
          );
          if (geo.isMocked) {
            loading(false);
            Utils.showFailed(
                msg:
                    'Anda menggunakan fake GPS, harap matikan terlebih dahulu');
            throw 'Anda menggunakan fake GPS, harap matikan terlebih dahulu';
          }
          double? lat = selectedPltaModel?.Lat?.toDouble();
          double? lon = selectedPltaModel?.Long?.toDouble();
          double? radius = selectedPltaModel?.Radius?.toDouble();
          bool? configStatus = selectedPltaModel?.RadiusStatus ?? false;
          double distance = Geolocator.distanceBetween(
              geo.latitude, geo.longitude, lat ?? 0, lon ?? 0);

          String? radiusType = selectedPltaModel?.RadiusType ?? 'kilometer';
          if (radiusType == 'meter') {
            distance = distance;
          } else if (radiusType == 'kilometer') {
            distance = distance / 1000;
          }
          log("RADIUS TYPE : $radiusType");
          log("RADIUS STATUS : $configStatus");
          log("DISTANCE : $distance");
          log("RADIUS : $radius");
          log("MASUK RADIUS : ${distance <= (radius ?? 0)}");
          log("LAT : ${geo.latitude}");
          log("LON : ${geo.longitude}");
          log("LAT API : ${lat}");
          log("LON API : ${lon}");
          if (geo.latitude != 0 && lat != 0) {
            // double distance = Geolocator.distanceBetween(
            //     geo.latitude, geo.longitude, lat ?? 0, lon ?? 0);
            if (configStatus == false) {
              selectedPltaModel = v;
              selectedPlta = v.Id ?? '0';
              pltaC.text = v.Name ?? '';
              loading(false);
            } else if (distance >= (radius ?? 0) && configStatus == true) {
              log("DALAM JANGKAUAN");

              selectedPltaModel = v;
              selectedPlta = v.Id ?? '0';
              pltaC.text = v.Name ?? '';
              loading(false);
              return;
            } else {
              loading(false);

              pltaC.text = '';
              selectedPltaModel = null;
              selectedPlta = null;
              Utils.showFailed(
                  msg:
                      'Lokasi Anda ${distance.toStringAsFixed(2)} ${radiusType} berada di luar batas jangkauan ($radius $radiusType)');
              throw 'Lokasi Anda ${distance.toStringAsFixed(2)} ${radiusType} berada di luar batas jangkauan ($radius $radiusType)';
            }
          } else {
            pltaC.text = '';
            selectedPltaModel = null;
            selectedPlta = null;
            loading(false);
            Utils.showFailed(msg: 'Gagal mendapatkan lokasi');
            throw 'Gagal mendapatkan lokasi';
          }
        } else {
          loading(false);
          pltaC.text = '';
          selectedPltaModel = null;
          selectedPlta = null;
          Utils.showFailed(msg: 'Harap Nyalakan GPS');
          throw 'Izinkan Nyalakan GPS';
        }
      } else {
        loading(false);
        pltaC.text = '';
        selectedPltaModel = null;
        selectedPlta = null;
        Utils.showFailed(msg: 'Harap Izinkan Akses Lokasi GPS');
        throw 'Izinkan Akses Lokasi GPS';
      }
    }
    // notifyListeners();
  }

  List<PltaModelData?> searchPlta(String pattern) {
    return (pltaList ?? [])
        .where((element) => (element?.Name ?? '')
            .toLowerCase()
            .contains(pattern.trim().toLowerCase()))
        .toList();
  }

  List<Widget> detailUnit() {
    return [
      CustomContainer.mainCard(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Constant.xSizedBox8,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Text(
                "Detail Unit",
                style: Constant.iBlackMedium16
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            Constant.xSizedBox4,
            Container(
              height: 1,
              width: double.infinity,
              color: Colors.grey.withOpacity(0.5),
            ),
            Constant.xSizedBox12,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: CustomTextField.borderTextField(
                required: false,
                controller: titleC,
                textInputType: TextInputType.name,
                labelText: "Nama File",
                hintText: "Nama File",
              ),
            ),
            Constant.xSizedBox4,
            Padding(
              padding: const EdgeInsets.only(
                  bottom: 10, left: 12, right: 12, top: 4),
              child: Row(
                children: [
                  Text(
                    "Nama PLTA",
                    style: Constant.primaryTextStyle
                        .copyWith(fontSize: 14, fontWeight: Constant.medium),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropDownSearchField<PltaModelData?>(
                displayAllSuggestionWhenTap: true,
                textFieldConfiguration: TextFieldConfiguration(
                  controller: pltaC,
                  autofocus: false,
                  // style: DefaultTextStyle.of(context).style.copyWith(
                  //   fontStyle: FontStyle.italic
                  // ),
                  onChanged: (value) {},
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.zero,
                    hintText: "Pilih PLTA",
                    isDense: false,
                    hintStyle: TextStyle(color: Constant.textHintColor2),
                    filled: true,
                    enabled: true,
                    fillColor: Colors.white,
                    suffixIconColor: Constant.grayColor,
                    suffixIcon: InkWell(
                      onTap: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        pltaC.text = '';
                        selectedPlta = null;
                      },
                      child: Icon(
                        pltaC.text.isEmpty
                            ? Icons.keyboard_arrow_down
                            : Icons.close,
                        size: 24,
                      ),
                    ),
                    hoverColor: Constant.primaryColor,
                    focusColor: Constant.primaryColor,
                    prefix: SizedBox(width: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        width: 0.5,
                        color: Constant.borderSearchColor,
                        style: BorderStyle.solid,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        width: 0.5,
                        color: Constant.borderSearchColor,
                        style: BorderStyle.solid,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        width: 1,
                        color: Constant.primaryColor,
                        style: BorderStyle.solid,
                      ),
                    ),
                  ),
                ),
                onSuggestionSelected: onChangedPLTA2,
                suggestionsCallback: (pattern) async =>
                    await searchPlta(pattern),
                itemBuilder: (context, suggestion) =>
                    ListTile(title: Text(suggestion?.Name ?? '')),
              ),
            ),
            Constant.xSizedBox16,
          ],
        ),
      ),
    ];
  }

  // onChangedShaft(String v) {
  //   if (v.trim() == '' && koplingTurbinC.text.isEmpty) {
  //     totalC.text = '0';
  //     rasioC.text = '0';
  //   } else {
  //     if (v.trim() != '') {
  //       double value = double.tryParse(v) ?? 0;
  //       if (koplingTurbinC.text.isEmpty) {
  //         totalC.text = "$value";
  //         rasioC.text = '0';
  //       } else {
  //         totalC.text =
  //             "${value + (double.tryParse(koplingTurbinC.text) ?? 0)}";
  //         rasioC.text =
  //             "${(value / (double.tryParse(totalC.text) ?? 0)).toStringAsFixed(2)}";
  //       }
  //     } else {
  //       totalC.text = "${double.tryParse(koplingTurbinC.text)}";
  //       rasioC.text = '0';
  //     }
  //   }
  // }

  onChangedBearingToCoupling(String v) {
    if (v.trim() == '' && koplingTurbinC.text.isEmpty) {
      totalC.text = '0';
      rasioC.text = '0';
    } else {
      if (v.trim() != '') {
        double value = double.tryParse(v) ?? 0;
        if (koplingTurbinC.text.isEmpty) {
          totalC.text = "$value";
          rasioC.text = '0';
        } else {
          double total = value + (double.tryParse(koplingTurbinC.text) ?? 0);
          double bearingToCoupling = value;
          double rasio = (bearingToCoupling / total);
          log("GEN BEARING KOPLING : $value");
          log("TOTAL : ${total}");
          log("RASIO : ${rasio}");
          totalC.text = "$total";
          rasioC.text = "${rasio.toStringAsFixed(2)}";
        }
      } else {
        totalC.text = "${double.tryParse(koplingTurbinC.text)}";
        rasioC.text = '0';
      }
    }
  }

  onChangedKoplingToTurbine(String v) {
    if (v.trim() == '' && genBearingKoplingC.text.isEmpty) {
      totalC.text = '0';
      rasioC.text = '0';
    } else {
      if (v.trim() != '') {
        double value = double.tryParse(v) ?? 0;
        if (genBearingKoplingC.text.isEmpty) {
          totalC.text = "$value";
          rasioC.text = '0';
        } else {
          double total =
              value + (double.tryParse(genBearingKoplingC.text) ?? 0);
          double bearingToCoupling =
              double.tryParse(genBearingKoplingC.text) ?? 0;
          double rasio = (bearingToCoupling / total);
          log("GEN BEARING KOPLING : ${genBearingKoplingC.text}");
          log("TOTAL : ${total}");
          log("RASIO : ${rasio}");
          notifyListeners();
          totalC.text = "$total";
          rasioC.text = "${rasio.toStringAsFixed(2)}";
        }
      } else {
        totalC.text = "${double.tryParse(genBearingKoplingC.text)}";
        rasioC.text = '0';
      }
    }
  }

  onChangedCurrentTorque(String v) {
    if (v.trim() == '' && maxTorqueC.text.isEmpty) {
      differenceQtyC.text = '0';
    } else {
      if (v.trim() != '') {
        double value = double.tryParse(v) ?? 0;
        if (maxTorqueC.text.isEmpty) {
          differenceQtyC.text = '0';
        } else {
          double difference = (double.tryParse(maxTorqueC.text) ?? 0) - value;
          log("CURRENT TORQUE : $value");
          log("DIFFERENCE : ${difference}");
          notifyListeners();
          differenceQtyC.text = "${difference.toStringAsFixed(2)}";
        }
      } else {
        differenceQtyC.text = '0';
      }
    }
  }

  onChangedMaxTorque(String v) {
    if (v.trim() == '' && currentTorqueC.text.isEmpty) {
      differenceQtyC.text = '0';
    } else {
      if (v.trim() != '') {
        double value = double.tryParse(v) ?? 0;
        if (currentTorqueC.text.isEmpty) {
          differenceQtyC.text = "$value";
        } else {
          double difference =
              value - (double.tryParse(currentTorqueC.text) ?? 0);
          log("MAX TORQUE : $value");
          log("DIFFERENCE : $difference");
          notifyListeners();
          differenceQtyC.text = "${difference.toStringAsFixed(2)}";
        }
      } else {
        differenceQtyC.text = '0';
      }
    }
  }

  List<Widget> shaftForm() {
    return [
      Text("Shaft", style: Constant.blackBold20),
      Constant.xSizedBox8,
      Text("Masukkan data shaft sesuai kolom", style: Constant.grayMedium),
      Constant.xSizedBox16,
      CustomTextField.borderTextField(
        controller: genBearingKoplingC,
        textInputType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d?')),
          FilteringTextInputFormatter.allow(RegExp(r'^[0-9]*$')),
        ],
        labelText: "Gen. Bearing-Kopling",
        hintText: "Gen. Bearing-Kopling",
        onChanged: onChangedBearingToCoupling,
        suffixIcon: Padding(
          padding: const EdgeInsets.fromLTRB(0, 14, 10, 0),
          child: Text(
            'mm',
            textAlign: TextAlign.right,
            style: TextStyle(color: Constant.redColor),
          ),
        ),
      ),
      Constant.xSizedBox16,
      CustomTextField.borderTextField(
        controller: koplingTurbinC,
        textInputType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d?')),
          FilteringTextInputFormatter.digitsOnly
        ],
        labelText: "Kopling - Turbin",
        hintText: "Kopling - Turbin",
        onChanged: onChangedKoplingToTurbine,
        suffixIcon: Padding(
          padding: const EdgeInsets.fromLTRB(0, 14, 10, 0),
          child: Text(
            'mm',
            textAlign: TextAlign.right,
            style: TextStyle(color: Constant.redColor),
          ),
        ),
      ),
      Constant.xSizedBox16,
      CustomTextField.borderTextField(
        enabled: false,
        readOnly: true,
        controller: totalC,
        labelText: "Total",
        suffixIcon: Padding(
          padding: const EdgeInsets.fromLTRB(0, 14, 10, 0),
          child: Text(
            'mm',
            textAlign: TextAlign.right,
            style: TextStyle(color: Constant.redColor),
          ),
        ),
      ),
      Constant.xSizedBox16,
      CustomTextField.borderTextField(
        enabled: false,
        readOnly: true,
        controller: rasioC,
        labelText: "Rasio",
      ),
      Constant.xSizedBox16,
    ];
  }

  List<Widget> boltDetailForm() {
    return [
      Text("Detail Baut", style: Constant.blackBold20),
      Constant.xSizedBox8,
      Text("Masukkan detail baut", style: Constant.grayMedium),
      Constant.xSizedBox16,
      CustomDropdown.searchDropdown(
        required: false,
        controller: boltQtyC,
        iconPadding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
        contentPadding: EdgeInsets.all(2),
        borderColor: Constant.primaryColor,
        labelText: "Jumlah Baut",
        hintText: "Jumlah Baut",
        selectedItem: selectedBolt,
        suffixIcon: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: Text(
            'Bolt',
            textAlign: TextAlign.right,
            style: TextStyle(
                color: Constant.redColor, fontWeight: FontWeight.w400),
          ),
        ),
        list: boltList.map((e) => e).toList(),
        onChanged: (val) {
          selectedBolt = val;
          // notifyListeners();
        },
      ),
      // CustomTextField.borderTextField(
      //   required: false,
      //   controller: boltQtyC,
      //   textInputType: TextInputType.number,
      //   inputFormatters: [
      //     FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d?')),
      //     FilteringTextInputFormatter.digitsOnly
      //   ],
      //   labelText: "Jumlah Baut",
      //   hintText: "Jumlah Baut",
      //   suffixIcon: Padding(
      //     padding: const EdgeInsets.fromLTRB(0, 14, 10, 0),
      //     child: Text(
      //       'Bolt',
      //       textAlign: TextAlign.right,
      //       style: TextStyle(color: Constant.redColor),
      //     ),
      //   ),
      // ),
      Constant.xSizedBox16,
      CustomTextField.borderTextField(
        required: false,
        controller: currentTorqueC,
        textInputType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d?')),
          FilteringTextInputFormatter.digitsOnly
        ],
        labelText: "Torsi Terkini",
        hintText: "Torsi Terkini",
        onChanged: onChangedCurrentTorque,
        suffixIcon: Padding(
          padding: const EdgeInsets.fromLTRB(0, 14, 10, 0),
          child: Text(
            'BAR/Psi/Nm',
            textAlign: TextAlign.right,
            style: TextStyle(color: Constant.redColor),
          ),
        ),
      ),
      Constant.xSizedBox16,
      CustomTextField.borderTextField(
        required: false,
        controller: maxTorqueC,
        textInputType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d?')),
          FilteringTextInputFormatter.digitsOnly
        ],
        labelText: "Max Torsi",
        hintText: "Max Torsi",
        onChanged: onChangedMaxTorque,
        suffixIcon: Padding(
          padding: const EdgeInsets.fromLTRB(0, 14, 10, 0),
          child: Text(
            'BAR/Psi/Nm',
            textAlign: TextAlign.right,
            style: TextStyle(color: Constant.redColor),
          ),
        ),
      ),
      Constant.xSizedBox16,
      CustomTextField.borderTextField(
        required: false,
        readOnly: true,
        enabled: false,
        controller: differenceQtyC,
        textInputType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d?')),
          FilteringTextInputFormatter.digitsOnly
        ],
        labelText: "Jumlah Selisih",
        hintText: "Jumlah Selisih",
        suffixIcon: Padding(
          padding: const EdgeInsets.fromLTRB(0, 14, 10, 0),
          child: Text(
            'BAR/Psi/Nm',
            textAlign: TextAlign.right,
            style: TextStyle(color: Constant.redColor),
          ),
        ),
      ),
      Constant.xSizedBox16,
    ];
  }

  generateAllData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString(Constant.kSetPrefParamCreateTurbine);
    log('CREATE DATA PARAM : $data');
    if (data != null) {
      createDataParam = CreateDataParam.fromJson(jsonDecode(data));
      generateShaftLocalData(createDataParam);
      generateDataUpperRowLocal();
      generateDataClutchRowLocal();
      generateDataTurbineRowLocal();
      notifyListeners();
    } else {
      generateDataUpperRow();
      generateDataClutchRow();
      generateDataTurbineRow();
    }
  }

  generateShaftLocalData(CreateDataParam? data) {
    if (data != null) {
      selectedPlta = data.TowerId;
      // String? pltaName = (pltaList ?? [])
      //     .firstWhere((element) => element?.Id == data.TowerId)
      //     ?.Name;
      // if (pltaName != null && pltaName != '') pltaC.text = pltaName;
      if (data.GenBearingToCoupling != null)
        genBearingKoplingC.text = data.GenBearingToCoupling ?? '';
      if (data.CouplingToTurbine != null)
        koplingTurbinC.text = data.CouplingToTurbine ?? '';
      if ((data.CouplingToTurbine == null || data.CouplingToTurbine == '') &&
          (data.GenBearingToCoupling == '' ||
              data.GenBearingToCoupling == '')) {
        totalC.text = '0';
        rasioC.text = '0';
      } else {
        if (data.CouplingToTurbine?.trim() != '') {
          double value = double.tryParse(data.CouplingToTurbine ?? '0') ?? 0;
          if (genBearingKoplingC.text.isEmpty) {
            totalC.text = "$value";
            rasioC.text = '0';
          } else {
            totalC.text =
                "${value + (double.tryParse(genBearingKoplingC.text) ?? 0)}";
            rasioC.text =
                "${(double.tryParse(koplingTurbinC.text) ?? 0 / (double.tryParse(totalC.text) ?? 0)).toStringAsFixed(2)}";
          }
        } else {
          totalC.text = "${double.tryParse(genBearingKoplingC.text)}";
          rasioC.text = '0';
        }
      }
    }
  }

  VoidCallback? refresh;

  // DATA UPPER
  List<List<TextEditingController>> dataUpperC = [];
  List<TableRow> wDataUpperRow = [];

  generateDataUpperRow() {
    for (int i = 0; i < 5; i++) {
      if (i == 0) {
        wDataUpperRow.add(TableRow(children: [
          Text('\n\n', textAlign: TextAlign.center),
          Text('\nA\n', textAlign: TextAlign.center),
          Text('\nB\n', textAlign: TextAlign.center),
          Text('\nC\n', textAlign: TextAlign.center),
          Text('\nD\n', textAlign: TextAlign.center),
        ]));
      } else {
        dataUpperC.add([
          TextEditingController(),
          TextEditingController(),
          TextEditingController(),
          TextEditingController()
        ]);
        wDataUpperRow.add(TableRow(children: [
          Text('$i', textAlign: TextAlign.center),
          CustomTextField.tableTextField(
            controller: dataUpperC[i - 1][0],
            onChanged: (_) => notifyListeners(),
          ),
          CustomTextField.tableTextField(
            controller: dataUpperC[i - 1][1],
            onChanged: (_) => notifyListeners(),
          ),
          CustomTextField.tableTextField(
            controller: dataUpperC[i - 1][2],
            onChanged: (_) => notifyListeners(),
          ),
          CustomTextField.tableTextField(
            controller: dataUpperC[i - 1][3],
            onChanged: (_) => notifyListeners(),
          ),
        ]));
      }
    }
  }

  generateDataUpperRowLocal() {
    for (int i = 0; i < 5; i++) {
      if (i == 0) {
        wDataUpperRow.add(TableRow(children: [
          Text('\n\n', textAlign: TextAlign.center),
          Text('\nA\n', textAlign: TextAlign.center),
          Text('\nB\n', textAlign: TextAlign.center),
          Text('\nC\n', textAlign: TextAlign.center),
          Text('\nD\n', textAlign: TextAlign.center),
        ]));
      } else {
        if (i == 1) {
          dataUpperC.add([
            TextEditingController()
              ..text = (createDataParam?.Data?.Upper?.A?[0]).toString(),
            TextEditingController()
              ..text = (createDataParam?.Data?.Upper?.A?[1]).toString(),
            TextEditingController()
              ..text = (createDataParam?.Data?.Upper?.A?[2]).toString(),
            TextEditingController()
              ..text = (createDataParam?.Data?.Upper?.A?[3]).toString(),
          ]);
        }
        if (i == 2) {
          dataUpperC.add([
            TextEditingController()
              ..text = (createDataParam?.Data?.Upper?.B?[0]).toString(),
            TextEditingController()
              ..text = (createDataParam?.Data?.Upper?.B?[1]).toString(),
            TextEditingController()
              ..text = (createDataParam?.Data?.Upper?.B?[2]).toString(),
            TextEditingController()
              ..text = (createDataParam?.Data?.Upper?.B?[3]).toString(),
          ]);
        }
        if (i == 3) {
          dataUpperC.add([
            TextEditingController()
              ..text = (createDataParam?.Data?.Upper?.C?[0]).toString(),
            TextEditingController()
              ..text = (createDataParam?.Data?.Upper?.C?[1]).toString(),
            TextEditingController()
              ..text = (createDataParam?.Data?.Upper?.C?[2]).toString(),
            TextEditingController()
              ..text = (createDataParam?.Data?.Upper?.C?[3]).toString(),
          ]);
        }
        if (i == 4) {
          dataUpperC.add([
            TextEditingController()
              ..text = (createDataParam?.Data?.Upper?.D?[0]).toString(),
            TextEditingController()
              ..text = (createDataParam?.Data?.Upper?.D?[1]).toString(),
            TextEditingController()
              ..text = (createDataParam?.Data?.Upper?.D?[2]).toString(),
            TextEditingController()
              ..text = (createDataParam?.Data?.Upper?.D?[3]).toString(),
          ]);
        }
        wDataUpperRow.add(TableRow(children: [
          Text('$i', textAlign: TextAlign.center),
          CustomTextField.tableTextField(
            controller: dataUpperC[i - 1][0],
            onChanged: (_) => notifyListeners(),
          ),
          CustomTextField.tableTextField(
            controller: dataUpperC[i - 1][1],
            onChanged: (_) => notifyListeners(),
          ),
          CustomTextField.tableTextField(
            controller: dataUpperC[i - 1][2],
            onChanged: (_) => notifyListeners(),
          ),
          CustomTextField.tableTextField(
            controller: dataUpperC[i - 1][3],
            onChanged: (_) => notifyListeners(),
          ),
        ]));
      }
    }
  }

  Widget tableFormUpper(BuildContext context) {
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
            children: wDataUpperRow,
          ),
        ),
      ],
    );
  }

  Widget upperForm(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        Text("Upper", style: Constant.blackBold20),
        Constant.xSizedBox8,
        Text("Masukkan data upper pada tabel", style: Constant.grayMedium),
        Constant.xSizedBox16,
        tableFormUpper(context),
        Constant.xSizedBox16,
      ],
    );
  }

  // DATA CLUTCH /KOPLING
  List<List<TextEditingController>> dataClutchC = [];
  List<TableRow> wDataClutchRow = [];

  generateDataClutchRow() {
    for (int i = 0; i < 5; i++) {
      if (i == 0) {
        wDataClutchRow.add(TableRow(children: [
          Text('\n\n', textAlign: TextAlign.center),
          Text('\nA\n', textAlign: TextAlign.center),
          Text('\nB\n', textAlign: TextAlign.center),
          Text('\nC\n', textAlign: TextAlign.center),
          Text('\nD\n', textAlign: TextAlign.center),
        ]));
      } else {
        dataClutchC.add([
          TextEditingController(),
          TextEditingController(),
          TextEditingController(),
          TextEditingController()
        ]);
        wDataClutchRow.add(TableRow(children: [
          Text('$i', textAlign: TextAlign.center),
          CustomTextField.tableTextField(
            controller: dataClutchC[i - 1][0],
            onChanged: (_) => notifyListeners(),
          ),
          CustomTextField.tableTextField(
            controller: dataClutchC[i - 1][1],
            onChanged: (_) => notifyListeners(),
          ),
          CustomTextField.tableTextField(
            controller: dataClutchC[i - 1][2],
            onChanged: (_) => notifyListeners(),
          ),
          CustomTextField.tableTextField(
            controller: dataClutchC[i - 1][3],
            onChanged: (_) => notifyListeners(),
          ),
        ]));
      }
    }
  }

  generateDataClutchRowLocal() {
    for (int i = 0; i < 5; i++) {
      if (i == 0) {
        wDataClutchRow.add(TableRow(children: [
          Text('\n\n', textAlign: TextAlign.center),
          Text('\nA\n', textAlign: TextAlign.center),
          Text('\nB\n', textAlign: TextAlign.center),
          Text('\nC\n', textAlign: TextAlign.center),
          Text('\nD\n', textAlign: TextAlign.center),
        ]));
      } else {
        if (i == 1) {
          dataClutchC.add([
            TextEditingController()
              ..text = (createDataParam?.Data?.Clutch?.A?[0]).toString(),
            TextEditingController()
              ..text = (createDataParam?.Data?.Clutch?.A?[1]).toString(),
            TextEditingController()
              ..text = (createDataParam?.Data?.Clutch?.A?[2]).toString(),
            TextEditingController()
              ..text = (createDataParam?.Data?.Clutch?.A?[3]).toString(),
          ]);
        }
        if (i == 2) {
          dataClutchC.add([
            TextEditingController()
              ..text = (createDataParam?.Data?.Clutch?.B?[0]).toString(),
            TextEditingController()
              ..text = (createDataParam?.Data?.Clutch?.B?[1]).toString(),
            TextEditingController()
              ..text = (createDataParam?.Data?.Clutch?.B?[2]).toString(),
            TextEditingController()
              ..text = (createDataParam?.Data?.Clutch?.B?[3]).toString(),
          ]);
        }
        if (i == 3) {
          dataClutchC.add([
            TextEditingController()
              ..text = (createDataParam?.Data?.Clutch?.C?[0]).toString(),
            TextEditingController()
              ..text = (createDataParam?.Data?.Clutch?.C?[1]).toString(),
            TextEditingController()
              ..text = (createDataParam?.Data?.Clutch?.C?[2]).toString(),
            TextEditingController()
              ..text = (createDataParam?.Data?.Clutch?.C?[3]).toString(),
          ]);
        }
        if (i == 4) {
          dataClutchC.add([
            TextEditingController()
              ..text = (createDataParam?.Data?.Clutch?.D?[0]).toString(),
            TextEditingController()
              ..text = (createDataParam?.Data?.Clutch?.D?[1]).toString(),
            TextEditingController()
              ..text = (createDataParam?.Data?.Clutch?.D?[2]).toString(),
            TextEditingController()
              ..text = (createDataParam?.Data?.Clutch?.D?[3]).toString(),
          ]);
        }
        wDataClutchRow.add(TableRow(children: [
          Text('$i', textAlign: TextAlign.center),
          CustomTextField.tableTextField(
            controller: dataClutchC[i - 1][0],
            onChanged: (_) => notifyListeners(),
          ),
          CustomTextField.tableTextField(
            controller: dataClutchC[i - 1][1],
            onChanged: (_) => notifyListeners(),
          ),
          CustomTextField.tableTextField(
            controller: dataClutchC[i - 1][2],
            onChanged: (_) => notifyListeners(),
          ),
          CustomTextField.tableTextField(
            controller: dataClutchC[i - 1][3],
            onChanged: (_) => notifyListeners(),
          ),
        ]));
      }
    }
  }

  Widget tableFormClutch(BuildContext context) {
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
            children: wDataClutchRow,
          ),
        ),
      ],
    );
  }

  Widget clutchForm(BuildContext context) {
    return ListView(
      children: [
        Text("Clutch", style: Constant.blackBold20),
        Constant.xSizedBox8,
        Text("Masukkan data upper pada tabel", style: Constant.grayMedium),
        Constant.xSizedBox16,
        tableFormClutch(context),
        Constant.xSizedBox16,
      ],
    );
  }

  // DATA TURBINE
  List<List<TextEditingController>> dataTurbineC = [];
  List<TableRow> wDataTurbineRow = [];

  generateDataTurbineRow() {
    for (int i = 0; i < 5; i++) {
      if (i == 0) {
        wDataTurbineRow.add(TableRow(children: [
          Text('\n\n', textAlign: TextAlign.center),
          Text('\nA\n', textAlign: TextAlign.center),
          Text('\nB\n', textAlign: TextAlign.center),
          Text('\nC\n', textAlign: TextAlign.center),
          Text('\nD\n', textAlign: TextAlign.center),
        ]));
      } else {
        dataTurbineC.add([
          TextEditingController(),
          TextEditingController(),
          TextEditingController(),
          TextEditingController()
        ]);
        wDataTurbineRow.add(TableRow(children: [
          Text('$i', textAlign: TextAlign.center),
          CustomTextField.tableTextField(
            controller: dataTurbineC[i - 1][0],
            onChanged: (_) => notifyListeners(),
          ),
          CustomTextField.tableTextField(
            controller: dataTurbineC[i - 1][1],
            onChanged: (_) => notifyListeners(),
          ),
          CustomTextField.tableTextField(
            controller: dataTurbineC[i - 1][2],
            onChanged: (_) => notifyListeners(),
          ),
          CustomTextField.tableTextField(
            controller: dataTurbineC[i - 1][3],
            onChanged: (_) => notifyListeners(),
          ),
        ]));
      }
    }
  }

  generateDataTurbineRowLocal() {
    for (int i = 0; i < 5; i++) {
      if (i == 0) {
        wDataTurbineRow.add(TableRow(children: [
          Text('\n\n', textAlign: TextAlign.center),
          Text('\nA\n', textAlign: TextAlign.center),
          Text('\nB\n', textAlign: TextAlign.center),
          Text('\nC\n', textAlign: TextAlign.center),
          Text('\nD\n', textAlign: TextAlign.center),
        ]));
      } else {
        if (i == 1) {
          dataTurbineC.add([
            TextEditingController()
              ..text = (createDataParam?.Data?.Turbine?.A?[0]).toString(),
            TextEditingController()
              ..text = (createDataParam?.Data?.Turbine?.A?[1]).toString(),
            TextEditingController()
              ..text = (createDataParam?.Data?.Turbine?.A?[2]).toString(),
            TextEditingController()
              ..text = (createDataParam?.Data?.Turbine?.A?[3]).toString(),
          ]);
        }
        if (i == 2) {
          dataTurbineC.add([
            TextEditingController()
              ..text = (createDataParam?.Data?.Turbine?.B?[0]).toString(),
            TextEditingController()
              ..text = (createDataParam?.Data?.Turbine?.B?[1]).toString(),
            TextEditingController()
              ..text = (createDataParam?.Data?.Turbine?.B?[2]).toString(),
            TextEditingController()
              ..text = (createDataParam?.Data?.Turbine?.B?[3]).toString(),
          ]);
        }
        if (i == 3) {
          dataTurbineC.add([
            TextEditingController()
              ..text = (createDataParam?.Data?.Turbine?.C?[0]).toString(),
            TextEditingController()
              ..text = (createDataParam?.Data?.Turbine?.C?[1]).toString(),
            TextEditingController()
              ..text = (createDataParam?.Data?.Turbine?.C?[2]).toString(),
            TextEditingController()
              ..text = (createDataParam?.Data?.Turbine?.C?[3]).toString(),
          ]);
        }
        if (i == 4) {
          dataTurbineC.add([
            TextEditingController()
              ..text = (createDataParam?.Data?.Turbine?.D?[0]).toString(),
            TextEditingController()
              ..text = (createDataParam?.Data?.Turbine?.D?[1]).toString(),
            TextEditingController()
              ..text = (createDataParam?.Data?.Turbine?.D?[2]).toString(),
            TextEditingController()
              ..text = (createDataParam?.Data?.Turbine?.D?[3]).toString(),
          ]);
        }
        wDataTurbineRow.add(TableRow(children: [
          Text('$i', textAlign: TextAlign.center),
          CustomTextField.tableTextField(
            controller: dataTurbineC[i - 1][0],
            onChanged: (_) => notifyListeners(),
          ),
          CustomTextField.tableTextField(
            controller: dataTurbineC[i - 1][1],
            onChanged: (_) => notifyListeners(),
          ),
          CustomTextField.tableTextField(
            controller: dataTurbineC[i - 1][2],
            onChanged: (_) => notifyListeners(),
          ),
          CustomTextField.tableTextField(
            controller: dataTurbineC[i - 1][3],
            onChanged: (_) => notifyListeners(),
          ),
        ]));
      }
    }
  }

  Widget tableFormTurbine(BuildContext context) {
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
            children: wDataTurbineRow,
          ),
        ),
      ],
    );
  }

  Widget turbineForm(BuildContext context) {
    return ListView(
      children: [
        Text("Turbine", style: Constant.blackBold20),
        Constant.xSizedBox8,
        Text("Masukkan data upper pada tabel", style: Constant.grayMedium),
        Constant.xSizedBox16,
        tableFormTurbine(context),
        Constant.xSizedBox16,
      ],
    );
  }

  Widget labelNo() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              border: Border.all(color: Constant.borderLightColor),
            ),
            child: Text(
              "",
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              border: Border.all(color: Constant.borderLightColor),
            ),
            child: Text(
              "1",
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              border: Border.all(color: Constant.borderLightColor),
            ),
            child: Text(
              "2",
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              border: Border.all(color: Constant.borderLightColor),
            ),
            child: Text(
              "3",
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              border: Border.all(color: Constant.borderLightColor),
            ),
            child: Text(
              "4",
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  Widget valueTable() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              border: Border.all(color: Constant.borderLightColor),
            ),
            child: Text(
              "1",
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              border: Border.all(color: Constant.borderLightColor),
            ),
            child: Text(
              "50",
              textAlign: TextAlign.center,
              style: TextStyle(color: Constant.borderRegularColor),
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              border: Border.all(color: Constant.borderLightColor),
            ),
            child: Text(
              "48",
              textAlign: TextAlign.center,
              style: TextStyle(color: Constant.borderRegularColor),
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              border: Border.all(color: Constant.borderLightColor),
            ),
            child: Text(
              "46",
              textAlign: TextAlign.center,
              style: TextStyle(color: Constant.borderRegularColor),
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              border: Border.all(color: Constant.borderLightColor),
            ),
            child: Text(
              "55",
              textAlign: TextAlign.center,
              style: TextStyle(color: Constant.borderRegularColor),
            ),
          ),
        ),
      ],
    );
  }
}
