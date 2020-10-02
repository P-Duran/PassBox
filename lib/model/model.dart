import 'dart:io';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:passbox/model/pass_info.dart';
import 'package:passbox/model/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:passbox/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<List<PassInfo>> extractPkpasses() async {
  var status = await Permission.storage.status;
  if (status.isUndetermined) {
    // You can request multiple permissions at once.
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
      Permission.camera,
    ].request();
    print(statuses[
        Permission.storage]); // it should print PermissionStatus.granted
  }
  Directory externalDir = await getExternalStorageDirectory();
  Directory downDir = Directory("/storage/emulated/0");
  var status2 = await Permission.storage.status;
  if (!status2.isGranted) {
    await Permission.storage.request();
  }
  bool selectiveScan = false;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  try {
    List<String> _settings = prefs.getStringList('settings');
    selectiveScan = _settings[2] == 'false';
  } catch (_) {}
  List<FileSystemEntity> dirList = [];
  if (selectiveScan) {
    for (var filePath in prefs.getStringList('folders') ?? []) {
      var _dir = Directory(filePath);
      dirList..addAll(await _dir.list().toList());
    }
  } else {
    var dirListStream = downDir.list(recursive: true);
    dirList = await dirListStream.toList();
  }
  for (var element in dirList) {
    if (element.path.endsWith(".pkpass")) {
      try {
        var dir = Directory(externalDir.path +
            element.path.substring(
                element.path.lastIndexOf("/"), element.path.length - 1));
        if (!await dir.exists()) {
          var d = await dir.create();

          File file = File(dir.path + "/file.path");
          file.createSync();
          file.writeAsString(element.path);
          await ZipFile.extractToDirectory(
              zipFile: File(element.path), destinationDir: d);
        }
      } catch (e) {
        print(e);
      }
    }
  }

  return await openPkpasses();
}

Future<List<PassInfo>> openPkpasses({Directory directory}) async {
  List<PassInfo> passInfoList = [];
  directory = directory ?? await getExternalStorageDirectory();
  var jsonpkpasses = directory.list(recursive: true);
  var a = await jsonpkpasses.toList();
  Directory parent;
  File file;
  for (var element in a) {
    try {
      if (element.path.endsWith("/pass.json")) {
        File filepath = element.parent
            .listSync()
            .firstWhere((e) => e.path.endsWith("file.path"));
        String contents = await filepath.readAsString();
        file = File(element.path);
        String text = await file.readAsString();
        parent = file.parent;
        passInfoList.add(PassInfo.jsonToPassInfo(
            text, filepath.lastModifiedSync(), parent.path, contents));
      }
    } catch (_) {
      parent.deleteSync(recursive: true);
      toast(parent.path
              .substring(parent.path.lastIndexOf("/") + 1, parent.path.length) +
          " could not be readed");
    }
  }
  passInfoList.sort((b, a) => a.lastModified.compareTo(b.lastModified));
  await flutterLocalNotificationsPlugin.cancelAll();
  for (var e in passInfoList) {
    if (e.relevantDate != null &&
        e.relevantDate.compareTo(DateTime.now()) >= 0) {
      String body;
      try {
        body = e.primaryFields[0].label +
            " " +
            e.primaryFields[0].value +
            " - " +
            e.primaryFields[1].label +
            " " +
            e.primaryFields[1].value;
      } catch (_) {
        body = "Today at " +
            e.relevantDate.hour.toString() +
            ":" +
            e.relevantDate.minute.toString();
      }
      bool notificationAllowed = true;
      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        List<String> _settings = prefs.getStringList('settings');
        notificationAllowed = _settings[1] == 'false';
      } catch (_) {
        print("Ups el true/false de las notifcaciones no fuca");
      }
      if (notificationAllowed)
        scheduleNotification(e.relevantDate,
            e.logoText != "" ? e.logoText : e.description, body);
    }
  }
  return passInfoList;
}

deletePkpass(String appPath, String passPath, {bool permanently = false}) {
  File(appPath).deleteSync(recursive: true);
  if (permanently) File(passPath).deleteSync();
}
