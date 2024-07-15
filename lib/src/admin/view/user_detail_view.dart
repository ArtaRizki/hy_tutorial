import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hy_tutorial/common/component/custom_navigator.dart';
import 'package:hy_tutorial/src/admin/view/user_add_view.dart';
import '../../../common/component/custom_appbar.dart';
import '../../../common/component/custom_button.dart';
import '../../../common/component/custom_container.dart';
import '../../../common/helper/constant.dart';
import 'package:provider/provider.dart';
import '../../../utils/utils.dart';
import '../provider/user_manage_provider.dart';

class UserDetailView extends StatefulWidget {
  UserDetailView({super.key, required this.id});
  final String id;
  @override
  State<UserDetailView> createState() => _UserDetailViewState();
}

class _UserDetailViewState extends State<UserDetailView>
    with TickerProviderStateMixin {
  @override
  void initState() {
    context.read<UserManageProvider>().fetchUserDetail(id: widget.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userDataP = context.watch<UserManageProvider>().userDetailModel;
    final userP = context.watch<UserManageProvider>().userDetailModel.Data;

    Widget modalHapus() {
      return CustomButton.secondaryButton('Hapus', () async {});
    }

    Widget modalSimpan() {
      return CustomButton.secondaryButton(
        'Simpan',
        () async {
          Utils.showYesNoDialog(
            context: context,
            title: "Simpan Perubahan",
            desc: "Apakah anda yakin\ningin menyimpan perubahan?",
            yesCallback: () async {
              
              Navigator.pop(context);
            },
            noCallback: () async {
              Navigator.pop(context);
            },
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar.appBar(context, "Detail User", action: [
        IconButton(
          onPressed: () {
            CusNav.nPush(context, UserAddView(data: userDataP));
          },
          icon: Icon(
            Icons.edit,
            color: Constant.primaryColor,
          ),
        ),
        IconButton(
          onPressed: () {
            Utils.showYesNoDialogWithWarning(
                context: context,
                title: "Konfirmasi Penghapusan",
                desc: "Apakah anda yakin ingin\nmenghapus user yang dipilih?",
                yesCallback: () async {
                  context.read<UserManageProvider>().deleteUser(id: userP?.Id ?? "0");
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                noCallback: () async {
                  Navigator.pop(context);
                });
          },
          icon: Icon(
            Icons.delete,
            color: Constant.redColor,
          ),
        ),
      ]),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Text("Detail User", style: Constant.blackBold20),
                  Constant.xSizedBox8,
                  Text("Detail data terakhir dari user",
                      style: Constant.grayMedium),
                  Constant.xSizedBox16,
                  Container(
                    color: Color(0xffEFEFEF),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: Text(
                            'Nama',
                            style: TextStyle(color: Constant.textColorBlack),
                          ),
                        ),
                        Constant.xSizedBox8,
                        Expanded(
                          flex: 5,
                          child: Text(
                            '${userP?.Name ?? "Jhon Doe"}',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: Text(
                            'Divisi / Jabatan',
                            style: TextStyle(color: Constant.textColorBlack),
                          ),
                        ),
                        Constant.xSizedBox8,
                        Expanded(
                          flex: 5,
                          child: Text(
                            '${userP?.Division ?? "Engineer"}',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    color: Color(0xffEFEFEF),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: Text(
                            'Nama',
                            style: TextStyle(color: Constant.textColorBlack),
                          ),
                        ),
                        Constant.xSizedBox8,
                        Expanded(
                          flex: 5,
                          child: Text(
                            '${userP?.Role ?? "User"}',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: Text(
                            'Username',
                            style: TextStyle(color: Constant.textColorBlack),
                          ),
                        ),
                        Constant.xSizedBox8,
                        Expanded(
                          flex: 5,
                          child: Text(
                            '${userP?.Username ?? "Jhon Doe"}',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    color: Color(0xffEFEFEF),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: Text(
                            'Status',
                            style: TextStyle(color: Constant.textColorBlack),
                          ),
                        ),
                        Constant.xSizedBox8,
                        Expanded(
                          flex: 5,
                          child: Text(
                            '${userP?.Status ?? "Jhon 123"}',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Padding(
            //   padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
            //   child: CustomButton.mainButton(
            //     'Submit',
            //     () {
            //       final dataP = context.read<UserManageProvider>();
            //       FocusManager.instance.primaryFocus?.unfocus();
            //       String? msg;
            //       //if (dataP.nameC.text.isEmpty) msg = 'Harap Isi Nama Lengkap';
            //       //if (dataP.nipC.text.isEmpty) msg = 'Harap Isi NIP';
            //       //if (dataP.roleC.text.isEmpty) msg = 'Harap Pilih Role';
            //       //if (dataP.usernameC.text.isEmpty) msg = 'Harap Isi Username';
            //       //if (dataP.passwordC.text.isEmpty) msg = 'Harap Isi Password';
            //       if (msg != null) {
            //         Utils.showFailed(msg: msg);
            //         return;
            //       } else {
            //         // Navigator
            //       }
            //     },
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
