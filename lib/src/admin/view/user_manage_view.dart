import 'dart:developer';

import 'package:hy_tutorial/common/base/base_state.dart';
import 'package:hy_tutorial/common/component/custom_container.dart';
import 'package:hy_tutorial/common/component/custom_navigator.dart';
import 'package:hy_tutorial/common/helper/constant.dart';
import 'package:hy_tutorial/src/admin/model/user_list_model.dart';
import 'package:hy_tutorial/src/admin/provider/user_manage_provider.dart';
import 'package:hy_tutorial/src/home/view/home_admin_view.dart';
import 'package:hy_tutorial/src/admin/view/user_add_view.dart';
import 'package:hy_tutorial/src/admin/view/user_detail_view.dart';
import 'package:hy_tutorial/src/data/view/data_add_view.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/component/custom_appbar.dart';
import '../../../common/component/custom_loading_indicator.dart';
import '../../../utils/utils.dart';
import '../../auth/provider/auth_provider.dart';
import '../../shaft/view/shaft_latest_view.dart';

class UserManageView extends StatefulWidget {
  const UserManageView({super.key});

  @override
  State<UserManageView> createState() => _UserManageViewState();
}

class _UserManageViewState extends BaseState<UserManageView>
    with TickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      log("INDEX ACTIVE : ${tabController.index}");
      setState(() {});
    });

    final userManageP = context.read<UserManageProvider>();
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
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final userManageP = context.watch<UserManageProvider>();
    final pagingC = context.watch<UserManageProvider>().pagingController;
    final pagingC2 = context.watch<UserManageProvider>().pagingController2;
    Widget headKonten() {
      return Container(
        color: Constant.primaryColor,
        height: 110,
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(20, 10, 20, 15),
        child: Column(
          children: [
            Expanded(
              child: Container(
                margin: EdgeInsets.only(bottom: 10),
                padding: EdgeInsets.fromLTRB(15, 15, 15, 10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Constant.secondaryColor),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 6,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Manage User",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                "Manage User Anda",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 30,
                        ),
                        Expanded(
                          flex: 4,
                          child: InkWell(
                            onTap: () => CusNav.nPush(context, UserAddView()),
                            child: Container(
                                padding: EdgeInsets.all(7),
                                height: 35,
                                decoration: BoxDecoration(
                                  color: Constant.thirdColor,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Add User",
                                      style: TextStyle(
                                          color: Constant.primaryColor,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Image.asset(
                                      'assets/icons/ic-add-user.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ],
                                )),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      );
    }

    Widget _buildTab(String tag) {
      return Tab(child: Text(tag, style: TextStyle(fontSize: 18)));
    }

    Widget toggleTab() {
      return Center(
        child: TabBar(
          isScrollable: true,
          controller: tabController,
          indicatorWeight: 4,
          unselectedLabelColor: Constant.grayColor,
          labelColor: Constant.primaryColor,
          unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w300),
          indicatorColor: Constant.primaryColor,
          tabs: [_buildTab("User Aktif"), _buildTab("Register Request")],
        ),
      );
    }

    Widget bodyKontenActive() {
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
                padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                shrinkWrap: true,
                physics: ScrollPhysics(),
                separatorBuilder: (context, index) {
                  return SizedBox();
                },
                builderDelegate: PagedChildBuilderDelegate<UserListModelData>(
                  firstPageProgressIndicatorBuilder: (_) => Container(
                    color: Colors.white,
                    padding: EdgeInsets.only(top: 32),
                    child: CustomLoadingIndicator.buildIndicator(),
                  ),
                  firstPageErrorIndicatorBuilder: (_) => Padding(
                    padding: const EdgeInsets.only(top: 56),
                    child: Center(child: Text("Gagal mendapatkan data")),
                  ),
                  newPageProgressIndicatorBuilder: (_) => Container(
                    color: Colors.white,
                    child: CustomLoadingIndicator.buildIndicator(),
                  ),
                  newPageErrorIndicatorBuilder: (_) => Padding(
                    padding: const EdgeInsets.only(top: 56),
                    child: Center(child: Text("Gagal mendapatkan data")),
                  ),
                  noItemsFoundIndicatorBuilder: (_) => Padding(
                    padding: const EdgeInsets.only(top: 56),
                    child: Center(child: Text("Tidak ada data")),
                  ),
                  itemBuilder: (context, item, index) {
                    if (item.Status != 'active') return SizedBox();
                    return InkWell(
                      onTap: () async {
                        await CusNav.nPush(
                            context, UserDetailView(id: item.Id ?? ''));
                        pagingC.refresh();
                      },
                      child: Column(
                        children: [
                          CustomContainer.mainCard(
                            isShadow: false,
                            child: Row(
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
                                        image: AssetImage(
                                          'assets/icons/ic-user-black.png',
                                        ),
                                        scale: 3,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  flex: 8,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.Name ?? 'Nama -',
                                        style: Constant.iPrimaryMedium8
                                            .copyWith(
                                                fontSize: 16,
                                                color: Colors.black),
                                      ),
                                      Text(
                                        item.Status ?? 'Status -',
                                        style: Constant.iPrimaryMedium8
                                            .copyWith(
                                                fontSize: 14,
                                                color: Colors.black),
                                      ),
                                      Text(
                                        item.Division ?? 'Divisi -',
                                        style: TextStyle(
                                            color: Constant.textHintColor2),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                    flex: 1,
                                    child: Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.grey,
                                      size: 20,
                                    ))
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20,
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

    Widget bodyKontenRequest() {
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
                padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                shrinkWrap: true,
                physics: ScrollPhysics(),
                separatorBuilder: (context, index) {
                  return SizedBox();
                },
                builderDelegate: PagedChildBuilderDelegate<UserListModelData>(
                  firstPageProgressIndicatorBuilder: (_) => Container(
                    color: Colors.white,
                    padding: EdgeInsets.only(top: 32),
                    child: CustomLoadingIndicator.buildIndicator(),
                  ),
                  newPageProgressIndicatorBuilder: (_) => Container(
                    color: Colors.white,
                    child: CustomLoadingIndicator.buildIndicator(),
                  ),
                  noItemsFoundIndicatorBuilder: (_) => Padding(
                    padding: const EdgeInsets.only(top: 56),
                    child: Center(child: Text("Tidak ada data")),
                  ),
                  itemBuilder: (context, item, index) {
                    return InkWell(
                      onTap: () async {
                        await CusNav.nPush(
                            context, UserDetailView(id: item.Id ?? ''));
                        pagingC2.refresh();
                      },
                      child: Column(
                        children: [
                          CustomContainer.mainCard(
                            isShadow: false,
                            child: Row(
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
                                        image: AssetImage(
                                          'assets/icons/ic-user-black.png',
                                        ),
                                        scale: 3,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  flex: 8,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.Name ?? 'Nama -',
                                        style: Constant.iPrimaryMedium8
                                            .copyWith(
                                                fontSize: 16,
                                                color: Colors.black),
                                      ),
                                      Text(
                                        item.Status ?? 'Status -',
                                        style: Constant.iPrimaryMedium8
                                            .copyWith(
                                                fontSize: 14,
                                                color: Colors.black),
                                      ),
                                      Text(
                                        item.Division ?? 'Divisi -',
                                        style: TextStyle(
                                            color: Constant.textHintColor2),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                    flex: 1,
                                    child: Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.grey,
                                      size: 20,
                                    ))
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20,
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
      appBar: CustomAppBar.appBar(context, "Manage User",
          textStyle: TextStyle(color: Colors.white, fontSize: 18),
          color: Constant.primaryColor,
          foregroundColor: Colors.white),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            headKonten(),
            SizedBox(height: 5),
            toggleTab(),
            SizedBox(height: 8),
            Expanded(
              child: TabBarView(
                physics: NeverScrollableScrollPhysics(),
                controller: tabController,
                children: [bodyKontenActive(), bodyKontenRequest()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
