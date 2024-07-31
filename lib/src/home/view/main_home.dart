import 'package:hy_tutorial/common/component/custom_navigator.dart';
import 'package:hy_tutorial/src/admin/view/user_manage_view.dart';
import 'package:hy_tutorial/src/data/view/data_add_view.dart';
import 'package:hy_tutorial/src/home/model/home_model.dart';
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

  @override
  void initState() {
    getData();
    // setIndex();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    isAdmin = ModalRoute.of(context)?.settings.arguments as bool?;
    // getData();
    super.didChangeDependencies();
  }

  getData() async {
    setIndex();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isAdmin = prefs.getBool(Constant.kSetPrefIsAdmin);
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
        shape: CircularNotchedRectangle(),
        notchMargin: 5,
        padding: EdgeInsets.only(top: 5),
        child: BottomNavigationBar(
          // backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
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
            // context.read<PaketProvider>().clearFilter();
            if (index == 1) {
              currentIndex = index;
              if (isAdmin == true)
                await CusNav.nPush(context, UserManageView());
              else
                await CusNav.nPush(context, DataAddView());
              setState(() {
                currentIndex = 0;
              });
            } else {
              setState(() => currentIndex = index);
            }
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
                  child: Image.asset(
                    'assets/icons/ic-home.png',
                    color: currentIndex == 0
                        ? Constant.primaryColor
                        : Color(0xff8A8C8D),
                  ),
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
                  child: Image.asset(
                    'assets/icons/ic-form.png',
                    color: currentIndex == 1
                        ? Constant.primaryColor
                        : Color(0xff8A8C8D),
                  ),
                ),
              ),
              label: isAdmin == true ? 'Manage Users' : 'Form',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.only(bottom: 4),
                width: 25,
                height: 25,
                child: FittedBox(
                  child: Image.asset(
                    'assets/icons/ic-riwayat.png',
                    color: currentIndex == 2
                        ? Constant.primaryColor
                        : Color(0xff8A8C8D),
                  ),
                ),
              ),
              label: 'Riwayat',
            ),
            BottomNavigationBarItem(
              icon: Container(
                  padding: EdgeInsets.only(bottom: 4),
                  width: 25,
                  height: 25,
                  child: FittedBox(
                      child: Image.asset(
                    'assets/icons/ic-profile.png',
                    color: currentIndex == 3
                        ? Constant.primaryColor
                        : Color(0xff8A8C8D),
                  ))),
              label: 'Profile',
            ),
          ],
        ),
      );
    }

    return Scaffold(
      //extendBody: true,
      primary: true,
      bottomNavigationBar: customBottomNav(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          CusNav.nPush(context, DataAddView());
        },
        child: CircleAvatar(
          radius: 60,
          backgroundColor: Constant.primaryColor,
          child:
              Image.asset('assets/icons/ic-button.png', width: 40, height: 40),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: WillPopScope(
        onWillPop: () async {
          if (currentIndex != 0) {
            setState(() => currentIndex = 0);
            return false;
          }
          // kalau sudah ada api maka muncul konfirm exit dua kali
          return true;
        },
        child: [
          isAdmin == true ? HomeAdminView() : HomeView(),
          isAdmin == true ? UserManageView() : DataAddView(),
          TurbineView(),
          ProfileView(),
          // ProfileView(jumpToJamaah, jumpToSubAgen)
        ][currentIndex],
      ),
    );
  }
}
