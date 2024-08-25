import 'package:hy_tutorial/common/base/base_state.dart';
import 'package:hy_tutorial/common/component/custom_button.dart';
import 'package:hy_tutorial/common/component/custom_container.dart';
import 'package:hy_tutorial/common/component/custom_navigator.dart';
import 'package:hy_tutorial/common/component/custom_textField.dart';
import 'package:hy_tutorial/common/helper/constant.dart';
import 'package:hy_tutorial/generated/assets.dart';
import 'package:hy_tutorial/src/auth/provider/auth_provider.dart';
import 'package:hy_tutorial/src/auth/view/register_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => LoginViewState();
}

class LoginViewState extends BaseState<LoginView> {
  AuthProvider authProvider = AuthProvider();
  @override
  void initState() {
    final authP = context.read<AuthProvider>();
    setController(authProvider);
    authP.loginViewState = this;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authP = context.watch<AuthProvider>();
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 120, 20, 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
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
                      "Masuk",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Username",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 10),
                    CustomTextField.borderTextField(
                      borderRadius: BorderRadius.circular(5),
                      controller: authP.usernameC,
                      fillColor: Colors.white,
                      hintColor: Constant.grayColor.withOpacity(0.5),
                      hintText: "Masukkan username",
                      onChanged: (v) {
                        setState(() {});
                      },
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
                      hintText: "Ketik kata sandi",
                      onChanged: (v) {
                        setState(() {});
                      },
                      labelFontSize: 20,
                      labelFontWeight: FontWeight.bold,
                      labelColor: Colors.black,
                      borderColor: Constant.grayColor.withOpacity(0.5),
                      obscureText: authP.obscurePass,
                      onEditingComplete: () async {
                        setState(() {});
                        if (authP.validateLogin())
                          await context.read<AuthProvider>().login(context);
                        setState(() {});
                      },
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
                    SizedBox(height: 20),
                    CustomButton.mainButton(
                      "Masuk",
                      () async {
                        setState(() {});
                        if (authP.validateLogin())
                          await context.read<AuthProvider>().login(context);
                        setState(() {});
                      },
                      borderRadius: BorderRadius.circular(10),
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                      enabled: authP.validateLogin(),
                      textStyle: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Belum Punya akun?"),
                  SizedBox(width: 5),
                  InkWell(
                    onTap: () => CusNav.nPush(context, RegisterView()),
                    child: Text(
                      "Daftar",
                      style: TextStyle(
                          color: Constant.primaryColor,
                          fontWeight: FontWeight.w600),
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
