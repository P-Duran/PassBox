import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:passbox/model/model.dart';
import 'package:passbox/model/pass_info.dart';
import 'package:passbox/screens/settings_screen.dart';
import 'package:passbox/theme/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  List<TileData> settingsInfo = [
    TileData(
        "Remove", "Super Delete", "Delete passes permanently"),
    TileData("Notifications", "Hide Notifications",
        "Activate if you hate notifications")
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

  StreamController<List<PassInfo>> _passInfoStreamontroller =
      new StreamController.broadcast();
  Stream<List<PassInfo>> get passesList => _passInfoStreamontroller.stream;
  Sink<List<PassInfo>> get _passListSink => _passInfoStreamontroller.sink;

  StreamController<List<bool>> _settingsStreamontroller =
      new StreamController.broadcast();
  Stream<List<bool>> get settings => _settingsStreamontroller.stream;
  Sink<List<bool>> get _settingsSink => _settingsStreamontroller.sink;

  final _passEventController = StreamController<PassEvent>();
  Sink<PassEvent> get sendEvent => _passEventController.sink;

  PkpassManager() {
    _passEventController.stream.listen(_mapEventToState);
  }

  _mapEventToState(PassEvent event) async {
    if (event is UpdatePassEvent) {
      try {
        var value = await extractPkpasses();
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
      } catch (_) {
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
      print("OpenPassesEvent");
      openPkpasses().then(
        (value) {
          _passList = value;
          _passListSink.add(_passList);
        },
      );
    } else if (event is RemovePassEvent) {
      deletePkpass(event.appPath, event.passPath,
          permanently: settingsList.isEmpty ? false : settingsList[0]);
      openPkpasses().then(
        (value) {
          _passList = value;
          _passListSink.add(_passList);
        },
      );
    } else if (event is UpdateSettingsPassEvent) {
      var _settings = event.settings.map((e) => e.toString()).toList();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('settings', _settings);
      print("Updatesettings " + _settings.toString());
      settingsList = event.settings;
      _settingsSink.add(settingsList);
    } else if (event is GetSettingsPassEvent) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> _settings = prefs.getStringList('settings') ??
          List.generate(event.lentgh, (index) => "false");
      _settings = _settings.length != event.lentgh
          ? List.generate(event.lentgh, (index) => "false")
          : _settings;
      print('settings $_settings');
      settingsList = _settings.map((e) => e == 'true').toList();
      _settingsSink.add(settingsList);
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
