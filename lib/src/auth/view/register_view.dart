import 'package:hy_tutorial/common/component/custom_button.dart';
import 'package:hy_tutorial/common/component/custom_dropdown.dart';
import 'package:hy_tutorial/common/component/custom_navigator.dart';
import 'package:hy_tutorial/common/component/custom_textField.dart';
import 'package:hy_tutorial/common/helper/constant.dart';
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
          padding: EdgeInsets.fromLTRB(20, 120, 20, 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/icons/ic-register.png', scale: 4),
              SizedBox(height: 15),
              Text(
                "Register",
                style: TextStyle(
                  color: Constant.primaryColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 15),
              Text(
                  "Silakan daftar dan masukan data diri anda, lalu tunggu sampai disetujui oleh admin",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                      fontWeight: FontWeight.w400)),
              SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Nama",
                    textAlign: TextAlign.start,
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  SizedBox(height: 10),
                  CustomTextField.borderTextField(
                    borderRadius: BorderRadius.circular(5),
                    controller: authP.nameC,
                    fillColor: Colors.white,
                    hintColor: Constant.quarteryColor,
                    hintText: "Nama",
                    labelFontSize: 20,
                    labelFontWeight: FontWeight.bold,
                    labelColor: Constant.primaryColor,
                    borderColor: Constant.primaryColor.withOpacity(0.5),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Divisi",
                    textAlign: TextAlign.start,
                    style: TextStyle(color: Colors.grey, fontSize: 14),
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
                    "Username",
                    textAlign: TextAlign.start,
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  SizedBox(height: 10),
                  CustomTextField.borderTextField(
                    borderRadius: BorderRadius.circular(5),
                    controller: authP.usernameC,
                    fillColor: Colors.white,
                    hintColor: Constant.quarteryColor,
                    hintText: "Username",
                    labelFontSize: 20,
                    labelFontWeight: FontWeight.bold,
                    labelColor: Constant.primaryColor,
                    borderColor: Constant.primaryColor.withOpacity(0.5),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Email",
                    textAlign: TextAlign.start,
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  SizedBox(height: 10),
                  CustomTextField.borderTextField(
                    borderRadius: BorderRadius.circular(5),
                    controller: authP.emailC,
                    fillColor: Colors.white,
                    hintColor: Constant.quarteryColor,
                    hintText: "Email",
                    labelFontSize: 20,
                    labelFontWeight: FontWeight.bold,
                    labelColor: Constant.primaryColor,
                    borderColor: Constant.primaryColor.withOpacity(0.5),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Password",
                    textAlign: TextAlign.start,
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  SizedBox(height: 10),
                  CustomTextField.borderTextField(
                    borderRadius: BorderRadius.circular(5),
                    controller: authP.passC,
                    fillColor: Colors.white,
                    hintColor: Constant.quarteryColor,
                    hintText: "Password",
                    labelFontSize: 20,
                    labelFontWeight: FontWeight.bold,
                    labelColor: Constant.primaryColor,
                    borderColor: Constant.primaryColor.withOpacity(0.5),
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
                    "Konfirmasi Password",
                    textAlign: TextAlign.start,
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  SizedBox(height: 10),
                  CustomTextField.borderTextField(
                    borderRadius: BorderRadius.circular(5),
                    controller: authP.passConfirmationC,
                    fillColor: Colors.white,
                    hintColor: Constant.quarteryColor,
                    hintText: "Password",
                    labelFontSize: 20,
                    labelFontWeight: FontWeight.bold,
                    labelColor: Constant.primaryColor,
                    borderColor: Constant.primaryColor.withOpacity(0.5),
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
                ],
              ),
              SizedBox(height: 30),
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
                        color: Colors.black,
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
