import 'dart:developer';

import 'package:drop_down_search_field/drop_down_search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hy_tutorial/common/base/base_state.dart';
import 'package:hy_tutorial/common/component/custom_container.dart';
import 'package:hy_tutorial/common/component/custom_dropdown.dart';
import 'package:hy_tutorial/common/component/custom_textfield.dart';
import 'package:hy_tutorial/common/helper/constant.dart';
import 'package:hy_tutorial/src/data/view/data_add_upper_view.dart';
import 'package:hy_tutorial/src/plta/model/plta_model.dart';
import 'package:hy_tutorial/utils/utils.dart';
import 'package:provider/provider.dart';
import '../provider/data_add_provider.dart';
import '../../../common/component/custom_appbar.dart';
import '../../../common/component/custom_button.dart';

class DataAddView extends StatefulWidget {
  DataAddView({super.key, this.isFromCenter = false});
  bool isFromCenter;
  @override
  State<DataAddView> createState() => DataAddViewState();
}

class DataAddViewState extends BaseState<DataAddView> {
  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    log("PANGGIL COU");
    final p = context.read<DataAddProvider>();
    p.dataAddViewState = this;
    p.refresh = () {
      setState(() {});
    };
    p.fetchPlta(context);
    p.resetData();
    p.generateAllData();
    p.pltaC.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<DataAddProvider>();

    Widget detailUnit() {
      return CustomContainer.mainCard(
          margin: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Detail Unit", style: Constant.iBlackMedium16),
              Constant.xSizedBox8,
              Divider(
                thickness: 0.5,
                color: Colors.grey.withOpacity(0.5),
              ),
              Constant.xSizedBox8,
              CustomTextField.borderTextField(
                required: false,
                controller: p.titleC,
                textInputType: TextInputType.name,
                labelText: "Nama File",
                hintText: "Nama File",
                onChange: (p0) {
                  setState(() {});
                },
              ),
              Constant.xSizedBox16,
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Text(
                      "Nama PLTA",
                      style: Constant.primaryTextStyle
                          .copyWith(fontSize: 14, fontWeight: Constant.medium),
                    ),
                  ],
                ),
              ),
              // if ((pltaList ?? []).isNotEmpty)
              DropDownSearchField<PltaModelData?>(
                displayAllSuggestionWhenTap: true,
                textFieldConfiguration: TextFieldConfiguration(
                  controller: p.pltaC,
                  autofocus: false,
                  // style: DefaultTextStyle.of(context).style.copyWith(
                  //   fontStyle: FontStyle.italic
                  // ),
                  onChanged: (value) {
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.zero,
                    hintText: "Pilih PLTA",
                    isDense: false,
                    hintStyle: TextStyle(color: Constant.textHintColor2),
                    filled: true,
                    enabled: true,
                    fillColor: Colors.white,
                    suffixIconColor: Constant.grayColor,
                    suffixIcon: InkWell(
                      onTap: () {
                        if (p.pltaC.text.isNotEmpty) {
                          FocusManager.instance.primaryFocus?.unfocus();
                          p.pltaC.text = '';
                          p.selectedPlta = null;
                          setState(() {});
                        }
                      },
                      child: Icon(
                        p.pltaC.text.isEmpty
                            ? Icons.keyboard_arrow_down
                            : Icons.close,
                        size: 24,
                      ),
                    ),
                    hoverColor: Constant.primaryColor,
                    focusColor: Constant.primaryColor,
                    prefix: SizedBox(width: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        width: 0.5,
                        color: Constant.borderSearchColor,
                        style: BorderStyle.solid,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        width: 0.5,
                        color: Constant.borderSearchColor,
                        style: BorderStyle.solid,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        width: 1,
                        color: Constant.primaryColor,
                        style: BorderStyle.solid,
                      ),
                    ),
                  ),
                ),
                onSuggestionSelected: p.onChangedPLTA2,
                suggestionsCallback: (pattern) async =>
                    await p.searchPlta(pattern),
                itemBuilder: (context, suggestion) =>
                    ListTile(title: Text(suggestion?.Name ?? '')),
              ),
              Constant.xSizedBox16,
              // CustomDropdown.searchDropdown(
              //   controller: pltaC,
              //   iconPadding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
              //   contentPadding: EdgeInsets.all(2),
              //   padding: EdgeInsets.zero,
              //   borderColor: Constant.primaryColor,
              //   labelText: 'Nama PLTA',
              //   selectedItem: selectedPlta,
              //   hintText: "Pilih PLTA",
              //   list: (pltaList ?? []).map((e) => e?.Name ?? '').toList(),
              //   onChanged: onChangedPLTA,
              // ),
              // Constant.xSizedBox16,
            ],
          ));
    }

    Widget detailBaut() {
      return CustomContainer.mainCard(
          margin: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Detail Baut", style: Constant.iBlackMedium16),
              Constant.xSizedBox8,
              Divider(
                thickness: 0.5,
                color: Colors.grey.withOpacity(0.5),
              ),
              Constant.xSizedBox8,
              CustomDropdown.searchDropdown(
                required: false,
                controller: p.boltQtyC,
                iconPadding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                contentPadding: EdgeInsets.all(2),
                borderColor: Constant.primaryColor,
                labelText: "Jumlah Baut",
                hintText: "Jumlah Baut",
                selectedItem: p.selectedBolt,
                // suffixIcon: Padding(
                //   padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                //   child: Text(
                //     'Bolt',
                //     textAlign: TextAlign.right,
                //     style: TextStyle(
                //         color: Constant.redColor, fontWeight: FontWeight.w400),
                //   ),
                // ),
                list: p.boltList.map((e) => e).toList(),
                onChanged: (val) {
                  p.selectedBolt = val;
                  // notifyListeners();
                },
              ),
              // CustomTextField.borderTextField(
              //   required: false,
              //   controller: boltQtyC,
              //   textInputType: TextInputType.number,
              //   inputFormatters: [
              //     FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d?')),
              //     FilteringTextInputFormatter.digitsOnly
              //   ],
              //   labelText: "Jumlah Baut",
              //   hintText: "Jumlah Baut",
              //   suffixIcon: Padding(
              //     padding: const EdgeInsets.fromLTRB(0, 14, 10, 0),
              //     child: Text(
              //       'Bolt',
              //       textAlign: TextAlign.right,
              //       style: TextStyle(color: Constant.redColor),
              //     ),
              //   ),
              // ),
              Constant.xSizedBox16,
              CustomTextField.borderTextField(
                required: false,
                controller: p.currentTorqueC,
                textInputType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d?')),
                  FilteringTextInputFormatter.digitsOnly
                ],
                labelText: "Torsi Terkini",
                hintText: "Torsi Terkini",
                onChange: p.onChangedCurrentTorque,
                suffixIcon: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 14, 10, 0),
                  child: Text(
                    'BAR/Psi/Nm',
                    textAlign: TextAlign.right,
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              Constant.xSizedBox16,
              CustomTextField.borderTextField(
                required: false,
                controller: p.maxTorqueC,
                textInputType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d?')),
                  FilteringTextInputFormatter.digitsOnly
                ],
                labelText: "Max Torsi",
                hintText: "Max Torsi",
                onChange: p.onChangedMaxTorque,
                suffixIcon: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 14, 10, 0),
                  child: Text(
                    'BAR/Psi/Nm',
                    textAlign: TextAlign.right,
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              Constant.xSizedBox16,
              CustomTextField.borderTextField(
                required: false,
                readOnly: true,
                enabled: false,
                controller: p.differenceQtyC,
                textInputType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d?')),
                  FilteringTextInputFormatter.digitsOnly
                ],
                labelText: "Jumlah Selisih",
                hintText: "Jumlah Selisih",
                suffixIcon: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 14, 10, 0),
                  child: Text(
                    'BAR/Psi/Nm',
                    textAlign: TextAlign.right,
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              Constant.xSizedBox16,
            ],
          ));
    }

    Widget detailShaft() {
      return CustomContainer.mainCard(
          margin: EdgeInsets.symmetric(horizontal: 20),
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
                    style: TextStyle(color: Colors.black),
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
                    style: TextStyle(color: Colors.black),
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
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              Constant.xSizedBox16,
              CustomTextField.borderTextField(
                enabled: false,
                readOnly: true,
                controller: p.rasioC,
                labelText: "Rasio",
                suffixIcon: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 14, 10, 0),
                  child: Text(
                    'mm',
                    textAlign: TextAlign.right,
                    style: TextStyle(color: Colors.black),
                  ),
                ),
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
        elevation: 1,
        shadowColor: Colors.black54,
      ),
      body: Container(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Constant.xSizedBox12,
                  detailUnit(),
                  Constant.xSizedBox16,
                  detailBaut(),
                  Constant.xSizedBox16,
                  detailShaft(),
                  Constant.xSizedBox24,
                ],
              ),
            ),
            CustomContainer.mainCard(
              radiusBorder: 0,
              padding: EdgeInsets.fromLTRB(10, 10, 10, 20),
              color: Colors.white,
              child: CustomButton.mainButton(
                borderRadius: BorderRadius.circular(10),
                contentPadding: EdgeInsets.symmetric(vertical: 5),
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
