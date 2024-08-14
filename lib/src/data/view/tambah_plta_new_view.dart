import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hy_tutorial/common/base/base_state.dart';
import 'package:hy_tutorial/common/component/custom_appbar.dart';
import 'package:hy_tutorial/common/component/custom_button.dart';
import 'package:hy_tutorial/common/component/custom_container.dart';
import 'package:hy_tutorial/common/component/custom_dropdown.dart';
import 'package:hy_tutorial/common/component/custom_textField.dart';
import 'package:hy_tutorial/common/helper/constant.dart';
import 'package:hy_tutorial/src/data/view/data_add_upper_view.dart';
import 'package:hy_tutorial/src/plta/provider/plta_provider.dart';
import 'package:hy_tutorial/utils/utils.dart';
import 'package:provider/provider.dart';
import '../provider/data_add_provider.dart';

class TambahPLTANewView extends StatefulWidget {
  TambahPLTANewView({super.key, this.id});
  final String? id;

  @override
  State<TambahPLTANewView> createState() => _TambahPLTANewViewState();
}

class _TambahPLTANewViewState extends BaseState<TambahPLTANewView> {
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

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: CustomAppBar.appBar(
        context,
        "${widget.id != null ? 'Edit' : 'Tambah'} PLTA",
        color: Constant.primaryColor,
        foregroundColor: Colors.white,
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
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
              child: CustomButton.mainButton(
                'Selanjutnya',
                () {
                  if (p.validatePltaForm()) {
                    final dataP = context.read<DataAddProvider>();
                    FocusManager.instance.primaryFocus?.unfocus();
                    String? msg;
                    if (dataP.selectedBolt == null)
                      msg = 'Harap Pilih Jumlah Baut';
                    if (dataP.selectedPlta == null) msg = 'Harap Pilih PLTA';
                    if (dataP.genBearingKoplingC.text.isEmpty)
                      msg = 'Harap Isi Gen Bearing Kopling';
                    if (dataP.koplingTurbinC.text.isEmpty)
                      msg = 'Harap Isi Kopling Turbin';
                    if (msg != null) {
                      Utils.showFailed(msg: msg);
                      return;
                    } else {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (c) => DataAddUpperView(),
                          ));
                    }
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
