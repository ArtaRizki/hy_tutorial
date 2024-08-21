import 'dart:developer';
import 'dart:io';

import 'package:hy_tutorial/common/component/custom_alert.dart';
import 'package:hy_tutorial/common/component/custom_container.dart';
import 'package:hy_tutorial/common/component/custom_navigator.dart';
import 'package:hy_tutorial/generated/assets.dart';
import 'package:hy_tutorial/main.dart';
import 'package:hy_tutorial/src/admin/view/user_manage_view.dart';
import 'package:hy_tutorial/src/turbine/view/turbine_view.dart';
import 'package:hy_tutorial/src/data/view/daftar_plta_new_view.dart';
import 'package:hy_tutorial/src/data/view/data_add_view.dart';
import 'package:hy_tutorial/src/home/model/home_model.dart';
import 'package:hy_tutorial/src/home/view/home_admin_view.dart';
import 'package:hy_tutorial/src/profile/view/profile_view.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../../common/helper/constant.dart';
import '../../turbine/provider/turbine_provider.dart';

class MainHome extends StatefulWidget {
  final int? index;

  const MainHome({super.key, this.index});

  @override
  State<MainHome> createState() => _MainHomeState();
}

class _MainHomeState extends State<MainHome> {
  int currentIndex = 0;
  late HomeModel homeModel;
  DateTime? lastPressed;

  @override
  void initState() {
    getData();
    setPermission();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    getData();
    super.didChangeDependencies();
  }

  setPermission() async {
    requestPermission(Permission.notification);
    await requestPermission(Permission.storage);
    await requestPermission(Permission.manageExternalStorage);
    await requestPermission(Permission.photos);
  }

  getData() async {
    setIndex();
    setState(() {});
    final PermissionStatus status = await Permission.notification.request();
    if (status.isGranted) {
      // Notification permissions granted
      log("NOTIF GRANTED");
    } else if (status.isDenied) {
      // Notification permissions denied
      log("NOTIF DENIED");
    } else if (status.isPermanentlyDenied && Platform.isAndroid) {
      // Notification permissions permanently denied, open app settings
      log("NOTIF PERMANENTLY DENIED");
      await openAppSettings();
    }
  }

  setIndex() {
    setState(() {
      if (widget.index != null) currentIndex = widget.index ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    showSheet() {
      CustomContainer.showModalBottom3(
        context: context,
        child: Column(
          children: [
            InkWell(
              onTap: () async {
                CusNav.nPop(context);
                setState(() => currentIndex = 0);
                await CusNav.nPush(context, DataAddView(isFromCenter: true));
                setState(() => currentIndex = 0);
              },
              child: CustomContainer.mainCard(
                child: Row(
                  children: [
                    Image.asset(Assets.iconsIcAddData, scale: 4),
                    Constant.xSizedBox12,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tambah Laporan',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Tulis laporan baru',
                            style: TextStyle(
                              color: Color(0xff525252),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_right,
                      color: Color(0xff737373),
                    ),
                  ],
                ),
              ),
            ),
            Constant.xSizedBox16,
            InkWell(
              onTap: () async {
                CusNav.nPop(context);
                setState(() => currentIndex = 0);
                await CusNav.nPush(context, TurbineView());
                setState(() => currentIndex = 0);
              },
              child: CustomContainer.mainCard(
                child: Row(
                  children: [
                    Image.asset(Assets.iconsIcFile, scale: 4),
                    Constant.xSizedBox12,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Daftar Laporan',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Kelola semua laporan Anda',
                            style: TextStyle(
                              color: Color(0xff525252),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_right,
                      color: Color(0xff737373),
                    ),
                  ],
                ),
              ),
            ),
            Constant.xSizedBox16,
          ],
        ),
      );
    }

    Widget customBottomNav() {
      return BottomAppBar(
        color: Colors.transparent,
        shape: CircularNotchedRectangle(),
        surfaceTintColor: Colors.transparent,
        notchMargin: 5,
        // padding: EdgeInsets.only(top: 5),
        elevation: 100,
        // color: Colors.white,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        padding: EdgeInsets.only(top: 2),
        shadowColor: Colors.black,
        height: kBottomNavigationBarHeight + 15,
        child: BottomNavigationBar(
          // backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
          elevation: 100,
          backgroundColor: Colors.white,
          selectedFontSize: 13,
          unselectedFontSize: 13,
          unselectedItemColor: Constant.textHintColor2,
          currentIndex: currentIndex,
          onTap: (index) async {
            if (index == 2) {
              await showSheet();
              setState(() => currentIndex = 0);
            } else {
              final turbineP = context.read<TurbineProvider>();
              turbineP.setStartDate(null);
              turbineP.startDateC.clear();
              turbineP.setEndDate(null);
              turbineP.endDateC.clear();
              turbineP.ascending = false;
              turbineP.descending = false;
              turbineP.towerName = false;
              turbineP.createdAt = false;
              turbineP.turbineSearchC.clear();
              setState(() => currentIndex = index);
            }
          },
          type: BottomNavigationBarType.fixed,
          selectedIconTheme: IconThemeData(color: Constant.primaryColor),
          selectedItemColor: Constant.primaryColor,
          selectedLabelStyle: Constant.primaryBold15.copyWith(fontSize: 12),
          unselectedLabelStyle:
              TextStyle(fontSize: 12, color: Constant.textHintColor2),
          items: [
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.only(bottom: 4),
                width: 24,
                height: 24,
                child: FittedBox(
                  child: Image.asset(
                    currentIndex == 0
                        ? Assets.iconsIcHomeBlue
                        : Assets.iconsIcHome,
                  ),
                ),
              ),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.only(bottom: 4),
                width: 24,
                height: 24,
                child: FittedBox(
                  child: Image.asset(
                    currentIndex == 1
                        ? Assets.iconsIcUserBlue
                        : Assets.iconsIcUserGray,
                  ),
                ),
              ),
              label: 'User',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.only(bottom: 4),
                width: 24,
                height: 24,
                child: FittedBox(),
              ),
              label: 'Laporan',
            ),
            BottomNavigationBarItem(
              icon: Container(
                  padding: EdgeInsets.only(bottom: 4),
                  width: 24,
                  height: 24,
                  child: FittedBox(
                      child: Image.asset(
                    currentIndex == 3
                        ? Assets.iconsIcPltaBlue
                        : Assets.iconsIcPlta,
                  ))),
              label: 'PLTA',
            ),
            BottomNavigationBarItem(
              icon: Container(
                  padding: EdgeInsets.only(bottom: 4),
                  width: 24,
                  height: 24,
                  child: FittedBox(
                      child: Image.asset(
                    currentIndex == 4
                        ? Assets.iconsIcProfilBlue
                        : Assets.iconsIcProfile,
                  ))),
              label: 'Profile',
            ),
          ],
        ),
      );
    }

    return Scaffold(
      primary: true,
      extendBody: true,
      bottomNavigationBar: customBottomNav(),
      floatingActionButton: MediaQuery.of(context).viewInsets.bottom != 0
          ? SizedBox()
          : FloatingActionButton(
              backgroundColor: Colors.transparent,
              onPressed: () async {
                showSheet();
                // setState(() => currentIndex = 0);
                // await CusNav.nPush(context, DataAddView(isFromCenter: true));
                // setState(() => currentIndex = 0);
              },
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Constant.primaryColor,
                child: Image.asset(Assets.iconsIcButton, width: 35, height: 35),
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: WillPopScope(
        onWillPop: () async {
          final now = DateTime.now();
          const maxDuration = Duration(seconds: 2);
          final isWarning =
              lastPressed == null || now.difference(lastPressed!) > maxDuration;
          if (currentIndex != 0) {
            if (FocusManager.instance.primaryFocus != null &&
                FocusManager.instance.primaryFocus!.hasFocus) {
              FocusManager.instance.primaryFocus?.unfocus();
            } else {
              setState(() => currentIndex = 0);
            }
            return false;
          } else {
            if (isWarning) {
              lastPressed = DateTime.now();
              CustomAlert.showSnackBar(
                  context, 'Tekan 2 kali untuk keluar aplikasi', false);
              return false;
            }
          }
          // kalau sudah ada api maka muncul konfirm exit dua kali
          return true;
        },
        child: [
          HomeAdminView(
            jumpToProfile: () {
              setState(() {
                currentIndex = 4;
              });
            },
          ),
          UserManageView(),
          SizedBox(),
          DaftarPLTANewView(),
          ProfileView(),
        ][currentIndex],
      ),
    );
  }
}
