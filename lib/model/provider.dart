import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:passbox/model/model.dart';
import 'package:passbox/model/pass_info.dart';
import 'package:passbox/screens/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';

class PkpassProvider extends InheritedWidget {
  PkpassProvider({
    Key key,
    @required this.value,
    @required Widget child,
  })  : assert(value != null),
        assert(child != null),
        assert(value != null),
        super(key: key, child: child);

  PkpassManager value;
  List<SettingData> settingsInfo = [
    SettingData(
      "Remove",
      "Super Delete",
      "Delete passes permanently",
    ),
    SettingData("Notifications", "Hide Notifications",
        "Activate if you hate notifications"),
    SettingData(
      "Folders",
      "Selective Scan",
      "Scan files only in the selected folders",
    ),
  ];
  static PkpassProvider of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PkpassProvider>();
  }

  @override
  bool updateShouldNotify(PkpassProvider old) => value != old.value;
}

class PkpassManager {
  List<PassInfo> _passList = [];
  List<bool> settingsList = [];
  List<String> folders_list = [];

  StreamController<List<PassInfo>> _passInfoStreamontroller =
      new StreamController.broadcast();
  Stream<List<PassInfo>> get passesList => _passInfoStreamontroller.stream;
  Sink<List<PassInfo>> get _passListSink => _passInfoStreamontroller.sink;

  StreamController<List<bool>> _settingsStreamontroller =
      new StreamController.broadcast();
  Stream<List<bool>> get settings => _settingsStreamontroller.stream;
  Sink<List<bool>> get _settingsSink => _settingsStreamontroller.sink;

  StreamController<List<String>> _foldersStreamontroller =
      new StreamController.broadcast();
  Stream<List<String>> get folders => _foldersStreamontroller.stream;
  Sink<List<String>> get _foldersSink => _foldersStreamontroller.sink;

  final _passEventController = StreamController<PassEvent>();
  Sink<PassEvent> get sendEvent => _passEventController.sink;

  PkpassManager() {
    _passEventController.stream.listen(_mapEventToState);
  }

  _mapEventToState(PassEvent event) async {
    if (event is UpdatePassEvent) {
      try {
        var value = await Model.extractPkpasses();
        if (event.notification) {
          showSimpleNotification(
              Text(
                value.isEmpty ? "No passes found" : "Passes have been added",
                style: TextStyle(color: Colors.blueGrey[700]),
              ),
              background: Colors.white,
              position: NotificationPosition.bottom,
              trailing: Icon(
                Icons.check,
                color: Colors.blueGrey[700],
              ));
          //toast(value.isEmpty?"No passes found":"All passes imported");
          _passList = value;
          _passListSink.add(_passList);
        }
      } catch (e) {
        var mailToSend = "mailto:pdhevs.supp@gmail.com?subject=bug>&body=$e";
        if (await canLaunch(mailToSend)) {
          await launch(mailToSend);
        } else {
          throw 'Could not launch $mailToSend';
        }
        showSimpleNotification(
            Text(
              "Ups, passes could not be imported!!",
              style: TextStyle(color: Colors.deepOrangeAccent[700]),
            ),
            background: Colors.white,
            position: NotificationPosition.bottom,
            trailing: Icon(
              Icons.sentiment_dissatisfied,
              color: Colors.deepOrangeAccent[700],
            ));
      }
    } else if (event is OpenPassesEvent) {
      Model.openPkpasses().then(
        (value) {
          _passList = value;
          _passListSink.add(_passList);
        },
      );
    } else if (event is RemovePassEvent) {
      Model.deletePkpass(event.appPath, event.passPath,
          permanently: settingsList.isEmpty ? false : settingsList[0]);
      Model.openPkpasses().then(
        (value) {
          _passList = value;
          _passListSink.add(_passList);
        },
      );
    } else if (event is UpdateSettingsPassEvent) {
      var _settings = event.settings.map((e) => e.toString()).toList();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('settings', _settings);
      settingsList = event.settings;
      _settingsSink.add(settingsList);
    } else if (event is GetSettingsPassEvent) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> _settings = prefs.getStringList('settings') ??
          List.generate(event.lentgh, (index) => "false");
      _settings = _settings.length != event.lentgh
          ? List.generate(event.lentgh, (index) => "false")
          : _settings;
      settingsList = _settings.map((e) => e == 'true').toList();
      _settingsSink.add(settingsList);
    } else if (event is GetFoldersEvent) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> _folders = prefs.getStringList('folders') ?? [];
      _foldersSink.add(_folders);
      folders_list = _folders;
    } else if (event is AddFolderEvent) {
      List<String> _folders = folders_list;
      if (event.folder != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        _folders = prefs.getStringList('folders') ?? [];
        _folders.add(event.folder);
        await prefs.setStringList('folders', _folders);
      }
      _foldersSink.add(_folders);
      folders_list = _folders;
    }
  }
}

class PassEvent {}

class UpdatePassEvent extends PassEvent {
  final bool notification;
  UpdatePassEvent({this.notification = false});
}

class OpenPassesEvent extends PassEvent {}

class RemovePassEvent extends PassEvent {
  final String appPath;
  final String passPath;
  RemovePassEvent(this.appPath, this.passPath);
}

class UpdateSettingsPassEvent extends PassEvent {
  final List<bool> settings;

  UpdateSettingsPassEvent(this.settings);
}

class GetSettingsPassEvent extends PassEvent {
  final int lentgh;

  GetSettingsPassEvent(this.lentgh);
}

class GetFoldersEvent extends PassEvent {}

class AddFolderEvent extends PassEvent {
  final String folder;

  AddFolderEvent(this.folder);
}

class ClearSettings extends PassEvent {}
