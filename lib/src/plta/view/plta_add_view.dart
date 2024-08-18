import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hy_tutorial/common/base/base_state.dart';
import 'package:hy_tutorial/common/component/custom_appbar.dart';
import 'package:hy_tutorial/common/component/custom_button.dart';
import 'package:hy_tutorial/common/component/custom_container.dart';
import 'package:hy_tutorial/common/component/custom_dropdown.dart';
import 'package:hy_tutorial/common/component/custom_navigator.dart';
import 'package:hy_tutorial/common/component/custom_textField.dart';
import 'package:hy_tutorial/common/helper/constant.dart';
import 'package:hy_tutorial/src/plta/provider/plta_provider.dart';
import 'package:hy_tutorial/utils/utils.dart';
import 'package:provider/provider.dart';

class PLTAAddView extends StatefulWidget {
  PLTAAddView({super.key, this.id});
  final String? id;

  @override
  State<PLTAAddView> createState() => _PLTAAddViewState();
}

class _PLTAAddViewState extends BaseState<PLTAAddView> {
  @override
  void initState() {
    context.read<PltaProvider>().setData(context, widget.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<PltaProvider>();
    final pltaDataP = p.pltaDetailModel;
    final pltaP = p.pltaDetailModel.Data;
    var pltaUnitList = p.pltaUnitList;
    var statusActiveList = p.statusActive;
    var pltaUnitListName = context.watch<PltaProvider>().pltaUnitListName;

    Widget informasiDasar() {
      return CustomContainer.mainCard(
        margin: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Informasi Dasar",
              style:
                  Constant.iBlackMedium16.copyWith(fontWeight: FontWeight.w600),
            ),
            Constant.xSizedBox8,
            Divider(
              thickness: 0.5,
              color: Colors.grey.withOpacity(0.5),
            ),
            Constant.xSizedBox8,
            CustomTextField.borderTextField(
              required: false,
              controller: p.nameC,
              textInputType: TextInputType.name,
              labelText: "Nama PLTA",
              hintText: "Nama PLTA",
            ),
            Constant.xSizedBox16,
            CustomTextField.borderTextField(
              required: false,
              controller: p.totalUnitC,
              textInputType: TextInputType.name,
              labelText: "Jumlah Unit",
              hintText: "0",
              suffixIcon: Padding(
                padding: const EdgeInsets.fromLTRB(0, 14, 10, 0),
                child: Text(
                  'Unit',
                  textAlign: TextAlign.right,
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
            Constant.xSizedBox16,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 6,
                  child: Text(
                    "Status",
                    style: Constant.s12BoldBlack,
                  ),
                ),
                Text(p.isActive ? 'Aktif' : 'Non-Aktif'),
                SizedBox(
                  width: 10,
                ),
                CupertinoSwitch(
                  value: p.isActive,
                  onChanged: (value) {
                    p.isActive = value;
                    p.active = value ? 'aktif' : 'non_aktif';
                    FocusManager.instance.primaryFocus?.unfocus();
                    setState(() {});
                  },
                ),
              ],
            )
          ],
        ),
      );
    }

    Widget detailLokasi() {
      return CustomContainer.mainCard(
        margin: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Lokasi",
              style:
                  Constant.iBlackMedium16.copyWith(fontWeight: FontWeight.w600),
            ),
            Constant.xSizedBox8,
            Divider(
              thickness: 0.5,
              color: Colors.grey.withOpacity(0.5),
            ),
            Constant.xSizedBox8,
            CustomTextField.borderTextField(
              required: false,
              controller: p.coordinateC,
              textInputType: TextInputType.name,
              labelText: "Titik Lokasi",
              hintText: "Masukan latitude dan longtitude",
            ),
            Constant.xSizedBox16,
            CustomTextField.borderTextField(
              required: false,
              controller: p.radiusC,
              textInputType: TextInputType.name,
              labelText: "Radius",
              hintText: "0",
              suffixIcon: Padding(
                padding: EdgeInsets.zero,
                child: Container(
                  width: 74,
                  decoration: BoxDecoration(
                      border: Border(
                          left: BorderSide(
                    width: 0.5,
                    color: Constant.borderSearchColor,
                    style: BorderStyle.solid,
                  ))),
                  child: CustomDropdown.normalDropdown(
                    controller: p.radiusTypeC,
                    iconPadding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
                    fillColor: Colors.transparent,
                    contentPadding: EdgeInsets.all(2),
                    borderColor: Constant.primaryColor,
                    customBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(10)),
                    labelText: null,
                    selectedItem: p.radiusType,
                    hintText: "",
                    list: [
                      DropdownMenuItem(
                        child: Text("KM"),
                        value: "kilometer",
                      ),
                      DropdownMenuItem(
                        child: Text("M"),
                        value: "meter",
                      ),
                    ],
                    onChanged: (val) {
                      p.radiusType = val;
                      p.radiusTypeC.text = val == 'meter' ? 'M' : 'KM';
                      FocusManager.instance.primaryFocus?.unfocus();
                      setState(() {});
                    },
                  ),
                ),
              ),
            ),
            Constant.xSizedBox16,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 6,
                  child: Text(
                    "Pembatasan Lokasi",
                    style: Constant.s12BoldBlack,
                  ),
                ),
                Text(p.radiusStatus ? 'Aktif' : 'Non-Aktif'),
                SizedBox(
                  width: 10,
                ),
                CupertinoSwitch(
                  value: p.radiusStatus,
                  onChanged: (value) {
                    p.radiusStatus = value;
                    p.radiusStatusC.text = value ? 'Aktif' : 'Tidak Aktif';
                    FocusManager.instance.primaryFocus?.unfocus();
                    setState(() {});
                  },
                ),
              ],
            )
          ],
        ),
      );
    }

    TableRow title() {
      return TableRow(
        decoration: BoxDecoration(color: Color(0xffFAFAFA)),
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: Text(
              'Nama Unit',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xff100629),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: Text(
              'Status',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xff100629),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: Text(
              'Aksi',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xff100629),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      );
    }

    List<TableRow> content() {
      final p = context.read<PltaProvider>();
      if (p.pltaUnitList.isEmpty ||
          statusActiveList.isEmpty ||
          pltaUnitListName.isEmpty) return [];
      return List<TableRow>.generate(
        p.pltaUnitList.length,
        (index) {
          final item = pltaUnitList[index];
          final itemStatus = statusActiveList[index];
          final itemC = pltaUnitListName[index];
          // log("ITEM C $index : ${itemC.text}");
          return TableRow(
            decoration: BoxDecoration(
                color: index % 2 != 0 || index == 1
                    ? Color(0xffFAFAFA)
                    : Colors.white),
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 8),
                child: CustomTextField.tableTextField(
                  hintText: 'Masukkan Nama Unit',
                  textInputType: TextInputType.name,
                  controller:
                      context.read<PltaProvider>().pltaUnitListName[index],
                  onChange: (v) {
                    context.read<PltaProvider>().setPltaUnitListName(index, v);
                    setState(() {});
                  },
                  fillColor: Colors.transparent,
                  noBorder: true,
                  isDense: true,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                child: Text(
                  itemStatus ? 'Aktif' : 'Non Aktif',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xff111E30)),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (p.statusActive.isNotEmpty)
                    Container(
                      width: 25,
                      height: 25,
                      child: FittedBox(
                        child: CupertinoSwitch(
                            value: p.statusActive[index],
                            onChanged: (value) async {
                              p.statusActive[index] = value;
                              p.pltaUnitList[index]?.Status = value;
                              setState(() {});
                              // if (widget.id != null)
                              // await p.sendPltaUnit(context,
                              //     pltaId: p.pltaDetailModel.Data?.Id ?? '',
                              //     isEdit: true);
                            }),
                      ),
                    ),
                  Container(
                    width: 35,
                    height: 35,
                    child: FittedBox(
                      child: IconButton(
                        onPressed: () {
                          Utils.showYesNoDialogWithWarning(
                              context: context,
                              title: "Konfirmasi Penghapusan",
                              desc:
                                  "Apakah anda yakin ingin\nmenghapus unit yang dipilih?",
                              yesCallback: () async {
                                try {
                                  if (pltaP?.Units?[index]?.Id != null) {
                                    await context
                                        .read<PltaProvider>()
                                        .deletePltaUnit(context,
                                            id: pltaP?.Units?[index]?.Id ?? "0",
                                            pltaId: pltaP?.Id ?? "");
                                  } else {
                                    p.hapusUnit(index);
                                    CusNav.nPop(context);
                                  }
                                } catch (e) {
                                  Utils.showFailed(
                                      msg: "Gagal hapus PLTA Unit");
                                }
                              },
                              noCallback: () async {
                                Navigator.pop(context);
                              });
                        },
                        icon: Icon(
                          Icons.delete,
                          color: Constant.redColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: CustomAppBar.appBar(
        context,
        "${widget.id != null ? 'Edit' : 'Tambah'} PLTA",
        elevation: 1,
        shadowColor: Colors.black54,
        action: [
          InkWell(
            onTap: () async {
              Utils.showYesNoDialogWithWarning(
                  context: context,
                  title: "Konfirmasi Penghapusan",
                  desc: "Apakah anda yakin ingin\nmenghapus user yang dipilih?",
                  yesCallback: () async {
                    Navigator.pop(context);
                    await context
                        .read<PltaProvider>()
                        .deletePlta(context, id: widget.id ?? "0");
                  },
                  noCallback: () async {
                    Navigator.pop(context);
                  });
            },
            child: Container(
              margin: EdgeInsets.only(right: 20),
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Constant.redColor),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    Icons.delete_forever_rounded,
                    size: 15,
                    color: Constant.redColor,
                  ),
                  Text(
                    "Hapus",
                    style: Constant.iPrimaryMedium12
                        .copyWith(color: Constant.redColor),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Constant.xSizedBox16,
                  informasiDasar(),
                  Constant.xSizedBox24,
                  detailLokasi(),
                  Constant.xSizedBox16,
                  if (widget.id != null) Constant.xSizedBox16,
                  if (widget.id != null)
                    Table(
                      border: TableBorder.all(
                          width: 0.5,
                          color: Constant.borderSearchColor.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(5)),
                      columnWidths: const <int, TableColumnWidth>{
                        0: FlexColumnWidth(),
                        // 0: IntrinsicColumnWidth(flex: 0.5),
                        1: FlexColumnWidth(),
                        2: FlexColumnWidth(),
                        3: FlexColumnWidth(),
                        4: FlexColumnWidth(),
                      },
                      defaultVerticalAlignment: TableCellVerticalAlignment.top,
                      children: [title(), ...content()],
                    ),
                  Constant.xSizedBox8,
                  if (widget.id != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Visibility(
                          visible: p.pltaUnitListName.isEmpty,
                          child: Expanded(
                            child: Text(
                              'Unit Anda kosong,\nsilahkan tambah unit',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                        Constant.xSizedBox8,
                        Align(
                          alignment: Alignment.centerRight,
                          child: InkWell(
                            onTap: () async {
                              await context.read<PltaProvider>().tambahUnit();
                              setState(() {});
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                                border:
                                    Border.all(color: Constant.primaryColor),
                              ),
                              child: Text(
                                'Tambah Unit',
                                style: TextStyle(
                                    fontSize: 12, color: Constant.primaryColor),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  Constant.xSizedBox32,
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
              child: CustomButton.mainButton(
                'Submit',
                () async {
                  if (p.validatePltaForm(isEdit: widget.id != null)) {
                    final dataP = context.read<PltaProvider>();
                    FocusManager.instance.primaryFocus?.unfocus();
                    await Utils.showYesNoDialog(
                      context: context,
                      title: "Konfirmasi",
                      desc: "Apakah Data Anda Sudah Benar?",
                      yesCallback: () => handleTap(
                        () async {
                          Navigator.pop(context);
                          Utils.showLoading();
                          if (widget.id != null) {
                            await p.sendPlta(
                              context,
                              isEdit: true,
                              back: false,
                              withLoading: false,
                              pltaId: pltaDataP.Data?.Id ?? '',
                            );
                            await dataP.sendPltaUnit(context,
                                isEdit: true, back: true, withLoading: false);
                          } else {
                            await p.sendPlta(
                              context,
                              back: true,
                              withLoading: false,
                              pltaId: pltaDataP.Data?.Id ?? '',
                            );
                            // await dataP.sendPltaUnit(context,
                            //     isEdit: false, back: true, withLoading: false);
                          }
                          p.next = null;
                          Utils.dismissLoading();
                        },
                      ),
                      noCallback: () => Navigator.pop(context),
                    );
                  }
                },
                enabled: p.validatePltaForm(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
