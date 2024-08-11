import 'package:flutter/material.dart';
import 'package:hy_tutorial/common/component/custom_button.dart';
import 'package:hy_tutorial/common/component/custom_navigator.dart';
import 'package:hy_tutorial/common/helper/constant.dart';
import 'package:hy_tutorial/generated/assets.dart';
import 'package:hy_tutorial/src/auth/view/new_login_view.dart';
import 'package:hy_tutorial/src/auth/view/new_register_view.dart';

class SplashScreenNewView extends StatefulWidget {
  const SplashScreenNewView({super.key});

  @override
  State<SplashScreenNewView> createState() => _SplashScreenNewViewState();
}

class _SplashScreenNewViewState extends State<SplashScreenNewView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.fromLTRB(15, 0, 15, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Image.asset(Assets.imagesImgSplashtop, scale: 1.5,),
            SizedBox(height: 20,),
            Text("Hello, Technician 👋", style: Constant.blackBold16.copyWith(fontWeight: FontWeight.w600),),
            SizedBox(height: 10,),
            Text("Selamat Datang di Hytutor Mobile"),
            SizedBox(height: 30,),
            CustomButton.mainButton("Masuk dengan Akun", color: Constant.redisignColor, borderRadius: BorderRadius.circular(10), contentPadding: EdgeInsets.all(10) ,() async {
              CusNav.nPush(context, NewLoginView());
            }),
            SizedBox(height: 15,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(color: Colors.grey.withOpacity(0.5), width: 94, height: 1,),
                SizedBox(width: 5,),
                Text("Belum memiliki akun?"),
                SizedBox(width: 5,),
                Container(color: Colors.grey.withOpacity(0.5), width: 94, height: 1,),
              ],
            ),
            SizedBox(height: 15,),
            CustomButton.secondaryButton("Daftar Akun",contentPadding: EdgeInsets.all(10),borderColor: Constant.redisignColor, textColor: Constant.redisignColor, borderRadius: BorderRadius.circular(10) ,() async {
              CusNav.nPush(context, NewRegisterView());
            }),
          ],
        ),
      ),
    );
  }
}
