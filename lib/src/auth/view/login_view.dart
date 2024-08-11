import 'package:hy_tutorial/common/base/base_state.dart';
import 'package:hy_tutorial/common/component/custom_button.dart';
import 'package:hy_tutorial/common/component/custom_textField.dart';
import 'package:hy_tutorial/common/helper/constant.dart';
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
              Image.asset(
                'assets/icons/ic-register.png',
                scale: 4,
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                "Selamat Datang",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                  "Selamat datang, sebelum login pastikan kamu memasukan akun dengan benar.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                      fontWeight: FontWeight.w300)),
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
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 10),
                  CustomTextField.borderTextField(
                    borderRadius: BorderRadius.circular(5),
                    controller: authP.usernameC,
                    fillColor: Colors.white,
                    hintColor: Constant.quarteryColor,
                    hintText: "Username",
                    onChange: (v) {
                      setState(() {});
                    },
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
                    onChange: (v) {
                      setState(() {});
                    },
                    labelFontSize: 20,
                    labelFontWeight: FontWeight.bold,
                    labelColor: Constant.primaryColor,
                    borderColor: Constant.primaryColor.withOpacity(0.5),
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
                ],
              ),
              SizedBox(height: 30),
              CustomButton.mainButtonSpinner("Masuk", () async {
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
                              builder: (context) => RegisterView()));
                    },
                    child: Text(
                      "Daftar",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w600),
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
