import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hy_tutorial/common/base/base_controller.dart';
import 'package:hy_tutorial/common/component/custom_navigator.dart';
import 'package:hy_tutorial/common/helper/constant.dart';
import 'package:hy_tutorial/src/auth/model/login_model.dart';
import 'package:hy_tutorial/src/home/view/home_view.dart';
import 'package:hy_tutorial/src/home/view/main_home.dart';
import 'package:hy_tutorial/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepo extends BaseController {
  TextEditingController usernameC = TextEditingController();
  TextEditingController passC = TextEditingController();

  Future<void> login(String username, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      log("USERNAME : ${username}");
      log("PASS : ${password}");
      // validate
      // bool validate = validateLogin();
      // if (!validate) throw 'Harap Lengkapi Form';
      if (username == '') throw 'Harap isi username';
      if (password == '') throw 'Harap isi password';

      loading(true);

      FocusManager.instance.primaryFocus?.unfocus();
      Map<String, String> param = {
        'Username': username,
        'Password': password,
      };
      final response =
          await post(Constant.BASE_API_FULL + '/auth/login', body: param);

      if (response.statusCode == 201 || response.statusCode == 200) {
        loading(false);

        final model = LoginModel.fromJson(jsonDecode(response.body));
        final roles = model.Data?.Source;
        // set to shared preferences
        await prefs.setString(Constant.kSetPrefToken, model.Data?.Token ?? '');
        await prefs.setString(
            Constant.kSetPrefDivision, model.Data?.Division ?? '');
        await prefs.setString(
            Constant.kSetPrefRefreshToken, model.Data?.RefreshToken ?? '');
        await prefs.setString(Constant.kSetPrefName, model.Data?.Name ?? '');
        await prefs.setBool(Constant.kSetPrefIsAdmin,
            roles == 'admin' || roles == 'main' ? true : false);
        await prefs.setBool(
            Constant.kSetPrefIsSuperAdmin, roles == 'main' ? true : false);
        if (roles == 'admin' || roles == 'main') {
          // CusNav.nPushAndRemoveUntil(context, MainHome(), arguments: true);
        } else {
          // CusNav.nPushAndRemoveUntil(context, HomeView());
        }
        usernameC.text = '';
        passC.text = '';
        // return model;
      } else {
        loading(false);

        final message = jsonDecode(response.body)["Message"];
        await Utils.showFailed(msg: message ?? "Error");
        Future.delayed(Duration(seconds: 2), () {});
        throw message;
      }
    } catch (e) {
      loading(false);

      prefs.clear();
      await Utils.showFailed(
          msg: e.toString().toLowerCase().contains("doctype")
              ? "Maaf, Terjadi Galat!"
              : "$e");
      throw Exception(e);
    }
  }

  bool validateLogin() {
    if (usernameC.text.isEmpty) return false;
    if (passC.text.isEmpty) return false;
    // if (!usernameC.text.isEmail()) return false;
    return true;
  }
}
