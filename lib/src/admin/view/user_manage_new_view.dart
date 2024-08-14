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
import 'package:hy_tutorial/src/admin/view/user_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:hy_tutorial/src/data/view/daftar_laporan_new_view.dart';
import 'package:hy_tutorial/src/plta/model/plta_list_model.dart';
import 'package:hy_tutorial/src/plta/provider/plta_provider.dart';
import 'package:hy_tutorial/src/plta/view/plta_add_view.dart';
import 'package:hy_tutorial/src/turbine/provider/turbine_provider.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import '../../../common/component/custom_appbar.dart';

class UserManageNewView extends StatefulWidget {
  const UserManageNewView({super.key});

  @override
  State<UserManageNewView> createState() => _UserManageNewViewState();
}

class _UserManageNewViewState extends BaseState<UserManageNewView>
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
    final turbineP = context.watch<TurbineProvider>();
    final userManageP = context.watch<UserManageProvider>();
    final pltaP = context.watch<PltaProvider>();
    final pltaList = context.watch<PltaProvider>().pltaListModel.Data ?? [];
    final pagingC = context.watch<UserManageProvider>().pagingController;
    final pagingC2 = context.watch<UserManageProvider>().pagingController2;
    final pagingC3 = context.watch<PltaProvider>().pagingController;

    Widget search() => CustomTextField.borderTextField(
      controller: turbineP.turbineSearchC,
      focusNode: turbineP.turbineSearchN,
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
      suffixIcon: turbineP.turbineSearchC.text.isEmpty
          ? null
          : InkWell(
        onTap: () {
          turbineP.turbineSearchC.clear();
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
        if (turbineP.searchOnStoppedTyping != null) {
          turbineP.searchOnStoppedTyping!.cancel();
        }
        turbineP.searchOnStoppedTyping = Timer(turbineP.duration, () async {
          turbineP.next = null;
          pagingC.refresh();
        });
      },
      onChange: (val) {
        setState(() {});
        if (turbineP.searchOnStoppedTyping != null) {
          turbineP.searchOnStoppedTyping!.cancel();
        }
        turbineP.searchOnStoppedTyping = Timer(turbineP.duration, () async {
          turbineP.next = null;
          pagingC.refresh();
        });
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
              SizedBox(width: 3,),
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
      return TabBar(
        isScrollable: false,
        controller: tabController,
        tabAlignment: TabAlignment.fill,
        indicatorSize: TabBarIndicatorSize.tab,
        unselectedLabelColor: Constant.grayColor,
        labelColor: Constant.primaryColor,
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w300),
        indicatorColor: Constant.primaryColor,
        tabs: [
          _buildTab("User Request", CircleAvatar(
            backgroundColor: Colors.white,
            radius: 10,
            child: Center(
              child: Text(
                "7",
                style: Constant.blackRegular14,
              ),
            ),
          ),),
          _buildTab("User Aktif", CircleAvatar(
            backgroundColor: Colors.white,
            radius: 10,
            child: Center(
              child: Text(
                "7",
                style: Constant.blackRegular14,
              ),
            ),
          )),
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

    Widget bodyUserRequest() {
      return ListView(
        children: List.generate(7, (index) {
          return Column(
            children: [
              SizedBox(height: 10,),
              CustomContainer.mainCard(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(Assets.iconsIcUser, scale: 6),
                      SizedBox(width: 5,),
                      Expanded(
                        flex: 6,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Alifano",
                              style: Constant.iBlackMedium14,
                            ),
                            Text(
                              "Machine Engineer",
                              style: Constant.blackRegular12,
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () {},
                        child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(7),
                                border:
                                Border.all(width: 1, color: Colors.red)),
                            child: Icon(
                              Icons.close,
                              size: 20,
                              color: Colors.red,
                            )),
                      ),
                      SizedBox(width: 5,),
                      InkWell(
                        onTap: () {},
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
                  )),
            ],
          );
        }),
      );
    }

    Widget bodyUserAktif() {
      return ListView(
        children: List.generate(7, (index) {
          return Column(
            children: [
              SizedBox(height: 10,),
              CustomContainer.mainCard(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(Assets.iconsIcUser, scale: 6),
                      SizedBox(width: 5,),
                      Expanded(
                        flex: 6,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Alifano",
                              style: Constant.iBlackMedium14,
                            ),
                            Text(
                              "Machine Engineer",
                              style: Constant.blackRegular12,
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Colors.black, weight: 1,),
                    ],
                  )),
            ],
          );
        }),
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
          context, "Daftar User",
          isLeading: false,
          action: [
            InkWell(
              onTap: () {
                CusNav.nPush(context, DaftarLaporanNewView());
              },
              child: Container(
                margin: EdgeInsets.only(right: 10),
                padding: EdgeInsets.all(3),
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: Constant.primaryColor
                  ),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Row(
                  children: [
                    Icon(Icons.add, size: 15,),
                    Text("Tambah User", style: Constant.iPrimaryMedium12,),
                  ],
                ),
              ),
            )
          ],
          titleSpacing: 20,
          color: Colors.white,
          foregroundColor: Constant.primaryColor),
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
                  bodyUserRequest(),
                  bodyUserAktif(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
