import 'dart:convert';
import 'dart:developer';
import 'package:hy_tutorial/src/auth/model/firebase_token_model.dart';
import 'package:hy_tutorial/src/auth/view/login_view.dart';
import 'package:hy_tutorial/src/auth/view/register_view.dart';
import 'package:hy_tutorial/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../common/base/base_controller.dart';
import '../../../common/base/base_response.dart';
import '../../../common/helper/constant.dart';
import '../model/config_model.dart';
import '../model/login_model.dart';
import 'package:flutter/material.dart';
import '../model/refresh_token_model.dart';

class AuthProvider extends BaseController with ChangeNotifier {
  late LoginViewState loginViewState;
  late RegisterViewState registerViewState;
  TextEditingController nameC = TextEditingController();
  TextEditingController usernameC = TextEditingController();
  TextEditingController emailC = TextEditingController();
  TextEditingController passC = TextEditingController();
  TextEditingController passConfirmationC = TextEditingController();
  TextEditingController namaLengkap = TextEditingController();
  TextEditingController selectedDivisionC = TextEditingController();

  String? _selectedDivisionV;

  String? get selectedDivisionV => this._selectedDivisionV;

  GlobalKey<FormState> loginKey = GlobalKey<FormState>();

  String? _selectedDivision;
  String? get selectedDivision => this._selectedDivision;

  set selectedDivision(value) {
    this._selectedDivision = value;
    notifyListeners();
  }

  //forgot
  TextEditingController emailForgotC = TextEditingController();
  TextEditingController tokenC = TextEditingController();
  TextEditingController passForgotC = TextEditingController();
  TextEditingController confirmPassForgotC = TextEditingController();
  GlobalKey<FormState> forgotKey = GlobalKey<FormState>();
  GlobalKey<FormState> tokenKey = GlobalKey<FormState>();
  GlobalKey<FormState> confirmKey = GlobalKey<FormState>();

  DateTime? tanggal;

  get date => tanggal;

  bool _obscurePass = true;

  bool get obscurePass => this._obscurePass;

  toggleObscurePass() {
    this._obscurePass = !obscurePass;
    notifyListeners();
  }

  bool _obscurePass1 = true;

  bool get obscurePass1 => this._obscurePass1;

  toggleObscurePass1() {
    this._obscurePass1 = !obscurePass1;
    notifyListeners();
  }

  FirebaseTokenModel _firebaseTokenModel = FirebaseTokenModel();
  get firebaseTokenModel => this._firebaseTokenModel;

  set firebaseTokenModel(value) {
    this._firebaseTokenModel = value;
    notifyListeners();
  }

  Future<void> clearLoginForm() async {
    emailC.clear();
    passC.clear();
    //notifyListeners();
  }

  Future<void> clearRegisterForm() async {
    nameC.text = '';
    usernameC.text = '';
    emailC.text = '';
    passC.text = '';
    passConfirmationC.text = '';
    selectedDivision = null;
    //notifyListeners();
  }

  bool validateLogin() {
    if (usernameC.text.isEmpty) return false;
    if (passC.text.isEmpty) return false;
    // if (!usernameC.text.isEmail()) return false;
    return true;
  }

  Future<void> login(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      log("USERNAME : ${usernameC.text}");
      log("PASS : ${passC.text}");
      // validate
      if (usernameC.text.isEmpty) throw 'Harap isi username';
      if (passC.text.isEmpty) throw 'Harap isi password';

      loading(true);
      FocusManager.instance.primaryFocus?.unfocus();
      Map<String, String> param = {
        'Username': usernameC.text,
        'Password': passC.text,
      };
      final response =
          await post(Constant.BASE_API_FULL + '/auth/login', body: param);

      if (response.statusCode == 201 || response.statusCode == 200) {
        loading(false);
        final model = LoginModel.fromJson(jsonDecode(response.body));

        // set to shared preferences
        await prefs.setString(Constant.kSetPrefToken, model.Data?.Token ?? '');
        await prefs.setString(
            Constant.kSetPrefDivision, model.Data?.Division ?? '');
        await prefs.setString(
            Constant.kSetPrefRefreshToken, model.Data?.RefreshToken ?? '');
        await prefs.setString(Constant.kSetPrefName, model.Data?.Name ?? '');
        await prefs.setBool(
            Constant.kSetPrefIsAdmin,
            model.Data?.Source == 'admin' || model.Data?.Source == 'main'
                ? true
                : false);

        Navigator.pushReplacementNamed(context, '/home',
            arguments: await prefs.getBool(Constant.kSetPrefIsAdmin));
        usernameC.text = '';
        passC.text = '';
      } else {
        loading(false);
        final message = jsonDecode(response.body)["Message"];
        await Utils.showFailed(msg: message ?? "Error");
      }
    } catch (e) {
      prefs.clear();
      await Utils.showFailed(
          msg: e.toString().toLowerCase().contains("doctype")
              ? "Maaf, Terjadi Galat!"
              : "$e");
      throw Exception(e);
    }
  }

  Future<void> getConfig({bool withLoading = false}) async {
    if (withLoading) loading(true);
    final response =
        await get(Constant.BASE_API_FULL + '/configs/root-location');

    if (response.statusCode == 201 || response.statusCode == 200) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final model = ConfigModel.fromJson(jsonDecode(response.body));

      // set to shared preferences
      await prefs.setDouble(Constant.kSetPrefConfigLat, model.Data?.Lat ?? 0);
      await prefs.setDouble(Constant.kSetPrefConfigLon, model.Data?.Long ?? 0);
      await prefs.setDouble(Constant.kSetPrefConfigRadius,
          (model.Data?.CoverageArea ?? 0).toDouble());
      await prefs.setString(Constant.kSetPrefConfigRadiusType,
          model.Data?.CoverageAreaType ?? '');
      await prefs.setBool(
          Constant.kSetPrefConfigStatus, model.Data?.Status ?? false);

      if (withLoading) loading(false);
      // return model;
    } else {
      final message = jsonDecode(response.body)["Message"];
      loading(false);
      // return LoginModel();
      throw Exception(message);
    }
  }

  bool validateRegister() {
    if (nameC.text.isEmpty) return false;
    if (selectedDivision == null) return false;
    if (usernameC.text.isEmpty) return false;
    if (emailC.text.isEmpty) return false;
    if (passC.text.isEmpty) return false;
    if (passConfirmationC.text.isEmpty) return false;
    if (passC.text != passConfirmationC.text) return false;
    return true;
  }

  Future<void> register(BuildContext context) async {
    try {
      // validate
      if (nameC.text.isEmpty) throw 'Harap isi username';
      if (selectedDivision == null) throw 'Pilih divisi terlebih dahulu';
      if (usernameC.text.isEmpty) throw 'Harap isi username';
      if (emailC.text.isEmpty) throw 'Harap isi email';
      if (passC.text.isEmpty) throw 'Harap isi password';
      if (passConfirmationC.text.isEmpty) throw 'Harap isi konfirmasi password';
      if (passC.text != passConfirmationC.text)
        throw 'Password & konfirmasi password tidak sama';

      loading(true);
      FocusManager.instance.primaryFocus?.unfocus();
      Map<String, String> param = {
        'Name': nameC.text,
        'Username': usernameC.text,
        'Email': emailC.text,
        'DivisionId': selectedDivision ?? '',
        'Password': passC.text,
        'PasswordConfirmation': passConfirmationC.text,
      };
      final response =
          await post(Constant.BASE_API_FULL + '/auth/register', body: param);

      if (response.statusCode == 201 || response.statusCode == 200) {
        loading(false);
        final model = BaseResponse.from(response);

        await Utils.showSuccess(msg: model.message);
        await Future.delayed(Duration(seconds: 2));
        Navigator.pushReplacementNamed(context, '/login', arguments: false);
        nameC.text = '';
        selectedDivision = null;
        selectedDivisionC.text = '';
        usernameC.text = '';
        passC.text = '';
        passConfirmationC.text = '';
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

  RefreshTokenModel _refreshTokenModel = RefreshTokenModel();
  RefreshTokenModel get refreshTokenModel => this._refreshTokenModel;
  set refreshTokenModel(RefreshTokenModel value) =>
      this._refreshTokenModel = value;

  Future<void> refreshToken() async {
    loading(true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? refreshToken = prefs.getString(Constant.kSetPrefRefreshToken);
    Map<String, String> param = {'RefreshToken': refreshToken ?? ''};
    final response =
        await post(Constant.BASE_API_FULL + '/auth/refresh-token', body: param);

    if (response.statusCode == 201 || response.statusCode == 200) {
      refreshTokenModel = RefreshTokenModel.fromJson(jsonDecode(response.body));
      await prefs.setString(
          Constant.kSetPrefToken, refreshTokenModel.Data?.Token ?? '');
      await prefs.setString(Constant.kSetPrefRefreshToken,
          refreshTokenModel.Data?.RefreshToken ?? '');
      loading(false);
    } else {
      final message = jsonDecode(response.body)["Message"];
      loading(false);
      throw Exception(message);
    }
  }

  Future<void> updateFirebaseToken() async {
    loading(true);
    final response =
        await post(Constant.BASE_API_FULL + '/firebase/update-token');

    if (response.statusCode == 201 || response.statusCode == 200) {
      firebaseTokenModel =
          FirebaseTokenModel.fromJson(jsonDecode(response.body));
      loading(false);
    } else {
      final message = jsonDecode(response.body)["Message"];
      loading(false);
      throw Exception(message);
    }
  }

  Future<void> logout() async {
    loading(true);
    // final response =
    //     BaseResponse.from(await post(Constant.BASE_API_FULL + '/logout'));

    // if (response.success) {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // set to shared preferences
    await prefs.remove(Constant.kSetPrefToken);
    await prefs.remove(Constant.kSetPrefId);
    await prefs.remove(Constant.kSetPrefName);
    await prefs.remove(Constant.kSetPrefIsAdmin);
    await prefs.clear();

    loading(false);
    // return response;
    // } else {
    //   final message = response.message;
    //   loading(false);
    //   throw Exception(message);
    // }
  }

  Future<BaseResponse> postForgot() async {
    // parameters
    final param = {'email': emailForgotC.text};
    loading(true);
    // response
    final response = BaseResponse.from(
        await post(Constant.BASE_API_FULL + '/forgot', body: param));
    loading(false);

    if (response.success) {
      return response;
    } else {
      final message = response.message;
      throw Exception(message);
    }
  }

  Future<String> postToken() async {
    // parameters
    final param = {
      'email': emailForgotC.text,
      'token': tokenC.text,
    };

    loading(true);
    // response
    final response = BaseResponse.from(
        await post(Constant.BASE_API_FULL + '/forgot/verify', body: param));
    loading(false);

    final message = response.message;
    if (response.success) {
      return message;
    } else {
      throw Exception(message);
    }
  }

  Future<String> postPassword() async {
    // parameters
    final param = {
      'email': emailForgotC.text,
      'token': tokenC.text,
      'password': passForgotC.text,
      'c_password': confirmPassForgotC.text
    };

    loading(true);
    // response
    final response = BaseResponse.from(await post(
        Constant.BASE_API_FULL + '/forgot/change-password',
        body: param));

    loading(false);

    final message = response.message;
    if (response.success) {
      usernameC.clear();
      emailForgotC.clear();
      passC.clear();
      passForgotC.clear();
      confirmPassForgotC.clear();
      return message;
    } else {
      throw Exception(message);
    }
  }

  setDate(DateTime? date) {
    tanggal = date;
    notifyListeners();
  }
}
