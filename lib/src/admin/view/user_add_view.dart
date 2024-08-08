import 'package:flutter/material.dart';
import 'package:hy_tutorial/common/helper/constant.dart';
import 'package:hy_tutorial/src/admin/model/user_detail_model.dart';
import 'package:hy_tutorial/utils/utils.dart';
import 'package:provider/provider.dart';
import '../../../common/base/base_state.dart';
import '../../division/provider/division_provider.dart';
import '../provider/user_manage_provider.dart';
import '../../../common/component/custom_appbar.dart';
import '../../../common/component/custom_button.dart';

class UserAddView extends StatefulWidget {
  UserAddView({super.key, this.data, this.fromDetail = false});
  bool fromDetail;
  UserDetailModel? data;

  @override
  State<UserAddView> createState() => _UserAddViewState();
}

class _UserAddViewState extends BaseState<UserAddView> {
  @override
  void initState() {
    setData();
    super.initState();
  }

  setData() async {
    await context.read<DivisionProvider>().fetchDivision(withLoading: true);
    if (widget.data != null) {
      final data = widget.data;
      final p = context.read<UserManageProvider>();
      p.nameC.text = data?.Data?.Name ?? '';
      p.nipC.text = '';
      final division = context.read<DivisionProvider>().divisionModel.Data;
      p.selectedDivision = division
          ?.firstWhere((element) => element?.Name == data?.Data?.Division)
          ?.Id;
      p.usernameC.text = data?.Data?.Username ?? '';
      p.emailC.text = data?.Data?.Email ?? '';
      p.passwordC.text = '';
      p.updateV = true;
      if (data?.Data?.Role == "admin")
        p.selectedRole = "2";
      else
        p.selectedRole = "3";
      if (data?.Data?.Status == "inactive")
        p.selectedStatus = "0";
      else if (data?.Data?.Status == "active")
        p.selectedStatus = "1";
      else
        p.selectedStatus = "2";
      setState(() {});
    } else {
      final p = context.read<UserManageProvider>();
      p.nameC.text = '';
      p.usernameC.text = '';
      p.emailC.text = '';
      p.selectedDivision = null;
      p.updateV = false;
      p.radiusStatus = false;
      p.radiusStatusC.text = '';
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<UserManageProvider>();
    final division = context.watch<DivisionProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: widget.data != null
          ? CustomAppBar.appBar(context, "Edit User",
              color: Constant.primaryColor, foregroundColor: Colors.white)
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
                  }, widget.data != null),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
              child: widget.data != null
                  ? CustomButton.mainButton(
                      'Submit',
                      enabled: p.validateUserForm(),
                      () async {
                        final dataP = context.read<UserManageProvider>();
                        FocusManager.instance.primaryFocus?.unfocus();
                        await Utils.showYesNoDialog(
                            context: context,
                            title: "Konfirmasi",
                            desc: "Apakah Data Anda Sudah Benar?",
                            yesCallback: () => handleTap(() async {
                                  Navigator.pop(context);
                                  dataP.updateUser(
                                    context,
                                    id: p.userDetailModel.Data?.Id ?? "",
                                    fromDetail: widget.fromDetail,
                                  );
                                }),
                            noCallback: () => Navigator.pop(context));
                      },
                    )
                  : CustomButton.mainButton(
                      'Submit',
                      () async {
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
                      },
                    ),
            ),
          ])),
    );
  }
}
