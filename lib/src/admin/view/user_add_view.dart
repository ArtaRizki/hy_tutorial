import 'package:flutter/material.dart';
import 'package:hy_tutorial/src/admin/model/user_detail_model.dart';
import 'package:hy_tutorial/utils/utils.dart';
import 'package:provider/provider.dart';
import '../../../common/helper/constant.dart';
import '../provider/user_manage_provider.dart';
import '../../../common/component/custom_appbar.dart';
import '../../../common/component/custom_button.dart';
import 'user_detail_view.dart';

class UserAddView extends StatefulWidget {
  UserAddView({super.key, this.data});
  UserDetailModel? data;

  @override
  State<UserAddView> createState() => _UserAddViewState();
}

class _UserAddViewState extends State<UserAddView> {
  @override
  void initState() {
    setData();
    super.initState();
  }

  setData() {
    if (widget.data != null) {
      final data = widget.data;
      final p = context.read<UserManageProvider>();
      p.nameC.text = data?.Data?.Name ?? '';
      p.nipC.text = '';
      p.selectedRole = data?.Data?.Role ?? '';
      p.usernameC.text = data?.Data?.Username ?? '';
      p.passwordC.text = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<UserManageProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar.appBar(context, "Tambah User"),
      body: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
          child: Column(children: [
            Expanded(child: ListView(children: [...p.userForm()])),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
              child: CustomButton.mainButton(
                'Submit',
                () {
                  final dataP = context.read<UserManageProvider>();
                  FocusManager.instance.primaryFocus?.unfocus();
                  String? msg;
                  //if (dataP.nameC.text.isEmpty) msg = 'Harap Isi Nama Lengkap';
                  //if (dataP.nipC.text.isEmpty) msg = 'Harap Isi NIP';
                  //if (dataP.roleC.text.isEmpty) msg = 'Harap Pilih Role';
                  //if (dataP.usernameC.text.isEmpty) msg = 'Harap Isi Username';
                  //if (dataP.passwordC.text.isEmpty) msg = 'Harap Isi Password';
                  if (msg != null) {
                    Utils.showFailed(msg: msg);
                    return;
                  } else {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: ((context) => UserDetailView(
                                id: "01J1WQEDH0SZYZWAC1Z9QDTXCK"))));
                  }
                },
              ),
            ),
          ])),
    );
  }
}
