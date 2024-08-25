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
    getData();
    super.initState();
  }

  getData() async {
    final authP = context.read<AuthProvider>();
    authP.clearRegisterForm();
    await context.read<DivisionProvider>().fetchDivision(withLoading: true);
    authP.registerViewState = this;
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: 164,
                  height: 46,
                  child: Image.asset(
                    Assets.imagesImgSplashscreen,
                    width: 164,
                    height: 46,
                  ),
                ),
              ),
              SizedBox(height: 20),
              CustomContainer.mainCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Daftar",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    CustomTextField.borderTextField(
                      borderRadius: BorderRadius.circular(5),
                      controller: authP.nameC,
                      fillColor: Colors.white,
                      hintColor: Constant.grayColor.withOpacity(0.5),
                      hintText: "Masukkan nama",
                      labelText: "Nama",
                      labelColor: Colors.black,
                      borderColor: Constant.grayColor.withOpacity(0.5),
                      onChanged: (v) {
                        setState(() {});
                      },
                    ),
                    SizedBox(height: 10),
                    CustomTextField.borderTextField(
                      borderRadius: BorderRadius.circular(5),
                      controller: authP.emailC,
                      fillColor: Colors.white,
                      hintColor: Constant.grayColor.withOpacity(0.5),
                      hintText: "Masukkan email",
                      labelText: "Email",
                      labelColor: Colors.black,
                      borderColor: Constant.grayColor.withOpacity(0.5),
                      onChanged: (v) {
                        setState(() {});
                      },
                    ),
                    SizedBox(height: 10),
                    CustomDropdown.normalDropdown(
                      //controller: roleC,
                      iconPadding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                      contentPadding: EdgeInsets.all(2),
                      hintColor: Colors.black26,
                      borderColor: Constant.primaryColor,
                      labelText: "Divisi",
                      //selectedItem: selectedRole,
                      selectedItem: authP.selectedDivision,
                      hintText: "Divisi",
                      list: List.generate(
                        division.divisionModel.Data?.length ?? 0,
                        (index) => DropdownMenuItem(
                            child: Text(
                                division.divisionModel.Data?[index]?.Name ??
                                    ""),
                            value:
                                division.divisionModel.Data?[index]?.Id ?? ""),
                      ),
                      onChanged: (val) {
                        authP.selectedDivision = val;
                        setState(() {});
                      },
                    ),
                    SizedBox(height: 10),
                    CustomTextField.borderTextField(
                      borderRadius: BorderRadius.circular(5),
                      controller: authP.phoneNumberC,
                      fillColor: Colors.white,
                      hintColor: Constant.grayColor.withOpacity(0.5),
                      hintText: "Masukkan nomor telepon",
                      labelText: "No. Telepon",
                      labelColor: Colors.black,
                      borderColor: Constant.grayColor.withOpacity(0.5),
                      onChanged: (v) {
                        setState(() {});
                      },
                    ),
                    SizedBox(height: 10),
                    CustomTextField.borderTextField(
                      borderRadius: BorderRadius.circular(5),
                      controller: authP.usernameC,
                      fillColor: Colors.white,
                      hintColor: Constant.grayColor.withOpacity(0.5),
                      hintText: "Masukkan username",
                      labelText: "Username",
                      labelColor: Colors.black,
                      borderColor: Constant.grayColor.withOpacity(0.5),
                      onChanged: (v) {
                        setState(() {});
                      },
                    ),
                    SizedBox(height: 10),
                    CustomTextField.borderTextField(
                      borderRadius: BorderRadius.circular(5),
                      controller: authP.passC,
                      fillColor: Colors.white,
                      hintColor: Constant.grayColor.withOpacity(0.5),
                      hintText: "Ketik Kata Sandi",
                      labelText: "Kata Sandi",
                      labelColor: Colors.black,
                      borderColor: Constant.grayColor.withOpacity(0.5),
                      obscureText: authP.obscurePass,
                      suffixIcon: InkWell(
                        onTap: () => authP.toggleObscurePass(),
                        child: Icon(
                          authP.obscurePass
                              ? Icons.visibility_off_outlined
                              : Icons.visibility,
                          color: Constant.primaryColor,
                        ),
                      ),
                      onChanged: (v) {
                        setState(() {});
                      },
                    ),
                    SizedBox(height: 10),
                    CustomTextField.borderTextField(
                      borderRadius: BorderRadius.circular(5),
                      controller: authP.passConfirmationC,
                      fillColor: Colors.white,
                      hintColor: Constant.grayColor.withOpacity(0.5),
                      hintText: "Ketik konfirmasi kata sandi",
                      labelText: "Konfirmasi Kata Sandi",
                      labelColor: Colors.black,
                      borderColor: Constant.grayColor.withOpacity(0.5),
                      obscureText: authP.obscurePass1,
                      onEditingComplete: () async {
                        if (authP.validateRegister())
                          await context.read<AuthProvider>().register(context);
                      },
                      suffixIcon: InkWell(
                        onTap: () => authP.toggleObscurePass1(),
                        child: Icon(
                          authP.obscurePass1
                              ? Icons.visibility_off_outlined
                              : Icons.visibility,
                          color: Constant.primaryColor,
                        ),
                      ),
                      onChanged: (v) {
                        setState(() {});
                      },
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
              SizedBox(height: 40),
              Center(child: Image.asset(Assets.imagesImgBottom)),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
