// ignore_for_file: unnecessary_getters_setters
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
      _pagingController;

  set pagingController(PagingController<int, UserListModelData> value) {
    _pagingController = value;
  }

  PagingController<int, UserListModelData> _pagingController2 =
      PagingController(firstPageKey: 1);

  PagingController<int, UserListModelData> get pagingController2 =>
      _pagingController2;

  set pagingController2(PagingController<int, UserListModelData> value) {
    _pagingController2 = value;
  }

  PagingController<int, UserListModelData> _pagingController3 =
      PagingController(firstPageKey: 1);

  PagingController<int, UserListModelData> get pagingController3 =>
      _pagingController3;

  set pagingController3(PagingController<int, UserListModelData> value) {
    _pagingController3 = value;
  }

  PagingController<int, UserListModelData> _pagingController4 =
      PagingController(firstPageKey: 1);

  PagingController<int, UserListModelData> get pagingController4 =>
      _pagingController4;

  set pagingController4(PagingController<int, UserListModelData> value) {
    _pagingController4 = value;
  }

  PagingController<int, UserListModelData> _pagingControllerAdmin =
      PagingController(firstPageKey: 1);

  PagingController<int, UserListModelData> get pagingControllerAdmin =>
      _pagingControllerAdmin;

  set pagingControllerAdmin(PagingController<int, UserListModelData> value) {
    _pagingControllerAdmin = value;
  }

  Duration duration = const Duration(seconds: 2);
  Timer? _searchOnStoppedTyping;
  Timer? get searchOnStoppedTyping => _searchOnStoppedTyping;

  set searchOnStoppedTyping(Timer? value) {
    _searchOnStoppedTyping = value;
    notifyListeners();
  }

  bool _isFetching = false;
  bool get isFetching => _isFetching;

  set isFetching(bool value) {
    _isFetching = value;
  }

  TextEditingController userSearchC = TextEditingController();
  FocusNode userN = FocusNode();

  Duration duration2 = const Duration(seconds: 2);
  Timer? _searchOnStoppedTyping2;
  Timer? get searchOnStoppedTyping2 => _searchOnStoppedTyping2;

  set searchOnStoppedTyping2(Timer? value) {
    _searchOnStoppedTyping2 = value;
    notifyListeners();
  }

  bool _isFetching2 = false;
  bool get isFetching2 => _isFetching2;

  set isFetching2(bool value) {
    _isFetching2 = value;
  }

  TextEditingController userSearchC2 = TextEditingController();
  FocusNode userN2 = FocusNode();

  Duration duration3 = const Duration(seconds: 2);
  Timer? _searchOnStoppedTyping3;
  Timer? get searchOnStoppedTyping3 => _searchOnStoppedTyping3;

  set searchOnStoppedTyping3(Timer? value) {
    _searchOnStoppedTyping3 = value;
    notifyListeners();
  }

  bool _isFetching3 = false;
  bool get isFetching3 => _isFetching3;

  set isFetching3(bool value) {
    _isFetching3 = value;
  }

  TextEditingController userSearchC3 = TextEditingController();
  FocusNode userN3 = FocusNode();

  Duration duration4 = const Duration(seconds: 2);
  Timer? _searchOnStoppedTyping4;
  Timer? get searchOnStoppedTyping4 => _searchOnStoppedTyping4;

  set searchOnStoppedTyping4(Timer? value) {
    _searchOnStoppedTyping4 = value;
    notifyListeners();
  }

  bool _isFetching4 = false;
  bool get isFetching4 => _isFetching4;

  set isFetching4(bool value) {
    _isFetching4 = value;
  }

  TextEditingController userSearchC4 = TextEditingController();
  FocusNode userN4 = FocusNode();

  Duration durationAdmin = const Duration(seconds: 2);
  Timer? _searchOnStoppedTypingAdmin;
  Timer? get searchOnStoppedTypingAdmin => _searchOnStoppedTypingAdmin;

  set searchOnStoppedTypingAdmin(Timer? value) {
    _searchOnStoppedTypingAdmin = value;
    notifyListeners();
  }

  bool _isFetchingAdmin = false;
  bool get isFetchingAdmin => _isFetchingAdmin;

  set isFetchingAdmin(bool value) {
    _isFetchingAdmin = value;
  }

  TextEditingController userSearchCAdmin = TextEditingController();
  FocusNode userNAdmin = FocusNode();

  bool _ascending = false;
  bool get ascending => _ascending;
  set ascending(bool value) => _ascending = value;
  bool _descending = false;
  bool get descending => _descending;
  set descending(bool value) => _descending = value;

  bool _createdAt = false;
  bool get createdAt => _createdAt;
  set createdAt(bool value) => _createdAt = value;
  bool _username = false;
  bool get username => _username;
  set username(bool value) => _username = value;

  int pageSize = 0;

  get getPageSize => pageSize;

  set setPageSize(pageSize) {
    this.pageSize = pageSize;
    notifyListeners();
  }

  bool _ascending2 = false;
  bool get ascending2 => _ascending2;
  set ascending2(bool value) => _ascending2 = value;
  bool _descending2 = false;
  bool get descending2 => _descending2;
  set descending2(bool value) => _descending2 = value;

  bool _createdAt2 = false;
  bool get createdAt2 => _createdAt2;
  set createdAt2(bool value) => _createdAt2 = value;
  bool _username2 = false;
  bool get username2 => _username2;
  set username2(bool value) => _username2 = value;

  int pageSize2 = 0;

  get getPageSize2 => pageSize2;

  set setPageSize2(pageSize) {
    pageSize2 = pageSize;
    notifyListeners();
  }

  bool _ascending3 = false;
  bool get ascending3 => _ascending3;
  set ascending3(bool value) => _ascending3 = value;
  bool _descending3 = false;
  bool get descending3 => _descending3;
  set descending3(bool value) => _descending3 = value;

  bool _createdAt3 = false;
  bool get createdAt3 => _createdAt3;
  set createdAt3(bool value) => _createdAt3 = value;
  bool _username3 = false;
  bool get username3 => _username3;
  set username3(bool value) => _username3 = value;

  int pageSize3 = 0;

  get getPageSize3 => pageSize3;

  set setPageSize3(pageSize) {
    pageSize3 = pageSize;
    notifyListeners();
  }

  bool _ascending4 = false;
  bool get ascending4 => _ascending4;
  set ascending4(bool value) => _ascending4 = value;
  bool _descending4 = false;
  bool get descending4 => _descending4;
  set descending4(bool value) => _descending4 = value;

  bool _createdAt4 = false;
  bool get createdAt4 => _createdAt4;
  set createdAt4(bool value) => _createdAt4 = value;
  bool _username4 = false;
  bool get username4 => _username4;
  set username4(bool value) => _username4 = value;

  int pageSize4 = 0;

  get getPageSize4 => pageSize4;

  set setPageSize4(pageSize) {
    pageSize4 = pageSize;
    notifyListeners();
  }

  bool _ascendingAdmin = false;
  bool get ascendingAdmin => _ascendingAdmin;
  set ascendingAdmin(bool value) => _ascendingAdmin = value;
  bool _descendingAdmin = false;
  bool get descendingAdmin => _descendingAdmin;
  set descendingAdmin(bool value) => _descendingAdmin = value;

  bool _createdAtAdmin = false;
  bool get createdAtAdmin => _createdAtAdmin;
  set createdAtAdmin(bool value) => _createdAtAdmin = value;
  bool _usernameAdmin = false;
  bool get usernameAdmin => _usernameAdmin;
  set usernameAdmin(bool value) => _usernameAdmin = value;

  int pageSizeAdmin = 0;

  get getPageSizeAdmin => pageSizeAdmin;

  set setPageSizeAdmin(pageSize) {
    pageSizeAdmin = pageSize;
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
            if (context != null && context.mounted) {
              CustomAlert.showSnackBar(
                  context, 'Gagal Mendapatkan Data User', true);
            }
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
            if (context != null && context.mounted) {
              CustomAlert.showSnackBar(
                  context, 'Gagal Mendapatkan Data User', true);
            }
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
            if (context != null && context.mounted) {
              CustomAlert.showSnackBar(
                  context, 'Gagal Mendapatkan Data User', true);
            }
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
            if (context != null && context.mounted) {
              CustomAlert.showSnackBar(
                  context, 'Gagal Mendapatkan Data User', true);
            }
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
            if (context != null && context.mounted) {
              CustomAlert.showSnackBar(
                  context, 'Gagal Mendapatkan Data User', true);
            }
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
        if (withLoading) {
          loading(true);
        }
        String url = '${Constant.BASE_API_FULL}/admin/users';
        Map<String, String> param = {
          'Filter': 'Status',
          'FilterValue': '1',
        };

        if (userSearchC.text.isNotEmpty) {
          param.addAll({'Search': userSearchC.text});
        }

        if (next != null && next != '') {
          param.addAll({'Next': next ?? ''});
        }
        if (pagingController.itemList?.isNotEmpty == true) {
          await Future.delayed(const Duration(seconds: 1));
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
            if (model.Meta?.Next != null && model.Meta?.Next != '') {
              next = model.Meta?.Next ?? '';
            }
            pagingController.appendPage(
                newItems as List<UserListModelData>, nextPageKey);
          }

          notifyListeners();
          if (withLoading) {
            loading(false);
          }
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
        if (withLoading) {
          loading(true);
        }
        String url = '${Constant.BASE_API_FULL}/admin/users';
        Map<String, String> param = {
          'Filter': 'Status',
          'FilterValue': '0',
        };
        if (userSearchC2.text.isNotEmpty) {
          param.addAll({'Search': userSearchC2.text});
        }
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
        if (next2 != null && next2 != '') {
          param.addAll({'Next': next2 ?? ''});
        }
        if (pagingController2.itemList?.isNotEmpty == true) {
          await Future.delayed(const Duration(seconds: 1));
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
            if (model.Meta?.Next != null && model.Meta?.Next != '') {
              next2 = model.Meta?.Next ?? '';
            }
            pagingController2.appendPage(
                newItems as List<UserListModelData>, nextPageKey);
          }

          notifyListeners();
          if (withLoading) {
            loading(false);
          }
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
        if (withLoading) {
          loading(true);
        }
        String url = '${Constant.BASE_API_FULL}/super/users';
        Map<String, String> param = {
          'Filter': 'Status',
          'FilterValue': '0',
        };
        if (userSearchC3.text.isNotEmpty) {
          param.addAll({'Search': userSearchC3.text});
        }

        if (next3 != null && next3 != '') {
          param.addAll({'Next': next3 ?? ''});
        }
        if (pagingController3.itemList?.isNotEmpty == true) {
          await Future.delayed(const Duration(seconds: 1));
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
            if (model.Meta?.Next != null && model.Meta?.Next != '') {
              next3 = model.Meta?.Next ?? '';
            }
            pagingController3.appendPage(
                newItems as List<UserListModelData>, nextPageKey);
          }

          notifyListeners();
          if (withLoading) {
            loading(false);
          }
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
        if (withLoading) {
          loading(true);
        }
        String url = '${Constant.BASE_API_FULL}/super/users';
        Map<String, String> param = {
          'Filter': 'Role',
          'FilterValue': '3',
        };
        if (userSearchC4.text.isNotEmpty) {
          param.addAll({'Search': userSearchC4.text});
        }

        if (next4 != null && next4 != '') {
          param.addAll({'Next': next4 ?? ''});
        }
        if (pagingController4.itemList?.isNotEmpty == true) {
          await Future.delayed(const Duration(seconds: 1));
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
            if (model.Meta?.Next != null && model.Meta?.Next != '') {
              next4 = model.Meta?.Next ?? '';
            }
            pagingController4.appendPage(
                newItems as List<UserListModelData>, nextPageKey);
          }

          notifyListeners();
          if (withLoading) {
            loading(false);
          }
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
        if (withLoading) {
          loading(true);
        }
        String url = '${Constant.BASE_API_FULL}/super/users';
        Map<String, String> param = {
          'Filter': 'Role',
          'FilterValue': '2',
        };
        if (userSearchCAdmin.text.isNotEmpty) {
          param.addAll({'Search': userSearchCAdmin.text});
        }
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
        if (nextAdmin != null && nextAdmin != '') {
          param.addAll({'Next': nextAdmin ?? ''});
        }
        if (pagingControllerAdmin.itemList?.isNotEmpty == true) {
          await Future.delayed(const Duration(seconds: 1));
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
            if (model.Meta?.Next != null && model.Meta?.Next != '') {
              nextAdmin = model.Meta?.Next ?? '';
            }
            pagingControllerAdmin.appendPage(
                newItems as List<UserListModelData>, nextPageKey);
          }

          notifyListeners();
          if (withLoading) {
            loading(false);
          }
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
      if (!context.mounted) return;
      final p = context.read<DivisionProvider>();
      await p.fetchDivision(withLoading: true);
      final division = p.divisionModel.Data;
      selectedDivision = division
          ?.firstWhere((element) => element?.Name == data.Data?.Division)
          ?.Id;
      usernameC.text = data.Data?.Username ?? '';
      emailC.text = data.Data?.Email ?? '';
      phoneNumberC.text = (data.Data?.Phone ?? '').replaceFirst('+', '');
      passwordC.text = '';
      if (data.Data?.Role == "admin") {
        selectedRole = "2";
      } else {
        selectedRole = "3";
      }
      if (data.Data?.Status == "inactive") {
        selectedStatus = "0";
      } else if (data.Data?.Status == "active") {
        selectedStatus = "1";
      } else {
        selectedStatus = "2";
      }
    } else {
      updateV = false;
      if (context.mounted) {
        final p = context.read<DivisionProvider>();
        await p.fetchDivision(withLoading: true);
      }
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

  bool get obscurePass => _obscurePass;

  toggleObscurePass() {
    _obscurePass = !obscurePass;
    notifyListeners();
  }

  String? _selectedDivision;
  String? get selectedDivision => _selectedDivision;

  set selectedDivision(String? value) {
    _selectedDivision = value;
    // notifyListeners();
  }

  String? _selectedRole;
  String? get selectedRole => _selectedRole;

  set selectedRole(String? value) {
    _selectedRole = value;
    // notifyListeners();
  }

  String? _selectedStatus;
  String? get selectedStatus => _selectedStatus;

  set selectedStatus(String? value) {
    _selectedStatus = value;
    // notifyListeners();
  }

  bool _updateV = false;
  bool get updateV => _updateV;
  set updateV(value) {
    _updateV = value;
    // notifyListeners();
  }

  UserDetailModel _userDetailModel = UserDetailModel();
  UserDetailModel get userDetailModel => _userDetailModel;
  set userDetailModel(UserDetailModel value) => _userDetailModel = value;

  TextEditingController radiusStatusC = TextEditingController();
  bool _radiusStatus = true;
  bool get radiusStatus => _radiusStatus;
  set radiusStatus(bool value) {
    _radiusStatus = value;
    // notifyListeners();
  }

  refresh() {
    notifyListeners();
  }

  Future<void> fetchUserDetail({required String id}) async {
    loading(true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final isSuperAdmin = prefs.getBool(Constant.kSetPrefIsSuperAdmin) ?? false;
    final response = await get(
        '${Constant.BASE_API_FULL}/${isSuperAdmin ? 'super' : 'admin'}/users/$id');

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
      List<DivisionModelData?>? data, VoidCallback setState, bool isEdit) {
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
        contentPadding: const EdgeInsets.all(2),
        borderColor: Constant.primaryColor,
        labelText: "Divisi",
        //selectedItem: selectedRole,
        selectedItem: selectedDivision,
        hintText: "Divisi",
        list: List.generate(
          data?.length ?? 0,
          (index) => DropdownMenuItem(
              value: data?[index]?.Id ?? "",
              child: Text(data?[index]?.Name ?? "")),
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
          padding: const EdgeInsets.only(top: 16),
          iconPadding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
          contentPadding: const EdgeInsets.all(2),
          borderColor: Constant.primaryColor,
          labelText: "Role",
          selectedItem: selectedRole,
          //selectedItem: selectedDivision,
          hintText: "Role",
          list: const [
            DropdownMenuItem(
              value: "2",
              child: Text("Admin"),
            ),
            DropdownMenuItem(
              value: "3",
              child: Text("User"),
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
          padding: const EdgeInsets.only(top: 16),
          iconPadding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
          contentPadding: const EdgeInsets.all(2),
          borderColor: Constant.primaryColor,
          labelText: "Status",
          selectedItem: selectedStatus,
          //selectedItem: selectedDivision,
          hintText: "Status",
          list: const [
            DropdownMenuItem(
              value: "0",
              child: Text("Inactive"),
            ),
            DropdownMenuItem(
              value: "1",
              child: Text("Active"),
            ),
            DropdownMenuItem(
              value: "2",
              child: Text("Blocked By Admin"),
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
        suffixIcon: SizedBox(
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
      const SizedBox(height: 64),
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
    if (isSuperAdmin && selectedRole != null) {
      param.addAll({'Role': selectedRole ?? ''});
    }

    final response = await post(
        '${Constant.BASE_API_FULL}/${isSuperAdmin ? 'super' : 'admin'}/users',
        body: param);

    if (response.statusCode == 201 || response.statusCode == 200) {
      final model = BaseResponse.from(response);

      loading(false);
      await Utils.showSuccess(msg: model.message);
      await Future.delayed(const Duration(seconds: 2));
      final isAdmin = prefs.getBool(Constant.kSetPrefIsAdmin) ?? false;

      // CusNav.nPop(context);
      if (context.mounted) {
        CusNav.nPushAndRemoveUntil(context, const MainHome(index: 1),
            arguments: isAdmin);
      }
      clearForm();
    } else {
      final model = BaseResponse.from(response);

      final message = model.message;
      loading(false);
      await Utils.showFailed(msg: model.message);
      await Future.delayed(const Duration(seconds: 2));
      throw Exception(message);
    }
  }

  Future<void> updateUser(BuildContext context,
      {required String id, bool fromHome = false}) async {
    loading(true);
    FocusManager.instance.primaryFocus?.unfocus();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final isSuperAdmin =
        prefs.getBool(Constant.kSetPrefIsSuperAdmin) ?? false;
    Map<String, String> param = {'RadiusStatus': '$radiusStatus'};
    // if (selectedRole != null) param.addAll({'Role': selectedRole ?? ''});

    if (isSuperAdmin && selectedRole != null) {
      param.addAll({'Role': selectedRole ?? ''});
    }
    if (selectedDivision != null) {
      param.addAll({'DivisionId': selectedDivision ?? ''});
    }
    if (selectedStatus != null) {
      param.addAll({'Status': selectedStatus ?? ''});
    }

    final response = await put(
        '${Constant.BASE_API_FULL}/${isSuperAdmin ? 'super' : 'admin'}/users/$id',
        body: param);

    if (response.statusCode == 201 || response.statusCode == 200) {
      final model = BaseResponse.from(response);

      loading(false);
      await Utils.showSuccess(msg: model.message);
      await Future.delayed(const Duration(seconds: 2));
      if (!fromHome) {
        if (context.mounted) {
          CusNav.nPop(context);
          CusNav.nPop(context);
        }
        next = null;
        next2 = null;
        notifyListeners();
        final isAdmin = prefs.getBool(Constant.kSetPrefIsAdmin) ?? false;
        if (context.mounted) {
          CusNav.nPushAndRemoveUntil(context, const MainHome(index: 1),
              arguments: isAdmin);
        }
      }

      clearForm();
    } else {
      final model = BaseResponse.from(response);

      final message = model.message;
      loading(false);
      await Utils.showFailed(msg: model.message);
      await Future.delayed(const Duration(seconds: 2));
      throw Exception(message);
    }
  }

  GeneratePasswordModel _generatePasswordModel = GeneratePasswordModel();
  GeneratePasswordModel get generatePasswordModel =>
      _generatePasswordModel;
  set generatePasswordModel(GeneratePasswordModel value) =>
      _generatePasswordModel = value;

  Future<void> generatePass(BuildContext context, {required String id}) async {
    loading(true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final isSuperAdmin = prefs.getBool(Constant.kSetPrefIsSuperAdmin) ?? false;
    final response = await post(
        '${Constant.BASE_API_FULL}/${isSuperAdmin ? 'super' : 'admin'}/users/generate-password/$id');

    if (response.statusCode == 201 || response.statusCode == 200) {
      generatePasswordModel =
          GeneratePasswordModel.fromJson(jsonDecode(response.body));
      passwordC.text = generatePasswordModel.Data?.Password ?? '';
      notifyListeners();
      loading(false);
      await Utils.showSuccess(msg: generatePasswordModel.Message ?? "Sukses");
      await Future.delayed(const Duration(seconds: 2));
      await Clipboard.setData(
          ClipboardData(text: generatePasswordModel.Data?.Password ?? ''));
      if (context.mounted) {
        CustomAlert.showSnackBar(context, 'Password berhasil disalin', false);
      }
      // CusNav.nPop(context);
    } else {
      final model = BaseResponse.from(response);

      final message = model.message;
      loading(false);
      await Utils.showFailed(msg: model.message);
      await Future.delayed(const Duration(seconds: 2));
      throw Exception(message);
    }
  }

  Future<void> deleteUser(BuildContext context, {required String id}) async {
    loading(true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final isSuperAdmin = prefs.getBool(Constant.kSetPrefIsSuperAdmin) ?? false;
    final response = await delete(
        '${Constant.BASE_API_FULL}/${isSuperAdmin ? 'super' : 'admin'}/users/$id');

    if (response.statusCode == 201 || response.statusCode == 200) {
      final model = BaseResponse.from(response);
      loading(false);
      await Utils.showSuccess(msg: model.message);
      await Future.delayed(const Duration(seconds: 2));
      if (context.mounted) {
        CusNav.nPop(context);
      }
    } else {
      final message = jsonDecode(response.body)["Message"];
      loading(false);
      return message;
    }
  }
}
