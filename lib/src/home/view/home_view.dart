import 'package:hy_tutorial/common/base/base_state.dart';
import 'package:hy_tutorial/common/component/custom_container.dart';
import 'package:hy_tutorial/common/component/custom_navigator.dart';
import 'package:hy_tutorial/common/component/skeleton.dart';
import 'package:hy_tutorial/common/helper/constant.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:hy_tutorial/common/helper/xenolog.dart';
import 'package:hy_tutorial/src/home/provider/home_provider.dart';
import 'package:hy_tutorial/src/profile/model/profile_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../utils/utils.dart';
import '../../profile/provider/profile_provider.dart';
import '../../shaft/view/shaft_latest_view.dart';

class HomeView extends StatefulWidget {
  final VoidCallback jumpToProfile;
  const HomeView({super.key, required this.jumpToProfile});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends BaseState<HomeView> {
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

    Widget bodyKonten() {
      return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
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
              SizedBox(height: 10),
              Column(
                children: List.generate(
                  staticArray.length,
                  (indexx) => InkWell(
                    onTap: () => CusNav.nPush(context, ShaftLatestView()),
                    child: Column(
                      children: [
                        CustomContainer.mainCard(
                          isShadow: false,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(40),
                                      color: Colors.lightBlueAccent.shade200
                                          .withOpacity(0.3),
                                      image: DecorationImage(
                                          image:
                                              AssetImage(staticImage[indexx]),
                                          scale: 3)),
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                flex: 8,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      staticArray[indexx],
                                      style: Constant.iPrimaryMedium8
                                          .copyWith(fontSize: 16),
                                    ),
                                    Text("Cek laporan mengenai " +
                                        staticArray[indexx]),
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
                              )
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: () async =>
            await context.read<HomeProvider>().getData(context),
        child: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [headKonten(), bodyKonten()],
            ),
          ),
        ),
      ),
    );
  }
}
