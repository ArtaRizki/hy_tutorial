import 'package:flutter/material.dart';
import 'package:hy_tutorial/common/base/base_state.dart';
import 'package:hy_tutorial/common/component/skeleton.dart';
import 'package:hy_tutorial/common/helper/constant.dart';
import 'package:hy_tutorial/generated/assets.dart';
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
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: () => context.read<ProfileProvider>().getData(context),
        child: ListView(
          shrinkWrap: true,
          children: [
            Container(
              color: Constant.primaryColor,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Text(
                'Profil Saya',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Stack(
              children: [
                Container(color: Constant.primaryColor, height: 64),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        padding: EdgeInsets.fromLTRB(10, 20, 10, 15),
                        // height: 100,
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Color(0xffFAFAFA),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(width: 2),
                              InkWell(
                                onTap: () => throw Exception(),
                                child: Image.asset('assets/icons/ic-user.png',
                                    scale: 4),
                              ),
                              SizedBox(width: 12),
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
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 18),
                          child: Text(
                            'Pengaturan',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Constant.xSizedBox16,
                      InkWell(
                        onTap: () async {
                          await CusNav.nPush(context, ProfileEditView());
                          context.read<ProfileProvider>().getData(context);
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 18),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Color(0XFFE5E5E5),
                              width: 1,
                            ),
                          ),
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Constant.xSizedBox4,
                              Row(
                                children: [
                                  SizedBox(width: 5),
                                  Image.asset(Assets.iconsIcInfoAkun, scale: 4),
                                  SizedBox(width: 8),
                                  Expanded(
                                    flex: 6,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Informasi akun",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          "Ubah Nama Akun, Foto, dan lainnya",
                                          style: TextStyle(
                                              color: Color(0xff525252),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w300),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.grey,
                                    size: 15,
                                  ),
                                  Constant.xSizedBox4,
                                ],
                              ),
                              SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                      Constant.xSizedBox12,
                      InkWell(
                        onTap: () async {
                          await CusNav.nPush(
                              context, ProfileEditView(isChangePass: true));
                          context.read<ProfileProvider>().getData(context);
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 18),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Color(0XFFE5E5E5),
                              width: 1,
                            ),
                          ),
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Constant.xSizedBox4,
                              Row(
                                children: [
                                  SizedBox(width: 5),
                                  Image.asset(Assets.iconsIcKeamananAkun,
                                      scale: 4),
                                  SizedBox(width: 8),
                                  Expanded(
                                    flex: 6,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Keamanan akun",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          "Ubah kata sandi",
                                          style: TextStyle(
                                              color: Color(0xff525252),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w300),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.grey,
                                    size: 15,
                                  ),
                                  Constant.xSizedBox4,
                                ],
                              ),
                              SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                      Constant.xSizedBox12,
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 18),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Color(0XFFE5E5E5),
                            width: 1,
                          ),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Constant.xSizedBox4,
                            Row(
                              children: [
                                SizedBox(width: 5),
                                Image.asset(Assets.iconsIcAbout, scale: 4),
                                SizedBox(width: 8),
                                Expanded(
                                  flex: 6,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          // CusNav.nPush(context, HomeView());
                                        },
                                        child: Text(
                                          "Tentang Aplikasi",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        "Versi 1.0",
                                        style: TextStyle(
                                            color: Color(0xff525252),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w300),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.grey,
                                  size: 15,
                                ),
                                Constant.xSizedBox4,
                              ],
                            ),
                            SizedBox(height: 8),
                          ],
                        ),
                      ),
                      Constant.xSizedBox12,
                      InkWell(
                        onTap: () async {
                          await Utils.showYesNoDialog(
                            context: context,
                            title: "Konfirmasi",
                            desc: "Apakah Anda Yakin Ingin Keluar?",
                            yesCallback: () => handleTap(() async {
                              CusNav.nPop(context);
                              try {
                                await context.read<AuthProvider>().logout();
                                Navigator.pushNamedAndRemoveUntil(
                                    context, '/boarding', (route) => false);
                              } catch (e) {
                                Utils.showFailed(
                                    msg: e
                                            .toString()
                                            .toLowerCase()
                                            .contains("doctype")
                                        ? "Maaf, Terjadi Galat!"
                                        : "$e");
                              }
                            }),
                            noCallback: () => CusNav.nPop(context),
                          );
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 18),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Color(0XFFE5E5E5),
                              width: 1,
                            ),
                          ),
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Constant.xSizedBox4,
                              Row(
                                children: [
                                  SizedBox(width: 5),
                                  Image.asset(Assets.iconsIcLogout2, scale: 4),
                                  SizedBox(width: 10),
                                  Expanded(
                                    flex: 6,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Keluar",
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          "Keluar akun dengan aman",
                                          style: TextStyle(
                                              color: Color(0xff525252),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w300),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.grey,
                                    size: 15,
                                  ),
                                  Constant.xSizedBox4,
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
