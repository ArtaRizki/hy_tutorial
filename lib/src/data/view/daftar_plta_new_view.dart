import 'dart:async';
import 'dart:developer';

import 'package:hy_tutorial/common/base/base_state.dart';
import 'package:hy_tutorial/common/component/custom_container.dart';
import 'package:hy_tutorial/common/component/custom_navigator.dart';
import 'package:hy_tutorial/common/component/custom_textField.dart';
import 'package:hy_tutorial/common/component/skeleton.dart';
import 'package:hy_tutorial/common/helper/constant.dart';
import 'package:hy_tutorial/generated/assets.dart';
import 'package:hy_tutorial/src/admin/provider/user_manage_provider.dart';
import 'package:flutter/material.dart';
import 'package:hy_tutorial/src/data/view/tambah_plta_new_view.dart';
import 'package:hy_tutorial/src/plta/model/plta_list_model.dart';
import 'package:hy_tutorial/src/plta/provider/plta_provider.dart';
import 'package:hy_tutorial/src/plta/view/plta_add_view.dart';
import 'package:hy_tutorial/src/shaft/view/shaft_detail_view.dart';
import 'package:hy_tutorial/src/turbine/model/turbine_model.dart';
import 'package:hy_tutorial/src/turbine/provider/turbine_provider.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../../../common/component/custom_appbar.dart';

class DaftarPLTANewView extends StatefulWidget {
  const DaftarPLTANewView({super.key});

  @override
  State<DaftarPLTANewView> createState() => _DaftarPLTANewViewState();
}

class _DaftarPLTANewViewState extends BaseState<DaftarPLTANewView>
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
    final pagingC = context.watch<UserManageProvider>().pagingController;
    final pagingC2 = context.watch<TurbineProvider>().pagingController2;

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
                Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text(turbineP.startDate == null
                      ? 'Pilih Tanggal Awal'
                      : turbineP.endDate == null
                          ? 'Pilih Tanggal Akhir'
                          : 'Silahkan Konfirmasi'),
                ),
                SfDateRangePicker(
                  monthCellStyle: DateRangePickerMonthCellStyle(),
                  headerHeight: 40,
                  headerStyle: DateRangePickerHeaderStyle(
                    backgroundColor: Constant.primaryColor,
                    textStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  controller: turbineP.dateRangePickerController,
                  showActionButtons: true,
                  cancelText: 'Batal',
                  confirmText: 'Konfirmasi',
                  view: DateRangePickerView.month,
                  backgroundColor: Colors.white,
                  monthViewSettings: DateRangePickerMonthViewSettings(
                      showTrailingAndLeadingDates: true,
                      dayFormat: 'E',
                      viewHeaderStyle: DateRangePickerViewHeaderStyle(
                          backgroundColor: Colors.white,
                          textStyle: TextStyle(fontWeight: FontWeight.bold)),
                      weekNumberStyle: DateRangePickerWeekNumberStyle(
                          backgroundColor: Colors.white)),
                  initialSelectedRange:
                      PickerDateRange(turbineP.startDate, turbineP.endDate),
                  onCancel: () async {
                    await turbineP.setStartDate(null);
                    await turbineP.setEndDate(null);
                    await turbineP.clearData();
                    sheetState(() {});
                    setState(() {});
                  },
                  onSubmit: (p0) {
                    CusNav.nPop(context);
                    turbineP.next = null;
                    pagingC.refresh();
                  },
                  onSelectionChanged:
                      (dateRangePickerSelectionChangedArgs) async {
                    if (dateRangePickerSelectionChangedArgs.value
                        is PickerDateRange) {
                      await turbineP.setStartDate(
                          dateRangePickerSelectionChangedArgs.value.startDate);
                      await turbineP.setEndDate(
                          dateRangePickerSelectionChangedArgs.value.endDate);
                      sheetState(() {});
                      setState(() {});
                    }
                  },
                  selectionMode: DateRangePickerSelectionMode.range,
                ),
                // Constant.xSizedBox16,
                // SizedBox(
                //   height: 50,
                //   child: CustomButton.mainButton(
                //     "View Result",
                //     () {
                //       Navigator.pop(context);
                //       turbineP.next2 = null;
                //       pagingC2.refresh();
                //     },
                //     textStyle: TextStyle(fontSize: 14, color: Colors.white),
                //   ),
                // ),
              ],
            );
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

    Widget itemListShimmer2() {
      return Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(width: 1, color: Colors.grey.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Skeleton<bool>(
                  width: 24,
                  height: 10,
                  value: turbineP.isFetching2 == true
                      ? null
                      : turbineP.isFetching2,
                  child: Text('', style: Constant.blackRegular12),
                ),
                Skeleton<bool>(
                  width: 48,
                  height: 10,
                  value: turbineP.isFetching2 == true
                      ? null
                      : turbineP.isFetching2,
                  child: Text('', style: Constant.blackRegular12),
                ),
              ],
            ),
            SizedBox(height: 5),
            Divider(
              thickness: 0.5,
              color: Colors.grey.withOpacity(0.5),
            ),
            SizedBox(height: 5),
            Row(
              children: [
                Skeleton<bool>(
                    width: 45,
                    height: 45,
                    value: turbineP.isFetching2 == true
                        ? null
                        : turbineP.isFetching2,
                    child: Image.asset(Assets.iconsIcFile, scale: 3.5)),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Constant.xSizedBox4,
                    Skeleton<bool>(
                      width: 175,
                      height: 17,
                      value: turbineP.isFetching2 == true
                          ? null
                          : turbineP.isFetching2,
                      child: Text(
                        '',
                        style: Constant.blackBold15,
                      ),
                    ),
                    SizedBox(height: 10),
                    Skeleton<bool>(
                      width: 100,
                      height: 12,
                      value: turbineP.isFetching2 == true
                          ? null
                          : turbineP.isFetching2,
                      child: Text("-", style: Constant.grayRegular13),
                    ),
                  ],
                ),
              ],
            ),
            Constant.xSizedBox8,
          ],
        ),
      );
    }

    Widget listShimmer2() {
      return Column(
        children: [
          itemListShimmer2(),
          SizedBox(height: 20),
          itemListShimmer2(),
          SizedBox(height: 20),
          itemListShimmer2(),
          SizedBox(height: 20),
        ],
      );
    }

    Widget kontenPLTA() {
      return Column(
        children: List.generate(7, (index) {
          return Column(
            children: [
              SizedBox(height: 10,),
              CustomContainer.mainCard(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(Assets.iconsIcPltaList, scale: 4),
                      SizedBox(width: 5,),
                      Expanded(
                        flex: 6,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "PLTA 1 Bojonegoro",
                              style: Constant.iBlackMedium14,
                            ),
                            Text(
                              "Unit 1",
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


    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar.appBar(context, "Daftar PLTA",
          isLeading: false,
          action: [
            Container(
              margin: EdgeInsets.only(right: 10),
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
              decoration: BoxDecoration(
                border: Border.all(width: 1, color: Constant.primaryColor),
                borderRadius: BorderRadius.circular(7),
              ),
              child: InkWell(
                onTap: (){
                  CusNav.nPush(context, TambahPLTANewView());
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      Icons.add,
                      size: 15,
                    ),
                    Text(
                      "Tambah PLTA",
                      style: Constant.iPrimaryMedium12,
                    ),
                  ],
                ),
              ),
            )
          ],
          titleSpacing: 20,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(85), // Ukuran tinggi
            child: Column(
              children: [
                Container(
                  child: headKonten(),
                ),
                Divider(
                  thickness: 0.5,
                  color: Colors.grey.withOpacity(0.5),
                ),
              ],
            ),
          ),
          color: Colors.white,
          foregroundColor: Constant.primaryColor),
      body: SingleChildScrollView(
        child: Container(
          child: kontenPLTA(),
        ),
      ),
    );
  }
}
