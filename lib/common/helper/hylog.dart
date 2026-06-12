import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

enum HYLogType {
  database,
  discord,
}

class HYLog {
  String projectName = ""; // bedakan untuk tiap project
  String version = "";
  String id = "0"; // id, nama user / device
  HYLogType logType = HYLogType.database;
  String setDatabaseURL = "";
  String getDatabaseURL = "";
  String webHookURL = "";
  String emailAddress = "";

  String projectNameDef = "Hytutorial";
  HYLogType logTypeDef = HYLogType.database;
  String setDatabaseURLDef = 'http://47.74.214.215:82/mg-log/log/ceklog?';
  String getDatabaseURLDef = 'http://47.74.214.215:82/mg-log/log/cekgetlog?';
  String webHookURLDef =
      'https://discord.com/api/webhooks/943699876951261204/drIDDI6zY81pR2EzqRl6wBU5G34cUe_TofqPasEGraGfSDrs5kVQ0MtBHQigBv39Ifuk';
  String emailAddressDef = 'mgelog@mgesolution.com';

  String keySharedPreferences = 'MgeLog';
  final String _keyAlwaysLog = 'MgeAlwaysLog';

  HYLog(this.id,
      {this.projectName = "",
      this.version = "",
      this.logType = HYLogType.database,
      this.webHookURL = "",
      this.emailAddress = ""}) {
    projectName = projectName != "" ? projectName : projectNameDef;
    setDatabaseURL = setDatabaseURLDef;
    getDatabaseURL = getDatabaseURLDef;
  }

  void sendLog(String log) async {
    // Legacy database/discord direct sending method
  }

  void save(String log, {bool alwaysLog = true}) async {
    bool doLog = true;
    if (!alwaysLog) {
      doLog = await _getAlwaysLog();
    }

    if (doLog) {
      String formattedLog = _formatLog(id.toString(), log);
      _saveUnsendLog(formattedLog, date: DateTime.now());
    }
  }

  Future<bool> sendAll() async {
    return true;
  }

  Future<bool> shareAll() async {
    String unsendLog = await _getUnsendLog(days: 2);
    String title = "< PROJECT LOG: ${projectName.toString().toUpperCase()} >\r\n";
    if (unsendLog == "") {
      unsendLog = 'No Data';
    }
    String fileName = await _writeToFile("$title\r\n$unsendLog");

    if (fileName != '') {
      await Share.shareXFiles([XFile(fileName)], text: 'Log $projectName');
    } else {
      await Share.share(title + "\r\n" + unsendLog);
    }
    return true;
  }

  Future<String> saveLogToDownloads() async {
    try {
      if (Platform.isAndroid) {
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          await Permission.storage.request();
        }
        var manageStatus = await Permission.manageExternalStorage.status;
        if (!manageStatus.isGranted) {
          await Permission.manageExternalStorage.request();
        }
      }

      String unsendLog = await _getUnsendLog(days: 2);
      String title = "< PROJECT LOG: ${projectName.toString().toUpperCase()} >\r\n";
      if (unsendLog == "") {
        unsendLog = 'No Data';
      }
      String content = "$title\r\n$unsendLog";

      Directory? downloadDir;
      if (Platform.isAndroid) {
        downloadDir = Directory('/storage/emulated/0/Download');
        if (!downloadDir.existsSync()) {
          downloadDir = await getExternalStorageDirectory();
        }
      } else {
        downloadDir = await getDownloadsDirectory();
      }

      if (downloadDir == null) {
        return '';
      }

      String timestamp = DateFormat("yyyyMMdd_HHmmss").format(DateTime.now());
      String filePath = "${downloadDir.path}/${projectName.toLowerCase()}_log_$timestamp.txt";
      final File file = File(filePath);
      await file.writeAsString(content);
      return filePath;
    } catch (e) {
      dev.log("Error saving log to downloads: $e");
      return '';
    }
  }

  void clearAll() async {
    _clearLog();
  }

  Future<String> _writeToFile(String text) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/logfile.txt');
    await file.writeAsString(text);
    return '${directory.path}/logfile.txt';
  }

  void _saveUnsendLog(String logg, {required DateTime date}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String dateKey = DateFormat("yyyy-MM-dd").format(date);
    var data = prefs.getString("${keySharedPreferences}_$dateKey") ?? "";
    if (data != "") {
      data = "\r\n$data";
    }
    data = logg + data;
    prefs.setString("${keySharedPreferences}_$dateKey", data);
  }

  Future<String> _getUnsendLog({int days = 1}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String dateKey = DateFormat("yyyy-MM-dd").format(DateTime.now());
    String data = prefs.getString("${keySharedPreferences}_$dateKey") ?? "";

    for (int i = 2; i <= days; i++) {
      dateKey = DateFormat("yyyy-MM-dd")
          .format(DateTime.now().subtract(Duration(days: i - 1)));
      String currData =
          prefs.getString("${keySharedPreferences}_$dateKey") ?? "";
      if (data != "" && currData != "") {
        data = "$data\r\n";
      }
      data = data + currData;
    }

    return data;
  }

  void _clearLog() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Set<String> list = prefs.getKeys();
    for (var element in list) {
      if (element.toString().substring(0, keySharedPreferences.length) ==
          keySharedPreferences) {
        prefs.remove(element);
      }
    }
  }

  String _formatLog(String id, String message) {
    if (logType == HYLogType.database) {
      return "Id: $id ${DateFormat("[yyyy-MM-dd HH:mm:ss]").format(DateTime.now())} $message";
    } else if (logType == HYLogType.discord) {
      return "Id: $id ${DateFormat("[yyyy-MM-dd HH:mm:ss]").format(DateTime.now())}\r\n$message";
    } else {
      return '';
    }
  }

  Future<bool> _getAlwaysLog() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyAlwaysLog) ?? false;
  }

  void _setAlwaysLog(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(_keyAlwaysLog, value);
  }

  Future<dynamic> showLogDialog({required BuildContext context}) async {
    bool alwaysLog = await _getAlwaysLog();

    if (!context.mounted) return;

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.all(24),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        content: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text(
                "HYLOG Settings",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 20),
              buttonDialog(
                  context, "SHARE / WHATSAPP", const Color(0xFF25D366), const Color(0xFF25D366), Colors.white, () async {
                Navigator.of(context).pop();
                EasyLoading.show(status: 'Sharing log...');
                await shareAll();
                EasyLoading.dismiss();
              }),
              buttonDialog(
                  context, "SAVE TO DOWNLOADS", const Color(0xFF6366F1), const Color(0xFF6366F1), Colors.white, () async {
                Navigator.of(context).pop();
                EasyLoading.show(status: 'Saving log...');
                String path = await saveLogToDownloads();
                EasyLoading.dismiss();
                if (path.isNotEmpty) {
                  EasyLoading.showSuccess("Saved to Downloads:\n${path.split('/').last}");
                } else {
                  EasyLoading.showError("Failed to save log");
                }
              }),
              buttonDialog(
                  context, "SHOW LOG", Colors.blueGrey, Colors.blueGrey, Colors.white, () {
                Navigator.of(context).pop();
                showLogContentDialog(context: context);
              }),
              buttonDialog(
                  context, "CLEAR LOG", Colors.red, Colors.red, Colors.white, () {
                clearAll();
                Navigator.of(context).pop();
                EasyLoading.showSuccess("Logs cleared");
              }),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Always Log:", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
                  Switch(
                    value: alwaysLog,
                    activeColor: const Color(0xFF6366F1),
                    onChanged: (val) {
                      _setAlwaysLog(val);
                      Navigator.of(context).pop();
                      showLogDialog(context: context);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buttonDialog(BuildContext context, String caption, Color buttonColor,
      Color borderColor, Color textColor, Function() onClick) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: textColor,
          side: BorderSide(color: borderColor, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        onPressed: onClick,
        child: Text(
          caption,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Future<dynamic> showLogContentDialog({required BuildContext context}) async {
    String unsendLog = await _getUnsendLog(days: 1);
    String title = "PROJECT LOG: ${projectName.toString().toUpperCase()}";
    if (unsendLog == "") {
      unsendLog = 'No Data';
    }

    if (!context.mounted) return;

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.all(16),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        title: const Text("Log File Content",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
            textAlign: TextAlign.center),
        content: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(unsendLog, style: const TextStyle(fontFamily: 'monospace', color: Colors.black54)),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 45),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("CLOSE"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
