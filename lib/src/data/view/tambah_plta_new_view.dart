import 'dart:developer';

import 'package:drop_down_search_field/drop_down_search_field.dart';
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
import 'package:hy_tutorial/src/plta/model/plta_model.dart';
import 'package:hy_tutorial/utils/utils.dart';
import 'package:provider/provider.dart';
import '../provider/data_add_provider.dart';

class TambahPLTANewView extends StatefulWidget {
  TambahPLTANewView({super.key, this.isFromCenter = false});

  bool isFromCenter;

  @override
  State<TambahPLTANewView> createState() => _TambahPLTANewViewState();
}

class _TambahPLTANewViewState extends BaseState<TambahPLTANewView> {
  bool isSwitched = false;
  bool isSwitched1 = false;

  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    log("PANGGIL COU");
    final p = context.read<DataAddProvider>();
    p.fetchPlta(context);
    p.resetData();
    p.generateAllData();
    p.pltaC.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<DataAddProvider>();

    Widget informasiDasar() {
      return CustomContainer.mainCard(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Informasi Dasar",
              style: Constant.iBlackMedium16
                  .copyWith(fontWeight: FontWeight.w600)),
          Constant.xSizedBox8,
          Divider(
            thickness: 0.5,
            color: Colors.grey.withOpacity(0.5),
          ),
          Constant.xSizedBox8,
          CustomTextField.borderTextField(
            required: false,
            controller: p.pltaC,
            textInputType: TextInputType.name,
            labelText: "Nama PLTA",
            hintText: "Nama PLTA",
          ),
          Constant.xSizedBox16,
          CustomTextField.borderTextField(
            required: false,
            controller: p.pltaC,
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
              )),
              Text(isSwitched ? 'Aktif' : 'Non-Aktif'),
              SizedBox(width: 10,),
              Switch(
                value: isSwitched,
                onChanged: (value) {
                  setState(() {
                    isSwitched = value;
                  });
                },
              ),
            ],
          )
        ],
      ));
    }

    Widget detailLokasi() {
      return CustomContainer.mainCard(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Lokasi",
                  style: Constant.iBlackMedium16
                      .copyWith(fontWeight: FontWeight.w600)),
              Constant.xSizedBox8,
              Divider(
                thickness: 0.5,
                color: Colors.grey.withOpacity(0.5),
              ),
              Constant.xSizedBox8,
              CustomTextField.borderTextField(
                required: false,
                controller: p.pltaC,
                textInputType: TextInputType.name,
                labelText: "Titik Lokasi",
                hintText: "Masukan latitude dan longtitude",
              ),
              Constant.xSizedBox16,
              CustomTextField.borderTextField(
                required: false,
                controller: p.pltaC,
                textInputType: TextInputType.name,
                labelText: "Radius",
                hintText: "0",
                suffixIcon: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 0.5,
                        height: 45,
                        color: Colors.grey.shade400,
                      ),
                      SizedBox(width: 10,),
                      Text(
                        'KM',
                        textAlign: TextAlign.right,
                        style: TextStyle(color: Colors.black),
                      ),
                      Icon(Icons.arrow_drop_down)
                    ],
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
                      )),
                  Text(isSwitched1 ? 'Aktif' : 'Non-Aktif'),
                  SizedBox(width: 10,),
                  Switch(
                    value: isSwitched1,
                    onChanged: (value) {
                      setState(() {
                        isSwitched1 = value;
                      });
                    },
                  ),
                ],
              )
            ],
          ));
    }

    Widget detailShaft() {
      return CustomContainer.mainCard(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text("Shaft", style: Constant.iBlackMedium16),
          Constant.xSizedBox8,
          Divider(
            thickness: 0.5,
            color: Colors.grey.withOpacity(0.5),
          ),
          Constant.xSizedBox8,
          CustomTextField.borderTextField(
            controller: p.genBearingKoplingC,
            textInputType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d?')),
              FilteringTextInputFormatter.allow(RegExp(r'^[0-9]*$')),
            ],
            labelText: "Gen. Bearing-Kopling",
            hintText: "Gen. Bearing-Kopling",
            onChange: p.onChangedBearingToCoupling,
            suffixIcon: Padding(
              padding: const EdgeInsets.fromLTRB(0, 14, 10, 0),
              child: Text(
                'mm',
                textAlign: TextAlign.right,
                style: TextStyle(color: Constant.redColor),
              ),
            ),
          ),
          Constant.xSizedBox16,
          CustomTextField.borderTextField(
            controller: p.koplingTurbinC,
            textInputType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d?')),
              FilteringTextInputFormatter.digitsOnly
            ],
            labelText: "Kopling - Turbin",
            hintText: "Kopling - Turbin",
            onChange: p.onChangedKoplingToTurbine,
            suffixIcon: Padding(
              padding: const EdgeInsets.fromLTRB(0, 14, 10, 0),
              child: Text(
                'mm',
                textAlign: TextAlign.right,
                style: TextStyle(color: Constant.redColor),
              ),
            ),
          ),
          Constant.xSizedBox16,
          CustomTextField.borderTextField(
            enabled: false,
            readOnly: true,
            controller: p.totalC,
            labelText: "Total",
            suffixIcon: Padding(
              padding: const EdgeInsets.fromLTRB(0, 14, 10, 0),
              child: Text(
                'mm',
                textAlign: TextAlign.right,
                style: TextStyle(color: Constant.redColor),
              ),
            ),
          ),
          Constant.xSizedBox16,
          CustomTextField.borderTextField(
            enabled: false,
            readOnly: true,
            controller: p.rasioC,
            labelText: "Rasio",
          ),
          Constant.xSizedBox16,
        ],
      ));
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: CustomAppBar.appBar(
        context,
        "Tambah Laporan",
        color: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  informasiDasar(),
                  Constant.xSizedBox16,
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
                  if (p.validatePage1()) {
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
                              builder: (c) => DataAddUpperView()));
                    }
                  }
                },
                enabled: p.validatePage1(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
