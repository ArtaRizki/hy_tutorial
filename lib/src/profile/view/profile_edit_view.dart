import 'package:flutter/material.dart';
import 'package:hy_tutorial/utils/utils.dart';
import 'package:provider/provider.dart';
import '../../../common/base/base_state.dart';
import '../../../common/helper/constant.dart';
import '../../division/provider/division_provider.dart';
import '../model/profile_model.dart';
import '../provider/profile_provider.dart';
import '../../../common/component/custom_appbar.dart';
import '../../../common/component/custom_button.dart';

class ProfileEditView extends StatefulWidget {
  ProfileEditView({super.key});

  @override
  State<ProfileEditView> createState() => _ProfileEditViewState();
}

class _ProfileEditViewState extends BaseState<ProfileEditView> {
  @override
  void initState() {
    setData();
    super.initState();
  }

  setData() async {
    await context.read<ProfileProvider>().fetchProfile();
    final data = context.read<ProfileProvider>().profileModel.Data;
    if (data != null) {
      final p = context.read<ProfileProvider>();
      p.usernameC.text = data.Username ?? '';
      p.nameC.text = data.Name ?? '';
      p.emailC.text = data.Email ?? '';
      setState(() {});
    } else {
      final p = context.read<ProfileProvider>();
      p.usernameC.text = '';
      p.nameC.text = '';
      p.emailC.text = '';
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ProfileProvider>();
    final data = context.watch<ProfileProvider>().profileModel.Data;
    final division = context.watch<DivisionProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar.appBar(context, "Edit Profile"),
      body: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
          child: Column(children: [
            Expanded(
                child: ListView(
                    children: [...p.profileForm(division.divisionModel.Data)])),
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                child: CustomButton.mainButton(
                  'Submit',
                  () async {
                    final dataP = context.read<ProfileProvider>();
                    FocusManager.instance.primaryFocus?.unfocus();
                    String? msg;
                    if (dataP.usernameC.text.isEmpty)
                      msg = 'Harap Isi Username';
                    if (dataP.nameC.text.isEmpty)
                      msg = 'Harap Isi Nama Lengkap';
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
                                // Navigator.pop(context);
                                // Navigator.pop(context);
                                dataP.updateProfile(context);
                              }),
                          noCallback: () => Navigator.pop(context));
                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: ((context) => ProfileManageView())));
                    }
                  },
                )),
          ])),
    );
  }
}
