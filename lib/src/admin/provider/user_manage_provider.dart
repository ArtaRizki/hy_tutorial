import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hy_tutorial/common/base/base_response.dart';
import 'package:hy_tutorial/common/component/custom_navigator.dart';
import 'package:hy_tutorial/src/admin/model/generate_password_model.dart';
import 'package:hy_tutorial/src/division/provider/division_provider.dart';
import 'package:hy_tutorial/src/home/view/main_home.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../common/component/custom_alert.dart';
import '../../../main.dart';
import '../../../utils/utils.dart';
import '../../../common/base/base_controller.dart';
import '../../../common/helper/constant.dart';
import '../../../common/component/custom_dropdown.dart';
import '../../../common/component/custom_textfield.dart';
import '../model/user_detail_model.dart';
import '../../division/model/divison_model.dart';
import '../model/user_list_model.dart';

class UserManageProvider extends BaseController with ChangeNotifier {
  GlobalKey<FormState> userAddKey = GlobalKey<FormState>();

  PagingController<int, UserListModelData> _pagingController =
      PagingController(firstPageKey: 1);

  PagingController<int, UserListModelData> get pagingController =>
      this._pagingController;

  set pagingController(PagingController<int, UserListModelData> value) {
    this._pagingController = value;
  }

  PagingController<int, UserListModelData> _pagingController2 =
      PagingController(firstPageKey: 1);

  PagingController<int, UserListModelData> get pagingController2 =>
      this._pagingController2;

  set pagingController2(PagingController<int, UserListModelData> value) {
    this._pagingController2 = value;
  }

  PagingController<int, UserListModelData> _pagingController3 =
      PagingController(firstPageKey: 1);

  PagingController<int, UserListModelData> get pagingController3 =>
      this._pagingController3;

  set pagingController3(PagingController<int, UserListModelData> value) {
    this._pagingController3 = value;
  }

  PagingController<int, UserListModelData> _pagingController4 =
      PagingController(firstPageKey: 1);

  PagingController<int, UserListModelData> get pagingController4 =>
      this._pagingController4;

  set pagingController4(PagingController<int, UserListModelData> value) {
    this._pagingController4 = value;
  }

  PagingController<int, UserListModelData> _pagingControllerAdmin =
      PagingController(firstPageKey: 1);

  PagingController<int, UserListModelData> get pagingControllerAdmin =>
      this._pagingControllerAdmin;

  set pagingControllerAdmin(PagingController<int, UserListModelData> value) {
    this._pagingControllerAdmin = value;
  }

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

  TextEditingController userSearchC = TextEditingController();
  FocusNode userN = FocusNode();

  Duration duration2 = const Duration(seconds: 2);
  Timer? _searchOnStoppedTyping2;
  Timer? get searchOnStoppedTyping2 => this._searchOnStoppedTyping2;

  set searchOnStoppedTyping2(Timer? value) {
    this._searchOnStoppedTyping2 = value;
    notifyListeners();
  }

  bool _isFetching2 = false;
  bool get isFetching2 => this._isFetching2;

  set isFetching2(bool value) {
    this._isFetching2 = value;
  }

  TextEditingController userSearchC2 = TextEditingController();
  FocusNode userN2 = FocusNode();

  Duration duration3 = const Duration(seconds: 2);
  Timer? _searchOnStoppedTyping3;
  Timer? get searchOnStoppedTyping3 => this._searchOnStoppedTyping3;

  set searchOnStoppedTyping3(Timer? value) {
    this._searchOnStoppedTyping3 = value;
    notifyListeners();
  }

  bool _isFetching3 = false;
  bool get isFetching3 => this._isFetching3;

  set isFetching3(bool value) {
    this._isFetching3 = value;
  }

  TextEditingController userSearchC3 = TextEditingController();
  FocusNode userN3 = FocusNode();

  Duration duration4 = const Duration(seconds: 2);
  Timer? _searchOnStoppedTyping4;
  Timer? get searchOnStoppedTyping4 => this._searchOnStoppedTyping4;

  set searchOnStoppedTyping4(Timer? value) {
    this._searchOnStoppedTyping4 = value;
    notifyListeners();
  }

  bool _isFetching4 = false;
  bool get isFetching4 => this._isFetching4;

  set isFetching4(bool value) {
    this._isFetching4 = value;
  }

  TextEditingController userSearchC4 = TextEditingController();
  FocusNode userN4 = FocusNode();

  Duration durationAdmin = const Duration(seconds: 2);
  Timer? _searchOnStoppedTypingAdmin;
  Timer? get searchOnStoppedTypingAdmin => this._searchOnStoppedTypingAdmin;

  set searchOnStoppedTypingAdmin(Timer? value) {
    this._searchOnStoppedTypingAdmin = value;
    notifyListeners();
  }

  bool _isFetchingAdmin = false;
  bool get isFetchingAdmin => this._isFetchingAdmin;

  set isFetchingAdmin(bool value) {
    this._isFetchingAdmin = value;
  }

  TextEditingController userSearchCAdmin = TextEditingController();
  FocusNode userNAdmin = FocusNode();

  bool _ascending = false;
  bool get ascending => this._ascending;
  set ascending(bool value) => this._ascending = value;
  bool _descending = false;
  bool get descending => this._descending;
  set descending(bool value) => this._descending = value;

  bool _createdAt = false;
  bool get createdAt => this._createdAt;
  set createdAt(bool value) => this._createdAt = value;
  bool _username = false;
  bool get username => this._username;
  set username(bool value) => this._username = value;

  int pageSize = 0;

  get getPageSize => this.pageSize;

  set setPageSize(pageSize) {
    this.pageSize = pageSize;
    notifyListeners();
  }

  bool _ascending2 = false;
  bool get ascending2 => this._ascending2;
  set ascending2(bool value) => this._ascending2 = value;
  bool _descending2 = false;
  bool get descending2 => this._descending2;
  set descending2(bool value) => this._descending2 = value;

  bool _createdAt2 = false;
  bool get createdAt2 => this._createdAt2;
  set createdAt2(bool value) => this._createdAt2 = value;
  bool _username2 = false;
  bool get username2 => this._username2;
  set username2(bool value) => this._username2 = value;

  int pageSize2 = 0;

  get getPageSize2 => this.pageSize2;

  set setPageSize2(pageSize) {
    this.pageSize2 = pageSize;
    notifyListeners();
  }

  bool _ascending3 = false;
  bool get ascending3 => this._ascending3;
  set ascending3(bool value) => this._ascending3 = value;
  bool _descending3 = false;
  bool get descending3 => this._descending3;
  set descending3(bool value) => this._descending3 = value;

  bool _createdAt3 = false;
  bool get createdAt3 => this._createdAt3;
  set createdAt3(bool value) => this._createdAt3 = value;
  bool _username3 = false;
  bool get username3 => this._username3;
  set username3(bool value) => this._username3 = value;

  int pageSize3 = 0;

  get getPageSize3 => this.pageSize3;

  set setPageSize3(pageSize) {
    this.pageSize3 = pageSize;
    notifyListeners();
  }

  bool _ascending4 = false;
  bool get ascending4 => this._ascending4;
  set ascending4(bool value) => this._ascending4 = value;
  bool _descending4 = false;
  bool get descending4 => this._descending4;
  set descending4(bool value) => this._descending4 = value;

  bool _createdAt4 = false;
  bool get createdAt4 => this._createdAt4;
  set createdAt4(bool value) => this._createdAt4 = value;
  bool _username4 = false;
  bool get username4 => this._username4;
  set username4(bool value) => this._username4 = value;

  int pageSize4 = 0;

  get getPageSize4 => this.pageSize4;

  set setPageSize4(pageSize) {
    this.pageSize4 = pageSize;
    notifyListeners();
  }

  bool _ascendingAdmin = false;
  bool get ascendingAdmin => this._ascendingAdmin;
  set ascendingAdmin(bool value) => this._ascendingAdmin = value;
  bool _descendingAdmin = false;
  bool get descendingAdmin => this._descendingAdmin;
  set descendingAdmin(bool value) => this._descendingAdmin = value;

  bool _createdAtAdmin = false;
  bool get createdAtAdmin => this._createdAtAdmin;
  set createdAtAdmin(bool value) => this._createdAtAdmin = value;
  bool _usernameAdmin = false;
  bool get usernameAdmin => this._usernameAdmin;
  set usernameAdmin(bool value) => this._usernameAdmin = value;

  int pageSizeAdmin = 0;

  get getPageSizeAdmin => this.pageSizeAdmin;

  set setPageSizeAdmin(pageSize) {
    this.pageSizeAdmin = pageSize;
    notifyListeners();
  }

  String? next;
  String? next2;
  String? next3;
  String? next4;
  String? nextAdmin;

  Future<void> getUserList() async {
    pagingController = PagingController(firstPageKey: 1)
      ..addPageRequestListener((pageKey) async {
        log("GET USER");
        await fetchUser(page: pageKey).onError((error, stackTrace) {
          isFetching = false;
          if (error.toString().contains('expired token')) {
            log("ERROR EXPIRED TOKEN");
            next = null;
            pagingController.refresh();
          } else {
            BuildContext? context =
                NavigationService.navigatorKey.currentContext;
            if (context != null)
              CustomAlert.showSnackBar(
                  context, 'Gagal Mendapatkan Data User', true);
          }
        });
      });
  }

  Future<void> getUserList2() async {
    pagingController2 = PagingController(firstPageKey: 1)
      ..addPageRequestListener((pageKey) async {
        log("GET USER 2");
        await fetchUser2(page: pageKey).onError((error, stackTrace) {
          isFetching2 = false;
          if (error.toString().contains('expired token')) {
            log("ERROR EXPIRED TOKEN");
            next2 = null;
            pagingController2.refresh();
          } else {
            BuildContext? context =
                NavigationService.navigatorKey.currentContext;
            if (context != null)
              CustomAlert.showSnackBar(
                  context, 'Gagal Mendapatkan Data User', true);
          }
        });
      });
  }

  Future<void> getUserList3() async {
    pagingController3 = PagingController(firstPageKey: 1)
      ..addPageRequestListener((pageKey) async {
        log("GET USER 3");
        await fetchUser3(page: pageKey).onError((error, stackTrace) {
          isFetching3 = false;
          if (error.toString().contains('expired token')) {
            log("ERROR EXPIRED TOKEN");
            next3 = null;
            pagingController3.refresh();
          } else {
            BuildContext? context =
                NavigationService.navigatorKey.currentContext;
            if (context != null)
              CustomAlert.showSnackBar(
                  context, 'Gagal Mendapatkan Data User', true);
          }
        });
      });
  }

  Future<void> getUserList4() async {
    pagingController4 = PagingController(firstPageKey: 1)
      ..addPageRequestListener((pageKey) async {
        log("GET USER 4");
        await fetchUser4(page: pageKey).onError((error, stackTrace) {
          isFetching4 = false;
          if (error.toString().contains('expired token')) {
            log("ERROR EXPIRED TOKEN");
            next4 = null;
            pagingController4.refresh();
          } else {
            BuildContext? context =
                NavigationService.navigatorKey.currentContext;
            if (context != null)
              CustomAlert.showSnackBar(
                  context, 'Gagal Mendapatkan Data User', true);
          }
        });
      });
  }

  Future<void> getUserListAdmin() async {
    pagingControllerAdmin = PagingController(firstPageKey: 1)
      ..addPageRequestListener((pageKey) async {
        log("GET USER ADMIN");
        await fetchUserAdmin(page: pageKey).onError((error, stackTrace) {
          isFetchingAdmin = false;
          if (error.toString().contains('expired token')) {
            log("ERROR EXPIRED TOKEN");
            nextAdmin = null;
            pagingControllerAdmin.refresh();
          } else {
            BuildContext? context =
                NavigationService.navigatorKey.currentContext;
            if (context != null)
              CustomAlert.showSnackBar(
                  context, 'Gagal Mendapatkan Data User', true);
          }
        });
      });
  }

  Future<void> fetchUser({
    bool withLoading = false,
    required int page,
    String keyword = "",
  }) async {
    try {
      if (!isFetching) {
        isFetching = true;
        if (withLoading) loading(true);
        String url = Constant.BASE_API_FULL + '/admin/users';
        Map<String, String> param = {
          'Filter': 'Status',
          'FilterValue': '1',
        };

        if (userSearchC.text.isNotEmpty)
          param.addAll({'Search': userSearchC.text});

        if (next != null && next != '') param.addAll({'Next': next ?? ''});
        if (_pagingController.itemList?.length != 0) {
          await Future.delayed(Duration(seconds: 1));
        }
        final response = await get(url, body: param);

        if (response.statusCode == 201 || response.statusCode == 200) {
          final model = UserListModel.fromJson(jsonDecode(response.body));
          final items = model.Data ?? [];
          List<UserListModelData?> newItems;
          newItems = items;
          pageSize = 10;
          log("ITEMS LENGTH : ${newItems.length}");
          final isLastPage = newItems.length < pageSize;

          if (isLastPage || (model.Meta?.Next ?? '') == '') {
            next = null;
            pagingController
                .appendLastPage(newItems as List<UserListModelData>);
          } else {
            final nextPageKey = page += 1;
            if (model.Meta?.Next != null && model.Meta?.Next != '')
              next = model.Meta?.Next ?? '';
            pagingController.appendPage(
                newItems as List<UserListModelData>, nextPageKey);
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

  Future<void> fetchUser2({
    bool withLoading = false,
    required int page,
    String keyword = "",
  }) async {
    try {
      if (!isFetching2) {
        isFetching2 = true;
        if (withLoading) loading(true);
        String url = Constant.BASE_API_FULL + '/admin/users';
        Map<String, String> param = {
          'Filter': 'Status',
          'FilterValue': '0',
        };
        if (userSearchC2.text.isNotEmpty)
          param.addAll({'Search': userSearchC2.text});
        if (ascending2) {
          param.remove('SortOrder');
          param.addAll({'SortOrder': 'ASC'});
        }
        if (descending2) {
          param.remove('SortOrder');
          param.addAll({'SortOrder': 'DESC'});
        }
        if (username2) {
          param.remove('SortBy');
          param.addAll({'SortBy': 'Username'});
        }
        if (createdAt2) {
          param.remove('SortBy');
          param.addAll({'SortBy': 'CreatedAt'});
        }
        if (next2 != null && next2 != '') param.addAll({'Next': next2 ?? ''});
        if (_pagingController2.itemList?.length != 0) {
          await Future.delayed(Duration(seconds: 1));
        }
        final response = await get(url, body: param);

        if (response.statusCode == 201 || response.statusCode == 200) {
          final model = UserListModel.fromJson(jsonDecode(response.body));
          final items = model.Data ?? [];
          List<UserListModelData?> newItems;
          newItems = items;
          pageSize2 = 10;
          log("ITEMS LENGTH : ${newItems.length}");
          final isLastPage = newItems.length < pageSize2;

          if (isLastPage || (model.Meta?.Next ?? '') == '') {
            next2 = null;
            pagingController2
                .appendLastPage(newItems as List<UserListModelData>);
          } else {
            final nextPageKey = page += 1;
            if (model.Meta?.Next != null && model.Meta?.Next != '')
              next2 = model.Meta?.Next ?? '';
            pagingController2.appendPage(
                newItems as List<UserListModelData>, nextPageKey);
          }

          notifyListeners();
          if (withLoading) loading(false);
          isFetching2 = false;
        } else {
          log("MASUK ELSE");
          loading(false);
          isFetching2 = false;
          final message = jsonDecode(response.body)["Message"];
          throw Exception(message);
        }
      }
    } catch (e) {
      log("MASUK ELSE CATCH $e");
      loading(false);
      isFetching2 = false;
      throw Exception(e.toString());
    }
  }

  Future<void> fetchUser3({
    bool withLoading = false,
    required int page,
    String keyword = "",
  }) async {
    try {
      if (!isFetching3) {
        isFetching3 = true;
        if (withLoading) loading(true);
        String url = Constant.BASE_API_FULL + '/super/users';
        Map<String, String> param = {
          'Filter': 'Status',
          'FilterValue': '0',
        };
        if (userSearchC3.text.isNotEmpty)
          param.addAll({'Search': userSearchC3.text});

        if (next3 != null && next3 != '') param.addAll({'Next': next3 ?? ''});
        if (_pagingController3.itemList?.length != 0) {
          await Future.delayed(Duration(seconds: 1));
        }
        final response = await get(url, body: param);

        if (response.statusCode == 201 || response.statusCode == 200) {
          final model = UserListModel.fromJson(jsonDecode(response.body));
          final items = model.Data ?? [];
          List<UserListModelData?> newItems;
          newItems = items;
          pageSize3 = 10;
          log("ITEMS LENGTH : ${newItems.length}");
          final isLastPage = newItems.length < pageSize3;

          if (isLastPage || (model.Meta?.Next ?? '') == '') {
            next3 = null;
            pagingController3
                .appendLastPage(newItems as List<UserListModelData>);
          } else {
            final nextPageKey = page += 1;
            if (model.Meta?.Next != null && model.Meta?.Next != '')
              next3 = model.Meta?.Next ?? '';
            pagingController3.appendPage(
                newItems as List<UserListModelData>, nextPageKey);
          }

          notifyListeners();
          if (withLoading) loading(false);
          isFetching3 = false;
        } else {
          log("MASUK ELSE");
          loading(false);
          isFetching3 = false;
          final message = jsonDecode(response.body)["Message"];
          throw Exception(message);
        }
      }
    } catch (e) {
      log("MASUK ELSE CATCH $e");
      loading(false);
      isFetching2 = false;
      throw Exception(e.toString());
    }
  }

  Future<void> fetchUser4({
    bool withLoading = false,
    required int page,
    String keyword = "",
  }) async {
    try {
      if (!isFetching4) {
        isFetching4 = true;
        if (withLoading) loading(true);
        String url = Constant.BASE_API_FULL + '/super/users';
        Map<String, String> param = {
          'Filter': 'Role',
          'FilterValue': '3',
        };
        if (userSearchC4.text.isNotEmpty)
          param.addAll({'Search': userSearchC4.text});

        if (next4 != null && next4 != '') param.addAll({'Next': next4 ?? ''});
        if (_pagingController4.itemList?.length != 0) {
          await Future.delayed(Duration(seconds: 1));
        }
        final response = await get(url, body: param);

        if (response.statusCode == 201 || response.statusCode == 200) {
          final model = UserListModel.fromJson(jsonDecode(response.body));
          final items = model.Data ?? [];
          List<UserListModelData?> newItems;
          newItems = items;
          pageSize4 = 10;
          log("ITEMS LENGTH : ${newItems.length}");
          final isLastPage = newItems.length < pageSize4;

          if (isLastPage || (model.Meta?.Next ?? '') == '') {
            next4 = null;
            pagingController4
                .appendLastPage(newItems as List<UserListModelData>);
          } else {
            final nextPageKey = page += 1;
            if (model.Meta?.Next != null && model.Meta?.Next != '')
              next4 = model.Meta?.Next ?? '';
            pagingController4.appendPage(
                newItems as List<UserListModelData>, nextPageKey);
          }

          notifyListeners();
          if (withLoading) loading(false);
          isFetching4 = false;
        } else {
          log("MASUK ELSE");
          loading(false);
          isFetching4 = false;
          final message = jsonDecode(response.body)["Message"];
          throw Exception(message);
        }
      }
    } catch (e) {
      log("MASUK ELSE CATCH $e");
      loading(false);
      isFetching2 = false;
      throw Exception(e.toString());
    }
  }

  Future<void> fetchUserAdmin({
    bool withLoading = false,
    required int page,
    String keyword = "",
  }) async {
    try {
      if (!isFetchingAdmin) {
        isFetchingAdmin = true;
        if (withLoading) loading(true);
        String url = Constant.BASE_API_FULL + '/super/users';
        Map<String, String> param = {
          'Filter': 'Role',
          'FilterValue': '2',
        };
        if (userSearchCAdmin.text.isNotEmpty)
          param.addAll({'Search': userSearchCAdmin.text});
        if (ascendingAdmin) {
          param.remove('SortOrder');
          param.addAll({'SortOrder': 'ASC'});
        }
        if (descendingAdmin) {
          param.remove('SortOrder');
          param.addAll({'SortOrder': 'DESC'});
        }
        if (usernameAdmin) {
          param.remove('SortBy');
          param.addAll({'SortBy': 'Username'});
        }
        if (createdAtAdmin) {
          param.remove('SortBy');
          param.addAll({'SortBy': 'CreatedAt'});
        }
        if (nextAdmin != null && nextAdmin != '')
          param.addAll({'Next': nextAdmin ?? ''});
        if (_pagingControllerAdmin.itemList?.length != 0) {
          await Future.delayed(Duration(seconds: 1));
        }
        final response = await get(url, body: param);

        if (response.statusCode == 201 || response.statusCode == 200) {
          final model = UserListModel.fromJson(jsonDecode(response.body));
          final items = model.Data ?? [];
          List<UserListModelData?> newItems;
          newItems = items;
          pageSizeAdmin = 10;
          log("ITEMS LENGTH : ${newItems.length}");
          final isLastPage = newItems.length < pageSizeAdmin;

          if (isLastPage || (model.Meta?.Next ?? '') == '') {
            nextAdmin = null;
            pagingControllerAdmin
                .appendLastPage(newItems as List<UserListModelData>);
          } else {
            final nextPageKey = page += 1;
            if (model.Meta?.Next != null && model.Meta?.Next != '')
              nextAdmin = model.Meta?.Next ?? '';
            pagingControllerAdmin.appendPage(
                newItems as List<UserListModelData>, nextPageKey);
          }

          notifyListeners();
          if (withLoading) loading(false);
          isFetchingAdmin = false;
        } else {
          log("MASUK ELSE");
          loading(false);
          isFetchingAdmin = false;
          final message = jsonDecode(response.body)["Message"];
          throw Exception(message);
        }
      }
    } catch (e) {
      log("MASUK ELSE CATCH $e");
      loading(false);
      isFetchingAdmin = false;
      throw Exception(e.toString());
    }
  }

  TextEditingController emailC = TextEditingController();
  TextEditingController nameC = TextEditingController();
  TextEditingController nipC = TextEditingController();
  TextEditingController phoneNumberC = TextEditingController();
  TextEditingController usernameC = TextEditingController();
  TextEditingController passwordC = TextEditingController();
  //TextEditingController statusC = TextEditingController();

  setData(BuildContext context, String? id) async {
    // await clearForm();
    updateV = false;
    if (id != null) {
      updateV = true;
      await fetchUserDetail(id: id);
      final data = userDetailModel;
      nameC.text = data.Data?.Name ?? '';
      nipC.text = '';
      final p = context.read<DivisionProvider>();
      await p.fetchDivision(withLoading: true);
      final division = p.divisionModel.Data;
      selectedDivision = division
          ?.firstWhere((element) => element?.Name == data.Data?.Division)
          ?.Id;
      usernameC.text = data.Data?.Username ?? '';
      emailC.text = data.Data?.Email ?? '';
      phoneNumberC.text = data.Data?.Phone ?? '';
      passwordC.text = '';
      if (data.Data?.Role == "admin")
        selectedRole = "2";
      else
        selectedRole = "3";
      if (data.Data?.Status == "inactive")
        selectedStatus = "0";
      else if (data.Data?.Status == "active")
        selectedStatus = "1";
      else
        selectedStatus = "2";
    } else {
      updateV = false;
      final p = context.read<DivisionProvider>();
      await p.fetchDivision(withLoading: true);
    }
    notifyListeners();
  }

  Future<void> clearForm() async {
    emailC.text = '';
    phoneNumberC.text = '';
    usernameC.text = '';
    nameC.text = '';
    usernameC.text = '';
    passwordC.text = '';
    selectedDivision = null;
    selectedRole = null;
    selectedStatus = null;
    radiusStatus = false;
    radiusStatusC.text = 'Tidak Aktif';
  }

  bool _obscurePass = true;

  bool get obscurePass => this._obscurePass;

  toggleObscurePass() {
    this._obscurePass = !obscurePass;
    notifyListeners();
  }

  String? _selectedDivision;
  String? get selectedDivision => this._selectedDivision;

  set selectedDivision(String? value) {
    this._selectedDivision = value;
    // notifyListeners();
  }

  String? _selectedRole;
  String? get selectedRole => this._selectedRole;

  set selectedRole(String? value) {
    this._selectedRole = value;
    // notifyListeners();
  }

  String? _selectedStatus;
  String? get selectedStatus => this._selectedStatus;

  set selectedStatus(String? value) {
    this._selectedStatus = value;
    // notifyListeners();
  }

  bool _updateV = false;
  bool get updateV => this._updateV;
  set updateV(value) {
    this._updateV = value;
    // notifyListeners();
  }

  UserDetailModel _userDetailModel = UserDetailModel();
  UserDetailModel get userDetailModel => this._userDetailModel;
  set userDetailModel(UserDetailModel value) => this._userDetailModel = value;

  TextEditingController radiusStatusC = TextEditingController();
  bool _radiusStatus = true;
  bool get radiusStatus => _radiusStatus;
  set radiusStatus(bool value) {
    this._radiusStatus = value;
    // notifyListeners();
  }

  refresh() {
    notifyListeners();
  }

  Future<void> fetchUserDetail({required String id}) async {
    loading(true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final isSuperAdmin = prefs.getBool(Constant.kSetPrefIsSuperAdmin) ?? false;
    final response = await get(Constant.BASE_API_FULL +
        '/${isSuperAdmin ? 'super' : 'admin'}/users/$id');

    if (response.statusCode == 201 || response.statusCode == 200) {
      final model = UserDetailModel.fromJson(jsonDecode(response.body));
      userDetailModel = model;
      radiusStatusC.text =
          (model.Data?.RadiusStatus ?? false) ? 'Aktif' : 'Tidak Aktif';
      radiusStatus = model.Data?.RadiusStatus ?? false;
      notifyListeners();
      loading(false);
    } else {
      final message = jsonDecode(response.body)["Message"];
      loading(false);
      return message;
    }
  }

  List<Widget> userForm(
      List<DivisionModelData?>? Data, VoidCallback setState, bool isEdit) {
    return [
      Text("Input Data User", style: Constant.blackBold20),
      Constant.xSizedBox8,
      Text("Masukkan data user pada field dibawah", style: Constant.grayMedium),
      Constant.xSizedBox16,
      CustomTextField.borderTextField(
        controller: nameC,
        textInputType: TextInputType.name,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
        ],
        readOnly: isEdit,
        enabled: !isEdit,
        labelText: "Nama",
        hintText: "Nama",
        onChanged: (v) {
          setState();
        },
      ),
      Constant.xSizedBox16,
      CustomDropdown.normalDropdown(
        //controller: roleC,
        iconPadding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
        contentPadding: EdgeInsets.all(2),
        borderColor: Constant.primaryColor,
        labelText: "Divisi",
        //selectedItem: selectedRole,
        selectedItem: selectedDivision,
        hintText: "Divisi",
        list: List.generate(
          Data?.length ?? 0,
          (index) => DropdownMenuItem(
              child: Text(Data?[index]?.Name ?? ""),
              value: Data?[index]?.Id ?? ""),
        ),
        onChanged: (val) {
          selectedDivision = val;
          setState();
        },
      ),
      Constant.xSizedBox16,
      CustomTextField.borderTextField(
        controller: usernameC,
        labelText: "Username",
        hintText: "Username",
        readOnly: isEdit,
        enabled: !isEdit,
        onChanged: (v) {
          setState();
        },
      ),
      Constant.xSizedBox16,
      CustomTextField.borderTextField(
        controller: emailC,
        labelText: "Email",
        hintText: "Email",
        readOnly: isEdit,
        enabled: !isEdit,
        onChanged: (v) {
          setState();
        },
      ),
      Visibility(
        visible: updateV,
        child: CustomDropdown.normalDropdown(
          //controller: roleC,
          padding: EdgeInsets.only(top: 16),
          iconPadding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
          contentPadding: EdgeInsets.all(2),
          borderColor: Constant.primaryColor,
          labelText: "Role",
          selectedItem: selectedRole,
          //selectedItem: selectedDivision,
          hintText: "Role",
          list: [
            DropdownMenuItem(
              child: Text("Admin"),
              value: "2",
            ),
            DropdownMenuItem(
              child: Text("User"),
              value: "3",
            ),
          ],
          onChanged: (val) {
            selectedRole = val;
            setState();
          },
        ),
      ),
      Visibility(
        visible: updateV,
        child: CustomDropdown.normalDropdown(
          //controller: roleC,
          padding: EdgeInsets.only(top: 16),
          iconPadding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
          contentPadding: EdgeInsets.all(2),
          borderColor: Constant.primaryColor,
          labelText: "Status",
          selectedItem: selectedStatus,
          //selectedItem: selectedDivision,
          hintText: "Status",
          list: [
            DropdownMenuItem(
              child: Text("Inactive"),
              value: "0",
            ),
            DropdownMenuItem(
              child: Text("Active"),
              value: "1",
            ),
            DropdownMenuItem(
              child: Text("Blocked By Admin"),
              value: "2",
            ),
          ],
          onChanged: (val) {
            selectedStatus = val;
            validateUserForm();
            setState();
          },
        ),
      ),
      Constant.xSizedBox16,
      CustomTextField.borderTextField(
        controller: radiusStatusC,
        labelText: "Pembatasan Lokasi",
        textInputType: TextInputType.name,
        readOnly: true,
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        suffixIcon: Container(
          width: 25,
          height: 25,
          child: FittedBox(
            child: CupertinoSwitch(
              value: radiusStatus,
              onChanged: (value) async {
                radiusStatus = value;
                radiusStatusC.text = value ? 'Aktif' : 'Tidak Aktif';
                FocusManager.instance.primaryFocus?.unfocus();
                setState();
              },
            ),
          ),
        ),
      ),
      SizedBox(height: 64),
    ];
  }

  bool validateUserForm() {
    if (!updateV) {
      if (nameC.text.isEmpty) return false;
      if (selectedDivision == null) return false;
      if (usernameC.text.isEmpty) return false;
      if (passwordC.text.isEmpty) return false;
      if (emailC.text.isEmpty) return false;
      if (phoneNumberC.text.isEmpty) return false;
    } else {
      if (selectedDivision == null) return false;
      if (selectedRole == null) return false;
      if (selectedStatus == null) return false;
    }
    return true;
  }

  Future<void> addUser(BuildContext context) async {
    loading(true);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final isSuperAdmin = prefs.getBool(Constant.kSetPrefIsSuperAdmin) ?? false;
    if (selectedDivision == null) throw 'Pilih Divisi Terlebih Dahulu';
    FocusManager.instance.primaryFocus?.unfocus();
    Map<String, String> param = {
      'Name': nameC.text,
      'Username': usernameC.text,
      'Email': emailC.text,
      'Phone': phoneNumberC.text.replaceFirst('08', '628'),
      'Password': passwordC.text,
      'DivisionId': selectedDivision ?? '',
      'RadiusStatus': '$radiusStatus',
    };
    if (isSuperAdmin && selectedRole != null)
      param.addAll({'Role': selectedRole ?? ''});

    final response = await post(
        Constant.BASE_API_FULL + '/${isSuperAdmin ? 'super' : 'admin'}/users',
        body: param);

    if (response.statusCode == 201 || response.statusCode == 200) {
      final model = BaseResponse.from(response);

      loading(false);
      await Utils.showSuccess(msg: model.message ?? "Sukses");
      await Future.delayed(Duration(seconds: 2));
      final isAdmin = await prefs.getBool(Constant.kSetPrefIsAdmin) ?? false;

      // Navigator.pop(context);
      CusNav.nPushAndRemoveUntil(context, MainHome(index: 1),
          arguments: isAdmin);
      clearForm();
    } else {
      final message = jsonDecode(response.body)["Message"];
      loading(false);
      throw Exception(message);
    }
  }

  Future<void> updateUser(BuildContext context,
      {required String id, bool fromHome = false}) async {
    loading(true);
    FocusManager.instance.primaryFocus?.unfocus();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final isSuperAdmin =
        await prefs.getBool(Constant.kSetPrefIsSuperAdmin) ?? false;
    Map<String, String> param = {'RadiusStatus': '$radiusStatus'};
    // if (selectedRole != null) param.addAll({'Role': selectedRole ?? ''});

    if (isSuperAdmin && selectedRole != null)
      param.addAll({'Role': selectedRole ?? ''});
    if (selectedDivision != null)
      param.addAll({'DivisionId': selectedDivision ?? ''});
    if (selectedStatus != null) param.addAll({'Status': selectedStatus ?? ''});

    final response = await put(
        Constant.BASE_API_FULL +
            '/${isSuperAdmin ? 'super' : 'admin'}/users/$id',
        body: param);

    if (response.statusCode == 201 || response.statusCode == 200) {
      final model = BaseResponse.from(response);

      loading(false);
      await Utils.showSuccess(msg: model.message ?? "Sukses");
      await Future.delayed(Duration(seconds: 2));
      if (!fromHome) {
        Navigator.pop(context);
        Navigator.pop(context);
        next = null;
        next2 = null;
        notifyListeners();
        final isAdmin = await prefs.getBool(Constant.kSetPrefIsAdmin) ?? false;
        CusNav.nPushAndRemoveUntil(context, MainHome(index: 1),
            arguments: isAdmin);
      }

      clearForm();
    } else {
      final message = jsonDecode(response.body)["Message"];
      loading(false);
      throw Exception(message);
    }
  }

  GeneratePasswordModel _generatePasswordModel = GeneratePasswordModel();
  GeneratePasswordModel get generatePasswordModel =>
      this._generatePasswordModel;
  set generatePasswordModel(GeneratePasswordModel value) =>
      this._generatePasswordModel = value;

  Future<void> generatePass(BuildContext context, {required String id}) async {
    loading(true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final isSuperAdmin = prefs.getBool(Constant.kSetPrefIsSuperAdmin) ?? false;
    final response = await post(Constant.BASE_API_FULL +
        '/${isSuperAdmin ? 'super' : 'admin'}/users/generate-password/$id');

    if (response.statusCode == 201 || response.statusCode == 200) {
      generatePasswordModel =
          GeneratePasswordModel.fromJson(jsonDecode(response.body));
      passwordC.text = generatePasswordModel.Data?.Password ?? '';
      notifyListeners();
      loading(false);
      await Utils.showSuccess(msg: generatePasswordModel.Message ?? "Sukses");
      await Future.delayed(Duration(seconds: 2));
      await Clipboard.setData(
          ClipboardData(text: generatePasswordModel.Data?.Password ?? ''));
      CustomAlert.showSnackBar(context, 'Password berhasil disalin', false);
      // Navigator.pop(context);
    } else {
      final message = jsonDecode(response.body)["Message"];
      loading(false);
      return message;
    }
  }

  Future<void> deleteUser(BuildContext context, {required String id}) async {
    loading(true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final isSuperAdmin = prefs.getBool(Constant.kSetPrefIsSuperAdmin) ?? false;
    final response = await delete(Constant.BASE_API_FULL +
        '/${isSuperAdmin ? 'super' : 'admin'}/users/$id');

    if (response.statusCode == 201 || response.statusCode == 200) {
      final model = BaseResponse.from(response);
      loading(false);
      await Utils.showSuccess(msg: model.message ?? "Sukses");
      await Future.delayed(Duration(seconds: 2));
      Navigator.pop(context);
    } else {
      final message = jsonDecode(response.body)["Message"];
      loading(false);
      return message;
    }
  }
}
