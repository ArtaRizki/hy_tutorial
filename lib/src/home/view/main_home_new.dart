import 'package:hy_tutorial/common/component/custom_alert.dart';
import 'package:hy_tutorial/common/component/custom_navigator.dart';
import 'package:hy_tutorial/generated/assets.dart';
import 'package:hy_tutorial/src/admin/view/user_manage_new_view.dart';
import 'package:hy_tutorial/src/data/view/data_add_view.dart';
import 'package:hy_tutorial/src/home/model/home_model.dart';
import 'package:hy_tutorial/src/home/view/home_admin_new_view.dart';
import 'package:hy_tutorial/src/home/view/home_admin_view.dart';
import 'package:hy_tutorial/src/profile/view/profile_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../../../common/helper/constant.dart';
import '../../turbine/provider/turbine_provider.dart';
import '../../turbine/view/turbine_view.dart';

class MainHomeNew extends StatefulWidget {
  final int? index;

  const MainHomeNew({super.key, this.index});

  @override
  State<MainHomeNew> createState() => _MainHomeNewState();
}

class _MainHomeNewState extends State<MainHomeNew> {
  int currentIndex = 0;
  late HomeModel homeModel;
  DateTime? lastPressed;

  @override
  void initState() {
    super.initState();
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
        surfaceTintColor: Colors.white,
        shape: CircularNotchedRectangle(),
        notchMargin: 5,
        padding: EdgeInsets.only(top: 5),
        elevation: 0,
        color: Colors.white,
        child: BottomNavigationBar(
          elevation: 0,
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
          selectedLabelStyle: Constant.primaryBold15.copyWith(fontSize: 13),
          unselectedLabelStyle:
              TextStyle(fontSize: 13, color: Constant.textHintColor2),
          items: [
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.only(bottom: 4),
                width: 25,
                height: 25,
                child: FittedBox(
                  child: currentIndex == 0
                      ? Image.asset(Assets.iconsIcHomeBlue)
                      : Image.asset(Assets.iconsIcHome),
                ),
              ),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.only(bottom: 4),
                width: 25,
                height: 25,
                child: FittedBox(
                  child: currentIndex == 1
                      ? Image.asset(Assets.iconsIcUserBlue)
                      : Image.asset(Assets.iconsIcUserGray),
                ),
              ),
              label: 'User',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.only(bottom: 4),
                width: 25,
                height: 25,
                child: FittedBox(
                  child: currentIndex == 2
                      ? Image.asset(Assets.iconsIcPltaBlue)
                      : Image.asset(Assets.iconsIcPlta),
                ),
              ),
              label: 'PLTA',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.only(bottom: 4),
                width: 25,
                height: 25,
                child: FittedBox(
                  child: currentIndex == 3
                      ? Image.asset(Assets.iconsIcProfilBlue)
                      : Image.asset(Assets.iconsIcProfil),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      primary: true,
      bottomNavigationBar: customBottomNav(),
      floatingActionButton: MediaQuery.of(context).viewInsets.bottom != 0
          ? SizedBox()
          : FloatingActionButton(
              backgroundColor: const Color.fromARGB(0, 140, 122, 122),
              onPressed: () async {},
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Constant.primaryColor,
                child: Image.asset(
                  Assets.iconsIcButton,
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
          return true;
        },
        child: [][currentIndex],
      ),
    );
  }
}
