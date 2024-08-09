import 'dart:developer';

import 'package:hy_tutorial/common/base/base_state.dart';
import 'package:hy_tutorial/common/component/custom_container.dart';
import 'package:hy_tutorial/common/component/custom_navigator.dart';
import 'package:hy_tutorial/common/component/skeleton.dart';
import 'package:hy_tutorial/common/helper/constant.dart';
import 'package:hy_tutorial/src/admin/model/user_list_model.dart';
import 'package:hy_tutorial/src/admin/provider/user_manage_provider.dart';
import 'package:hy_tutorial/src/admin/view/user_add_view.dart';
import 'package:hy_tutorial/src/admin/view/user_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:hy_tutorial/src/plta/model/plta_list_model.dart';
import 'package:hy_tutorial/src/plta/provider/plta_provider.dart';
import 'package:hy_tutorial/src/plta/view/plta_add_view_old.dart';
import 'package:hy_tutorial/src/plta/view/plta_add_view.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import '../../../common/component/custom_appbar.dart';

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
    tabController = TabController(length: 3, vsync: this);
    tabController.addListener(() {
      log("INDEX ACTIVE : ${tabController.index}");
      setState(() {});
    });

    final userManageP = context.read<UserManageProvider>();
    final pltaP = context.read<PltaProvider>();
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
    //plta
    if ((pltaP.pagingController.itemList ?? []).isEmpty) {
      pltaP.getPltaList();
    } else {
      pltaP.pagingController.dispose();
      pltaP.next = null;
      pltaP.getPltaList();
      setState(() {});
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final userManageP = context.watch<UserManageProvider>();
    final pltaP = context.watch<PltaProvider>();
    final pltaList = context.watch<PltaProvider>().pltaListModel.Data ?? [];
    final pagingC = context.watch<UserManageProvider>().pagingController;
    final pagingC2 = context.watch<UserManageProvider>().pagingController2;
    final pagingC3 = context.watch<PltaProvider>().pagingController;
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
                                "Manage ${tabController.index != 2 ? 'User' : 'PLTA'}",
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
                                "Manage ${tabController.index != 2 ? 'User' : 'PLTA'} Anda",
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
                            onTap: () async {
                              tabController.index != 2
                                  ? await CusNav.nPush(context, UserAddView())
                                  : await CusNav.nPush(context, PltaAddView());
                              pagingC3.refresh();
                            },
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
                                      "Add ${tabController.index != 2 ? 'User' : 'PLTA'}",
                                      style: TextStyle(
                                          color: Constant.primaryColor,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Image.asset(
                                      tabController.index != 2
                                          ? 'assets/icons/ic-add-user.png'
                                          : 'assets/icons/ic-add-plta.png',
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
      return Tab(
          child: Text(
        tag,
        style: TextStyle(fontSize: 18),
        textAlign: TextAlign.left,
      ));
    }

    Widget toggleTab() {
      return TabBar(
        isScrollable: true,
        controller: tabController,
        indicatorWeight: 4,
        tabAlignment: TabAlignment.start,
        indicatorSize: TabBarIndicatorSize.label,
        unselectedLabelColor: Constant.grayColor,
        labelColor: Constant.primaryColor,
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w300),
        indicatorColor: Constant.primaryColor,
        tabs: [
          _buildTab("User"),
          _buildTab("Register Request"),
          _buildTab("Manage PLTA"),
        ],
      );
    }

    Widget itemShimmer() {
      return CustomContainer.mainCard(
        isShadow: false,
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Skeleton<bool>(
                width: 50,
                height: 55,
                isCircle: true,
                value: userManageP.isFetching == true
                    ? null
                    : userManageP.isFetching,
                child: Container(
                  height: 50,
                  width: 55,
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
            ),
            SizedBox(width: 10),
            Expanded(
              flex: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Constant.xSizedBox8,
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
                  Constant.xSizedBox4,
                  Skeleton<bool>(
                    width: 60,
                    height: 10,
                    value: userManageP.isFetching == true
                        ? null
                        : userManageP.isFetching,
                    child: Text(
                      'Divisi -',
                      style: TextStyle(color: Constant.textHintColor2),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Skeleton<bool>(
                value: userManageP.isFetching == true
                    ? null
                    : userManageP.isFetching,
                width: 1,
                height: 25,
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget itemShimmer2() {
      return CustomContainer.mainCard(
        isShadow: false,
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Skeleton<bool>(
                width: 50,
                height: 55,
                isCircle: true,
                value: userManageP.isFetching2 == true
                    ? null
                    : userManageP.isFetching2,
                child: Container(
                  height: 50,
                  width: 55,
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
            ),
            SizedBox(width: 10),
            Expanded(
              flex: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Constant.xSizedBox8,
                  Skeleton<bool>(
                    width: 100,
                    height: 13,
                    value: userManageP.isFetching2 == true
                        ? null
                        : userManageP.isFetching2,
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
                    value: userManageP.isFetching2 == true
                        ? null
                        : userManageP.isFetching2,
                    child: Text(
                      'Status -',
                      style: Constant.iPrimaryMedium8
                          .copyWith(fontSize: 14, color: Colors.black),
                    ),
                  ),
                  Constant.xSizedBox4,
                  Skeleton<bool>(
                    width: 60,
                    height: 10,
                    value: userManageP.isFetching2 == true
                        ? null
                        : userManageP.isFetching2,
                    child: Text(
                      'Divisi -',
                      style: TextStyle(color: Constant.textHintColor2),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Skeleton<bool>(
                width: 1,
                height: 25,
                value: userManageP.isFetching2 == true
                    ? null
                    : userManageP.isFetching2,
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget bodyUserListShimmer() {
      return Column(
        children: [
          itemShimmer(),
          SizedBox(height: 20),
          itemShimmer(),
          SizedBox(height: 20),
          itemShimmer(),
          SizedBox(height: 20),
        ],
      );
    }

    Widget bodyUserListShimmer2() {
      return Column(
        children: [
          itemShimmer2(),
          SizedBox(height: 20),
          itemShimmer2(),
          SizedBox(height: 20),
          itemShimmer2(),
          SizedBox(height: 20),
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

    Widget bodyUserList() {
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
                physics: AlwaysScrollableScrollPhysics(),
                separatorBuilder: (_, __) => SizedBox(),
                builderDelegate: PagedChildBuilderDelegate<UserListModelData>(
                  firstPageProgressIndicatorBuilder: (_) =>
                      bodyUserListShimmer(),
                  firstPageErrorIndicatorBuilder: (_) => failedData(),
                  newPageProgressIndicatorBuilder: (_) => bodyUserListShimmer(),
                  newPageErrorIndicatorBuilder: (_) => failedData(),
                  noItemsFoundIndicatorBuilder: (_) => noData(),
                  itemBuilder: (context, item, index) {
                    if (item.Status != 'active') return SizedBox();
                    return InkWell(
                      onTap: () async {
                        await CusNav.nPush(
                            context, UserAddView(id: item.Id ?? ''));
                        // context, UserDetailView(id: item.Id ?? ''));
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
                padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                shrinkWrap: true,
                physics: ScrollPhysics(),
                separatorBuilder: (context, index) {
                  return SizedBox();
                },
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

    Widget itemShimmer3() {
      return Column(
        children: [
          CustomContainer.mainCard(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            isShadow: false,
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Skeleton<bool>(
                    width: 50,
                    height: 55,
                    isCircle: true,
                    value: pltaP.isFetching == true ? null : pltaP.isFetching,
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        color: Colors.white,
                        image: DecorationImage(
                          image: AssetImage(
                            'assets/icons/ic-plta-black.png',
                          ),
                          scale: 3,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 5),
                Expanded(
                  flex: 8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Constant.xSizedBox8,
                      Skeleton<bool>(
                        width: 100,
                        height: 13,
                        value:
                            pltaP.isFetching == true ? null : pltaP.isFetching,
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
                        value:
                            pltaP.isFetching == true ? null : pltaP.isFetching,
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
                    width: 1,
                    height: 25,
                    value: pltaP.isFetching == true ? null : pltaP.isFetching,
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey,
                      size: 20,
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      );
    }

    Widget bodyPLTAListShimmer() {
      return Column(
        children: [
          itemShimmer3(),
          SizedBox(height: 20),
          itemShimmer3(),
          SizedBox(height: 20),
          itemShimmer3(),
          SizedBox(height: 20),
        ],
      );
    }

    Widget bodyPLTA() {
      return RefreshIndicator(
        onRefresh: () async {
          pltaP.next = null;
          if ((pltaP.pagingController.itemList ?? []).isEmpty) {
            pltaP.pagingController.refresh();
          } else {
            pltaP.next = null;
            pltaP.pagingController.refresh();
          }
        },
        child: Column(
          children: [
            Expanded(
              child: PagedListView.separated(
                pagingController: pagingC3,
                padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                shrinkWrap: true,
                physics: ScrollPhysics(),
                separatorBuilder: (context, index) {
                  return SizedBox();
                },
                builderDelegate: PagedChildBuilderDelegate<PltaListModelData>(
                  firstPageProgressIndicatorBuilder: (_) =>
                      bodyPLTAListShimmer(),
                  firstPageErrorIndicatorBuilder: (_) => failedData(),
                  newPageProgressIndicatorBuilder: (_) => bodyPLTAListShimmer(),
                  newPageErrorIndicatorBuilder: (_) => failedData(),
                  noItemsFoundIndicatorBuilder: (_) => noData(),
                  itemBuilder: (context, item, index) {
                    return InkWell(
                      onTap: () async {
                        await CusNav.nPush(
                            context, PltaAddView(id: item.Id ?? ''));
                        pagingC3.refresh();
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
                                          'assets/icons/ic-plta-black.png',
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
                                        '${(item.Status ?? false) ? 'Aktif' : 'Nonaktif'}',
                                        style: Constant.iPrimaryMedium8
                                            .copyWith(
                                                fontSize: 14,
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
      appBar: CustomAppBar.appBar(
          context, "Manage ${tabController.index != 2 ? 'User' : 'PLTA'}",
          isLeading: false,
          titleSpacing: 20,
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
                children: [
                  bodyUserList(),
                  bodyUserRequest(),
                  bodyPLTA(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
