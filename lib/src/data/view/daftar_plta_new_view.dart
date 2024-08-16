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

class _DaftarPLTANewViewState extends BaseState<DaftarPLTANewView> {
  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    //plta
    final pltaP = context.read<PltaProvider>();
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
    final pltaP = context.watch<PltaProvider>();
    final pagingC = context.watch<PltaProvider>().pagingController;

    Widget search() => CustomTextField.borderTextField(
          controller: pltaP.searchC,
          focusNode: pltaP.searchN,
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
          suffixIcon: pltaP.searchC.text.isEmpty
              ? null
              : InkWell(
                  onTap: () {
                    pltaP.searchC.clear();
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
            if (pltaP.searchOnStoppedTyping != null) {
              pltaP.searchOnStoppedTyping!.cancel();
            }
            pltaP.searchOnStoppedTyping = Timer(pltaP.duration, () async {
              pltaP.next = null;
              pagingC.refresh();
            });
          },
          onChange: (val) {
            setState(() {});
            if (pltaP.searchOnStoppedTyping != null) {
              pltaP.searchOnStoppedTyping!.cancel();
            }
            pltaP.searchOnStoppedTyping = Timer(pltaP.duration, () async {
              pltaP.next = null;
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
                  value: pltaP.isFetching == true ? null : pltaP.isFetching,
                  child: Text('', style: Constant.blackRegular12),
                ),
                Skeleton<bool>(
                  width: 48,
                  height: 10,
                  value: pltaP.isFetching == true ? null : pltaP.isFetching,
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
                    value: pltaP.isFetching == true ? null : pltaP.isFetching,
                    child: Image.asset(Assets.iconsIcFile, scale: 3.5)),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Constant.xSizedBox4,
                    Skeleton<bool>(
                      width: 175,
                      height: 17,
                      value: pltaP.isFetching == true ? null : pltaP.isFetching,
                      child: Text(
                        '',
                        style: Constant.blackBold15,
                      ),
                    ),
                    SizedBox(height: 10),
                    Skeleton<bool>(
                      width: 100,
                      height: 12,
                      value: pltaP.isFetching == true ? null : pltaP.isFetching,
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

    Widget itemShimmer3() {
      return CustomContainer.mainCard(
        margin: EdgeInsets.symmetric(horizontal: 10),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        isShadow: true,
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Skeleton<bool>(
                width: 40,
                height: 40,
                isCircle: true,
                value: pltaP.isFetching == true ? null : pltaP.isFetching,
                child: Image.asset(Assets.iconsIcPlta),
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
                    value: pltaP.isFetching == true ? null : pltaP.isFetching,
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
                    value: pltaP.isFetching == true ? null : pltaP.isFetching,
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

    Widget kontenPLTA() {
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
        child: PagedListView.separated(
          pagingController: pagingC,
          padding: EdgeInsets.fromLTRB(10, 0, 10, 20),
          shrinkWrap: true,
          physics: ScrollPhysics(),
          separatorBuilder: (context, index) {
            return SizedBox();
          },
          builderDelegate: PagedChildBuilderDelegate<PltaListModelData>(
            firstPageProgressIndicatorBuilder: (_) => bodyPLTAListShimmer(),
            firstPageErrorIndicatorBuilder: (_) => failedData(),
            newPageProgressIndicatorBuilder: (_) => bodyPLTAListShimmer(),
            newPageErrorIndicatorBuilder: (_) => failedData(),
            noItemsFoundIndicatorBuilder: (_) => noData(),
            itemBuilder: (context, item, index) {
              return InkWell(
                onTap: () async {
                  await CusNav.nPush(
                      context, TambahPLTANewView(id: item.Id ?? '0'));
                  pagingC.refresh();
                },
                child: Column(
                  children: [
                    CustomContainer.mainCard(
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image.asset(Assets.iconsIcPltaList, scale: 4),
                          SizedBox(width: 5),
                          Expanded(
                            flex: 6,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item?.Name ?? '-',
                                  style: Constant.iBlackMedium14,
                                ),
                                Text(
                                  '${(item.Status ?? false) ? 'Aktif' : 'Nonaktif'}',
                                  style: Constant.blackRegular12,
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: Colors.black,
                            weight: 1,
                          ),
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
      );
      // return Column(
      //   children: List.generate(7, (index) {
      //     return Column(
      //       children: [
      //         SizedBox(height: 10,),
      //         CustomContainer.mainCard(
      //             margin: EdgeInsets.symmetric(horizontal: 10),
      //             child: Row(
      //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //               children: [
      //                 Image.asset(Assets.iconsIcPltaList, scale: 4),
      //                 SizedBox(width: 5,),
      //                 Expanded(
      //                   flex: 6,
      //                   child: Column(
      //                     mainAxisAlignment: MainAxisAlignment.start,
      //                     crossAxisAlignment: CrossAxisAlignment.start,
      //                     children: [
      //                       Text(
      //                         "PLTA 1 Bojonegoro",
      //                         style: Constant.iBlackMedium14,
      //                       ),
      //                       Text(
      //                         "Unit 1",
      //                         style: Constant.blackRegular12,
      //                       ),
      //                     ],
      //                   ),
      //                 ),
      //                 Icon(Icons.chevron_right, color: Colors.black, weight: 1,),
      //               ],
      //             )),
      //       ],
      //     );
      //   }),
      // );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar.appBar(context, "Daftar PLTA",
          isLeading: false,
          action: [
            Container(
              margin: EdgeInsets.only(right: 20),
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
              decoration: BoxDecoration(
                border: Border.all(width: 1, color: Constant.primaryColor),
                borderRadius: BorderRadius.circular(7),
              ),
              child: InkWell(
                onTap: () {
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
                headKonten(),
                Divider(
                  thickness: 0.5,
                  color: Colors.grey.withOpacity(0.5),
                ),
              ],
            ),
          ),
          color: Colors.white,
          foregroundColor: Constant.primaryColor),
      body: kontenPLTA(),
    );
  }
}
