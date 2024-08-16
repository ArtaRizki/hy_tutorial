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
import '../provider/user_manage_provider.dart';
import '../../../common/component/custom_appbar.dart';
import '../../../common/component/custom_button.dart';

class UserAddView extends StatefulWidget {
  UserAddView({super.key, this.id});
  String? id;

  @override
  State<UserAddView> createState() => _UserAddViewState();
}

class _UserAddViewState extends BaseState<UserAddView> {
  @override
  void initState() {
    context.read<UserManageProvider>().setData(context, widget.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<UserManageProvider>();
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
            Constant.xSizedBox8,
            CustomTextField.borderTextField(
              controller: p.nameC,
              textInputType: TextInputType.name,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
              ],
              readOnly: widget.id != null,
              enabled: !(widget.id != null),
              labelText: "Nama",
              hintText: "Nama",
              onChange: (v) {
                setState(() {});
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
              selectedItem: p.selectedDivision,
              hintText: "Divisi",
              list: List.generate(
                division.divisionModel.Data?.length ?? 0,
                (index) => DropdownMenuItem(
                    child:
                        Text(division.divisionModel.Data?[index]?.Name ?? ""),
                    value: division.divisionModel.Data?[index]?.Id ?? ""),
              ),
              onChanged: (val) {
                p.selectedDivision = val;
                setState(() {});
              },
            ),
            Constant.xSizedBox16,
            CustomDropdown.normalDropdown(
              //controller: roleC,
              padding: EdgeInsets.only(top: 16),
              iconPadding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
              contentPadding: EdgeInsets.all(2),
              borderColor: Constant.primaryColor,
              labelText: "Role",
              selectedItem: p.selectedRole,
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
                p.selectedRole = val;
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
              readOnly: widget.id != null,
              enabled: !(widget.id != null),
              onChange: (v) {
                setState(() {});
              },
            ),
            Constant.xSizedBox16,
            CustomTextField.borderTextField(
              controller: p.phoneNumberC,
              labelText: "No. Telepon",
              hintText: "No. Telepon",
              readOnly: widget.id != null,
              enabled: !(widget.id != null),
              onChange: (v) {
                setState(() {});
              },
            ),
            Constant.xSizedBox16,
            CustomTextField.borderTextField(
              controller: p.usernameC,
              labelText: "Username",
              hintText: "Username",
              readOnly: widget.id != null,
              enabled: !(widget.id != null),
              onChange: (v) {
                setState(() {});
              },
            ),
            Constant.xSizedBox16,
            CustomTextField.borderTextField(
              controller: p.passwordC,
              labelText: "Password",
              hintText: "Password",
              readOnly: widget.id != null,
              enabled: !(widget.id != null),
              onChange: (v) {
                setState(() {});
              },
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
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: widget.id != null
          ? CustomAppBar.appBar(
              context,
              "Edit User",
              elevation: 1,
              shadowColor: Colors.black54,
              action: [
                IconButton(
                  onPressed: () {
                    Utils.showYesNoDialogWithWarning(
                        context: context,
                        title: "Konfirmasi Penghapusan",
                        desc:
                            "Apakah anda yakin ingin\nmenghapus user yang dipilih?",
                        yesCallback: () async {
                          Navigator.pop(context);
                          await context
                              .read<UserManageProvider>()
                              .deleteUser(context, id: widget.id ?? "0");
                        },
                        noCallback: () async {
                          Navigator.pop(context);
                        });
                  },
                  icon: Icon(Icons.delete),
                ),
              ],
            )
          : CustomAppBar.appBar(
              context,
              "Tambah User",
              elevation: 1,
              shadowColor: Colors.black54,
            ),
      body: Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: Column(children: [
            Expanded(
              child: ListView(
                children: [
                  informasiDasar(),
                  akunKredensial(),
                  // ...p.userForm(division.divisionModel.Data, () {
                  //   setState(() {});
                  // }, widget.id != null),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: widget.id != null
                  ? CustomButton.mainButton(
                      'Submit',
                      enabled: p.validateUserForm(),
                      () async {
                        if (p.validateUserForm()) {
                          final dataP = context.read<UserManageProvider>();
                          FocusManager.instance.primaryFocus?.unfocus();
                          await Utils.showYesNoDialog(
                              context: context,
                              title: "Konfirmasi",
                              desc: "Apakah Data Anda Sudah Benar?",
                              yesCallback: () => handleTap(() async {
                                    Navigator.pop(context);
                                    dataP.updateUser(context,
                                        id: p.userDetailModel.Data?.Id ?? "");
                                  }),
                              noCallback: () => Navigator.pop(context));
                        }
                      },
                    )
                  : CustomButton.mainButton(
                      'Submit',
                      enabled: p.validateUserForm(),
                      () async {
                        if (p.validateUserForm()) {
                          final dataP = context.read<UserManageProvider>();
                          FocusManager.instance.primaryFocus?.unfocus();
                          await Utils.showYesNoDialog(
                              context: context,
                              title: "Konfirmasi",
                              desc: "Apakah Data Anda Sudah Benar?",
                              yesCallback: () => handleTap(() async {
                                    Navigator.pop(context);
                                    dataP.addUser(context);
                                  }),
                              noCallback: () => Navigator.pop(context));
                        }
                      },
                    ),
            ),
          ])),
    );
  }
}
