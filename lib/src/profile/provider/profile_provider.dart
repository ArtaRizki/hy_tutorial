import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hy_tutorial/common/base/base_response.dart';
import 'package:hy_tutorial/src/division/provider/division_provider.dart';
import 'package:hy_tutorial/src/home/view/main_home.dart';
import 'package:provider/provider.dart';
import '../../../utils/utils.dart';
import '../../../common/base/base_controller.dart';
import '../../../common/helper/constant.dart';
import '../../../common/component/custom_textfield.dart';
import '../model/profile_model.dart';
import '../../division/model/divison_model.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:hy_tutorial/common/component/custom_navigator.dart';

class ProfileProvider extends BaseController with ChangeNotifier {
  GlobalKey<FormState> userAddKey = GlobalKey<FormState>();

  TextEditingController nameC = TextEditingController();
  TextEditingController usernameC = TextEditingController();
  TextEditingController emailC = TextEditingController();
  TextEditingController phoneNumberC = TextEditingController();
  TextEditingController divisionC = TextEditingController();
  TextEditingController passwordC = TextEditingController();
  TextEditingController passwordConfirmationC = TextEditingController();

  String? _selectedDivision;
  String? get selectedDivision => this._selectedDivision;

  set selectedDivision(String? value) {
    this._selectedDivision = value;
    // notifyListeners();
  }

  setData(BuildContext context) async {
    final p = context.read<DivisionProvider>();
    await p.fetchDivision(withLoading: true);
    await fetchProfile();
    final data = profileModel.Data;
    if (data != null) {
      nameC.text = data.Name ?? '';
      usernameC.text = data.Username ?? '';
      emailC.text = data.Email ?? '';
      phoneNumberC.text = (data.Phone ?? '').replaceFirst('+', '');
      final division = p.divisionModel.Data;
      divisionC.text = data.Division ?? '';
      selectedDivision =
          division?.firstWhere((element) => element?.Name == data.Division)?.Id;
      log("SELECTED DIVISION : $selectedDivision");
    } else {
      usernameC.text = '';
      nameC.text = '';
      emailC.text = '';
      divisionC.text = '';
      phoneNumberC.text = '';
      selectedDivision = null;
    }
    notifyListeners();
  }

  Future<void> clearForm() async {
    nameC.text = '';
    usernameC.text = '';
    phoneNumberC.text = '';
    emailC.text = '';
    divisionC.text = '';
    passwordC.text = '';
    passwordConfirmationC.text = '';
    selectedDivision = null;
  }

  getData(BuildContext context) async {
    profileModel = ProfileModel();
    await context.read<ProfileProvider>().fetchProfile(withLoading: false);
  }

  ProfileModel _profileModel = ProfileModel();
  ProfileModel get profileModel => this._profileModel;
  set profileModel(ProfileModel value) => this._profileModel = value;

  Future<void> fetchProfile({bool withLoading = false}) async {
    profileModel = ProfileModel();
    if (withLoading) loading(true);
    final response = await get(Constant.BASE_API_FULL + '/my');

    if (response.statusCode == 201 || response.statusCode == 200) {
      final model = ProfileModel.fromJson(jsonDecode(response.body));
      profileModel = model;
      notifyListeners();
      if (withLoading) loading(false);
    } else {
      final message = jsonDecode(response.body)["Message"];
      loading(false);
      return message;
    }
  }

  List<Widget> profileForm(List<DivisionModelData?>? Data) {
    return [
      Text("Edit Data Profile", style: Constant.blackBold20),
      Constant.xSizedBox8,
      Text("Masukkan data profile pada field dibawah",
          style: Constant.grayMedium),
      Constant.xSizedBox16,
      CustomTextField.borderTextField(
        controller: usernameC,
        labelText: "Username",
      ),
      Constant.xSizedBox16,
      CustomTextField.borderTextField(
        controller: nameC,
        textInputType: TextInputType.name,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
        ],
        labelText: "Nama",
      ),
      Constant.xSizedBox16,
      CustomTextField.borderTextField(
        controller: emailC,
        labelText: "Email",
      ),
      Constant.xSizedBox16,
    ];
  }

  bool validateEdit() {
    if (usernameC.text.isEmpty) return false;
    if (nameC.text.isEmpty) return false;
    if (phoneNumberC.text.isEmpty) return false;
    if (emailC.text.isEmpty) return false;
    return true;
  }

  Future<void> updateProfile(BuildContext context) async {
    loading(true);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    FocusManager.instance.primaryFocus?.unfocus();
    if (usernameC.text.isEmpty) throw 'Harap Isi Username';
    if (nameC.text.isEmpty) throw 'Harap Isi Nama';
    if (emailC.text.isEmpty) throw 'Harap Isi Email';
    Map<String, String> param = {
      'Name': nameC.text,
      'Username': usernameC.text,
      'Email': emailC.text,
      'Phone': phoneNumberC.text.replaceFirst('08', '628'),
    };

    final response = await put(Constant.BASE_API_FULL + '/my', body: param);

    if (response.statusCode == 201 || response.statusCode == 200) {
      final model = BaseResponse.from(response);

      loading(false);
      await Utils.showSuccess(msg: model.message ?? "Sukses");
      await Future.delayed(Duration(seconds: 2));
      // Navigator.pop(context);
      final isAdmin = prefs.getBool(Constant.kSetPrefIsAdmin) ?? false;
      if (isAdmin) {
        CusNav.nPushAndRemoveUntil(context, MainHome(index: 4),
            arguments: isAdmin);
      } else {
        CusNav.nPop(context);
      }
      clearForm();
    } else {
      final model = BaseResponse.from(response);

      final message = model.message;
      loading(false);
      await Utils.showFailed(msg: model.message ?? "Gagal");
      await Future.delayed(Duration(seconds: 2));
      throw Exception(message);
    }
  }

  bool _obscurePass = true;

  bool get obscurePass => this._obscurePass;

  toggleObscurePass() {
    this._obscurePass = !obscurePass;
    notifyListeners();
  }

  bool _obscurePass2 = true;

  bool get obscurePass2 => this._obscurePass2;

  toggleObscurePass2() {
    this._obscurePass2 = !obscurePass2;
    notifyListeners();
  }

  bool validateChangingPass() {
    if (passwordC.text.isEmpty) return false;
    if (passwordConfirmationC.text.isEmpty) return false;
    if (passwordC.text != passwordConfirmationC.text) return false;
    return true;
  }

  Future<void> changePass(BuildContext context) async {
    loading(true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    FocusManager.instance.primaryFocus?.unfocus();
    Map<String, String> param = {
      'Password': passwordC.text,
      'PasswordConfirmation': passwordConfirmationC.text,
    };

    final response =
        await post(Constant.BASE_API_FULL + '/my/change-password', body: param);

    if (response.statusCode == 201 || response.statusCode == 200) {
      final model = BaseResponse.from(response);

      loading(false);
      await Utils.showSuccess(msg: model.message ?? "Sukses");
      await Future.delayed(Duration(seconds: 2));
      // Navigator.pop(context);
      final isAdmin = prefs.getBool(Constant.kSetPrefIsAdmin) ?? false;
      if (isAdmin) {
        CusNav.nPushAndRemoveUntil(context, MainHome(index: 4),
            arguments: isAdmin);
      } else {
        CusNav.nPop(context);
      }
      clearForm();
    } else {
      final model = BaseResponse.from(response);

      final message = model.message;
      loading(false);
      await Utils.showFailed(msg: model.message ?? "Gagal");
      await Future.delayed(Duration(seconds: 2));
      throw Exception(message);
    }
  }
}
