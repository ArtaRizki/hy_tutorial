import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hy_tutorial/generated/assets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../common/helper/constant.dart';

class SplashView extends StatefulWidget {
  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // init();
    super.didChangeDependencies();
  }

  void init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final isLoggedIn =
        prefs.getString(Constant.kSetPrefToken)?.isNotEmpty ?? false;
    final isAdmin = prefs.getBool(Constant.kSetPrefIsAdmin) ?? false;

    Timer(
      Duration(seconds: 1),
      () => Navigator.pushNamedAndRemoveUntil(
          context,
          isLoggedIn
              ? isAdmin
                  ? '/home'
                  : '/new_home'
              : '/boarding',
          arguments: isAdmin,
          (route) => false),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constant.primaryColor,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
                width: 200,
                height: 200,
                child: Image.asset(Assets.imagesImgSplashscreen,
                    width: 200, height: 200))
          ],
        ),
      ),
    );
  }
}
