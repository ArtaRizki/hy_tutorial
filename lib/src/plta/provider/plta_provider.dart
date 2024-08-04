import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hy_tutorial/common/component/custom_alert.dart';
import 'package:hy_tutorial/common/component/custom_dropdown.dart';
import 'package:hy_tutorial/main.dart';
import 'package:hy_tutorial/src/admin/view/user_manage_view.dart';
import 'package:hy_tutorial/src/data/provider/data_add_provider.dart';
import 'package:hy_tutorial/src/home/view/main_home.dart';
import 'package:hy_tutorial/src/plta/model/create_update_plta_unit_model.dart';
import 'package:hy_tutorial/src/plta/model/plta_list_model.dart';
import 'package:hy_tutorial/src/plta/view/plta_add_view.dart';
import 'package:hy_tutorial/src/plta/view/plta_detail_view.dart';
import 'package:hy_tutorial/utils/utils.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import '../../../common/base/base_response.dart';
import '../../../common/base/base_controller.dart';
import '../../../common/component/custom_textfield.dart';
import '../../../common/helper/constant.dart';
import '../model/plta_model.dart';
import '../model/plta_create_model.dart';
import '../model/plta_detail_model.dart';
import 'package:flutter_regex/flutter_regex.dart';
import 'package:http/http.dart' as http;

class PltaProvider extends BaseController with ChangeNotifier {
  PltaModel _pltaModel = PltaModel();
  PltaModel get pltaModel => this._pltaModel;
  set pltaModel(PltaModel value) => this._pltaModel = value;

  List<PltaModelData?>? _pltaList = [];
  List<PltaModelData?>? get pltaList => this._pltaList;

  set pltaList(List<PltaModelData?>? value) {
    this._pltaList = value;
    notifyListeners();
  }

  TextEditingController searchC = TextEditingController();

  Duration duration = const Duration(seconds: 2);
  Timer? _searchOnStoppedTyping;
  Timer? get searchOnStoppedTyping => this._searchOnStoppedTyping;

  set searchOnStoppedTyping(Timer? value) {
    this._searchOnStoppedTyping = value;
    notifyListeners();
  }

  bool _isFetching = false;
  bool get isFetching => this._isFetching;

  set isFetching(bool value) {
    this._isFetching = value;
  }

  int pageSize = 0;

  String? next;

  Widget search(BuildContext context) => CustomTextField.borderTextField(
        controller: searchC,
        required: false,
        hintText: "Search",
        hintColor: Constant.textHintColor,
        suffixIcon: Padding(
          padding: const EdgeInsets.all(12),
          child: Image.asset(
            'assets/icons/ic-search.png',
            width: 5,
            height: 5,
          ),
        ),
        onChange: (val) {
          if (searchOnStoppedTyping != null) {
            searchOnStoppedTyping!.cancel();
          }
          searchOnStoppedTyping = Timer(duration, () {
            fetchPlta(context);
          });
        },
      );

  Future<void> fetchPlta(BuildContext context) async {
    try {
      loading(true);
      pltaModel = PltaModel();
      final response = await get(Constant.BASE_API_FULL + '/plta/master');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final model = PltaModel.fromJson(jsonDecode(response.body));
        pltaList = model.Data;
        loading(false);
        notifyListeners();
      } else {
        loading(false);
        final message = jsonDecode(response.body)["Message"];
        await Utils.showFailed(msg: message ?? "Error");
      }
    } catch (e) {
      await Utils.showFailed(
          msg: e.toString().toLowerCase().contains("doctype")
              ? "Maaf, Terjadi Galat!"
              : "$e");
      throw Exception(e);
    }
  }

  PagingController<int, PltaListModelData> _pagingController =
      PagingController(firstPageKey: 1);

  PagingController<int, PltaListModelData> get pagingController =>
      this._pagingController;

  set pagingController(PagingController<int, PltaListModelData> value) {
    this._pagingController = value;
  }

  PltaListModel _pltaListModel = PltaListModel();
  PltaListModel get pltaListModel => this._pltaListModel;
  set pltaListModel(PltaListModel value) => this._pltaListModel = value;

  Future<void> getPltaList() async {
    pagingController = PagingController(firstPageKey: 1)
      ..addPageRequestListener((pageKey) async {
        log("GET PLTA LIST");
        await fetchPltaList(page: pageKey).onError((error, stackTrace) {
          if (error.toString().contains('expired token')) {
            log("ERROR EXPIRED TOKEN");
            next = null;
            pagingController.refresh();
          } else {
            BuildContext? context =
                NavigationService.navigatorKey.currentContext;
            if (context != null)
              CustomAlert.showSnackBar(
                  context, 'Gagal Mendapatkan Data Plta', true);
          }
        });
      });
  }

  // var pltaListDummy = {
  //   "Success": true,
  //   "StatusCode": 200,
  //   "Message": "berhasil mendapatkan semua plta",
  //   "Data": [
  //     {
  //       "Id": "01J4B2TGE9TEH97X27SJB65BT1",
  //       "Name": "PLTA Kebumen 1",
  //       "Status": true,
  //       "CreatedAt": "2024-08-03 09:59:10",
  //       "CreatedBy": "aditya fullname"
  //     },
  //     {
  //       "Id": "01J4B268KE75V22479S8XTSCXD",
  //       "Name": "PLTA golang",
  //       "Status": false,
  //       "CreatedAt": "2024-08-03 09:48:07",
  //       "CreatedBy": "aditya fullname"
  //     }
  //   ],
  //   "Meta": {"Next": "", "Prev": ""}
  // };
  Future<void> fetchPltaList({
    bool withLoading = false,
    required int page,
    String keyword = "",
  }) async {
    try {
      if (!isFetching) {
        isFetching = true;
        if (withLoading) loading(true);
        String url = Constant.BASE_API_FULL + '/plta';
        Map<String, String> param = {
          'Filter': 'Status',
          'FilterValue': '1',
        };
        if (searchC.text.isNotEmpty) param.addAll({'Search': searchC.text});
        if (next != null && next != '') param.addAll({'Next': next ?? ''});
        // log("PANGGIL");
        if (_pagingController.itemList?.length != 0) {
          await Future.delayed(Duration(seconds: 1));
        }
        final response = await get(
          url,
          body: param,
        );

        if (response.statusCode == 201 || response.statusCode == 200) {
          final model = PltaListModel.fromJson(jsonDecode(response.body));
          final items = model.Data ?? [];
          List<PltaListModelData?> newItems;
          newItems = items;
          // items.where((element) => element?.Status == 'active').toList();

          // userModel = model;
          // notifyListeners();

          final previouslyFetchedWordCount =
              _pagingController.itemList?.length ?? 0;
          pageSize = 10;
          log("ITEMS LENGTH : ${newItems.length}");
          final isLastPage = newItems.length < pageSize;

          if (isLastPage || (model.Meta?.Next ?? '') == '') {
            next = null;
            pagingController
                .appendLastPage(newItems as List<PltaListModelData>);
          } else {
            final nextPageKey = page += 1;
            if (model.Meta?.Next != null && model.Meta?.Next != '')
              next = model.Meta?.Next ?? '';
            pagingController.appendPage(
                newItems as List<PltaListModelData>, nextPageKey);
          }

          notifyListeners();
          if (withLoading) loading(false);
          isFetching = false;
        } else {
          log("MASUK ELSE");
          loading(false);
          isFetching = false;
          final message = jsonDecode(response.body)["Message"];
          throw Exception(message);
        }
      }
    } catch (e) {
      log("MASUK ELSE CATCH $e");
      loading(false);
      isFetching = false;
      throw Exception(e.toString());
    }
  }

  PltaDetailModel _pltaDetailModel = PltaDetailModel();
  PltaDetailModel get pltaDetailModel => this._pltaDetailModel;
  set pltaDetailModel(PltaDetailModel value) {
    this._pltaDetailModel = value;
    // notifyListeners();
  }

  List<bool> _statusActive = [];
  List<bool> get statusActive => this._statusActive;
  set statusActive(List<bool> value) => this._statusActive = value;

  List<PltaDetailModelDataUnits?> _pltaUnitList = [];
  List<PltaDetailModelDataUnits?> get pltaUnitList => this._pltaUnitList;
  set pltaUnitList(List<PltaDetailModelDataUnits?> value) =>
      this._pltaUnitList = value;

  List<TextEditingController> _pltaUnitListName = [];
  List<TextEditingController> get pltaUnitListName => this._pltaUnitListName;
  set pltaUnitListName(List<TextEditingController> value) =>
      this._pltaUnitListName = value;

  Future<void> fetchPltaDetail({required String id}) async {
    loading(true);
    statusActive = [];
    pltaUnitList = [];
    pltaUnitListName = [];
    final response = await get(Constant.BASE_API_FULL + '/plta/$id');

    if (response.statusCode == 201 || response.statusCode == 200) {
      // final model = PltaDetailModel.fromJson(dummyDetail);
      final model = PltaDetailModel.fromJson(jsonDecode(response.body));
      pltaDetailModel = model;
      statusActive =
          (model.Data?.Units ?? []).map((e) => e?.Status ?? false).toList();
      pltaUnitList = model.Data?.Units ?? [];

      if ((model.Data?.Units ?? []).isNotEmpty) {
        model.Data?.Units?.forEach((item) {
          pltaUnitListName.add(TextEditingController(text: item?.Name ?? ''));
        });
      }
      loading(false);
      notifyListeners();
    } else {
      final message = jsonDecode(response.body)["Message"];
      loading(false);
      throw Exception(message);
    }
  }

  tambahUnit() async {
    pltaUnitListName.add(TextEditingController());
    pltaUnitList.add(PltaDetailModelDataUnits(Name: '', Status: false));
    statusActive.add(false);
    notifyListeners();
  }

  hapusUnit(int index) async {
    pltaUnitListName.removeAt(index);
    pltaUnitList.removeAt(index);
    statusActive.removeAt(index);
    notifyListeners();
  }

  setPltaUnitListName(int index, String v) {
    pltaUnitList[index]?.Name = v;
    notifyListeners();
  }

  Future<void> sendPltaUnit(
    BuildContext context, {
    required String pltaId,
    bool isEdit = false,
    bool back = false,
    bool withLoading = false,
  }) async {
    if (withLoading) loading(true);
    PltaDetailModelData pltaDetailModelData =
        PltaDetailModelData(Units: pltaUnitList);
    String param = jsonEncode(pltaDetailModelData.toJson2());
    log("PARAM : $param");
    // Map<String, dynamic> body = jsonDecode(param);
    List<Map<String, dynamic>> b = [];
    for (int i = 0; i < (pltaDetailModelData.Units ?? []).length; i++) {
      final item = pltaDetailModelData.Units?[i];
      final itemC = pltaUnitListName[i].text;
      final bodyItem = {
        'Name': item?.Name ?? '',
        'Status': item?.Status ?? '',
      };
      if (item?.Id != null) bodyItem.addAll({'Id': item?.Id ?? ''});
      b.add(bodyItem);
    }
    notifyListeners();
    Map<String, dynamic> body = {"Units": jsonEncode(b)};
    http.Response response;
    if (isEdit)
      response =
          await put(Constant.BASE_API_FULL + '/plta-unit/$pltaId', body: body);
    else
      response =
          await post(Constant.BASE_API_FULL + '/plta-unit/$pltaId', body: body);
    if (response.statusCode == 201 || response.statusCode == 200) {
      final model = BaseResponse.from(response);
      if (withLoading) loading(false);
      await Utils.showSuccess(msg: model.message);
      await Future.delayed(Duration(seconds: 2));
      if (!isEdit || back) {
        Navigator.pop(context);
        nameC.clear();
        active = null;
        totalUnitC.clear();
        coordinateC.clear();
      }
    } else {
      final message = jsonDecode(response.body)["Message"];
      if (withLoading) loading(false);
      throw Exception(message);
    }
  }

  TextEditingController nameC = TextEditingController();
  TextEditingController totalUnitC = TextEditingController();
  String? active;
  String? get getActive => this.active;
  set setActive(String? active) => this.active = active;

  TextEditingController radiusStatusC = TextEditingController();
  bool _radiusStatus = true;
  get radiusStatus => _radiusStatus;
  set radiusStatus(value) {
    this._radiusStatus = value;
    notifyListeners();
  }

  TextEditingController coordinateC = TextEditingController();
  TextEditingController radiusC = TextEditingController();
  String? radiusType;
  String? get getRadiusType => this.radiusType;
  set setRadiusType(String? radiusType) => this.radiusType = radiusType;

  List<Widget> pltaForm(VoidCallback setState) {
    return [
      Text("Input Data PLTA", style: Constant.blackBold20),
      Constant.xSizedBox8,
      Text("Masukkan data PLTA pada field dibawah", style: Constant.grayMedium),
      Constant.xSizedBox16,
      CustomTextField.borderTextField(
        controller: nameC,
        textInputType: TextInputType.name,
        labelText: "Nama PLTA",
        hintText: "Masukkan nama PLTA",
      ),
      Constant.xSizedBox16,
      CustomTextField.borderTextField(
        controller: totalUnitC,
        labelText: "Jumlah Unit",
        hintText: "Masukkan jumlah unit",
      ),
      Constant.xSizedBox16,
      CustomDropdown.normalDropdown(
        //controller: roleC,
        iconPadding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
        contentPadding: EdgeInsets.all(2),
        borderColor: Constant.primaryColor,
        labelText: "Status",
        selectedItem: active,
        hintText: "Pilih status PLTA",
        list: [
          DropdownMenuItem(
            child: Text("Aktif"),
            value: "aktif",
          ),
          DropdownMenuItem(
            child: Text("Non Aktif"),
            value: "non_aktif",
          ),
        ],
        onChanged: (val) {
          active = val;
          setState();
          FocusManager.instance.primaryFocus?.unfocus();
        },
      ),
      Constant.xSizedBox16,
      CustomTextField.borderTextField(
        controller: coordinateC,
        labelText: "Titik Lokasi (Latitude & Longitude)",
        hintText: "Koordinat",
        textInputType: TextInputType.number,
        validator: (val) {
          if (val != null && !val.isLatLongCoordinatesDecimal())
            return 'Koordinat Tidak Valid';
          return null;
        },
      ),
      Constant.xSizedBox16,
      CustomTextField.borderTextField(
        controller: radiusC,
        labelText: "Radius",
        textInputType: TextInputType.number,
        hintText: "Masukkan Radius",
      ),
      Constant.xSizedBox16,
      CustomDropdown.normalDropdown(
        //controller: roleC,
        iconPadding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
        contentPadding: EdgeInsets.all(2),
        borderColor: Constant.primaryColor,
        labelText: "Tipe Radius",
        selectedItem: radiusType,
        hintText: "Pilih tipe Radius",
        list: [
          DropdownMenuItem(
            child: Text("KM"),
            value: "kilometer",
          ),
          DropdownMenuItem(
            child: Text("M"),
            value: "meter",
          ),
        ],
        onChanged: (val) {
          radiusType = val;
          setState();
          FocusManager.instance.primaryFocus?.unfocus();
        },
      ),
    ];
  }

  Future<void> sendPlta(
    BuildContext context, {
    bool isEdit = false,
    bool back = false,
    String? pltaId,
    bool withLoading = true,
  }) async {
    try {
      if (withLoading) loading(true);
      if (nameC.text.isEmpty) throw 'Nama harap diisi';
      if (active == null && !isEdit) throw 'Status harap dipilih';
      if (totalUnitC.text.isEmpty && !isEdit) throw 'Total unit harap diisi';
      if (coordinateC.text.isEmpty) throw 'Koordinat harap diisi';
      if (!coordinateC.text.isLatLongCoordinatesDecimal())
        throw 'Koordinat Tidak Valid';
      if (radiusC.text.isEmpty) throw 'Radius harap diisi';
      if (radiusType == null) throw 'Tipe radius harap dipilih';
      var split = coordinateC.text.split(',');
      Map<String, String> body = {
        'Name': nameC.text,
        'Status': active == 'aktif' ? 'true' : 'false',
        'Lat': split[0].replaceAll(',', '').trim(),
        'Long': split[1].trim(),
        'RadiusStatus': radiusStatus == true ? 'true' : 'false',
        'Radius': radiusC.text,
        'RadiusType': radiusType == 'kilometer' ? 'kilometer' : 'meter',
      };
      if (!isEdit) body.addAll({'TotalUnits': totalUnitC.text});
      http.Response response;
      if (isEdit)
        response =
            await put(Constant.BASE_API_FULL + '/plta/$pltaId', body: body);
      else
        response = await post(Constant.BASE_API_FULL + '/plta', body: body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        final model = BaseResponse.from(response);
        await Utils.showSuccess(msg: model.message);
        await Future.delayed(Duration(seconds: 2));
        if (withLoading) loading(false);
        if (back) {
          Navigator.pop(context);
          // Navigator.pushReplacement(context,
          //     MaterialPageRoute(builder: (context) => MainHome(index: 1)));
          nameC.clear();
          active = null;
          totalUnitC.clear();
          coordinateC.clear();
        }
      } else {
        final message = jsonDecode(response.body)["Message"];
        if (withLoading) loading(false);
        throw Exception(message);
      }
    } catch (e) {
      await Utils.showFailed(
          msg: e.toString().toLowerCase().contains("doctype")
              ? "Maaf, Terjadi Galat!"
              : "$e");
      throw Exception(e);
    }
  }

  Future<void> deletePlta(BuildContext context, {required String id}) async {
    loading(true);
    final response = await delete(Constant.BASE_API_FULL + '/plta/$id');

    if (response.statusCode == 201 || response.statusCode == 200) {
      final model = BaseResponse.from(response);
      loading(false);
      await Utils.showSuccess(msg: model.message ?? "Sukses");
      await Future.delayed(Duration(seconds: 2));
      Navigator.pop(context);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: ((context) => MainHome(
                    index: 1,
                  ))));
    } else {
      final message = jsonDecode(response.body)["Message"];
      loading(false);
      throw Exception(message);
    }
  }

  Future<void> deletePltaUnit(BuildContext context,
      {required String id, required String pltaId}) async {
    loading(true);
    final response = await delete(Constant.BASE_API_FULL + '/plta-unit/$id');

    if (response.statusCode == 201 || response.statusCode == 200) {
      final model = BaseResponse.from(response);
      loading(false);
      await Utils.showSuccess(msg: model.message ?? "Sukses");
      await Future.delayed(Duration(seconds: 2));
      Navigator.pop(context);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: ((context) => PltaDetailView(id: pltaId))));
    } else {
      final message = jsonDecode(response.body)["Message"];
      loading(false);
      throw Exception(message);
    }
  }
}
