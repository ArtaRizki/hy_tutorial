import 'dart:async';

import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:hy_tutorial/common/component/custom_appbar.dart';
import 'package:hy_tutorial/common/component/custom_button.dart';
import 'package:hy_tutorial/common/component/custom_container.dart';
import 'package:hy_tutorial/common/component/custom_date_picker.dart';
import 'package:hy_tutorial/common/component/custom_navigator.dart';
import 'package:hy_tutorial/common/component/custom_textField.dart';
import 'package:hy_tutorial/common/component/skeleton.dart';
import 'package:hy_tutorial/common/helper/constant.dart';
import 'package:hy_tutorial/common/helper/xenolog.dart';
import 'package:hy_tutorial/generated/assets.dart';
import 'package:hy_tutorial/src/data/view/new_data_add_view.dart';
import 'package:hy_tutorial/src/home/provider/home_provider.dart';
import 'package:hy_tutorial/src/profile/model/profile_model.dart';
import 'package:hy_tutorial/src/profile/provider/profile_provider.dart';
import 'package:hy_tutorial/src/turbine/provider/turbine_provider.dart';
import 'package:provider/provider.dart';

class NewHomeView extends StatefulWidget {
  const NewHomeView({super.key});

  @override
  State<NewHomeView> createState() => _NewHomeViewState();
}

class _NewHomeViewState extends State<NewHomeView>
    with TickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final turbineP = context.watch<TurbineProvider>();
    final pagingC = context.watch<TurbineProvider>().pagingController;
    final profile = context.watch<ProfileProvider>().profileModel.Data;
    final homeP = context.watch<HomeProvider>();

    Widget headKonten() {
      return Container(
        decoration: BoxDecoration(
            image: DecorationImage(
          image: AssetImage(Assets.imagesImgHomeTop),
          fit: BoxFit.contain,
        )),
        height: 150,
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(20, 35, 20, 15),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.3),
                  child: Icon(
                    Icons.notifications_outlined,
                    color: Colors.white,
                  ),
                ),
                SizedBox(
                  width: 15,
                ),
                InkWell(
                  onTap: () {
                    CusNav.nPush(context, NewDataAddView());
                  },
                    child: Image.asset('assets/icons/ic-user.png', scale: 5.2)),
              ],
            ),
          ],
        ),
      );
    }

    Widget search() => CustomTextField.borderTextField(
          controller: turbineP.turbineSearchC,
          required: false,
          hintText: "Cari Laporan",
          hintColor: Constant.textHintColor2,
          prefixIcon: Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
            child: Image.asset(
              'assets/icons/ic-search.png',
              color: Colors.black.withOpacity(0.5),
              width: 5,
              height: 5,
            ),
          ),
          onChange: (val) {
            if (turbineP.searchOnStoppedTyping != null) {
              turbineP.searchOnStoppedTyping!.cancel();
            }
            turbineP.searchOnStoppedTyping = Timer(turbineP.duration, () async {
              turbineP.next = null;
              pagingC.refresh();
            });
          },
        );
    Widget filterAllWidget() => StatefulBuilder(
          builder: (BuildContext context, StateSetter sheetState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Filter',
                        style: Constant.iPrimaryMedium14.copyWith(
                            fontSize: 18, fontWeight: FontWeight.w500)),
                    InkWell(
                      onTap: () async {
                        await context.read<TurbineProvider>().clearData();
                        sheetState(() {});
                        setState(() {});
                      },
                      child: Text(
                        "Reset",
                        style: Constant.primaryBold15,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              flex: 5,
                              child: CustomTextField.borderTextField(
                                controller: turbineP.startDateC,
                                labelText: "Start Date",
                                hintText: "Start Date",
                                required: false,
                                readOnly: true,
                                onTap: () async {
                                  await turbineP.setStartDate(
                                      await CustomDatePicker.pickDate(
                                          context, DateTime.now()));
                                  FocusManager.instance.primaryFocus?.unfocus();
                                },
                                suffixIcon: Icon(Icons.calendar_month),
                                suffixIconColor: Constant.textHintColor,
                              )),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            flex: 5,
                            child: CustomTextField.borderTextField(
                              controller: turbineP.endDateC,
                              labelText: "End Date",
                              hintText: "End Date",
                              required: false,
                              readOnly: true,
                              onTap: () async {
                                await turbineP.setEndDate(
                                    await CustomDatePicker.pickDate(
                                        context, DateTime.now()));
                                FocusManager.instance.primaryFocus?.unfocus();
                              },
                              suffixIcon: Icon(Icons.calendar_month),
                              suffixIconColor: Constant.textHintColor,
                            ),
                          ),
                        ],
                      ),
                      Constant.xSizedBox16,
                      // Text('Sort Order'),
                      // Wrap(
                      //   children: [
                      //     FilterChip(
                      //       selectedColor: Constant.primaryColor,
                      //       backgroundColor: Colors.white,
                      //       showCheckmark: false,
                      //       labelStyle: TextStyle(
                      //           color: turbineP.ascending
                      //               ? Colors.white
                      //               : Constant.primaryColor),
                      //       side: BorderSide(color: Constant.primaryColor),
                      //       label: Text('Ascending'),
                      //       selected: turbineP.ascending,
                      //       onSelected: (value) {
                      //         context.read<TurbineProvider>().ascending = true;
                      //         context.read<TurbineProvider>().descending = false;
                      //         sheetState(() {});
                      //       },
                      //     ),
                      //     Constant.xSizedBox16,
                      //     FilterChip(
                      //       selectedColor: Constant.primaryColor,
                      //       backgroundColor: Colors.white,
                      //       showCheckmark: false,
                      //       labelStyle: TextStyle(
                      //           color: turbineP.descending
                      //               ? Colors.white
                      //               : Constant.primaryColor),
                      //       side: BorderSide(color: Constant.primaryColor),
                      //       label: Text('Descending'),
                      //       selected: turbineP.descending,
                      //       onSelected: (value) {
                      //         context.read<TurbineProvider>().descending = true;
                      //         context.read<TurbineProvider>().ascending = false;
                      //         sheetState(() {});
                      //       },
                      //     ),
                      // ],
                      // ),
                      // Constant.xSizedBox16,
                      // Text('Sort By'),
                      // Wrap(
                      //   children: [
                      //     FilterChip(
                      //       selectedColor: Constant.primaryColor,
                      //       backgroundColor: Colors.white,
                      //       showCheckmark: false,
                      //       labelStyle: TextStyle(
                      //           color: turbineP.towerName
                      //               ? Colors.white
                      //               : Constant.primaryColor),
                      //       side: BorderSide(color: Constant.primaryColor),
                      //       label: Text('Tower Name'),
                      //       selected: turbineP.towerName,
                      //       onSelected: (value) {
                      //         context.read<TurbineProvider>().towerName = true;
                      //         context.read<TurbineProvider>().createdAt = false;
                      //         sheetState(() {});
                      //       },
                      //     ),
                      //     Constant.xSizedBox16,
                      //     FilterChip(
                      //       selectedColor: Constant.primaryColor,
                      //       backgroundColor: Colors.white,
                      //       showCheckmark: false,
                      //       labelStyle: TextStyle(
                      //           color: turbineP.createdAt
                      //               ? Colors.white
                      //               : Constant.primaryColor),
                      //       side: BorderSide(color: Constant.primaryColor),
                      //       label: Text('Created At'),
                      //       selected: turbineP.createdAt,
                      //       onSelected: (value) {
                      //         context.read<TurbineProvider>().createdAt = true;
                      //         context.read<TurbineProvider>().towerName = false;
                      //         sheetState(() {});
                      //       },
                      //     ),
                      //   ],
                      // ),
                      // Constant.xSizedBox16,
                    ],
                  ),
                ),
                Constant.xSizedBox16,
                CustomButton.mainButton(
                  "View Result",
                  () {
                    Navigator.pop(context);
                    turbineP.next = null;
                    pagingC.refresh();
                    // turbineP.clearDate();
                  },
                ),
              ],
            );
          },
        );
    Widget toggleTab() {
      return DefaultTabController(
        length: 2,
        child: TabBar(
          labelPadding: EdgeInsets.all(8),
          isScrollable: true,
          controller: tabController,
          unselectedLabelColor: Colors.black,
          labelColor: Constant.primaryColor,
          indicatorColor: Constant.primaryColor,
          labelStyle: Constant.primaryTextStyle
              .copyWith(fontWeight: FontWeight.bold, fontSize: 15),
          unselectedLabelStyle:
              Constant.primaryTextStyle.copyWith(fontSize: 15),
          tabs: [
            Text("Terakhir Dilihat"),
            Text("Riwayat Pencarian"),
          ],
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 200,
            width: double.infinity,
            child: Stack(
              children: [
                headKonten(),
                Positioned(
                  bottom: 15,
                  right: 0,
                  left: 0,
                  child: CustomContainer.mainCard(
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              Image.asset(Assets.iconsIcAddData),
                              SizedBox(
                                height: 10,
                              ),
                              Text("Add Data"),
                            ],
                          ),
                          Container(
                            width: 1,
                            height: 45,
                            color: Colors.grey.withOpacity(0.5),
                          ),
                          Column(
                            children: [
                              Image.asset(Assets.iconsIcDataTerakhir),
                              SizedBox(
                                height: 10,
                              ),
                              Text("Data Terakhir"),
                            ],
                          ),
                        ],
                      )),
                )
              ],
            ),
          ),
          Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: CustomContainer.mainCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Laporan",
                    style: Constant.blackBold16
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(flex: 8, child: search()),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        flex: 2,
                        child: InkWell(
                          onTap: () async {
                            CustomContainer.showModalBottomScroll(
                                initialChildSize: 0.45,
                                context: context,
                                child: filterAllWidget());
                          },
                          child: Container(
                            height: 50,
                            width: 50,
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1,
                                color: Colors.grey.withOpacity(0.5),
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.filter_alt_outlined, size: 25),
                          ),
                        ),
                      ),
                    ],
                  ),
                  toggleTab(),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
