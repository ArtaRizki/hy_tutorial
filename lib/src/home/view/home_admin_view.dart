import 'dart:developer';

import 'package:hy_tutorial/common/base/base_state.dart';
import 'package:hy_tutorial/common/component/custom_button.dart';
import 'package:hy_tutorial/common/component/custom_container.dart';
import 'package:hy_tutorial/common/component/custom_loading_indicator.dart';
import 'package:hy_tutorial/common/component/custom_navigator.dart';
import 'package:hy_tutorial/common/helper/constant.dart';
import 'package:hy_tutorial/src/admin/model/user_list_model.dart';
import 'package:hy_tutorial/src/admin/provider/user_manage_provider.dart';
import 'package:hy_tutorial/src/admin/view/user_detail_view.dart';
import 'package:hy_tutorial/src/admin/view/user_manage_view.dart';
import 'package:hy_tutorial/src/data/view/data_add_view.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:hy_tutorial/src/home/provider/home_provider.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../utils/utils.dart';
import '../../auth/provider/auth_provider.dart';
import '../../profile/provider/profile_provider.dart';
import '../../profile/view/profile_view.dart';
import '../../shaft/view/shaft_latest_view.dart';

class HomeAdminView extends StatefulWidget {
  final VoidCallback jumpToProfile;
  final VoidCallback jumpToManageUsers;
  const HomeAdminView({
    super.key,
    required this.jumpToProfile,
    required this.jumpToManageUsers,
  });

  @override
  State<HomeAdminView> createState() => _HomeAdminViewState();
}

class _HomeAdminViewState extends BaseState<HomeAdminView> {
  String? name;
  String? division;
  static const List<String> staticArray = [
    'Shaft',
    'Upper',
    'Clutch',
    'Turbine',
    // 'Result'
    // 'Shaft',
    // 'Upper',
    // 'Clutch',
    // 'Turbine'
  ];
  static const List<String> staticImage = [
    'assets/icons/admin/ic-shaft.png',
    'assets/icons/admin/ic-upper.png',
    'assets/icons/admin/ic-clutch.png',
    'assets/icons/admin/ic-turbine.png',
    // 'assets/icons/ic-shaft.png',
    // 'Shaft',
    // 'Upper',
    // 'Clutch',
    // 'Turbine'
  ];

  @override
  void initState() {
    getData();
    // final userManageP = context.read<UserManageProvider>();
    // if ((userManageP.pagingController.itemList ?? []).isEmpty) {
    //   userManageP.getUserList();
    // } else {
    //   userManageP.pagingController.dispose();
    //   userManageP.next = null;
    //   userManageP.getUserList();
    // }
    super.initState();
  }

  getData() async {
    Utils.showLoading();
    await context.read<ProfileProvider>().fetchProfile(withLoading: false);
    final data = context.read<ProfileProvider>().profileModel.Data;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final name2 = prefs.getString(Constant.kSetPrefName);
    final division2 = prefs.getString(Constant.kSetPrefDivision);
    name = data?.Name ?? name2;
    division = data?.Division ?? division2;
    setState(() {});
    // await context.read<AuthProvider>().getConfig(withLoading: false);
    await context.read<HomeProvider>().fetchUserList(withLoading: true);
    Utils.dismissLoading();
  }

  @override
  Widget build(BuildContext context) {
    final homeP = context.watch<HomeProvider>();
    // final userManageP = context.watch<UserManageProvider>();
    // final pagingC = context.watch<UserManageProvider>().pagingController;

    Widget headKonten() {
      return Container(
        color: Constant.primaryColor,
        height: 180,
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(20, 60, 20, 15),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name ?? "",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w500),
                    ),
                    Constant.xSizedBox8,
                    Text(
                      division ?? "",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                InkWell(
                    onTap: () async {
                      widget.jumpToProfile;
                    },
                    child: Image.asset('assets/icons/ic-user.png', scale: 4)),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            DottedLine(
                dashColor: Colors.white.withOpacity(0.7),
                lineThickness: 1,
                dashLength: 2),
          ],
        ),
      );
    }

    Widget bodyKontenActive() {
      return RefreshIndicator(
        onRefresh: () async {
          await getData();
          // userManageP.next = null;
          // if ((userManageP.pagingController.itemList ?? []).isEmpty) {
          //   userManageP.pagingController.refresh();
          // } else {
          //   userManageP.next = null;
          //   userManageP.pagingController.refresh();
          // }
        },
        child: Column(
          children: [
            (homeP.userListModel.Data ?? []).isEmpty
                ? Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: Center(
                        child: Text('Tidak ada data',
                            style: Constant.grayRegular13)),
                  )
                : Expanded(
                    child: ListView.separated(
                        itemCount: (homeP.userListModel.Data ?? []).length,
                        // pagingController: pagingC,
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                        shrinkWrap: true,
                        physics: ScrollPhysics(),
                        separatorBuilder: (context, index) {
                          return SizedBox();
                        },
                        itemBuilder: (context, index) {
                          final item = homeP.userListModel.Data?[index];
                          return InkWell(
                            onTap: () async {
                              await CusNav.nPush(
                                  context, UserDetailView(id: item?.Id ?? ''));
                              await context
                                  .read<HomeProvider>()
                                  .fetchUserList();
                              // pagingC.refresh();
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
                                            borderRadius:
                                                BorderRadius.circular(40),
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
                                        flex: 5,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item?.Name ?? 'Nama -',
                                              style: Constant.iPrimaryMedium8
                                                  .copyWith(
                                                      fontSize: 16,
                                                      color: Colors.black),
                                            ),
                                            // Text(
                                            //   item.Status ?? 'Status -',
                                            //   style: Constant.iPrimaryMedium8
                                            //       .copyWith(
                                            //       fontSize: 14,
                                            //       color: Colors.black),
                                            // ),
                                            Text(
                                              item?.Division ?? 'Divisi -',
                                              style: TextStyle(
                                                  color:
                                                      Constant.textHintColor2),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                          flex: 2,
                                          child: InkWell(
                                            onTap: () async {
                                              await Utils.showYesNoDialog(
                                                  context: context,
                                                  title: "Konfirmasi",
                                                  desc:
                                                      "Apakah Anda Yakin Menolak User Ini?",
                                                  yesCallback: () async {
                                                    CusNav.nPop(context);
                                                    final p = context.read<
                                                        UserManageProvider>();
                                                    handleTap(() async {
                                                      p.selectedStatus = '2';
                                                      await p.updateUser(
                                                        context,
                                                        id: item?.Id ?? '',
                                                        fromHome: true,
                                                      );

                                                      p.selectedStatus = null;
                                                      getData();
                                                    });
                                                  },
                                                  noCallback: () =>
                                                      CusNav.nPop(context));
                                            },
                                            child: Container(
                                              padding: EdgeInsets.all(7),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Constant.redColor),
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              child: Center(
                                                  child: Text(
                                                "Tolak",
                                                style: Constant.redMedium12,
                                              )),
                                            ),
                                          )),
                                      SizedBox(width: 10),
                                      Expanded(
                                          flex: 2,
                                          child: InkWell(
                                            onTap: () async {
                                              await Utils.showYesNoDialog(
                                                  context: context,
                                                  title: "Konfirmasi",
                                                  desc:
                                                      "Apakah Anda Yakin Menerima User Ini?",
                                                  yesCallback: () async {
                                                    CusNav.nPop(context);
                                                    final p = context.read<
                                                        UserManageProvider>();
                                                    handleTap(() async {
                                                      p.selectedStatus = '1';
                                                      await p.updateUser(
                                                        context,
                                                        id: item?.Id ?? '',
                                                        fromHome: true,
                                                      );
                                                      p.selectedStatus = null;
                                                      getData();
                                                    });
                                                  },
                                                  noCallback: () =>
                                                      CusNav.nPop(context));
                                            },
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 7),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color:
                                                        Constant.primaryColor),
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              child: Center(
                                                  child: Text(
                                                "Terima",
                                                style: Constant.iBlackMedium12,
                                              )),
                                            ),
                                          )),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 20),
                              ],
                            ),
                          );
                        }
                        // builderDelegate: PagedChildBuilderDelegate<UserListModelData>(
                        //   firstPageProgressIndicatorBuilder: (_) => Container(
                        //     color: Colors.white,
                        //     padding: EdgeInsets.only(top: 32),
                        //     child: CustomLoadingIndicator.buildIndicator(),
                        //   ),
                        //   firstPageErrorIndicatorBuilder: (_) => Padding(
                        //     padding: const EdgeInsets.only(top: 56),
                        //     child: Center(child: Text("Gagal mendapatkan data")),
                        //   ),
                        //   newPageProgressIndicatorBuilder: (_) => Container(
                        //     color: Colors.white,
                        //     child: CustomLoadingIndicator.buildIndicator(),
                        //   ),
                        //   newPageErrorIndicatorBuilder: (_) => Padding(
                        //     padding: const EdgeInsets.only(top: 56),
                        //     child: Center(child: Text("Gagal mendapatkan data")),
                        //   ),
                        //   noItemsFoundIndicatorBuilder: (_) => Padding(
                        //     padding: const EdgeInsets.only(top: 56),
                        //     child: Center(child: Text("Tidak ada data")),
                        //   ),
                        //   itemBuilder: (context, item, index) {
                        //     if (item.Status != 'active') return SizedBox();
                        //     return InkWell(
                        //       onTap: () async {
                        //         await CusNav.nPush(
                        //             context, UserDetailView(id: item.Id ?? ''));
                        //         pagingC.refresh();
                        //       },
                        //       child: Column(
                        //         children: [
                        //           CustomContainer.mainCard(
                        //             isShadow: false,
                        //             child: Row(
                        //               children: [
                        //                 Expanded(
                        //                   flex: 2,
                        //                   child: Container(
                        //                     height: 50,
                        //                     width: 50,
                        //                     decoration: BoxDecoration(
                        //                       borderRadius: BorderRadius.circular(40),
                        //                       color: Colors.white,
                        //                       image: DecorationImage(
                        //                         image: AssetImage(
                        //                           'assets/icons/ic-user-black.png',
                        //                         ),
                        //                         scale: 3,
                        //                       ),
                        //                     ),
                        //                   ),
                        //                 ),
                        //                 SizedBox(width: 10),
                        //                 Expanded(
                        //                   flex: 5,
                        //                   child: Column(
                        //                     crossAxisAlignment:
                        //                         CrossAxisAlignment.start,
                        //                     children: [
                        //                       Text(
                        //                         item.Name ?? 'Nama -',
                        //                         style: Constant.iPrimaryMedium8
                        //                             .copyWith(
                        //                                 fontSize: 16,
                        //                                 color: Colors.black),
                        //                       ),
                        //                       // Text(
                        //                       //   item.Status ?? 'Status -',
                        //                       //   style: Constant.iPrimaryMedium8
                        //                       //       .copyWith(
                        //                       //       fontSize: 14,
                        //                       //       color: Colors.black),
                        //                       // ),
                        //                       Text(
                        //                         item.Division ?? 'Divisi -',
                        //                         style: TextStyle(
                        //                             color: Constant.textHintColor2),
                        //                       ),
                        //                     ],
                        //                   ),
                        //                 ),
                        //                 Expanded(
                        //                     flex: 2,
                        //                     child: InkWell(
                        //                       onTap: () async {},
                        //                       child: Container(
                        //                         padding: EdgeInsets.all(7),
                        //                         decoration: BoxDecoration(
                        //                           border: Border.all(
                        //                               color: Constant.redColor),
                        //                           borderRadius:
                        //                               BorderRadius.circular(5),
                        //                         ),
                        //                         child: Center(
                        //                             child: Text(
                        //                           "Tolak",
                        //                           style: Constant.redMedium12,
                        //                         )),
                        //                       ),
                        //                     )),
                        //                 SizedBox(width: 10),
                        //                 Expanded(
                        //                     flex: 2,
                        //                     child: InkWell(
                        //                       onTap: () async {},
                        //                       child: Container(
                        //                         padding:
                        //                             EdgeInsets.symmetric(vertical: 7),
                        //                         decoration: BoxDecoration(
                        //                           border: Border.all(
                        //                               color: Constant.primaryColor),
                        //                           borderRadius:
                        //                               BorderRadius.circular(5),
                        //                         ),
                        //                         child: Center(
                        //                             child: Text(
                        //                           "Terima",
                        //                           style: Constant.iBlackMedium12,
                        //                         )),
                        //                       ),
                        //                     )),
                        //               ],
                        //             ),
                        //           ),
                        //           SizedBox(
                        //             height: 20,
                        //           ),
                        //         ],
                        //       ),
                        //     );
                        //   },
                        // ),
                        ),
                  ),
          ],
        ),
      );
    }

    Widget bodyKonten() {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 20,
            ),
            Text(
              "Menu",
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.w500),
            ),
            ListView.separated(
              shrinkWrap: true,
              // scrollDirection: Axis.horizontal,
              physics: ScrollPhysics(),
              itemBuilder: (context, index) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    staticArray.length,
                    (indexx) => InkWell(
                      onTap: () {
                        CusNav.nPush(context, ShaftLatestView());
                      },
                      child: Column(
                        children: [
                          Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(40),
                                color: Colors.lightBlueAccent.shade200
                                    .withOpacity(0.3),
                                image: DecorationImage(
                                    image: AssetImage(staticImage[indexx]),
                                    scale: 3)),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            staticArray[indexx],
                            style:
                                Constant.iPrimaryMedium8.copyWith(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return SizedBox();
              },
              itemCount: 1,
            ),
            SizedBox(
              height: 15,
            ),
            Divider(
              thickness: 0.5,
              color: Colors.grey.withOpacity(0.5),
            ),
            SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Register Request",
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                ),
                InkWell(
                  onTap: () async {
                    widget.jumpToManageUsers();
                  },
                  child: Row(
                    children: [
                      Text(
                        "Selengkapnya",
                        style: TextStyle(
                            color: Constant.primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                      ),
                      Icon(
                        Icons.arrow_forward,
                        color: Constant.primaryColor,
                      )
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 15,
            ),
            Container(height: 300, child: bodyKontenActive()),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: () => getData(),
        child: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                headKonten(),
                SizedBox(height: 5),
                bodyKonten(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
