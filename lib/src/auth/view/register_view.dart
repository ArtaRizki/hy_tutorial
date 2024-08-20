import 'package:hy_tutorial/common/component/custom_button.dart';
import 'package:hy_tutorial/common/component/custom_container.dart';
import 'package:hy_tutorial/common/component/custom_dropdown.dart';
import 'package:hy_tutorial/common/component/custom_navigator.dart';
import 'package:hy_tutorial/common/component/custom_textField.dart';
import 'package:hy_tutorial/common/helper/constant.dart';
import 'package:hy_tutorial/generated/assets.dart';
import 'package:hy_tutorial/src/auth/provider/auth_provider.dart';
import 'package:hy_tutorial/src/auth/view/login_view.dart';
import 'package:hy_tutorial/src/division/provider/division_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => RegisterViewState();
}

class RegisterViewState extends State<RegisterView> {
  @override
  void initState() {
    context.read<DivisionProvider>().fetchDivision();
    context.read<AuthProvider>().clearRegisterForm();

    final authP = context.read<AuthProvider>();
    authP.registerViewState = this;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final division = context.watch<DivisionProvider>();
    final authP = context.watch<AuthProvider>();
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 50, 20, 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(Assets.iconsIcAuth, scale: 3),
              SizedBox(height: 15),
              Text(
                "Daftar",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              CustomContainer.mainCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Email",
                      textAlign: TextAlign.start,
                      style: TextStyle(color: Colors.black, fontSize: 14),
                    ),
                    SizedBox(height: 10),
                    CustomTextField.borderTextField(
                      borderRadius: BorderRadius.circular(5),
                      controller: authP.emailC,
                      fillColor: Colors.white,
                      hintColor: Constant.grayColor.withOpacity(0.5),
                      hintText: "Masukan email",
                      labelFontSize: 20,
                      labelFontWeight: FontWeight.bold,
                      labelColor: Colors.black,
                      borderColor: Constant.grayColor.withOpacity(0.5),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Divisi",
                      textAlign: TextAlign.start,
                      style: TextStyle(color: Colors.black, fontSize: 14),
                    ),
                    SizedBox(height: 10),
                    CustomDropdown.searchDropdown(
                      required: true,
                      list: List.generate(
                          division.divisionModel.Data?.length ?? 0,
                          (index) =>
                              division.divisionModel.Data?[index]?.Name ?? ""),
                      onChanged: (val) {
                        final p = context.read<AuthProvider>();
                        String? selected = (division.divisionModel.Data ?? [])
                            .firstWhere((element) => element?.Name == val)
                            ?.Id;
                        if (selected != null && val != null) {
                          p.selectedDivision = selected;
                          p.selectedDivisionC.text = val;
                        }
                      },
                    ),
                    SizedBox(height: 10),
                    Text(
                      "No. Telepon",
                      textAlign: TextAlign.start,
                      style: TextStyle(color: Colors.black, fontSize: 14),
                    ),
                    SizedBox(height: 10),
                    CustomTextField.borderTextField(
                      borderRadius: BorderRadius.circular(5),
                      controller: authP.nameC,
                      fillColor: Colors.white,
                      hintColor: Constant.grayColor.withOpacity(0.5),
                      hintText: "Masukan nomor telepon",
                      labelFontSize: 20,
                      labelFontWeight: FontWeight.bold,
                      labelColor: Colors.black,
                      borderColor: Constant.grayColor.withOpacity(0.5),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Username",
                      textAlign: TextAlign.start,
                      style: TextStyle(color: Colors.black, fontSize: 14),
                    ),
                    SizedBox(height: 10),
                    CustomTextField.borderTextField(
                      borderRadius: BorderRadius.circular(5),
                      controller: authP.usernameC,
                      fillColor: Colors.white,
                      hintColor: Constant.grayColor.withOpacity(0.5),
                      hintText: "Masukan username",
                      labelFontSize: 20,
                      labelFontWeight: FontWeight.bold,
                      labelColor: Colors.black,
                      borderColor: Constant.grayColor.withOpacity(0.5),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Kata Sandi",
                      textAlign: TextAlign.start,
                      style: TextStyle(color: Colors.black, fontSize: 14),
                    ),
                    SizedBox(height: 10),
                    CustomTextField.borderTextField(
                      borderRadius: BorderRadius.circular(5),
                      controller: authP.passC,
                      fillColor: Colors.white,
                      hintColor: Constant.grayColor.withOpacity(0.5),
                      hintText: "Ketik Kata Sandi",
                      labelFontSize: 20,
                      labelFontWeight: FontWeight.bold,
                      labelColor: Colors.black,
                      borderColor: Constant.grayColor.withOpacity(0.5),
                      obscureText: authP.obscurePass,
                      onEditingComplete: () async =>
                          await context.read<AuthProvider>().login(context),
                      suffixIcon: InkWell(
                        onTap: () => authP.toggleObscurePass(),
                        child: Icon(
                          authP.obscurePass
                              ? Icons.visibility_off_outlined
                              : Icons.visibility,
                          color: Constant.primaryColor,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Konfirmasi Kata Sandi",
                      textAlign: TextAlign.start,
                      style: TextStyle(color: Colors.black, fontSize: 14),
                    ),
                    SizedBox(height: 10),
                    CustomTextField.borderTextField(
                      borderRadius: BorderRadius.circular(5),
                      controller: authP.passConfirmationC,
                      fillColor: Colors.white,
                      hintColor: Constant.grayColor.withOpacity(0.5),
                      hintText: "Ketik konfirmasi kata sandi",
                      labelFontSize: 20,
                      labelFontWeight: FontWeight.bold,
                      labelColor: Colors.black,
                      borderColor: Constant.grayColor.withOpacity(0.5),
                      obscureText: authP.obscurePass1,
                      onEditingComplete: () async =>
                          await context.read<AuthProvider>().login(context),
                      suffixIcon: InkWell(
                        onTap: () => authP.toggleObscurePass1(),
                        child: Icon(
                          authP.obscurePass1
                              ? Icons.visibility_off_outlined
                              : Icons.visibility,
                          color: Constant.primaryColor,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    CustomButton.mainButton(
                      "Daftar",
                      () async {
                        if (authP.validateRegister())
                          await context.read<AuthProvider>().register(context);
                      },
                      borderRadius: BorderRadius.circular(10),
                      enabled: authP.validateRegister(),
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                      textStyle: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.white),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Sudah memiliki akun?"),
                  SizedBox(width: 5),
                  InkWell(
                    onTap: () => CusNav.nPush(context, LoginView()),
                    child: Text(
                      "Masuk",
                      style: TextStyle(
                        color: Constant.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
