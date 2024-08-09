
// import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_regex/flutter_regex.dart';
import 'package:hy_tutorial/common/component/custom_dropdown.dart';
import 'package:hy_tutorial/common/component/custom_navigator.dart';
import 'package:hy_tutorial/common/component/custom_textfield.dart';
import 'package:hy_tutorial/src/plta/provider/plta_provider.dart';
import '../../../common/base/base_state.dart';
import '../../../common/component/custom_appbar.dart';
import '../../../common/component/custom_button.dart';
import '../../../common/helper/constant.dart';
import 'package:provider/provider.dart';
import '../../../utils/utils.dart';

class PltaAddView extends StatefulWidget {
  PltaAddView({super.key, this.id});
  final String? id;
  @override
  State<PltaAddView> createState() => _PltaAddViewState();
}

class _PltaAddViewState extends BaseState<PltaAddView> {
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

    Widget hapusBtn() {
      return Visibility(
        visible: widget.id != null,
        child: InkWell(
          onTap: () async {
            await Utils.showYesNoDialog(
              context: context,
              title: "Konfirmasi",
              desc: "Apakah Anda Yakin Ingin Hapus PLTA Ini?",
              yesCallback: () async {
                Navigator.pop(context);
                try {
                  await context
                      .read<PltaProvider>()
                      .deletePlta(context, id: widget.id ?? "0");
                } catch (e) {
                  Utils.showFailed(msg: "Gagal hapus PLTA");
                }
              },
              noCallback: () => Navigator.pop(context),
            );
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: Constant.redColor),
            ),
            child: Text(
              'Hapus PLTA',
              style: TextStyle(fontSize: 12, color: Constant.redColor),
            ),
          ),
        ),
      );
    }

    Widget submitBtn() {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
        child: CustomButton.mainButton(
          'Submit',
          enabled: p.validatePltaForm(isEdit: widget.id != null),
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

    Widget detailPlta() {
      final p = context.read<PltaProvider>();
      return Column(
        children: [
          CustomTextField.borderTextField(
            controller: p.nameC,
            textInputType: TextInputType.name,
            labelText: "Nama PLTA",
            hintText: "Masukkan nama PLTA",
            onChange: (v) {
              setState(() {});
            },
          ),
          Constant.xSizedBox16,
          CustomTextField.borderTextField(
            controller: p.totalUnitC,
            labelText: "Jumlah Unit",
            hintText: "Masukkan jumlah unit",
            onChange: (v) {
              setState(() {});
            },
          ),
          Constant.xSizedBox16,
          CustomDropdown.normalDropdown(
            //controller: roleC,
            iconPadding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
            contentPadding: EdgeInsets.all(2),
            borderColor: Constant.primaryColor,
            labelText: "Status",
            selectedItem: p.active,
            hintText: "Pilih status PLTA",
            list: [
              DropdownMenuItem(
                child: Text("Aktif"),
                value: "aktif",
              ),
              DropdownMenuItem(
                child: Text("Non Aktif"),
                value: "non_aktif",
              ),
            ],
            onChanged: (val) {
              p.active = val;
              FocusManager.instance.primaryFocus?.unfocus();
              setState(() {});
            },
          ),
          Constant.xSizedBox16,
          CustomTextField.borderTextField(
            controller: p.radiusStatusC,
            labelText: "Pembatasan Lokasi",
            textInputType: TextInputType.name,
            readOnly: true,
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            suffixIcon: Container(
              width: 25,
              height: 25,
              child: FittedBox(
                child: CupertinoSwitch(
                  value: p.radiusStatus,
                  onChanged: (value) {
                    p.radiusStatus = value;
                    p.radiusStatusC.text = value ? 'Aktif' : 'Tidak Aktif';
                    FocusManager.instance.primaryFocus?.unfocus();
                    setState(() {});
                  },
                ),
              ),
            ),
          ),
          Constant.xSizedBox16,
          CustomTextField.borderTextField(
            controller: p.coordinateC,
            labelText: "Titik Lokasi (Latitude & Longitude)",
            hintText: "Masukkan Latitude & Longitude",
            textInputType: TextInputType.number,
            validator: (val) {
              if (val != null && !val.isLatLongCoordinatesDecimal())
                return 'Koordinat Tidak Valid';
              return null;
            },
          ),
          Constant.xSizedBox16,
          CustomTextField.borderTextField(
            controller: p.radiusC,
            labelText: "Radius",
            textInputType: TextInputType.number,
            hintText: "Masukkan Radius",
            onChange: (v) {
              setState(() {});
            },
          ),
          Constant.xSizedBox16,
          CustomDropdown.normalDropdown(
            //controller: roleC,
            iconPadding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
            contentPadding: EdgeInsets.all(2),
            borderColor: Constant.primaryColor,
            labelText: "Tipe Radius",
            selectedItem: p.radiusType,
            hintText: "Pilih tipe radius",
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
              FocusManager.instance.primaryFocus?.unfocus();
              setState(() {});
            },
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
            decoration: BoxDecoration(color: Color(0xffFAFAFA)),
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
      backgroundColor: Colors.white,
      appBar: CustomAppBar.appBar(
        context,
        "${widget.id != null ? 'Edit' : 'Tambah'} PLTA",
        color: Constant.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Constant.xSizedBox16,
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                "${widget.id != null ? 'Edit' : 'Tambah'} PLTA",
                                style: Constant.blackBold20),
                            Text(
                                "${widget.id != null ? 'Edit' : 'Tambah'} data plta",
                                style: Constant.grayMedium),
                          ],
                        ),
                      ),
                      hapusBtn(),
                    ],
                  ),
                  Constant.xSizedBox16,
                  detailPlta(),
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
            submitBtn(),
          ],
        ),
      ),
    );
  }
}
