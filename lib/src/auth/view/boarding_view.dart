import 'package:flutter/material.dart';
import 'package:hy_tutorial/common/component/custom_button.dart';
import 'package:hy_tutorial/common/component/custom_navigator.dart';
import 'package:hy_tutorial/common/helper/constant.dart';
import 'package:hy_tutorial/generated/assets.dart';
import 'package:hy_tutorial/src/auth/view/login_view.dart';
import 'package:hy_tutorial/src/auth/view/register_view.dart';

class BoardingView extends StatefulWidget {
  const BoardingView({super.key});

  @override
  State<BoardingView> createState() => _BoardingViewState();
}

class _BoardingViewState extends State<BoardingView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.fromLTRB(15, 40, 15, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Image.asset(Assets.imagesImgSplashtop, scale: 1.5),
            SizedBox(height: 20),
            Text(
              "Hello, Technician 👋",
              style: Constant.blackBold16.copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 10),
            Text("Selamat Datang di Hytutor Mobile"),
            SizedBox(height: 30),
            CustomButton.mainButton("Masuk dengan Akun",
                color: Constant.primaryColor,
                borderRadius: BorderRadius.circular(10),
                contentPadding: EdgeInsets.all(10), () async {
              CusNav.nPush(context, LoginView());
            }),
            SizedBox(height: 15),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Container(
                    color: Colors.grey.withOpacity(0.5),
                    width: 94,
                    height: 1,
                  ),
                ),
                SizedBox(width: 5),
                Text("Belum memiliki akun?"),
                SizedBox(width: 5),
                Flexible(
                  child: Container(
                      color: Colors.grey.withOpacity(0.5),
                      width: 94,
                      height: 1),
                ),
              ],
            ),
            SizedBox(height: 15),
            CustomButton.secondaryButton("Daftar Akun",
                contentPadding: EdgeInsets.all(10),
                borderColor: Constant.primaryColor,
                textColor: Constant.primaryColor,
                borderRadius: BorderRadius.circular(10), () async {
              CusNav.nPush(context, RegisterView());
            }),
          ],
        ),
      ),
    );
  }
}
