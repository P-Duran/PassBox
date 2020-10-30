import 'package:after_layout/after_layout.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:passbox/model/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key key}) : super(key: key);
  @override
  _SettingsScreen createState() => new _SettingsScreen();
}

class _SettingsScreen extends State<SettingsScreen>
    with AfterLayoutMixin<SettingsScreen> {
  List<SettingData> switchSettings;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    switchSettings = PkpassProvider.of(context).settingsInfo;
    return Hero(
      tag: "settings",
      child: Scaffold(
        body: StreamBuilder(
          initialData: PkpassProvider.of(context).value.settingsList,
          stream: PkpassProvider.of(context).value.settings,
          builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
            List data;
            if (snapshot.hasData && snapshot.data.isNotEmpty)
              data = snapshot.data;
            else
              data = List.filled(switchSettings.length, false);
            return ListView.builder(
                itemCount: switchSettings.length + 2,
                itemBuilder: (BuildContext context, int index) {
                  if (index == switchSettings.length + 1)
                    return ListTile(
                      title: AutoSizeText(
                        "Restore Settings",
                        maxLines: 2,
                        minFontSize: 1,
                      ),
                      trailing: IconButton(
                          icon: Icon(Icons.settings_backup_restore),
                          onPressed: () async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            prefs.clear();
                            PkpassProvider.of(context).value.sendEvent.add(
                                GetSettingsPassEvent(switchSettings.length));
                            PkpassProvider.of(context)
                                .value
                                .sendEvent
                                .add(GetFoldersEvent());
                          }),
                    );
                  else if (index == switchSettings.length)
                    return AnimatedOpacity(
                      // If the widget is visible, animate to 0.0 (invisible).
                      // If the widget is hidden, animate to 1.0 (fully visible).
                      opacity: data[index - 1] ? 1.0 : 0,
                      duration: Duration(milliseconds: 200),
                      // The green box must be a child of the AnimatedOpacity widget.
                      child: StreamBuilder(
                        initialData:
                            PkpassProvider.of(context).value.folders_list,
                        stream: PkpassProvider.of(context).value.folders,
                        builder: (BuildContext context,
                            AsyncSnapshot<List> snapshot) {
                          var height = (snapshot.data.length * 35.0 + 100);
                          return AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            height: data[index - 1]
                                ? (height < 200) ? height : 200
                                : 0,
                            child: Column(
                              children: [
                                Flexible(
                                  child: ListTile(
                                    title: Text("Selected Folders"),
                                    trailing: IconButton(
                                      icon: Icon(Icons.folder),
                                      onPressed: () async {
                                        var res = await FilePicker.platform
                                            .getDirectoryPath();
                                        PkpassProvider.of(context)
                                            .value
                                            .sendEvent
                                            .add(AddFolderEvent(res));
                                      },
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: ConstrainedBox(
                                    constraints: new BoxConstraints(
                                      maxHeight: 100.0,
                                    ),
                                    child: Padding(
                                        padding: EdgeInsets.only(
                                            left: 30, right: 30),
                                        child: ListView.builder(
                                            itemCount: snapshot.data.length,
                                            itemBuilder:
                                                (BuildContext ctxt, int index) {
                                              return new Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(snapshot.data[index]),
                                                    Divider()
                                                  ]);
                                            })),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  else
                    return settingTile(data, switchSettings[index], index);
                });
          },
        ),
      ),
    );
  }

  Widget settingTile(List data, SettingData settingData, int index) {
    return Padding(
      padding: EdgeInsets.only(top: 5),
      child: ListTile(
        title: AutoSizeText(
          settingData.title,
          maxLines: 2,
          minFontSize: 1,
        ),
        subtitle: AutoSizeText(
          settingData.subtitle,
          maxLines: 1,
          minFontSize: 1,
        ),
        trailing: settingData.trailing ??
            CupertinoSwitch(
                onChanged: (bool value) {
                  data[index] = value;
                  PkpassProvider.of(context)
                      .value
                      .sendEvent
                      .add(UpdateSettingsPassEvent(data));
                },
                value: data[index],
                activeColor: Colors.blueGrey),
      ),
    );
  }

  @override
  void afterFirstLayout(BuildContext context) {
    PkpassProvider.of(context).value.sendEvent.add(
        GetSettingsPassEvent(PkpassProvider.of(context).settingsInfo.length));
    PkpassProvider.of(context).value.sendEvent.add(GetFoldersEvent());
  }
}

class SettingData {
  final String title;
  final String subtitle;
  final String key;
  final Widget trailing;

  SettingData(this.key, this.title, this.subtitle, {this.trailing});
}
