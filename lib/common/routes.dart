part of '../main.dart';

Map<String, WidgetBuilder> get _routes => <String, WidgetBuilder>{
      '/': (context) => SplashView(),
      '/boarding': (context) => BoardingView(),
      '/login': (context) => LoginView(),
      '/login2': (context) => LoginView2(),
      '/home': (context) => MainHome(),
      '/new_home': (context) => HomeView(),
      '/add_data': (context) => DataAddView(),
    };
