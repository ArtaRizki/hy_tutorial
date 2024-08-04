import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hy_tutorial/common/base/base_response.dart';
import '../../../utils/utils.dart';
import '../../../common/base/base_controller.dart';
import '../../../common/helper/constant.dart';
import '../../../common/component/custom_textfield.dart';
import '../model/profile_model.dart';
import '../../division/model/divison_model.dart';

class ProfileProvider extends BaseController with ChangeNotifier {
  GlobalKey<FormState> userAddKey = GlobalKey<FormState>();

  TextEditingController nameC = TextEditingController();
  TextEditingController usernameC = TextEditingController();
  TextEditingController emailC = TextEditingController();

  Future<void> clearForm() async {
    nameC.clear();
    usernameC.clear();
    emailC.clear();
  }

  ProfileModel _profileModel = ProfileModel();
  ProfileModel get profileModel => this._profileModel;
  set profileModel(ProfileModel value) => this._profileModel = value;

  Future<void> fetchProfile({bool withLoading = false}) async {
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

  Future<void> updateProfile(BuildContext context) async {
    loading(true);
    FocusManager.instance.primaryFocus?.unfocus();
    if (usernameC.text.isEmpty) throw 'Harap Isi Username';
    if (nameC.text.isEmpty) throw 'Harap Isi Nama';
    if (emailC.text.isEmpty) throw 'Harap Isi Email';
    Map<String, String> param = {
      'Name': nameC.text,
      'Username': usernameC.text,
      'Email': emailC.text,
    };

    final response = await put(Constant.BASE_API_FULL + '/my', body: param);

    if (response.statusCode == 201 || response.statusCode == 200) {
      final model = BaseResponse.from(response);

      loading(false);
      await Utils.showSuccess(msg: model.message ?? "Sukses");
      await Future.delayed(Duration(seconds: 2));
      Navigator.pop(context);
      clearForm();
    } else {
      final message = jsonDecode(response.body)["Message"];
      loading(false);
      throw Exception(message);
    }
  }
}
