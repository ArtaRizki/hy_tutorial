import 'package:hy_tutorial/common/component/custom_alert.dart';
import 'package:hy_tutorial/common/component/custom_navigator.dart';
import 'package:hy_tutorial/generated/assets.dart';
import 'package:hy_tutorial/src/admin/view/user_manage_new_view.dart';
import 'package:hy_tutorial/src/admin/view/user_manage_view.dart';
import 'package:hy_tutorial/src/data/view/daftar_plta_new_view.dart';
import 'package:hy_tutorial/src/data/view/data_add_view.dart';
import 'package:hy_tutorial/src/home/model/home_model.dart';
import 'package:hy_tutorial/src/home/view/home_admin_new_view.dart';
import 'package:hy_tutorial/src/home/view/home_admin_view.dart';
import 'package:hy_tutorial/src/home/view/home_view.dart';
import 'package:hy_tutorial/src/profile/view/profile_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../../../common/helper/constant.dart';
import '../../turbine/provider/turbine_provider.dart';
import '../../turbine/view/turbine_view.dart';

class MainHome extends StatefulWidget {
  final int? index;

  const MainHome({super.key, this.index});

  @override
  State<MainHome> createState() => _MainHomeState();
}

class _MainHomeState extends State<MainHome> {
  int currentIndex = 0;
  late HomeModel homeModel;
  bool? isAdmin;
  DateTime? lastPressed;

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    getData();
    super.didChangeDependencies();
  }

  getData() async {
    setIndex();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {});
  }

  setIndex() {
    setState(() {
      if (widget.index != null) currentIndex = widget.index ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget customBottomNav() {
      return BottomAppBar(
        color: Colors.transparent,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        shadowColor: Colors.black,
        padding: EdgeInsets.only(top: 2),
        height: kBottomNavigationBarHeight + 15,
        shape: CircularNotchedRectangle(),
        child: BottomNavigationBar(
          // backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
          elevation: 10,
          backgroundColor: Colors.white,
          selectedFontSize: 13,
          unselectedFontSize: 13,
          unselectedItemColor: Constant.textHintColor2,
          currentIndex: currentIndex,
          onTap: (index) async {
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
                setState(() => currentIndex = 0);
                await CusNav.nPush(context, DataAddView(isFromCenter: true));
                setState(() => currentIndex = 0);
              },
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Constant.primaryColor,
                child: Image.asset(
                  'assets/icons/ic-button.png',
                  width: 40,
                  height: 40,
                ),
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
            setState(() => currentIndex = 0);
            return false;
          } else {
            if (isWarning) {
              lastPressed = DateTime.now();
              CustomAlert.showSnackBar(
                  context, 'Tekan 2 kali untuk keluar aplikasi', false);
              return false;
            } else {
              return true;
            }
          }
          // kalau sudah ada api maka muncul konfirm exit dua kali
          return true;
        },
        child: [
          // HomeAdminView(
          //   jumpToProfile: () => setState(() => currentIndex = 3),
          //   jumpToManageUsers: () async {
          //     currentIndex = 1;
          //     //await CusNav.nPush(context, UserManageView());
          //     setState(() {
          //       currentIndex = 1;
          //     });
          //     await getData();
          //   },
          // ),
          HomeAdminNewView(),
          UserManageNewView(),
          SizedBox(),
          DaftarPLTANewView(),
          ProfileView(),
        ][currentIndex],
      ),
    );
  }
}
