import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hy_tutorial/common/component/custom_container.dart';
import 'package:hy_tutorial/common/component/custom_dropdown.dart';
import 'package:hy_tutorial/common/component/custom_textfield.dart';
import 'package:hy_tutorial/common/helper/constant.dart';
import 'package:hy_tutorial/utils/utils.dart';
import 'package:provider/provider.dart';
import '../../../common/base/base_state.dart';
import '../../division/provider/division_provider.dart';
import '../provider/profile_provider.dart';
import '../../../common/component/custom_appbar.dart';
import '../../../common/component/custom_button.dart';

class ProfileEditView extends StatefulWidget {
  ProfileEditView({super.key, this.isChangePass = false});
  bool isChangePass;
  @override
  State<ProfileEditView> createState() => _ProfileEditViewState();
}

class _ProfileEditViewState extends BaseState<ProfileEditView> {
  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    final p = context.read<ProfileProvider>();
    p.clearForm();
    await p.setData(context);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ProfileProvider>();
    final data = context.watch<ProfileProvider>().profileModel.Data;
    final division = context.watch<DivisionProvider>();

    Widget informasiDasar() {
      return CustomContainer.mainCard(
        margin: EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Informasi Dasar",
              style:
                  Constant.iBlackMedium16.copyWith(fontWeight: FontWeight.w600),
            ),
            Constant.xSizedBox8,
            Divider(
              thickness: 0.5,
              color: Colors.grey.withOpacity(0.5),
            ),
            CustomTextField.borderTextField(
              controller: p.nameC,
              textInputType: TextInputType.name,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
              ],
              labelText: "Nama",
              onChanged: (v) {
                setState(() {});
              },
            ),
            Constant.xSizedBox16,
            CustomTextField.borderTextField(
              controller: p.divisionC,
              suffixIcon: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 12, 0),
                child: Icon(Icons.keyboard_arrow_down,
                    color: Constant.textHintColor2, size: 24),
              ),
              // contentPadding: EdgeInsets.all(2),
              borderColor: Constant.primaryColor,
              labelText: "Divisi",
              // selectedItem: p.selectedDivision,
              readOnly: true,
              enabled: false,
              hintText: "Divisi",
              // list: List.generate(
              //   division.divisionModel.Data?.length ?? 0,
              //   (index) => DropdownMenuItem(
              //       child:
              //           Text(division.divisionModel.Data?[index]?.Name ?? ""),
              //       value: division.divisionModel.Data?[index]?.Id ?? ""),
              // ),
              onChanged: (val) {
                p.selectedDivision = val;
                setState(() {});
              },
            ),
          ],
        ),
      );
    }

    Widget akunKredensial() {
      return CustomContainer.mainCard(
        margin: EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Akun Kredensial",
              style:
                  Constant.iBlackMedium16.copyWith(fontWeight: FontWeight.w600),
            ),
            Constant.xSizedBox8,
            Divider(
              thickness: 0.5,
              color: Colors.grey.withOpacity(0.5),
            ),
            Constant.xSizedBox8,
            CustomTextField.borderTextField(
              controller: p.emailC,
              labelText: "Email",
              hintText: "Email",
              onChanged: (v) {
                setState(() {});
              },
            ),
            Constant.xSizedBox16,
            CustomTextField.borderTextField(
              controller: p.phoneNumberC,
              labelText: "No. Telepon",
              hintText: "No. Telepon",
              onChanged: (v) {
                setState(() {});
              },
            ),
            Constant.xSizedBox16,
            CustomTextField.borderTextField(
              controller: p.usernameC,
              labelText: "Username",
              hintText: "Username",
              onChanged: (v) {
                setState(() {});
              },
            ),
            Constant.xSizedBox16,
            Constant.xSizedBox16,
          ],
        ),
      );
    }

    Widget ubahSandi() {
      return CustomContainer.mainCard(
        margin: EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Ubah Sandi",
              style:
                  Constant.iBlackMedium16.copyWith(fontWeight: FontWeight.w600),
            ),
            Constant.xSizedBox8,
            Divider(
              thickness: 0.5,
              color: Colors.grey.withOpacity(0.5),
            ),
            CustomTextField.borderTextField(
              controller: p.passwordC,
              textInputType: TextInputType.name,
              labelText: "Kata Sandi Baru",
              onChanged: (v) {
                setState(() {});
              },
              obscureText: p.obscurePass,
              suffixIcon: InkWell(
                onTap: () => p.toggleObscurePass(),
                child: Icon(
                  p.obscurePass
                      ? Icons.visibility_off_outlined
                      : Icons.visibility,
                  color: Constant.primaryColor,
                ),
              ),
            ),
            Constant.xSizedBox16,
            CustomTextField.borderTextField(
              controller: p.passwordConfirmationC,
              textInputType: TextInputType.name,
              labelText: "Konfirmasi Kata Sandi",
              onChanged: (v) {
                setState(() {});
              },
              obscureText: p.obscurePass2,
              suffixIcon: InkWell(
                onTap: () => p.toggleObscurePass2(),
                child: Icon(
                  p.obscurePass2
                      ? Icons.visibility_off_outlined
                      : Icons.visibility,
                  color: Constant.primaryColor,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar.appBar(
        context,
        "Informasi Akun",
        elevation: 1,
        shadowColor: Colors.black54,
      ),
      body: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
          child: Column(children: [
            Expanded(
              child: ListView(
                children: widget.isChangePass
                    ? [ubahSandi()]
                    : [informasiDasar(), akunKredensial()],
              ),
            ),
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: CustomButton.mainButton(
                  'Submit',
                  enabled: widget.isChangePass
                      ? p.validateChangingPass()
                      : p.validateEdit(),
                  () async {
                    if (p.validateEdit() && !widget.isChangePass) {
                      final dataP = context.read<ProfileProvider>();
                      FocusManager.instance.primaryFocus?.unfocus();
                      String? msg;
                      if (dataP.usernameC.text.isEmpty)
                        msg = 'Harap Isi Username';
                      if (dataP.nameC.text.isEmpty)
                        msg = 'Harap Isi Nama Lengkap';
                      if (dataP.phoneNumberC.text.isEmpty)
                        msg = 'Harap Isi No. Telepon';
                      if (dataP.emailC.text.isEmpty) msg = 'Harap Isi Email';
                      if (msg != null) {
                        Utils.showFailed(msg: msg);
                        return;
                      } else {
                        await Utils.showYesNoDialog(
                            context: context,
                            title: "Konfirmasi",
                            desc: "Apakah Data Anda Sudah Benar?",
                            yesCallback: () => handleTap(() async {
                                  Navigator.pop(context);

                                  dataP.updateProfile(context);
                                }),
                            noCallback: () => Navigator.pop(context));
                      }
                    } else {
                      final dataP = context.read<ProfileProvider>();
                      FocusManager.instance.primaryFocus?.unfocus();
                      String? msg;
                      if (dataP.passwordC.text.isEmpty)
                        msg = 'Harap Isi Kata Sandi Baru';
                      if (dataP.passwordConfirmationC.text.isEmpty)
                        msg = 'Harap Isi Konfirmasi Kata Sandi Baru';
                      if (dataP.passwordConfirmationC.text !=
                          dataP.passwordC.text)
                        msg =
                            'Kata Sandi Baru dan Konfirmasi Kata Sandi Baru tidak valid';
                      if (msg != null) {
                        Utils.showFailed(msg: msg);
                        return;
                      } else {
                        await Utils.showYesNoDialog(
                            context: context,
                            title: "Konfirmasi",
                            desc: "Apakah Data Anda Sudah Benar?",
                            yesCallback: () => handleTap(() async {
                                  Navigator.pop(context);
                                  dataP.changePass(context);
                                }),
                            noCallback: () => Navigator.pop(context));
                      }
                    }
                  },
                )),
          ])),
    );
  }
}
