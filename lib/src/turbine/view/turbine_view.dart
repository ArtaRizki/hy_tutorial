import 'dart:async';
import 'package:hy_tutorial/common/component/custom_button.dart';
import 'package:hy_tutorial/common/component/custom_container.dart';
import 'package:hy_tutorial/common/component/custom_date_picker.dart';
import 'package:hy_tutorial/common/component/skeleton.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../common/component/custom_appbar.dart';
import '../../../common/component/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../common/base/base_state.dart';
import '../../../../common/helper/constant.dart';
import '../../shaft/view/shaft_detail_view.dart';
import '../model/turbine_model.dart';
import '../provider/turbine_provider.dart';

class TurbineView extends StatefulWidget {
  @override
  State<TurbineView> createState() => _TurbineViewState();
}

class _TurbineViewState extends BaseState<TurbineView> {
  @override
  void initState() {
    final turbineP = context.read<TurbineProvider>();
    if ((turbineP.pagingController.itemList ?? []).isEmpty) {
      turbineP.getTurbine();
    } else {
      turbineP.pagingController.dispose();
      turbineP.next = null;
      turbineP.getTurbine();
    }
    // turbineP.fetchTurbine(withLoading: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final turbineP = context.watch<TurbineProvider>();
    final turbineData =
        context.watch<TurbineProvider>().turbineModel.Data ?? [];
    final pagingC = context.watch<TurbineProvider>().pagingController;

    Widget search() => CustomTextField.borderTextField(
          controller: turbineP.turbineSearchC,
          required: false,
          hintText: "Cari Riwayat",
          hintColor: Constant.textHintColor2,
          suffixIcon: Padding(
            padding: const EdgeInsets.all(12),
            child: Image.asset(
              'assets/icons/ic-search.png',
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
                      SfDateRangePicker(
                        view: DateRangePickerView.month,
                        initialSelectedDates: [
                          DateTime.now(),
                          DateTime.now().add(Duration(days: 7)),
                        ],
                        onSubmit: (p0) async {
                          if (p0 is List<DateTime>) {
                            final data = p0;

                            await turbineP.setStartDate(
                                await CustomDatePicker.pickDate(
                                    context, DateTime.now()));
                            FocusManager.instance.primaryFocus?.unfocus();
                          }
                        },
                        selectionMode: DateRangePickerSelectionMode.range,
                      ),
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
                  child: Text(
                    '',
                    style: Constant.blackRegular12,
                  ),
                ),
                Skeleton<bool>(
                  width: 48,
                  height: 10,
                  value:
                      turbineP.isFetching == true ? null : turbineP.isFetching,
                  child: Text(
                    '',
                    style: Constant.blackRegular12,
                  ),
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
                    child: Image.asset('assets/icons/ic-file.png', scale: 3.5)),
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
                        child: Text("-", style: Constant.grayRegular13)),
                  ],
                ),
              ],
            ),
            Constant.xSizedBox8,
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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar.appBar(context, "Riwayat",
          textStyle: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
          isLeading: false,
          titleSpacing: 20,
          color: Constant.primaryColor,
          foregroundColor: Colors.white),
      body: SafeArea(
        child: RefreshIndicator(
          color: Constant.primaryColor,
          onRefresh: () async {
            turbineP.next = null;
            if ((turbineP.pagingController.itemList ?? []).isEmpty) {
              turbineP.pagingController.refresh();
            } else {
              turbineP.next = null;
              turbineP.pagingController.refresh();
            }
          },
          child: GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: Container(
              padding: EdgeInsets.fromLTRB(
                  20, 10, 20, kBottomNavigationBarHeight - 42),
              color: Colors.transparent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Constant.xSizedBox16,
                  search(),
                  Constant.xSizedBox16,
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Filter",
                            style: Constant.grayMedium.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.w400)),
                        InkWell(
                          onTap: () async {
                            CustomContainer.showModalBottomScroll(
                                initialChildSize: 0.85,
                                context: context,
                                child: filterAllWidget());
                          },
                          child: Container(
                            height: 30,
                            width: 60,
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1,
                                color: Colors.grey.withOpacity(0.5),
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.filter_alt_outlined, size: 20),
                                SizedBox(width: 4),
                                Icon(Icons.keyboard_arrow_down, size: 15)
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Constant.xSizedBox8,
                  Flexible(
                    child: PagedListView.separated(
                      shrinkWrap: true,
                      pagingController: pagingC,
                      padding: EdgeInsets.fromLTRB(0, 18, 0, 20),
                      separatorBuilder: (_, __) => Constant.xSizedBox16,
                      builderDelegate:
                          PagedChildBuilderDelegate<TurbineModelData>(
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
                                    width: 1,
                                    color: Colors.grey.withOpacity(0.5)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                                        'assets/icons/ic-file.png',
                                        scale: 3.5,
                                      ),
                                      SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
