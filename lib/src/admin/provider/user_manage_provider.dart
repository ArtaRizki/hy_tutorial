import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hy_tutorial/common/base/base_response.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:powers/powers.dart';
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
import '../view/user_manage_view.dart';

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

  String? next;
  String? next2;

  Future<void> getUserList() async {
    pagingController = PagingController(firstPageKey: 1)
      ..addPageRequestListener((pageKey) async {
        log("GET USER");
        await fetchUser(page: pageKey).onError((error, stackTrace) {
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
        if (ascending) {
          param.remove('SortOrder');
          param.addAll({'SortOrder': 'ASC'});
        }
        if (descending) {
          param.remove('SortOrder');
          param.addAll({'SortOrder': 'DESC'});
        }
        if (username) {
          param.remove('SortBy');
          param.addAll({'SortBy': 'Username'});
        }
        if (createdAt) {
          param.remove('SortBy');
          param.addAll({'SortBy': 'CreatedAt'});
        }

        if (next != null && next != '') param.addAll({'Next': next ?? ''});
        log("PANGGIL");
        if (_pagingController.itemList?.length != 0) {
          await Future.delayed(Duration(seconds: 1));
        }
        final response = await get(
          url,
          body: param,
        );

        if (response.statusCode == 201 || response.statusCode == 200) {
          final model = UserListModel.fromJson(jsonDecode(response.body));
          final items = model.Data ?? [];
          List<UserListModelData?> newItems;
          newItems = items;
          // items.where((element) => element?.Status == 'active').toList();

          // userModel = model;
          // notifyListeners();

          final previouslyFetchedWordCount =
              _pagingController.itemList?.length ?? 0;
          pageSize = 10;
          log("ITEMS LENGTH : ${newItems.length}");
          final isLastPage = newItems.length < pageSize;

          if (isLastPage) {
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

          // notifyListeners();
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
        log("PANGGIL");
        if (_pagingController2.itemList?.length != 0) {
          await Future.delayed(Duration(seconds: 1));
        }
        final response = await get(
          url,
          body: param,
        );

        if (response.statusCode == 201 || response.statusCode == 200) {
          final model = UserListModel.fromJson(jsonDecode(response.body));
          final items = model.Data ?? [];
          List<UserListModelData?> newItems;
          newItems = items;
          // items.where((element) => element?.Status != 'active').toList();

          // userModel = model;
          // notifyListeners();

          final previouslyFetchedWordCount =
              _pagingController2.itemList?.length ?? 0;
          pageSize2 = 10;
          log("ITEMS LENGTH : ${newItems.length}");
          final isLastPage = newItems.length < pageSize2;

          if (isLastPage) {
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

          // notifyListeners();
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

  TextEditingController emailC = TextEditingController();
  TextEditingController nameC = TextEditingController();
  TextEditingController nipC = TextEditingController();
  //TextEditingController roleC = TextEditingController();
  TextEditingController usernameC = TextEditingController();
  TextEditingController passwordC = TextEditingController();
  //TextEditingController statusC = TextEditingController();

  Future<void> clearForm() async {
    emailC.clear();
    usernameC.clear();
    nameC.clear();
    nipC.clear();
    //roleC.clear();
    usernameC.clear();
    selectedDivision = null;
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

  Future<void> fetchUserDetail({required String id}) async {
    loading(true);
    final response = await get(Constant.BASE_API_FULL + '/admin/users/$id');

    if (response.statusCode == 201 || response.statusCode == 200) {
      final model = UserDetailModel.fromJson(jsonDecode(response.body));
      userDetailModel = model;
      notifyListeners();
      loading(false);
    } else {
      final message = jsonDecode(response.body)["Message"];
      loading(false);
      return message;
    }
  }

  List<Widget> userForm(List<DivisionModelData?>? Data) {
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
        labelText: "Nama",
      ),
      // Constant.xSizedBox16,
      // CustomTextField.borderTextField(
      //   controller: nipC,
      //   required: false,
      //   textInputType: TextInputType.number,
      //   inputFormatters: [
      //     FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
      //     FilteringTextInputFormatter.digitsOnly,
      //   ],
      //   labelText: "NIP",
      // ),
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
        },
      ),
      Constant.xSizedBox16,
      CustomTextField.borderTextField(
        controller: usernameC,
        labelText: "Username",
      ),
      Constant.xSizedBox16,
      CustomTextField.borderTextField(
        controller: emailC,
        labelText: "Email",
      ),
      Constant.xSizedBox16,
      Visibility(
        visible: updateV,
        child: CustomDropdown.normalDropdown(
          //controller: roleC,
          iconPadding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
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
          },
        ),
      ),
      Constant.xSizedBox16,
      Visibility(
        visible: updateV,
        child: CustomDropdown.normalDropdown(
          //controller: roleC,
          iconPadding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
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
          },
        ),
      ),
      Constant.xSizedBox16,
      // CustomTextField.borderTextField(
      //   controller: passwordC,
      //   labelText: "Password",
      //   obscureText: obscurePass,
      //   suffixIcon: InkWell(
      //     onTap: () => toggleObscurePass(),
      //     child: Icon(
      //       obscurePass ? Icons.visibility_off_outlined : Icons.visibility,
      //       color: Constant.primaryColor,
      //     ),
      //   ),
      // ),
      // Constant.xSizedBox16,
    ];
  }

  Future<void> addUser(BuildContext context) async {
    loading(true);

    if (selectedDivision == null) throw 'Pilih Divisi Terlebih Dahulu';
    FocusManager.instance.primaryFocus?.unfocus();
    Map<String, String> param = {
      'Name': nameC.text,
      'Username': usernameC.text,
      'Email': emailC.text,
      'DivisionId': selectedDivision ?? '',
    };
    final response =
        await post(Constant.BASE_API_FULL + '/admin/users', body: param);

    if (response.statusCode == 201 || response.statusCode == 200) {
      final model = BaseResponse.from(response);

      loading(false);
      await Utils.showSuccess(msg: model.message ?? "Sukses");
      await Future.delayed(Duration(seconds: 2));
      Navigator.pop(context);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: ((context) => UserManageView())));
      nameC.clear();
      emailC.clear();
      usernameC.clear();
      selectedDivision = null;
    } else {
      final message = jsonDecode(response.body)["message"];
      loading(false);
      throw Exception(message);
    }
  }

  Future<void> updateUser(BuildContext context,
      {required String id, bool fromHome = false}) async {
    loading(true);
    FocusManager.instance.primaryFocus?.unfocus();
    Map<String, String> param = {
      // 'Name': nameC.text,
      // 'Username': usernameC.text,
      // 'Email': emailC.text,
    };
    if (selectedRole != null) param.addAll({'Role': selectedRole ?? ''});
    if (selectedDivision != null)
      param.addAll({'DivisionId': selectedDivision ?? ''});
    if (selectedStatus != null) param.addAll({'Status': selectedStatus ?? ''});

    final response =
        await put(Constant.BASE_API_FULL + '/admin/users/$id', body: param);

    if (response.statusCode == 201 || response.statusCode == 200) {
      final model = BaseResponse.from(response);

      loading(false);
      await Utils.showSuccess(msg: model.message ?? "Sukses");
      await Future.delayed(Duration(seconds: 2));
      if (!fromHome) {
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: ((context) => UserManageView())));
      }
      nameC.clear();
      emailC.clear();
      usernameC.clear();
      selectedDivision = null;
    } else {
      final message = jsonDecode(response.body)["message"];
      loading(false);
      throw Exception(message);
    }
  }

  Future<void> deleteUser(BuildContext context, {required String id}) async {
    loading(true);
    final response = await delete(Constant.BASE_API_FULL + '/admin/users/$id');

    if (response.statusCode == 201 || response.statusCode == 200) {
      final model = BaseResponse.from(response);
      loading(false);
      await Utils.showSuccess(msg: model.message ?? "Sukses");
      await Future.delayed(Duration(seconds: 2));
      Navigator.pop(context);
      // Navigator.pop(context);
      // Navigator.pop(context);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: ((context) => UserManageView())));
    } else {
      final message = jsonDecode(response.body)["message"];
      loading(false);
      return message;
    }
  }
}
