import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hy_tutorial/common/base/base_state.dart';
import 'package:hy_tutorial/common/component/custom_container.dart';
import 'package:hy_tutorial/common/component/custom_navigator.dart';
import 'package:hy_tutorial/common/component/custom_textField.dart';
import 'package:hy_tutorial/common/component/skeleton.dart';
import 'package:hy_tutorial/common/helper/constant.dart';
import 'package:hy_tutorial/generated/assets.dart';
import 'package:hy_tutorial/src/data/view/data_add_view.dart';
import 'package:hy_tutorial/src/profile/view/profile_view.dart';
import 'package:hy_tutorial/src/shaft/view/shaft_detail_view.dart';
import 'package:hy_tutorial/src/shaft/view/shaft_latest_view.dart';
import 'package:hy_tutorial/src/turbine/model/turbine_model.dart';
import 'package:hy_tutorial/src/turbine/provider/turbine_provider.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends BaseState<HomeView> with TickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);

    final turbineP = context.read<TurbineProvider>();
    if ((turbineP.pagingController.itemList ?? []).isEmpty) {
      turbineP.getTurbine();
    } else {
      turbineP.pagingController.dispose();
      turbineP.next = null;
      turbineP.getTurbine();
    }
    if ((turbineP.pagingController2.itemList ?? []).isEmpty) {
      turbineP.getTurbine2();
    } else {
      turbineP.pagingController2.dispose();
      turbineP.next2 = null;
      turbineP.getTurbine2();
    }
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
    // if (turbineP.turbineSearchN.hasFocus) turbineP.turbineSearchN.unfocus();
    final pagingC = context.watch<TurbineProvider>().pagingController;
    final pagingC2 = context.watch<TurbineProvider>().pagingController2;

    Widget headKonten() {
      return Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            alignment: Alignment.topCenter,
            image: AssetImage(Assets.imagesImgHomeTop),
            fit: BoxFit.fitWidth,
          ),
        ),
        // height: 150,
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(20, 35, 20, 15),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.3),
                    child: Icon(Icons.notifications_outlined,
                        color: Colors.white)),
                SizedBox(width: 15),
                InkWell(
                  onTap: () {
                    CusNav.nPush(context, ProfileView());
                  },
                  child: Image.asset(Assets.iconsIcUser, scale: 5.2),
                ),
              ],
            ),
          ],
        ),
      );
    }

    Widget search() => CustomTextField.borderTextField(
          controller: turbineP.turbineSearchC,
          activeBorderColor: tabController.index == 0
              ? Constant.borderSearchColor
              : Constant.primaryColor,
          activeBorderWidth: tabController.index == 0 ? 0.5 : 1,
          focusNode: turbineP.turbineSearchN,
          required: false,
          readOnly: tabController.index == 0,
          hintText: "Cari Laporan",
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
                    turbineP.turbineSearchN.unfocus();
                    setState(() {});
                    pagingC.refresh();
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

    Widget _buildTab(String tag) {
      return Tab(
        height: 35,
        child: Text(
          tag,
          style: TextStyle(fontSize: 12),
          textAlign: TextAlign.center,
        ),
      );
    }

    Widget toggleTab() {
      return DefaultTabController(
        length: 2,
        child: TabBar(
          isScrollable: false,
          onTap: (index) {
            setState(() {});
            FocusManager.instance.primaryFocus?.unfocus();
          },
          padding: EdgeInsets.only(top: 8),
          labelPadding: EdgeInsets.zero,
          indicatorPadding: EdgeInsets.zero,
          controller: tabController,
          tabAlignment: TabAlignment.fill,
          indicatorSize: TabBarIndicatorSize.label,
          unselectedLabelColor: Colors.black,
          labelColor: Constant.primaryColor,
          indicatorColor: Constant.primaryColor,
          labelStyle: Constant.primaryTextStyle
              .copyWith(fontWeight: FontWeight.bold, fontSize: 14),
          unselectedLabelStyle:
              Constant.primaryTextStyle.copyWith(fontSize: 14),
          tabs: [
            _buildTab("Seminggu Terakhir"),
            _buildTab("Riwayat"),
          ],
        ),
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

    Widget semingguTerakhir() {
      return RefreshIndicator(
        onRefresh: () async {
          turbineP.next2 = null;
          if ((turbineP.pagingController2.itemList ?? []).isEmpty) {
            turbineP.pagingController2.refresh();
          } else {
            turbineP.next2 = null;
            turbineP.pagingController2.refresh();
          }
        },
        child: PagedListView.separated(
          shrinkWrap: true,
          pagingController: pagingC2,
          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
          separatorBuilder: (_, __) => Constant.xSizedBox16,
          builderDelegate: PagedChildBuilderDelegate<TurbineModelData>(
            firstPageProgressIndicatorBuilder: (_) => listShimmer2(),
            firstPageErrorIndicatorBuilder: (_) => failedData(),
            newPageProgressIndicatorBuilder: (_) => listShimmer2(),
            noItemsFoundIndicatorBuilder: (_) => noData(),
            itemBuilder: (context, item, indexs) {
              return InkWell(
                onTap: () async {
                  FocusManager.instance.primaryFocus?.unfocus();
                  turbineP.turbineSearchC.clear();
                  final f = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ShaftDetailView(id: item.Id ?? '')));
                  if (f != null) {
                    turbineP.next2 = null;
                    pagingC2.refresh();
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(
                        width: 1, color: Colors.grey.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${DateFormat('HH : mm').format(DateFormat('yyyy-MM-dd HH:mm:ss').parse(item.CreatedAt ?? '${DateTime.now()}'))}',
                            style: Constant.blackRegular12,
                          ),
                          Text(
                            '${DateFormat('dd MMM yyyy').format(DateFormat('yyyy-MM-dd HH:mm:ss').parse(item.CreatedAt ?? '${DateTime.now()}'))}',
                            style: Constant.blackRegular12,
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
                          Image.asset(
                            Assets.iconsIcFile,
                            scale: 3.5,
                          ),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.Title ?? '',
                                style: Constant.blackBold15,
                              ),
                              SizedBox(height: 5),
                              Text(item.TowerName ?? "-",
                                  style: Constant.grayRegular13),
                            ],
                          ),
                        ],
                      ),
                      Constant.xSizedBox8,
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    Widget itemListShimmer() {
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
                  value:
                      turbineP.isFetching == true ? null : turbineP.isFetching,
                  child: Text('', style: Constant.blackRegular12),
                ),
                Skeleton<bool>(
                  width: 48,
                  height: 10,
                  value:
                      turbineP.isFetching == true ? null : turbineP.isFetching,
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
                    value: turbineP.isFetching == true
                        ? null
                        : turbineP.isFetching,
                    child: Image.asset(Assets.iconsIcFile, scale: 3.5)),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Constant.xSizedBox4,
                    Skeleton<bool>(
                      width: 175,
                      height: 17,
                      value: turbineP.isFetching == true
                          ? null
                          : turbineP.isFetching,
                      child: Text(
                        '',
                        style: Constant.blackBold15,
                      ),
                    ),
                    SizedBox(height: 10),
                    Skeleton<bool>(
                      width: 100,
                      height: 12,
                      value: turbineP.isFetching == true
                          ? null
                          : turbineP.isFetching,
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

    Widget listShimmer() {
      return Column(
        children: [
          itemListShimmer(),
          SizedBox(height: 20),
          itemListShimmer(),
          SizedBox(height: 20),
          itemListShimmer(),
          SizedBox(height: 20),
        ],
      );
    }

    Widget riwayat() {
      return RefreshIndicator(
        onRefresh: () async {
          turbineP.next = null;
          if ((turbineP.pagingController.itemList ?? []).isEmpty) {
            turbineP.pagingController.refresh();
          } else {
            turbineP.next = null;
            turbineP.pagingController.refresh();
          }
        },
        child: PagedListView.separated(
          shrinkWrap: true,
          pagingController: pagingC,
          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
          separatorBuilder: (_, __) => Constant.xSizedBox16,
          builderDelegate: PagedChildBuilderDelegate<TurbineModelData>(
            firstPageProgressIndicatorBuilder: (_) => listShimmer(),
            firstPageErrorIndicatorBuilder: (_) => failedData(),
            newPageProgressIndicatorBuilder: (_) => listShimmer(),
            noItemsFoundIndicatorBuilder: (_) => noData(),
            itemBuilder: (context, item, indexs) {
              return InkWell(
                onTap: () async {
                  FocusManager.instance.primaryFocus?.unfocus();
                  turbineP.turbineSearchC.clear();
                  final f = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ShaftDetailView(id: item.Id ?? '')));
                  if (f != null) {
                    turbineP.next = null;
                    pagingC.refresh();
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(
                        width: 1, color: Colors.grey.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${DateFormat('HH : mm').format(DateFormat('yyyy-MM-dd HH:mm:ss').parse(item.CreatedAt ?? '${DateTime.now()}'))}',
                            style: Constant.blackRegular12,
                          ),
                          Text(
                            '${DateFormat('dd MMM yyyy').format(DateFormat('yyyy-MM-dd HH:mm:ss').parse(item.CreatedAt ?? '${DateTime.now()}'))}',
                            style: Constant.blackRegular12,
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
                          Image.asset(
                            Assets.iconsIcFile,
                            scale: 3.5,
                          ),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.Title ?? '',
                                style: Constant.blackBold15,
                              ),
                              SizedBox(height: 5),
                              Text(item.TowerName ?? "-",
                                  style: Constant.grayRegular13),
                            ],
                          ),
                        ],
                      ),
                      Constant.xSizedBox8,
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          if (turbineP.turbineSearchN.hasFocus &&
              (pagingC.itemList?.isEmpty ?? false)) {
            turbineP.turbineSearchC.clear();
            turbineP.turbineSearchN.unfocus();

            if (turbineP.searchOnStoppedTyping != null) {
              turbineP.searchOnStoppedTyping!.cancel();
            }
            turbineP.searchOnStoppedTyping = Timer(turbineP.duration, () async {
              turbineP.next = null;
              pagingC.refresh();
            });
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: SizedBox(
                width: double.infinity,
                child: Stack(
                  children: [
                    headKonten(),
                    Positioned(
                      bottom: 20,
                      right: 0,
                      left: 0,
                      child: CustomContainer.mainCard(
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  turbineP.turbineSearchN.unfocus();
                                  await CusNav.nPush(
                                      context, DataAddView(isFromCenter: true));
                                },
                                child: Column(
                                  children: [
                                    Image.asset(
                                      Assets.iconsIcAddData,
                                      scale: 4,
                                    ),
                                    SizedBox(height: 4),
                                    Text("Add Data"),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 45,
                              color: Colors.grey.withOpacity(0.5),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  turbineP.turbineSearchN.unfocus();
                                  CusNav.nPush(context, ShaftLatestView());
                                },
                                child: Column(
                                  children: [
                                    Image.asset(
                                      Assets.iconsIcDataTerakhir,
                                      scale: 4,
                                    ),
                                    SizedBox(height: 4),
                                    Text("Data Terakhir"),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 6,
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: CustomContainer.mainCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Laporan",
                        style: Constant.blackBold16
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(flex: 8, child: search()),
                          SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: InkWell(
                              onTap: () async {
                                if (tabController.index == 1)
                                  CustomContainer.showModalBottomScroll(
                                    initialChildSize: 0.8,
                                    context: context,
                                    child: filterAllWidget(),
                                  );
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
                                child: Icon(
                                  Icons.filter_alt_outlined,
                                  size: 25,
                                  color: tabController.index == 0
                                      ? Constant.textHintColor2
                                      : null,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      toggleTab(),
                      SizedBox(height: 10),
                      Expanded(
                        child: TabBarView(
                          physics: NeverScrollableScrollPhysics(),
                          controller: tabController,
                          children: [
                            semingguTerakhir(),
                            riwayat(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
