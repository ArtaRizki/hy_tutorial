import 'package:flutter/material.dart';
import 'package:hy_tutorial/common/helper/constant.dart';
import 'package:hy_tutorial/src/plta/model/plta_detail_model.dart';
import 'package:hy_tutorial/src/plta/provider/plta_provider.dart';
import 'package:hy_tutorial/utils/utils.dart';
import 'package:provider/provider.dart';
import '../../../common/base/base_state.dart';
import '../../division/provider/division_provider.dart';
import '../../../common/component/custom_appbar.dart';
import '../../../common/component/custom_button.dart';

class PltaAddView extends StatefulWidget {
  PltaAddView({super.key, this.data});
  PltaDetailModel? data;

  @override
  State<PltaAddView> createState() => PltaAddViewState();
}

class PltaAddViewState extends BaseState<PltaAddView> {
  @override
  void initState() {
    setData();
    super.initState();
  }

  setData() async {
    if (widget.data != null) {
      final data = widget.data;
      final p = context.read<PltaProvider>();
      p.nameC.text = data?.Data?.Name ?? '';
      p.totalUnitC.text = '${data?.Data?.Units?.length ?? 0}';
      setState(() {});
    } else {
      final p = context.read<PltaProvider>();
      p.nameC.text = '';
      p.totalUnitC.text = '';
      p.active = null;
      p.coordinateC.text = '';
      p.radiusC.text = '';
      p.radiusType = null;

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<PltaProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: widget.data != null
          ? CustomAppBar.appBar(context, "Edit Plta",
              color: Constant.primaryColor, foregroundColor: Colors.white)
          : CustomAppBar.appBar(context, "Tambah Plta",
              color: Constant.primaryColor, foregroundColor: Colors.white),
      body: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
          child: Column(children: [
            Expanded(
                child:
                    ListView(children: [...p.pltaForm(() => setState(() {}))])),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
              child: CustomButton.mainButton(
                'Submit',
                () async {
                  final dataP = context.read<PltaProvider>();
                  FocusManager.instance.primaryFocus?.unfocus();
                  String? msg;
                  //if (dataP.nameC.text.isEmpty) msg = 'Harap Isi Nama Lengkap';
                  //if (dataP.nipC.text.isEmpty) msg = 'Harap Isi NIP';
                  //if (dataP.roleC.text.isEmpty) msg = 'Harap Pilih Role';
                  //if (dataP.towernameC.text.isEmpty) msg = 'Harap Isi Pltaname';
                  //if (dataP.passwordC.text.isEmpty) msg = 'Harap Isi Password';
                  if (msg != null) {
                    Utils.showFailed(msg: msg);
                    return;
                  } else {
                    await Utils.showYesNoDialog(
                      context: context,
                      title: "Konfirmasi",
                      desc: "Apakah Data Anda Sudah Benar?",
                      yesCallback: () => handleTap(
                        () async {
                          Navigator.pop(context);
                          await dataP.sendPlta(context, back: true);
                        },
                      ),
                      noCallback: () => Navigator.pop(context),
                    );
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //         builder: ((context) => PltaView())));
                  }
                },
              ),
            ),
          ])),
    );
  }
}
