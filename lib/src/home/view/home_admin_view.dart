import 'package:hy_tutorial/common/base/base_state.dart';
import 'package:hy_tutorial/common/component/custom_button.dart';
import 'package:hy_tutorial/common/component/custom_container.dart';
import 'package:hy_tutorial/common/component/custom_loading_indicator.dart';
import 'package:hy_tutorial/common/component/custom_navigator.dart';
import 'package:hy_tutorial/common/helper/constant.dart';
import 'package:hy_tutorial/src/admin/model/user_list_model.dart';
import 'package:hy_tutorial/src/admin/provider/user_manage_provider.dart';
import 'package:hy_tutorial/src/admin/view/user_detail_view.dart';
import 'package:hy_tutorial/src/data/view/data_add_view.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:hy_tutorial/src/home/provider/home_provider.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../auth/provider/auth_provider.dart';
import '../../shaft/view/shaft_latest_view.dart';

class HomeAdminView extends StatefulWidget {
  const HomeAdminView({super.key});

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
    final userManageP = context.read<UserManageProvider>();
    if ((userManageP.pagingController.itemList ?? []).isEmpty) {
      userManageP.getUserList();
    } else {
      userManageP.pagingController.dispose();
      userManageP.next = null;
      userManageP.getUserList();
    }
    super.initState();
  }

  getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    name = prefs.getString(Constant.kSetPrefName);
    division = prefs.getString(Constant.kSetPrefRoles);
    setState(() {});
    await context.read<AuthProvider>().getConfig();
    await context.read<HomeProvider>().fetchUserList();
  }

  @override
  Widget build(BuildContext context) {
    final userManageP = context.watch<UserManageProvider>();
    final pagingC = context.watch<UserManageProvider>().pagingController;

    Widget headKonten() {
      return Container(
        color: Constant.primaryColor,
        height: 300,
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
                      name ?? "Alifano Reinanda",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w500),
                    ),
                    Constant.xSizedBox8,
                    Text(
                      division ?? "Turbine Engineer",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                InkWell(
                    onTap: () async {},
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
            SizedBox(
              height: 20,
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(bottom: 10),
                padding: EdgeInsets.fromLTRB(15, 15, 15, 10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Constant.secondaryColor),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 6,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Overall Turbine Status",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                "8/10",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
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
                            onTap: () => CusNav.nPush(context, DataAddView()),
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
                                      "Add Data",
                                      style: TextStyle(
                                          color: Constant.primaryColor,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Image.asset(
                                      'assets/icons/ic-inbox.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ],
                                )),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Pencapaian",
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        Text(
                          "80%",
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    LinearProgressIndicator(
                      value: 0.8,
                      color: Colors.lightBlueAccent,
                      backgroundColor: Colors.grey.shade400,
                    ),
                  ],
                ),
              ),
            )
          ],
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
                                  flex: 5,
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
                                      // Text(
                                      //   item.Status ?? 'Status -',
                                      //   style: Constant.iPrimaryMedium8
                                      //       .copyWith(
                                      //       fontSize: 14,
                                      //       color: Colors.black),
                                      // ),
                                      Text(
                                        item.Division ?? 'Divisi -',
                                        style: TextStyle(
                                            color: Constant.textHintColor2),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                    flex: 2,
                                    child: InkWell(
                                      onTap: () async {},
                                      child: Container(
                                        padding: EdgeInsets.all(7),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Constant.redColor
                                          ),
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                        child: Center(child: Text("Tolak", style: Constant.redMedium12,)),
                                      ),
                                    )),
                                SizedBox(width: 10),
                                Expanded(
                                    flex: 2,
                                    child: InkWell(
                                      onTap: () async {},
                                      child: Container(
                                        padding: EdgeInsets.symmetric(vertical: 7),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Constant.primaryColor
                                          ),
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                        child: Center(child: Text("Terima", style: Constant.iBlackMedium12,)),
                                      ),
                                    )),
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
                            CusNav.nPush(
                                context,
                                ShaftLatestView(
                                    index: indexx == 1
                                        ? 2
                                        : indexx == 3
                                        ? 1
                                        : 0));
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
                                style: Constant.iPrimaryMedium8
                                    .copyWith(fontSize: 16),
                              ),
                            ],
                          ),
                          // Column(
                          //   children: [
                          //     CustomContainer.mainCard(
                          //       isShadow: false,
                          //       child: Row(
                          //         children: [
                          //           Expanded(
                          //             flex: 2,
                          //             child: Container(
                          //               height: 50,
                          //               width: 50,
                          //               decoration: BoxDecoration(
                          //                   borderRadius:
                          //                   BorderRadius.circular(40),
                          //                   color: Colors
                          //                       .lightBlueAccent.shade200
                          //                       .withOpacity(0.3),
                          //                   image: DecorationImage(
                          //                       image: AssetImage(
                          //                           staticImage[indexx]),
                          //                       scale: 3)),
                          //             ),
                          //           ),
                          //           SizedBox(
                          //             width: 10,
                          //           ),
                          //           Expanded(
                          //             flex: 8,
                          //             child: Column(
                          //               crossAxisAlignment:
                          //               CrossAxisAlignment.start,
                          //               children: [
                          //                 Text(
                          //                   staticArray[indexx],
                          //                   style: Constant.iPrimaryMedium8
                          //                       .copyWith(fontSize: 16),
                          //                 ),
                          //                 Text("Cek laporan mengenai " +
                          //                     staticArray[indexx]),
                          //               ],
                          //             ),
                          //           ),
                          //           Expanded(
                          //               flex: 1,
                          //               child: Icon(
                          //                 Icons.arrow_forward_ios,
                          //                 color: Colors.grey,
                          //                 size: 20,
                          //               ))
                          //         ],
                          //       ),
                          //     ),
                          //     SizedBox(
                          //       height: 20,
                          //     ),
                          //   ],
                          // ),
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return SizedBox();
                  },
                  itemCount: 1),
              SizedBox(height: 15,),
              Divider(
                thickness: 0.5,
                color: Colors.grey.withOpacity(0.5),
              ),
              SizedBox(height: 15,),
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
                  Row(
                    children: [
                      Text(
                        "Selengkapnya",
                        style: TextStyle(
                            color: Constant.primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                      ),
                      Icon(Icons.arrow_forward, color: Constant.primaryColor,)
                    ],
                  ),
                ],
              ),
              SizedBox(height: 15,),
              Container(
                  height: 300,
                  child: bodyKontenActive()),
            ],
          ));
    }


    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<AuthProvider>().getConfig();
        },
        child: SingleChildScrollView(
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
    );
  }
}
