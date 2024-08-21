import 'dart:async';
import 'dart:developer';

import 'package:hy_tutorial/common/base/base_state.dart';
import 'package:hy_tutorial/common/component/custom_container.dart';
import 'package:hy_tutorial/common/component/custom_navigator.dart';
import 'package:hy_tutorial/common/component/custom_textField.dart';
import 'package:hy_tutorial/common/component/skeleton.dart';
import 'package:hy_tutorial/common/helper/constant.dart';
import 'package:hy_tutorial/generated/assets.dart';
import 'package:hy_tutorial/src/admin/model/user_list_model.dart';
import 'package:hy_tutorial/src/admin/provider/user_manage_provider.dart';
import 'package:hy_tutorial/src/admin/view/user_add_view.dart';
import 'package:flutter/material.dart';
import 'package:hy_tutorial/src/home/provider/home_provider.dart';
import 'package:hy_tutorial/utils/utils.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../common/component/custom_appbar.dart';

class UserManageView extends StatefulWidget {
  const UserManageView({super.key});

  @override
  State<UserManageView> createState() => _UserManageViewState();
}

class _UserManageViewState extends BaseState<UserManageView>
    with TickerProviderStateMixin {
  late TabController tabController;
  bool? isSuperAdmin;

  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isSuperAdmin = prefs.getBool(Constant.kSetPrefIsSuperAdmin) ?? false;
    log("IS SUPER ADMIN : $isSuperAdmin");
    setState(() {});
    tabController = TabController(
        length: isSuperAdmin == null ? 0 : ((isSuperAdmin ?? false) ? 3 : 2),
        vsync: this);
    tabController.addListener(() {
      log("INDEX ACTIVE : ${tabController.index}");
      setState(() {});
    });

    final userManageP = context.read<UserManageProvider>();
    if (isSuperAdmin == false) {
      if ((userManageP.pagingController.itemList ?? []).isEmpty) {
        userManageP.getUserList();
      } else {
        userManageP.pagingController.dispose();
        userManageP.next = null;
        userManageP.getUserList();
        setState(() {});
      }
      if ((userManageP.pagingController2.itemList ?? []).isEmpty) {
        userManageP.getUserList2();
      } else {
        userManageP.pagingController2.dispose();
        userManageP.next2 = null;
        userManageP.getUserList2();
        setState(() {});
      }
    } else {
      if ((userManageP.pagingController3.itemList ?? []).isEmpty) {
        userManageP.getUserList3();
      } else {
        userManageP.pagingController3.dispose();
        userManageP.next3 = null;
        userManageP.getUserList3();
        setState(() {});
      }
      if ((userManageP.pagingController4.itemList ?? []).isEmpty) {
        userManageP.getUserList4();
      } else {
        userManageP.pagingController4.dispose();
        userManageP.next4 = null;
        userManageP.getUserList4();
        setState(() {});
      }
      if ((userManageP.pagingControllerAdmin.itemList ?? []).isEmpty) {
        userManageP.getUserListAdmin();
      } else {
        userManageP.pagingControllerAdmin.dispose();
        userManageP.nextAdmin = null;
        userManageP.getUserListAdmin();
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userManageP = context.watch<UserManageProvider>();

    final pagingC = context.watch<UserManageProvider>().pagingController;
    final pagingC2 = context.watch<UserManageProvider>().pagingController2;
    final pagingC3 = context.watch<UserManageProvider>().pagingController3;
    final pagingC4 = context.watch<UserManageProvider>().pagingController4;
    final pagingCAdmin =
        context.watch<UserManageProvider>().pagingControllerAdmin;

    TextEditingController getC() {
      if (isSuperAdmin == null) return TextEditingController();
      final i = tabController.index;
      if (isSuperAdmin == true) {
        if (i == 0) return userManageP.userSearchC3;
        if (i == 1) return userManageP.userSearchC4;
        if (i == 2) return userManageP.userSearchCAdmin;
      } else {
        if (i == 0) return userManageP.userSearchC2;
        if (i == 1) return userManageP.userSearchC;
      }
      return TextEditingController();
    }

    FocusNode getN() {
      if (isSuperAdmin == null) return FocusNode();
      final i = tabController.index;
      if (isSuperAdmin == true) {
        if (i == 0) return userManageP.userN3;
        if (i == 1) return userManageP.userN4;
        if (i == 2) return userManageP.userNAdmin;
      } else {
        if (i == 0) return userManageP.userN2;
        if (i == 1) return userManageP.userN;
      }
      return FocusNode();
    }

    bool getSuffixCheck() {
      if (isSuperAdmin == null) return false;
      final i = tabController.index;
      if (isSuperAdmin == true) {
        if (i == 0) return userManageP.userSearchC3.text.isEmpty;
        if (i == 1) return userManageP.userSearchC4.text.isEmpty;
        if (i == 2) return userManageP.userSearchCAdmin.text.isEmpty;
      } else {
        if (i == 0) return userManageP.userSearchC2.text.isEmpty;
        if (i == 1) return userManageP.userSearchC.text.isEmpty;
      }
      return true;
    }

    void Function()? getOnTap() {
      if (isSuperAdmin == null) return () {};
      final i = tabController.index;
      if (isSuperAdmin == true) {
        if (i == 0) {
          userManageP.userSearchC3.clear();
          userManageP.userN3.unfocus();
          pagingC3.refresh();
        }
        if (i == 1) {
          userManageP.userSearchC4.clear();
          userManageP.userN4.unfocus();
          pagingC4.refresh();
        }
        if (i == 2) {
          userManageP.userSearchCAdmin.clear();
          userManageP.userNAdmin.unfocus();
          pagingCAdmin.refresh();
        }
      } else {
        if (i == 0) {
          userManageP.userSearchC2.clear();
          userManageP.userN2.unfocus();
          pagingC2.refresh();
        }

        if (i == 1) {
          userManageP.userSearchC.clear();
          userManageP.userN.unfocus();
          pagingC.refresh();
        }
      }

      return () {};
    }

    void Function()? getOnSubmitted() {
      if (isSuperAdmin == null) return () {};
      final i = tabController.index;
      if (isSuperAdmin == true) {
        if (i == 0) {
          if (userManageP.searchOnStoppedTyping3 != null) {
            userManageP.searchOnStoppedTyping3!.cancel();
          }
          userManageP.searchOnStoppedTyping3 =
              Timer(userManageP.duration3, () async {
            userManageP.next3 = null;
            pagingC3.refresh();
          });
        }
        if (i == 1) {
          if (userManageP.searchOnStoppedTyping4 != null) {
            userManageP.searchOnStoppedTyping4!.cancel();
          }
          userManageP.searchOnStoppedTyping4 =
              Timer(userManageP.duration4, () async {
            userManageP.next4 = null;
            pagingC4.refresh();
          });
        }
        if (i == 2) {
          if (userManageP.searchOnStoppedTypingAdmin != null) {
            userManageP.searchOnStoppedTypingAdmin!.cancel();
          }
          userManageP.searchOnStoppedTypingAdmin =
              Timer(userManageP.durationAdmin, () async {
            userManageP.nextAdmin = null;
            pagingCAdmin.refresh();
          });
        }
      } else {
        if (i == 0) {
          if (userManageP.searchOnStoppedTyping2 != null) {
            userManageP.searchOnStoppedTyping2!.cancel();
          }
          userManageP.searchOnStoppedTyping2 =
              Timer(userManageP.duration2, () async {
            userManageP.next2 = null;
            pagingC2.refresh();
          });
        }
        if (i == 1) {
          if (userManageP.searchOnStoppedTyping != null) {
            userManageP.searchOnStoppedTyping!.cancel();
          }
          userManageP.searchOnStoppedTyping =
              Timer(userManageP.duration, () async {
            userManageP.next = null;
            pagingC.refresh();
          });
        }
      }

      return () {};
    }

    Widget search() => CustomTextField.borderTextField(
          controller: getC(),
          focusNode: getN(),
          required: false,
          hintText: "Cari User",
          hintColor: Constant.textHintColor2,
          prefixIcon: Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
            child: Image.asset(
              Assets.iconsIcSearch,
              color: Colors.black.withOpacity(0.5),
              width: 5,
              height: 5,
            ),
          ),
          suffixIcon: getSuffixCheck()
              ? null
              : InkWell(
                  onTap: () async {
                    await getOnTap();
                    setState(() {});
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
                    child: Icon(Icons.close),
                  ),
                ),
          onEditingComplete: () {
            setState(() {});
            FocusManager.instance.primaryFocus?.unfocus();
            getOnSubmitted();
          },
          onChanged: (val) {
            setState(() {});
            getOnSubmitted();
          },
        );

    Widget headKonten() {
      return Container(
        color: Colors.white,
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(20, 10, 20, 15),
        child: search(),
      );
    }

    Widget _buildTab(String tag, Widget conten) {
      return Tab(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            tag,
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          SizedBox(
            width: 3,
          ),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey, width: 0.5),
            ),
            child: conten,
          )
        ],
      ));
    }

    Widget toggleTab() {
      if (isSuperAdmin == null) return SizedBox();
      return TabBar(
        isScrollable: isSuperAdmin == true,
        controller: tabController,
        tabAlignment:
            isSuperAdmin == true ? TabAlignment.center : TabAlignment.fill,
        indicatorSize: TabBarIndicatorSize.tab,
        unselectedLabelColor: Constant.grayColor,
        labelColor: Colors.black,
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w300),
        indicatorColor: Constant.primaryColor,
        tabs: isSuperAdmin == true
            ? [
                _buildTab(
                  "User Request",
                  (pagingC3.itemList?.length ?? 0) == 0
                      ? SizedBox()
                      : CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 10,
                          child: Center(
                            child: Text(
                              '${pagingC3.itemList?.length ?? 0}',
                              style: Constant.blackRegular14,
                            ),
                          ),
                        ),
                ),
                _buildTab(
                  "User",
                  (pagingC4.itemList?.length ?? 0) == 0
                      ? SizedBox()
                      : CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 10,
                          child: Center(
                            child: Text(
                              '${pagingC4.itemList?.length ?? 0}',
                              style: Constant.blackRegular14,
                            ),
                          ),
                        ),
                ),
                _buildTab(
                  "Admin",
                  (pagingCAdmin.itemList?.length ?? 0) == 0
                      ? SizedBox()
                      : CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 10,
                          child: Center(
                            child: Text(
                              '${pagingCAdmin.itemList?.length ?? 0}',
                              style: Constant.blackRegular14,
                            ),
                          ),
                        ),
                ),
              ]
            : [
                _buildTab(
                  "User Request",
                  (pagingC2.itemList?.length ?? 0) == 0
                      ? SizedBox()
                      : CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 10,
                          child: Center(
                            child: Text(
                              '${pagingC2.itemList?.length ?? 0}',
                              style: Constant.blackRegular14,
                            ),
                          ),
                        ),
                ),
                _buildTab(
                  "User Aktif",
                  (pagingC.itemList?.length ?? 0) == 0
                      ? SizedBox()
                      : CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 10,
                          child: Center(
                            child: Text(
                              '${pagingC.itemList?.length ?? 0}',
                              style: Constant.blackRegular14,
                            ),
                          ),
                        ),
                ),
              ],
      );
    }

    Widget itemShimmer2() {
      return Column(
        children: [
          Constant.xSizedBox12,
          CustomContainer.mainCard(
            margin: EdgeInsets.symmetric(horizontal: 8),
            padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
            isShadow: false,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Skeleton<bool>(
                    width: 40,
                    height: 40,
                    isCircle: true,
                    value: userManageP.isFetching2 == true
                        ? null
                        : userManageP.isFetching2,
                    child: Image.asset(Assets.iconsIcUser),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  flex: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Skeleton<bool>(
                        value: userManageP.isFetching2 == true
                            ? null
                            : userManageP.isFetching2,
                        width: 80,
                        height: 15,
                        child: Text(
                          'Namaaaaaaaaa',
                          style: Constant.iPrimaryMedium8
                              .copyWith(fontSize: 16, color: Colors.black),
                        ),
                      ),
                      Skeleton<bool>(
                        value: userManageP.isFetching2 == true
                            ? null
                            : userManageP.isFetching2,
                        width: 60,
                        height: 12,
                        child: Text(
                          'Divisiiiiiiiii -',
                          style: TextStyle(
                            color: Constant.textHintColor2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Skeleton<bool>(
                  value: userManageP.isFetching2 == true
                      ? null
                      : userManageP.isFetching2,
                  width: 30,
                  height: 30,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(width: 1, color: Colors.red)),
                    child: Icon(
                      Icons.close,
                      size: 20,
                      color: Colors.red,
                    ),
                  ),
                ),
                SizedBox(width: 4),
                Skeleton<bool>(
                  width: 55,
                  height: 30,
                  value: userManageP.isFetching2 == true
                      ? null
                      : userManageP.isFetching2,
                  child: Container(
                    width: 60,
                    height: 30,
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Color(0xFF19B76E),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      "Terima",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    Widget itemShimmer3() {
      return Column(
        children: [
          Constant.xSizedBox12,
          CustomContainer.mainCard(
            margin: EdgeInsets.symmetric(horizontal: 8),
            padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
            isShadow: false,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Skeleton<bool>(
                    width: 40,
                    height: 40,
                    isCircle: true,
                    value: userManageP.isFetching3 == true
                        ? null
                        : userManageP.isFetching3,
                    child: Image.asset(Assets.iconsIcUser),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  flex: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Skeleton<bool>(
                        value: userManageP.isFetching3 == true
                            ? null
                            : userManageP.isFetching3,
                        width: 80,
                        height: 15,
                        child: Text(
                          'Namaaaaaaaaa',
                          style: Constant.iPrimaryMedium8
                              .copyWith(fontSize: 16, color: Colors.black),
                        ),
                      ),
                      Skeleton<bool>(
                        value: userManageP.isFetching3 == true
                            ? null
                            : userManageP.isFetching3,
                        width: 60,
                        height: 12,
                        child: Text(
                          'Divisiiiiiiiii -',
                          style: TextStyle(
                            color: Constant.textHintColor2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Skeleton<bool>(
                  value: userManageP.isFetching3 == true
                      ? null
                      : userManageP.isFetching3,
                  width: 30,
                  height: 30,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(width: 1, color: Colors.red)),
                    child: Icon(
                      Icons.close,
                      size: 20,
                      color: Colors.red,
                    ),
                  ),
                ),
                SizedBox(width: 4),
                Skeleton<bool>(
                  width: 55,
                  height: 30,
                  value: userManageP.isFetching3 == true
                      ? null
                      : userManageP.isFetching3,
                  child: Container(
                    width: 60,
                    height: 30,
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Color(0xFF19B76E),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      "Terima",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    Widget itemShimmer4() {
      return Column(
        children: [
          Constant.xSizedBox12,
          CustomContainer.mainCard(
            margin: EdgeInsets.symmetric(horizontal: 8),
            padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
            isShadow: false,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Skeleton<bool>(
                    width: 40,
                    height: 40,
                    isCircle: true,
                    value: userManageP.isFetchingAdmin == true
                        ? null
                        : userManageP.isFetching4,
                    child: Image.asset(Assets.iconsIcUser),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  flex: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Skeleton<bool>(
                        value: userManageP.isFetching4 == true
                            ? null
                            : userManageP.isFetching4,
                        width: 80,
                        height: 15,
                        child: Text(
                          'Namaaaaaaaaa',
                          style: Constant.iPrimaryMedium8
                              .copyWith(fontSize: 16, color: Colors.black),
                        ),
                      ),
                      Skeleton<bool>(
                        value: userManageP.isFetching4 == true
                            ? null
                            : userManageP.isFetching4,
                        width: 60,
                        height: 12,
                        child: Text(
                          'Divisiiiiiiiii -',
                          style: TextStyle(
                            color: Constant.textHintColor2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Skeleton<bool>(
                  value: userManageP.isFetching4 == true
                      ? null
                      : userManageP.isFetching4,
                  width: 30,
                  height: 30,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(width: 1, color: Colors.red)),
                    child: Icon(
                      Icons.close,
                      size: 20,
                      color: Colors.red,
                    ),
                  ),
                ),
                SizedBox(width: 4),
                Skeleton<bool>(
                  width: 55,
                  height: 30,
                  value: userManageP.isFetching4 == true
                      ? null
                      : userManageP.isFetching4,
                  child: Container(
                    width: 60,
                    height: 30,
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Color(0xFF19B76E),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      "Terima",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    Widget itemShimmerAdmin() {
      return Column(
        children: [
          Constant.xSizedBox12,
          CustomContainer.mainCard(
            margin: EdgeInsets.symmetric(horizontal: 8),
            padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
            isShadow: false,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Skeleton<bool>(
                    width: 40,
                    height: 40,
                    isCircle: true,
                    value: userManageP.isFetchingAdmin == true
                        ? null
                        : userManageP.isFetchingAdmin,
                    child: Image.asset(Assets.iconsIcUser),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  flex: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Skeleton<bool>(
                        value: userManageP.isFetchingAdmin == true
                            ? null
                            : userManageP.isFetchingAdmin,
                        width: 80,
                        height: 15,
                        child: Text(
                          'Namaaaaaaaaa',
                          style: Constant.iPrimaryMedium8
                              .copyWith(fontSize: 16, color: Colors.black),
                        ),
                      ),
                      Skeleton<bool>(
                        value: userManageP.isFetchingAdmin == true
                            ? null
                            : userManageP.isFetchingAdmin,
                        width: 60,
                        height: 12,
                        child: Text(
                          'Divisiiiiiiiii -',
                          style: TextStyle(
                            color: Constant.textHintColor2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Skeleton<bool>(
                  value: userManageP.isFetchingAdmin == true
                      ? null
                      : userManageP.isFetchingAdmin,
                  width: 30,
                  height: 30,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(width: 1, color: Colors.red)),
                    child: Icon(
                      Icons.close,
                      size: 20,
                      color: Colors.red,
                    ),
                  ),
                ),
                SizedBox(width: 4),
                Skeleton<bool>(
                  width: 55,
                  height: 30,
                  value: userManageP.isFetchingAdmin == true
                      ? null
                      : userManageP.isFetchingAdmin,
                  child: Container(
                    width: 60,
                    height: 30,
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Color(0xFF19B76E),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      "Terima",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    Widget itemShimmer() {
      return Column(
        children: [
          Constant.xSizedBox12,
          CustomContainer.mainCard(
            margin: EdgeInsets.symmetric(horizontal: 8),
            padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
            isShadow: true,
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Skeleton<bool>(
                    width: 40,
                    height: 40,
                    isCircle: true,
                    value: userManageP.isFetching == true
                        ? null
                        : userManageP.isFetching,
                    child: Image.asset(Assets.iconsIcUser),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  flex: 8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Skeleton<bool>(
                        width: 100,
                        height: 13,
                        value: userManageP.isFetching == true
                            ? null
                            : userManageP.isFetching,
                        child: Text(
                          'Nama -',
                          style: Constant.iPrimaryMedium8
                              .copyWith(fontSize: 16, color: Colors.black),
                        ),
                      ),
                      Constant.xSizedBox4,
                      Skeleton<bool>(
                        width: 50,
                        height: 10,
                        value: userManageP.isFetching == true
                            ? null
                            : userManageP.isFetching,
                        child: Text(
                          'Status -',
                          style: Constant.iPrimaryMedium8
                              .copyWith(fontSize: 14, color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Skeleton<bool>(
                    width: 25,
                    height: 25,
                    value: userManageP.isFetching == true
                        ? null
                        : userManageP.isFetching,
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    Widget bodyUserListShimmer() {
      return Column(
        children: [
          itemShimmer(),
          itemShimmer(),
          itemShimmer(),
        ],
      );
    }

    Widget bodyUserListShimmer2() {
      return Column(
        children: [
          itemShimmer2(),
          itemShimmer2(),
          itemShimmer2(),
        ],
      );
    }

    Widget bodyUserListShimmer3() {
      return Column(
        children: [
          itemShimmer3(),
          itemShimmer3(),
          itemShimmer3(),
        ],
      );
    }

    Widget bodyUserListShimmer4() {
      return Column(
        children: [
          itemShimmer4(),
          itemShimmer4(),
          itemShimmer4(),
        ],
      );
    }

    Widget bodyUserListShimmerAdmin() {
      return Column(
        children: [
          itemShimmerAdmin(),
          itemShimmerAdmin(),
          itemShimmerAdmin(),
        ],
      );
    }

    Widget noData() {
      return ListView(shrinkWrap: true, children: [
        Padding(
          padding: const EdgeInsets.only(top: 56),
          child: Center(child: Text("Data tidak ditemukan")),
        )
      ]);
    }

    Widget failedData() {
      return ListView(shrinkWrap: true, children: [
        Padding(
          padding: const EdgeInsets.only(top: 56),
          child: Center(child: Text("Gagal mendapatkan data")),
        )
      ]);
    }

    Widget bodyUserRequest() {
      return RefreshIndicator(
        onRefresh: () async {
          userManageP.next2 = null;
          if ((userManageP.pagingController2.itemList ?? []).isEmpty) {
            userManageP.pagingController2.refresh();
          } else {
            userManageP.next2 = null;
            userManageP.pagingController2.refresh();
          }
        },
        child: Column(
          children: [
            Expanded(
              child: PagedListView.separated(
                pagingController: pagingC2,
                padding: EdgeInsets.fromLTRB(0, 0, 0, 30),
                shrinkWrap: true,
                physics: AlwaysScrollableScrollPhysics(),
                separatorBuilder: (context, index) => SizedBox(height: 8),
                builderDelegate: PagedChildBuilderDelegate<UserListModelData>(
                  firstPageProgressIndicatorBuilder: (_) =>
                      bodyUserListShimmer2(),
                  firstPageErrorIndicatorBuilder: (_) => failedData(),
                  newPageProgressIndicatorBuilder: (_) =>
                      bodyUserListShimmer2(),
                  newPageErrorIndicatorBuilder: (_) => failedData(),
                  noItemsFoundIndicatorBuilder: (_) => noData(),
                  itemBuilder: (context, item, index) {
                    return InkWell(
                      onTap: () async {
                        await context.read<UserManageProvider>().clearForm();
                        await CusNav.nPush(
                            context, UserAddView(id: item.Id ?? ''));
                        pagingC2.refresh();
                      },
                      child: Column(
                        children: [
                          SizedBox(height: 10),
                          CustomContainer.mainCard(
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(40),
                                      color: Colors.white,
                                      image: DecorationImage(
                                        image: AssetImage(Assets.iconsIcUser),
                                        scale: 6,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 5),
                                Expanded(
                                  flex: 6,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(item.Name ?? 'Nama -',
                                          style: Constant.iBlackMedium14),
                                      Text(item.Division ?? 'Divisi -',
                                          style: Constant.blackRegular12),
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: () async {
                                    await Utils.showYesNoDialog(
                                        context: context,
                                        title: "Konfirmasi",
                                        desc:
                                            "Apakah Anda Yakin Menolak User Ini?",
                                        yesCallback: () async {
                                          CusNav.nPop(context);
                                          final p = context
                                              .read<UserManageProvider>();
                                          handleTap(() async {
                                            p.selectedStatus = '2';
                                            await p.updateUser(
                                              context,
                                              id: item.Id ?? '',
                                              fromHome: true,
                                            );

                                            p.selectedStatus = null;

                                            await context
                                                .read<HomeProvider>()
                                                .getData(context);
                                            ;
                                          });
                                        },
                                        noCallback: () => CusNav.nPop(context));
                                  },
                                  child: Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(7),
                                          border: Border.all(
                                              width: 1, color: Colors.red)),
                                      child: Icon(
                                        Icons.close,
                                        size: 20,
                                        color: Colors.red,
                                      )),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                InkWell(
                                  onTap: () async {
                                    await Utils.showYesNoDialog(
                                        context: context,
                                        title: "Konfirmasi",
                                        desc:
                                            "Apakah Anda Yakin Menerima User Ini?",
                                        yesCallback: () async {
                                          CusNav.nPop(context);
                                          final p = context
                                              .read<UserManageProvider>();
                                          handleTap(() async {
                                            p.selectedStatus = '1';
                                            await p.updateUser(
                                              context,
                                              id: item.Id ?? '',
                                              fromHome: true,
                                            );
                                            p.selectedStatus = null;

                                            await context
                                                .read<HomeProvider>()
                                                .getData(context);
                                            ;
                                          });
                                        },
                                        noCallback: () => CusNav.nPop(context));
                                  },
                                  child: Container(
                                    width: 60,
                                    padding: EdgeInsets.all(5),
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: Color(0xFF19B76E),
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                    child: Text(
                                      "Terima",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget bodyUserRequestSuper() {
      return RefreshIndicator(
        onRefresh: () async {
          userManageP.next3 = null;
          if ((userManageP.pagingController3.itemList ?? []).isEmpty) {
            userManageP.pagingController3.refresh();
          } else {
            userManageP.next3 = null;
            userManageP.pagingController3.refresh();
          }
        },
        child: Column(
          children: [
            Expanded(
              child: PagedListView.separated(
                pagingController: pagingC3,
                padding: EdgeInsets.fromLTRB(0, 0, 0, 30),
                shrinkWrap: true,
                physics: AlwaysScrollableScrollPhysics(),
                separatorBuilder: (context, index) => SizedBox(height: 8),
                builderDelegate: PagedChildBuilderDelegate<UserListModelData>(
                  firstPageProgressIndicatorBuilder: (_) =>
                      bodyUserListShimmer3(),
                  firstPageErrorIndicatorBuilder: (_) => failedData(),
                  newPageProgressIndicatorBuilder: (_) =>
                      bodyUserListShimmer3(),
                  newPageErrorIndicatorBuilder: (_) => failedData(),
                  noItemsFoundIndicatorBuilder: (_) => noData(),
                  itemBuilder: (context, item, index) {
                    return InkWell(
                      onTap: () async {
                        await context.read<UserManageProvider>().clearForm();
                        await CusNav.nPush(
                            context, UserAddView(id: item.Id ?? ''));

                        userManageP.next3 = null;
                        if ((userManageP.pagingController3.itemList ?? [])
                            .isEmpty) {
                          userManageP.pagingController3.refresh();
                        } else {
                          userManageP.next3 = null;
                          userManageP.pagingController3.refresh();
                        }
                      },
                      child: Column(
                        children: [
                          SizedBox(height: 10),
                          CustomContainer.mainCard(
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(40),
                                      color: Colors.white,
                                      image: DecorationImage(
                                        image: AssetImage(Assets.iconsIcUser),
                                        scale: 6,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 5),
                                Expanded(
                                  flex: 6,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(item.Name ?? 'Nama -',
                                          style: Constant.iBlackMedium14),
                                      Text(item.Division ?? 'Divisi -',
                                          style: Constant.blackRegular12),
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: () async {
                                    await Utils.showYesNoDialog(
                                        context: context,
                                        title: "Konfirmasi",
                                        desc:
                                            "Apakah Anda Yakin Menolak User Ini?",
                                        yesCallback: () async {
                                          CusNav.nPop(context);
                                          final p = context
                                              .read<UserManageProvider>();
                                          handleTap(() async {
                                            p.selectedStatus = '2';
                                            await p.updateUser(
                                              context,
                                              id: item.Id ?? '',
                                              fromHome: true,
                                            );

                                            p.selectedStatus = null;

                                            await context
                                                .read<HomeProvider>()
                                                .getData(context);
                                            ;
                                          });
                                        },
                                        noCallback: () => CusNav.nPop(context));
                                  },
                                  child: Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(7),
                                          border: Border.all(
                                              width: 1, color: Colors.red)),
                                      child: Icon(
                                        Icons.close,
                                        size: 20,
                                        color: Colors.red,
                                      )),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                InkWell(
                                  onTap: () async {
                                    await Utils.showYesNoDialog(
                                        context: context,
                                        title: "Konfirmasi",
                                        desc:
                                            "Apakah Anda Yakin Menerima User Ini?",
                                        yesCallback: () async {
                                          CusNav.nPop(context);
                                          final p = context
                                              .read<UserManageProvider>();
                                          handleTap(() async {
                                            p.selectedStatus = '1';
                                            await p.updateUser(
                                              context,
                                              id: item.Id ?? '',
                                              fromHome: true,
                                            );
                                            p.selectedStatus = null;
                                            pagingC3.refresh();
                                          });
                                        },
                                        noCallback: () => CusNav.nPop(context));
                                  },
                                  child: Container(
                                    width: 60,
                                    padding: EdgeInsets.all(5),
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: Color(0xFF19B76E),
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                    child: Text(
                                      "Terima",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget bodyUserAllSuper() {
      return RefreshIndicator(
        onRefresh: () async {
          userManageP.next4 = null;
          if ((userManageP.pagingController4.itemList ?? []).isEmpty) {
            userManageP.pagingController4.refresh();
          } else {
            userManageP.next4 = null;
            userManageP.pagingController4.refresh();
          }
        },
        child: Column(
          children: [
            Expanded(
              child: PagedListView.separated(
                pagingController: pagingC4,
                padding: EdgeInsets.fromLTRB(0, 0, 0, 30),
                shrinkWrap: true,
                physics: AlwaysScrollableScrollPhysics(),
                separatorBuilder: (context, index) => SizedBox(height: 8),
                builderDelegate: PagedChildBuilderDelegate<UserListModelData>(
                  firstPageProgressIndicatorBuilder: (_) =>
                      bodyUserListShimmer4(),
                  firstPageErrorIndicatorBuilder: (_) => failedData(),
                  newPageProgressIndicatorBuilder: (_) =>
                      bodyUserListShimmer4(),
                  newPageErrorIndicatorBuilder: (_) => failedData(),
                  noItemsFoundIndicatorBuilder: (_) => noData(),
                  itemBuilder: (context, item, index) {
                    return InkWell(
                      onTap: () async {
                        await context.read<UserManageProvider>().clearForm();
                        await CusNav.nPush(
                            context, UserAddView(id: item.Id ?? ''));

                        userManageP.next4 = null;
                        if ((userManageP.pagingController4.itemList ?? [])
                            .isEmpty) {
                          userManageP.pagingController4.refresh();
                        } else {
                          userManageP.next4 = null;
                          userManageP.pagingController4.refresh();
                        }
                      },
                      child: Column(
                        children: [
                          SizedBox(height: 10),
                          CustomContainer.mainCard(
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(40),
                                      color: Colors.white,
                                      image: DecorationImage(
                                        image: AssetImage(Assets.iconsIcUser),
                                        scale: 6,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 5),
                                Expanded(
                                  flex: 8,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(item.Name ?? 'Nama -',
                                          style: Constant.iBlackMedium14),
                                      Text(item.Division ?? 'Divisi -',
                                          style: Constant.blackRegular12),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.grey,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget bodyAdminAllSuper() {
      return RefreshIndicator(
        onRefresh: () async {
          userManageP.nextAdmin = null;
          if ((userManageP.pagingControllerAdmin.itemList ?? []).isEmpty) {
            userManageP.pagingControllerAdmin.refresh();
          } else {
            userManageP.nextAdmin = null;
            userManageP.pagingControllerAdmin.refresh();
          }
        },
        child: Column(
          children: [
            Expanded(
              child: PagedListView.separated(
                pagingController: pagingCAdmin,
                padding: EdgeInsets.fromLTRB(0, 0, 0, 30),
                shrinkWrap: true,
                physics: AlwaysScrollableScrollPhysics(),
                separatorBuilder: (context, index) => SizedBox(height: 8),
                builderDelegate: PagedChildBuilderDelegate<UserListModelData>(
                  firstPageProgressIndicatorBuilder: (_) =>
                      bodyUserListShimmerAdmin(),
                  firstPageErrorIndicatorBuilder: (_) => failedData(),
                  newPageProgressIndicatorBuilder: (_) =>
                      bodyUserListShimmerAdmin(),
                  newPageErrorIndicatorBuilder: (_) => failedData(),
                  noItemsFoundIndicatorBuilder: (_) => noData(),
                  itemBuilder: (context, item, index) {
                    return InkWell(
                      onTap: () async {
                        await context.read<UserManageProvider>().clearForm();
                        await CusNav.nPush(
                            context, UserAddView(id: item.Id ?? ''));

                        userManageP.nextAdmin = null;
                        if ((userManageP.pagingControllerAdmin.itemList ?? [])
                            .isEmpty) {
                          userManageP.pagingControllerAdmin.refresh();
                        } else {
                          userManageP.nextAdmin = null;
                          userManageP.pagingControllerAdmin.refresh();
                        }
                      },
                      child: Column(
                        children: [
                          SizedBox(height: 10),
                          CustomContainer.mainCard(
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(40),
                                      color: Colors.white,
                                      image: DecorationImage(
                                        image: AssetImage(Assets.iconsIcUser),
                                        scale: 6,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 5),
                                Expanded(
                                  flex: 8,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(item.Name ?? 'Nama -',
                                          style: Constant.iBlackMedium14),
                                      Text(item.Division ?? 'Divisi -',
                                          style: Constant.blackRegular12),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.grey,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget bodyUserAktif() {
      return RefreshIndicator(
        onRefresh: () async {
          userManageP.next = null;
          if ((userManageP.pagingController.itemList ?? []).isEmpty) {
            userManageP.pagingController.refresh();
          } else {
            userManageP.next = null;
            userManageP.pagingController.refresh();
          }
        },
        child: Column(
          children: [
            Expanded(
              child: PagedListView.separated(
                pagingController: pagingC,
                padding: EdgeInsets.fromLTRB(0, 0, 0, 30),
                shrinkWrap: true,
                physics: AlwaysScrollableScrollPhysics(),
                separatorBuilder: (context, index) => SizedBox(height: 8),
                builderDelegate: PagedChildBuilderDelegate<UserListModelData>(
                  firstPageProgressIndicatorBuilder: (_) =>
                      bodyUserListShimmer(),
                  firstPageErrorIndicatorBuilder: (_) => failedData(),
                  newPageProgressIndicatorBuilder: (_) => bodyUserListShimmer(),
                  newPageErrorIndicatorBuilder: (_) => failedData(),
                  noItemsFoundIndicatorBuilder: (_) => noData(),
                  itemBuilder: (context, item, index) {
                    return InkWell(
                      onTap: () async {
                        await context.read<UserManageProvider>().clearForm();
                        await CusNav.nPush(
                            context, UserAddView(id: item.Id ?? ''));
                        pagingC.refresh();
                      },
                      child: Column(
                        children: [
                          SizedBox(height: 10),
                          CustomContainer.mainCard(
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(40),
                                      color: Colors.white,
                                      image: DecorationImage(
                                        image: AssetImage(Assets.iconsIcUser),
                                        scale: 6,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 5),
                                Expanded(
                                  flex: 8,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(item.Name ?? 'Nama -',
                                          style: Constant.iBlackMedium14),
                                      Text(item.Division ?? 'Divisi -',
                                          style: Constant.blackRegular12),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.grey,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: CustomAppBar.appBar(context, "Daftar User",
          isLeading: false,
          action: [
            InkWell(
              onTap: () async {
                await context.read<UserManageProvider>().clearForm();
                CusNav.nPush(context, UserAddView());
              },
              child: Container(
                margin: EdgeInsets.only(right: 20),
                padding: EdgeInsets.all(3),
                decoration: BoxDecoration(
                  border: Border.all(width: 1, color: Constant.primaryColor),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.add,
                      size: 15,
                      color: Constant.primaryColor,
                    ),
                    Text(
                      "Tambah User",
                      style: Constant.iPrimaryMedium12,
                    ),
                  ],
                ),
              ),
            )
          ],
          titleSpacing: 20,
          color: Colors.white,
          foregroundColor: Constant.primaryColor),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              headKonten(),
              SizedBox(height: 5),
              toggleTab(),
              SizedBox(height: 8),
              Expanded(
                child: isSuperAdmin == null
                    ? SizedBox()
                    : TabBarView(
                        // physics: NeverScrollableScrollPhysics(),
                        controller: tabController,
                        children: isSuperAdmin == true
                            ? [
                                bodyUserRequestSuper(),
                                bodyUserAllSuper(),
                                bodyAdminAllSuper(),
                              ]
                            : [
                                bodyUserRequest(),
                                bodyUserAktif(),
                              ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
