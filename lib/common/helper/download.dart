import 'dart:developer';
import 'dart:io';
import 'package:hy_tutorial/common/component/custom_alert.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// INITIALIZATION SETTINGS ///
const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@drawable/notif_icon');

DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings(
  defaultPresentAlert: true,
  defaultPresentBadge: true,
  defaultPresentSound: true,
);
final InitializationSettings initializationSettings = InitializationSettings(
  android: initializationSettingsAndroid,
  iOS: initializationSettingsDarwin,
);

final NotificationDetails notificationDetails = NotificationDetails(
  android: AndroidNotificationDetails("HY TUTORIAL", "HY TUTORIAL",
      priority: Priority.max,
      playSound: true,
      enableVibration: true,
      importance: Importance.max,
      icon: '@drawable/notif_icon'),
  iOS: DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  ),
);

AndroidFlutterLocalNotificationsPlugin? androidFlutterLocalNotificationsPlugin;
IOSFlutterLocalNotificationsPlugin? iosFlutterLocalNotificationPlugin;

const AndroidNotificationChannel androidChannel = AndroidNotificationChannel(
    'Chatour Travel', 'Chatour Travel',
    importance: Importance.high, enableVibration: true, playSound: true);

Future<String?> getToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return (await prefs).getString('token');
}

downloadFile(
  BuildContext context,
  String link, {
  required String filename,
  bool openAfterDownload = false,
  required String typeFile,
}) async {
  try {
    await Permission.storage.request();
    await Permission.manageExternalStorage.request();
    var request = await HttpClient().getUrl(Uri.parse(link));
    request.headers.add('Connection', 'Keep-Alive');
    var token = await getToken();
    request.headers.add('Authorization', 'Bearer $token');
    var response = await request.close();
    if (response.statusCode == 200) {
      var bytes = await consolidateHttpClientResponseBytes(response);
      Directory? d;
      if (Platform.isAndroid) {
        d = await getExternalStorageDirectory();
        var directory = Directory("${d!.path}/hy_tutorial");
        bool dExists = directory.existsSync();
        if (!dExists) directory.createSync();
        File f = await File(d.path + "/hy_tutorial/$filename.$typeFile")
            .writeAsBytes(bytes);
        FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
            FlutterLocalNotificationsPlugin();

        flutterLocalNotificationsPlugin
            .getNotificationAppLaunchDetails()
            .then((details) {});
        if (openAfterDownload) {
          log("OPEN FILE:  ${openAfterDownload}");
          await flutterLocalNotificationsPlugin.initialize(
              initializationSettings,
              onDidReceiveNotificationResponse: (payload) {});
          await flutterLocalNotificationsPlugin.show(0, filename,
              "Download berhasil disimpan di ${f.path}", notificationDetails);
          await OpenFile.open(f.path);
        } else {
          await flutterLocalNotificationsPlugin
              .initialize(initializationSettings,
                  onDidReceiveNotificationResponse: (payload) {
            if (payload.payload != null) OpenFile.open(f.path);
          });
          await flutterLocalNotificationsPlugin.show(0, filename,
              "Download berhasil, Ketuk untuk buka file", notificationDetails);
        }
      } else {
        d = await getApplicationDocumentsDirectory();
        bool dExists = Directory("${d.path}/hy_tutorial").existsSync();
        if (!dExists) {
          Directory("${d.path}/hy_tutorial").createSync();
        }
        File f = await File(d.path + "/hy_tutorial/$filename.$typeFile")
            .writeAsBytes(bytes);
        FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
            FlutterLocalNotificationsPlugin();
        if (openAfterDownload) {
          await flutterLocalNotificationsPlugin.initialize(
              initializationSettings,
              onDidReceiveNotificationResponse: (payload) {});
          await flutterLocalNotificationsPlugin.show(
              0, filename, "Download berhasil", notificationDetails);
          await OpenFile.open(f.path);
        } else {
          await flutterLocalNotificationsPlugin
              .initialize(initializationSettings,
                  onDidReceiveNotificationResponse: (payload) {
            if (payload.payload != null) OpenFile.open(f.path);
          });
          await flutterLocalNotificationsPlugin.show(0, filename,
              "Download berhasil, Ketuk untuk buka file", notificationDetails);
        }
      }
    } else {
      CustomAlert.showSnackBar(
          context, "Gagal Download ${response.statusCode}", true);
      log('Error code: ' + response.statusCode.toString());
    }
  } catch (e) {
    CustomAlert.showSnackBar(context, "Gagal Download $e", true);
    log('Error : $e');
  }
}
