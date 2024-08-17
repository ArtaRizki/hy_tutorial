import 'package:flutter/material.dart';
import 'package:hy_tutorial/common/base/base_state.dart';
import 'package:hy_tutorial/common/component/custom_appbar.dart';
import 'package:hy_tutorial/common/component/skeleton.dart';
import 'package:hy_tutorial/common/helper/constant.dart';
import 'package:hy_tutorial/src/home/view/home_admin_view.dart';
import 'package:hy_tutorial/src/home/view/home_view.dart';
import 'package:hy_tutorial/src/profile/model/profile_model.dart';
import 'package:hy_tutorial/src/profile/view/profile_edit_view.dart';
import 'package:provider/provider.dart';

import '../../../common/component/custom_navigator.dart';
import '../../../utils/utils.dart';
import '../../auth/provider/auth_provider.dart';
import '../provider/profile_provider.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends BaseState<ProfileView> {
  @override
  void initState() {
    context.read<ProfileProvider>().getData(context);
    super.initState;
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profileModel.Data;
    return Scaffold(
      appBar: CustomAppBar.appBar(
        context,
        "Profile",
        leading: SizedBox(),
        titleSpacing: 20,
        isLeading: false,
        color: Constant.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<ProfileProvider>().getData(context),
        child: ListView(
          shrinkWrap: true,
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(10, 20, 20, 20),
              height: 100,
              color: Constant.primaryColor,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: 10),
                  InkWell(
                    onTap: () => throw Exception(),
                    child: Image.asset(
                      'assets/icons/ic-user.png',
                      scale: 4,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    flex: 6,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Skeleton<ProfileModelData?>(
                          value: profile,
                          width: 65,
                          height: 14,
                          child: Text(
                            profile?.Name ?? '',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Constant.xSizedBox4,
                        Skeleton<ProfileModelData?>(
                          value: profile,
                          width: 75,
                          height: 14,
                          child: Text(
                            profile?.Division ?? '',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Akun",
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      SizedBox(width: 5),
                      Image.asset('assets/icons/ic-edit.png', scale: 3),
                      SizedBox(width: 13),
                      Expanded(
                        flex: 6,
                        child: InkWell(
                          onTap: () async {
                            CusNav.nPush(context, ProfileEditView());
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Ubah informasi akun",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                "Ganti nama, username, dan email",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w300),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                ],
              ),
            ),
            SizedBox(height: 10),
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  Row(
                    children: [
                      SizedBox(width: 5),
                      InkWell(
                        onTap: () {
                          CusNav.nPush(context, HomeAdminView());
                        },
                        child: Image.asset(
                          'assets/icons/ic-info.png',
                          scale: 3.5,
                        ),
                      ),
                      SizedBox(width: 13),
                      Expanded(
                        flex: 6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () {
                                CusNav.nPush(context, HomeView());
                              },
                              child: Text(
                                "Tentang Aplikasi",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              "Versi 1.0",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w300),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                ],
              ),
            ),
            SizedBox(height: 10),
            InkWell(
              onTap: () async {
                await Utils.showYesNoDialog(
                  context: context,
                  title: "Konfirmasi",
                  desc: "Apakah Anda Yakin Ingin Keluar?",
                  yesCallback: () => handleTap(() async {
                    Navigator.pop(context);
                    try {
                      await context.read<AuthProvider>().logout();
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/login', (route) => false);
                    } catch (e) {
                      Utils.showFailed(
                          msg: e.toString().toLowerCase().contains("doctype")
                              ? "Maaf, Terjadi Galat!"
                              : "$e");
                    }
                  }),
                  noCallback: () => Navigator.pop(context),
                );
              },
              child: Container(
                width: double.infinity,
                color: Colors.white,
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    Row(
                      children: [
                        SizedBox(
                          width: 5,
                        ),
                        Image.asset(
                          'assets/icons/ic-logout.png',
                          scale: 3.5,
                        ),
                        SizedBox(width: 13),
                        Expanded(
                          flex: 6,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Keluar",
                                style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                "Keluar akun dengan aman",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w300),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
