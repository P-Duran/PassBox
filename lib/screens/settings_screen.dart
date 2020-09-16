import 'package:after_layout/after_layout.dart';
import 'package:auto_size_text/auto_size_text.dart';
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
  List<TileData> switchSettings;
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
                itemCount: switchSettings.length + 1,
                itemBuilder: (BuildContext context, int index) {
                  return index >= switchSettings.length
                      ? ListTile(
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
                                    GetSettingsPassEvent(
                                        switchSettings.length));
                              }),
                        )
                      : settingTile(data, switchSettings[index].title,
                          switchSettings[index].subtitle, index);
                });
          },
        ),
      ),
    );
  }

  Widget settingTile(List data, String title, String subtitle, int index) {
    return Padding(
      padding: EdgeInsets.only(top: 5),
      child: ListTile(
        title: AutoSizeText(
          title,
          maxLines: 2,
          minFontSize: 1,
        ),
        subtitle: AutoSizeText(
          subtitle,
          maxLines: 1,
          minFontSize: 1,
        ),
        trailing: CupertinoSwitch(
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
  }
}

class TileData {
  final String title;
  final String subtitle;
  final String key;

  TileData(this.key, this.title, this.subtitle);
}
