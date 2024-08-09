import 'package:flutter/material.dart';
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: widget.id != null
          ? CustomAppBar.appBar(
              context,
              "Edit User",
              color: Constant.primaryColor,
              foregroundColor: Colors.white,
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
          : CustomAppBar.appBar(context, "Tambah User",
              color: Constant.primaryColor, foregroundColor: Colors.white),
      body: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
          child: Column(children: [
            Expanded(
              child: ListView(
                children: [
                  ...p.userForm(division.divisionModel.Data, () {
                    setState(() {});
                  }, widget.id != null),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
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
