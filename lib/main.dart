import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hy_tutorial/src/admin/provider/user_manage_provider.dart';
import 'package:hy_tutorial/src/auth/view/login_view.dart';
import 'package:hy_tutorial/src/auth/view/boarding_view.dart';
import 'package:hy_tutorial/src/data/provider/data_add_provider.dart';
import 'package:hy_tutorial/src/division/provider/division_provider.dart';
import 'package:hy_tutorial/src/home/view/home_new_view.dart';
import 'package:hy_tutorial/src/plta/provider/plta_provider.dart';
import 'package:hy_tutorial/src/turbine/provider/turbine_provider.dart';
import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:hy_tutorial/common/helper/constant.dart';
import 'package:hy_tutorial/src/auth/provider/auth_provider.dart';
import 'package:hy_tutorial/src/home/provider/home_provider.dart';
import 'package:hy_tutorial/src/home/view/main_home.dart';
import 'package:hy_tutorial/src/splash_view.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'src/profile/provider/profile_provider.dart';
import 'utils/nav_observer.dart';
import 'utils/utils.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

part 'common/routes.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    // initialize crashlytics
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    FirebaseMessaging.instance.getToken().then((value) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString(Constant.kSetPrefFcmToken, "${value ?? ""}");
      log("FCM token : $value");
    });

    await FirebaseMessaging.instance.setAutoInitEnabled(true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String initialRoute;

    if (kDebugMode) {
      log("[Bearer Token]");
      log(prefs.getString(Constant.kSetPrefToken) ?? "");
      log("[/Bearer Token]");

      log("[FCM Registration Token]");
      log(await FirebaseMessaging.instance.getToken() ?? "");
      log("[/FCM Registration Token]");
    }

    if (prefs.getString(Constant.kSetPrefToken) == null) {
      //not signed in
      initialRoute = '/';
    } else {
      //signed in
      initialRoute = '/';
    }

    log("INITIAL ROUTE : $initialRoute");
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Constant.primaryColor,
      systemNavigationBarColor: Constant.primaryColor,
      systemNavigationBarDividerColor: Constant.primaryColor,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.light,
    ));
    runApp(MyApp());
  }, (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  });
}

class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}

Future<bool> requestPermission(Permission permission) async {
  PermissionStatus status = await permission.request();
  return [PermissionStatus.granted, PermissionStatus.limited].contains(status);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // checkLang(context);
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider<DivisionProvider>(
                create: (context) => DivisionProvider()),
            ChangeNotifierProvider<DataAddProvider>(
                create: (context) => DataAddProvider()),
            ChangeNotifierProvider<UserManageProvider>(
                create: (context) => UserManageProvider()),
            ChangeNotifierProvider<ProfileProvider>(
                create: (context) => ProfileProvider()),
            ChangeNotifierProvider<PltaProvider>(
                create: (context) => PltaProvider()),
            ChangeNotifierProvider<TurbineProvider>(
                create: (context) => TurbineProvider()),
            ChangeNotifierProvider<AuthProvider>(
                create: (context) => AuthProvider()),
            ChangeNotifierProvider<HomeProvider>(
                create: (context) => HomeProvider()),
          ],
          child: MaterialApp(
            title: 'HY TUTORIAL',
            restorationScopeId: 'root',
            // localizationsDelegates: context.localizationDelegates,
            // supportedLocales: context.supportedLocales,
            // locale: context.locale,
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: [Locale('id', 'ID'), Locale('en')],
            locale: Locale('id'),
            navigatorObservers: [XNObsever()],
            navigatorKey: NavigationService.navigatorKey,
            theme: Constant.mainThemeData,
            color: Constant.primaryColor,
            initialRoute: '/',
            routes: _routes,
            builder: (context, child) {
              child = EasyLoading.init()(
                  context, child); // assuming this is returning a widget
              log(MediaQuery.of(context).size.toString());
              return MediaQuery(
                child: child,
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.linear(1.0)),
              );
            },
            debugShowCheckedModeBanner: false,
          ),
        );
      },
    );
  }
}

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  log("Handling a background message");
  log(message.data.toString());
}

Future<Response> WrapLoading<Response>(Future<Response> future) async {
  try {
    Utils.showLoading();
    Response data = await future;
    Utils.dismissLoading();
    return data;
  } catch (e) {
    Utils.dismissLoading();
    rethrow;
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
