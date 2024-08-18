import 'dart:math';

import 'package:flutter/cupertino.dart';
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
              // readOnly: widget.id != null,
              // enabled: !(widget.id != null),
              readOnly: false,
              enabled: true,
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
            CustomDropdown.normalDropdown(
              //controller: roleC,
              padding: EdgeInsets.only(top: 16),
              iconPadding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
              contentPadding: EdgeInsets.all(2),
              borderColor: Constant.primaryColor,
              labelText: "Status",
              selectedItem: p.selectedStatus,
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
                p.selectedStatus = val;
                p.validateUserForm();
                setState(() {});
              },
            ),
            Constant.xSizedBox16,
            CustomTextField.borderTextField(
              controller: p.radiusStatusC,
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
                    value: p.radiusStatus,
                    onChanged: (value) async {
                      p.radiusStatus = value;
                      p.radiusStatusC.text = value ? 'Aktif' : 'Tidak Aktif';
                      FocusManager.instance.primaryFocus?.unfocus();
                      setState(() {});
                    },
                  ),
                ),
              ),
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
              // readOnly: widget.id != null,
              // enabled: !(widget.id != null),
              readOnly: false,
              enabled: true,
              onChange: (v) {
                setState(() {});
              },
            ),
            Constant.xSizedBox16,
            CustomTextField.borderTextField(
              controller: p.phoneNumberC,
              labelText: "No. Telepon",
              hintText: "No. Telepon",
              // readOnly: widget.id != null,
              // enabled: !(widget.id != null),
              readOnly: false,
              enabled: true,
              onChange: (v) {
                setState(() {});
              },
            ),
            Constant.xSizedBox16,
            CustomTextField.borderTextField(
              controller: p.usernameC,
              labelText: "Username",
              hintText: "Username",
              // readOnly: widget.id != null,
              // enabled: !(widget.id != null),
              onChange: (v) {
                setState(() {});
              },
            ),
            if (widget.id == null) Constant.xSizedBox16,
            Visibility(
              visible: widget.id == null,
              child: CustomTextField.borderTextField(
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
            ),
            if (widget.id != null) Constant.xSizedBox16,
            Visibility(
              visible: widget.id != null,
              child: CustomTextField.borderTextField(
                controller: p.passwordC,
                labelText: "Password",
                readOnly: true,

                hintText: "Password",
                // enabled: !(widget.id != null),
                onChange: (v) {
                  setState(() {});
                },
                suffixIcon: GestureDetector(
                  onTap: () async {
                    context.read<UserManageProvider>().passwordC.text =
                        Random().nextInt(999999999).toString();
                    context.read<UserManageProvider>().refresh();
                    setState(() {});
                  },
                  child: Container(
                    padding: EdgeInsets.fromLTRB(24, 13, 24, 12),
                    decoration: BoxDecoration(
                      color: Constant.primaryColor,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Buat',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
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
                InkWell(
                  onTap: () async {
                    Utils.showYesNoDialogWithWarning(
                        context: context,
                        title: "Konfirmasi Penghapusan",
                        desc:
                            "Apakah anda yakin ingin\nmenghapus user yang dipilih?",
                        yesCallback: () async {
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
                        noCallback: () async {
                          Navigator.pop(context);
                        });
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 20),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Constant.redColor),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          Icons.delete_forever_rounded,
                          size: 15,
                          color: Constant.redColor,
                        ),
                        Text(
                          "Hapus",
                          style: Constant.iPrimaryMedium12
                              .copyWith(color: Constant.redColor),
                        ),
                      ],
                    ),
                  ),
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
                borderRadius: BorderRadius.circular(10),
                      contentPadding: EdgeInsets.symmetric(vertical: 0),
                      'Selanjutnya',
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
