import 'package:hy_tutorial/common/base/base_state.dart';
import 'package:hy_tutorial/common/component/custom_container.dart';
import 'package:hy_tutorial/common/component/custom_navigator.dart';
import 'package:hy_tutorial/common/component/skeleton.dart';
import 'package:hy_tutorial/common/helper/constant.dart';
import 'package:hy_tutorial/common/helper/xenolog.dart';
import 'package:hy_tutorial/src/admin/model/user_list_model.dart';
import 'package:hy_tutorial/src/admin/provider/user_manage_provider.dart';
import 'package:hy_tutorial/src/admin/view/user_detail_view.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:hy_tutorial/src/home/provider/home_provider.dart';
import 'package:hy_tutorial/src/profile/model/profile_model.dart';
import 'package:hy_tutorial/src/profile/provider/profile_provider.dart';
import 'package:provider/provider.dart';
import '../../../utils/utils.dart';
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
  @override
  void initState() {
    context.read<HomeProvider>().getData(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final homeP = context.watch<HomeProvider>();
    final profile = context.watch<ProfileProvider>().profileModel.Data;
    final userList = homeP.userListModel.Data;
    final staticImage = homeP.staticImage;
    final staticArray = homeP.staticArray;

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
                    Skeleton<ProfileModelData?>(
                      value: profile,
                      width: 75,
                      height: 24,
                      child: Text(
                        profile?.Name ?? '',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    Constant.xSizedBox8,
                    Skeleton<ProfileModelData?>(
                      value: profile,
                      width: 75,
                      height: 24,
                      child: Text(
                        profile?.Division ?? '',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                InkWell(
                    onTap: () async {
                      XenoLog("1",
                              logType: XenoLogType.Database,
                              projectName: '',
                              version: '',
                              webHookURL: '',
                              emailAddress: '')
                          .showLogDialog(context: context);
                    },
                    child: Image.asset('assets/icons/ic-user.png', scale: 4)),
              ],
            ),
            SizedBox(height: 20),
            DottedLine(
              dashColor: Colors.white.withOpacity(0.7),
              lineThickness: 1,
              dashLength: 2,
            ),
          ],
        ),
      );
    }

    Widget itemShimmer() {
      return Column(
        children: [
          CustomContainer.mainCard(
            isShadow: false,
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Skeleton<List<UserListModelData?>?>(
                    value: userList,
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
                ),
                SizedBox(width: 10),
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Skeleton<List<UserListModelData?>?>(
                        value: userList,
                        child: Text(
                          'Namaaaaaaaaa',
                          style: Constant.iPrimaryMedium8
                              .copyWith(fontSize: 16, color: Colors.black),
                        ),
                      ),
                      Skeleton<List<UserListModelData?>?>(
                        value: userList,
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
                Expanded(
                  flex: 2,
                  child: Skeleton<List<UserListModelData?>?>(
                    value: userList,
                    child: Container(
                      padding: EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        border: Border.all(color: Constant.redColor),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Center(
                        child: Text(
                          "Tolak",
                          style: Constant.redMedium12,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: Skeleton<List<UserListModelData?>?>(
                    value: userList,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 7),
                      decoration: BoxDecoration(
                        border: Border.all(color: Constant.primaryColor),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Center(
                        child: Text(
                          "Terima",
                          style: Constant.iBlackMedium12,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
        ],
      );
    }

    Widget itemList(int index) {
      final item = userList?[index];
      return InkWell(
        onTap: () async {
          await CusNav.nPush(context, UserDetailView(id: item?.Id ?? ''));
          await context.read<HomeProvider>().fetchUserList();
        },
        child: Column(
          children: [
            CustomContainer.mainCard(
              isShadow: false,
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Skeleton<List<UserListModelData?>?>(
                      value: userList,
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
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Skeleton<List<UserListModelData?>?>(
                          value: userList,
                          child: Text(
                            item?.Name ?? 'Nama -',
                            style: Constant.iPrimaryMedium8
                                .copyWith(fontSize: 16, color: Colors.black),
                          ),
                        ),
                        Skeleton<List<UserListModelData?>?>(
                          value: userList,
                          child: Text(
                            item?.Division ?? 'Divisi -',
                            style: TextStyle(
                              color: Constant.textHintColor2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Skeleton<List<UserListModelData?>?>(
                      value: userList,
                      child: InkWell(
                        onTap: () async {
                          await Utils.showYesNoDialog(
                              context: context,
                              title: "Konfirmasi",
                              desc: "Apakah Anda Yakin Menolak User Ini?",
                              yesCallback: () async {
                                CusNav.nPop(context);
                                final p = context.read<UserManageProvider>();
                                handleTap(() async {
                                  p.selectedStatus = '2';
                                  await p.updateUser(
                                    context,
                                    id: item?.Id ?? '',
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
                          padding: EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            border: Border.all(color: Constant.redColor),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Center(
                            child: Text(
                              "Tolak",
                              style: Constant.redMedium12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: Skeleton<List<UserListModelData?>?>(
                      value: userList,
                      child: InkWell(
                        onTap: () async {
                          await Utils.showYesNoDialog(
                              context: context,
                              title: "Konfirmasi",
                              desc: "Apakah Anda Yakin Menerima User Ini?",
                              yesCallback: () async {
                                CusNav.nPop(context);
                                final p = context.read<UserManageProvider>();
                                handleTap(() async {
                                  p.selectedStatus = '1';
                                  await p.updateUser(
                                    context,
                                    id: item?.Id ?? '',
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
                          padding: EdgeInsets.symmetric(vertical: 7),
                          decoration: BoxDecoration(
                            border: Border.all(color: Constant.primaryColor),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Center(
                            child: Text(
                              "Terima",
                              style: Constant.iBlackMedium12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      );
    }

    Widget registerRequest() {
      return RefreshIndicator(
        onRefresh: () async =>
            await await context.read<HomeProvider>().getData(context),
        child: userList != null && userList.isEmpty
            ? Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Center(
                    child: Text('Data tidak ditemukan',
                        style: Constant.grayRegular13)),
              )
            : ListView.separated(
                itemCount:
                    (userList ?? []).isEmpty ? 1 : (userList ?? []).length,
                padding: EdgeInsets.only(bottom: 20),
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                separatorBuilder: (context, index) => SizedBox(),
                itemBuilder: (context, index) {
                  if ((userList ?? []).isEmpty) return itemShimmer();
                  return itemList(index);
                },
              ),
      );
    }

    Widget bodyKonten() {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Text(
                "Menu",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              ListView.separated(
                shrinkWrap: true,
                physics: ScrollPhysics(),
                separatorBuilder: (_, __) => SizedBox(),
                itemCount: 1,
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
                              style: Constant.iPrimaryMedium8
                                  .copyWith(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 15),
              Divider(
                thickness: 0.5,
                color: Colors.grey.withOpacity(0.5),
              ),
              SizedBox(height: 15),
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
              SizedBox(height: 15),
              registerRequest(),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: () async =>
            await context.read<HomeProvider>().getData(context),
        child: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            child: Column(children: [headKonten(), bodyKonten()]),
          ),
        ),
      ),
    );
  }
}
