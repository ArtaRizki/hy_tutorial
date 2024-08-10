import 'package:hy_tutorial/common/base/base_state.dart';
import 'package:hy_tutorial/common/component/custom_button.dart';
import 'package:hy_tutorial/common/component/custom_navigator.dart';
import 'package:hy_tutorial/common/component/custom_textField.dart';
import 'package:hy_tutorial/common/helper/constant.dart';
import 'package:hy_tutorial/generated/assets.dart';
import 'package:hy_tutorial/src/auth/provider/auth_provider.dart';
import 'package:hy_tutorial/src/auth/view/new_register_view.dart';
import 'package:hy_tutorial/src/auth/view/register_view.dart';
import 'package:flutter/material.dart';
import 'package:hy_tutorial/src/auth/view/splash_screen_new_view.dart';
import 'package:hy_tutorial/src/home/view/new_home_view.dart';
import 'package:provider/provider.dart';

class NewLoginView extends StatefulWidget {
  const NewLoginView({super.key});

  @override
  State<NewLoginView> createState() => NewLoginViewState();
}

class NewLoginViewState extends BaseState<NewLoginView> {
  @override
  void initState() {
    final authP = context.read<AuthProvider>();
    authP.newLoginViewState = this;
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
              Image.asset(
                Assets.iconsIcAuth,
                scale: 3,
              ),
              SizedBox(
                height: 15,
              ),
              InkWell(
                onTap: () {
                  CusNav.nPush(context, NewHomeView());
                },
                child: Text(
                  "Masuk",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                    hintText: "Masukan username",
                    onChange: (v) {
                      setState(() {});
                    },
                    labelFontSize: 20,
                    labelFontWeight: FontWeight.bold,
                    labelColor: Constant.redisignColor,
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
                    onChange: (v) {
                      setState(() {});
                    },
                    labelFontSize: 20,
                    labelFontWeight: FontWeight.bold,
                    labelColor: Constant.redisignColor,
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
                        color: Constant.redisignColor,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              CustomButton.mainButton("Masuk", () async {
                if (authP.validateLogin())
                  await context.read<AuthProvider>().login(context);
              },
                  borderRadius: BorderRadius.circular(10),
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                  enabled: authP.validateLogin(),
                  textStyle: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.white)),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Belum Punya akun?"),
                  SizedBox(
                    width: 5,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => NewRegisterView()));
                    },
                    child: Text(
                      "Daftar",
                      style: TextStyle(
                          color: Constant.redisignColor, fontWeight: FontWeight.w600),
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
