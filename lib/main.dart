import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:passbox/model/provider.dart';
import 'package:passbox/screens/pass_swiper_screen.dart';
import 'package:passbox/screens/settings_screen.dart';
import 'package:rxdart/rxdart.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:passbox/theme/theme.dart';
import 'package:passbox/widgets/pass_card.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:after_layout/after_layout.dart';
import 'package:passbox/widgets/tool_card.dart';
import 'package:qrscan/qrscan.dart' as scanner;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Streams are created so that app can respond to notification-related events since the plugin is initialised in the `main` function
final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
    BehaviorSubject<ReceivedNotification>();

final BehaviorSubject<String> selectNotificationSubject =
    BehaviorSubject<String>();

NotificationAppLaunchDetails notificationAppLaunchDetails;

Future<void> scheduleNotification(
    DateTime dateTime, String title, String body) async {
  var scheduledNotificationDateTime = dateTime;
  var vibrationPattern = Int64List(4);
  vibrationPattern[0] = 0;
  vibrationPattern[1] = 1000;
  vibrationPattern[2] = 5000;
  vibrationPattern[3] = 2000;

  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your other channel id',
      'your other channel name',
      'your other channel description',
      icon: '@mipmap/ic_launcher',
      sound: RawResourceAndroidNotificationSound('slow_spring_board'),
      vibrationPattern: vibrationPattern,
      enableLights: true,
      color: const Color.fromARGB(255, 255, 0, 0),
      ledColor: const Color.fromARGB(255, 255, 0, 0),
      ledOnMs: 1000,
      ledOffMs: 500);
  var iOSPlatformChannelSpecifics =
      IOSNotificationDetails(sound: 'slow_spring_board.aiff');
  var platformChannelSpecifics = NotificationDetails(
      androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.schedule(
      0, title, body, scheduledNotificationDateTime, platformChannelSpecifics);
}

class ReceivedNotification {
  final int id;
  final String title;
  final String body;
  final String payload;

  ReceivedNotification({
    @required this.id,
    @required this.title,
    @required this.body,
    @required this.payload,
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  var initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  // Note: permissions aren't requested here just to demonstrate that can be done later using the `requestPermissions()` method
  // of the `IOSFlutterLocalNotificationsPlugin` class
  var initializationSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      onDidReceiveLocalNotification:
          (int id, String title, String body, String payload) async {
        didReceiveLocalNotificationSubject.add(ReceivedNotification(
            id: id, title: title, body: body, payload: payload));
      });
  var initializationSettings = InitializationSettings(
      initializationSettingsAndroid, initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
    selectNotificationSubject.add(payload);
  });
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyApp createState() => _MyApp();
}

class _MyApp extends State<MyApp> {
  @override
  void dispose() {
    didReceiveLocalNotificationSubject.close();
    selectNotificationSubject.close();
    super.dispose();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return OverlaySupport(
      child: PkpassProvider(
        value: PkpassManager(),
        child: MaterialApp(
          title: 'FlipCard',
          home: HomePageScreen(),
          theme: lightTheme,
          builder: (context, child) {
            return ScrollConfiguration(
              behavior: MyBehavior(),
              child: child,
            );
          },
        ),
      ),
    );
  }
}

class HomePageScreen extends StatefulWidget {
  @override
  _HomePageScreen createState() => new _HomePageScreen();
}

class _HomePageScreen extends State<HomePageScreen>
    with AfterLayoutMixin<HomePageScreen> {
  SwiperController _swiperController;
  @override
  void initState() {
    // TODO: implement initState
    _swiperController = SwiperController();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _swiperController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> tools = [
      ToolCard(
        icon: Icons.find_replace,
        color: Colors.black,
        label: "Import Passes",
        function: () {
          PkpassProvider.of(context)
              .value
              .sendEvent
              .add(UpdatePassEvent(notification: true));
        },
      ),
      ToolCard(
        icon: Icons.filter_center_focus,
        color: Colors.black,
        label: "QR Scanner",
        function: () async {
          String cameraScanResult = await scanner.scan();
          if (await canLaunch(cameraScanResult)) {
            await launch(cameraScanResult);
          } else {
            throw 'Could not launch $cameraScanResult';
          }
        },
      ),
      // ToolCard(
      //   icon: Icons.folder_open,
      //   color: Colors.black,
      //   label: "Archived Passes",
      //   function: () {
      //     Navigator.push(
      //       context,
      //       CupertinoPageRoute(builder: (_) {
      //         return SettingsScreen();
      //       }),
      //     );
      //   },
      // ),
      Hero(
        tag: "settings",
        child: ToolCard(
          icon: Icons.more_horiz,
          color: Colors.black,
          label: "Settings",
          function: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) {
                return SettingsScreen();
              }),
            );
          },
        ),
      ),
    ];
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20, 30, 20, 0),
              child: Text(
                "Your Passes",
                style: Theme.of(context).textTheme.headline5,
              ),
            ),
            Expanded(
              flex: 3,
              child: StreamBuilder(
                initialData: [],
                stream: PkpassProvider.of(context).value.passesList,
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.hasData &&
                      snapshot.data != null &&
                      snapshot.data.isNotEmpty) {
                    return new Swiper(
                      loop: false,
                      viewportFraction: 0.7,
                      itemCount: snapshot.data.length,
                      controller: _swiperController,
                      itemBuilder: (BuildContext context, int index) {
                        return MiniPassCard(
                          passIndex: index,
                          passList: snapshot.data,
                          swiperController: _swiperController,
                        );
                      },
                    );
                  }
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: Icon(
                            Icons.book,
                            size: 50,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            "You don't have any passes yet, try to import them",
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Text(
                "Tools",
                style: Theme.of(context).textTheme.headline5,
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.only(bottom: 20, top: 10),
                child: Swiper(
                  itemCount: tools.length,
                  loop: false,
                  viewportFraction: 0.5,
                  itemBuilder: (BuildContext context, int index) {
                    return tools[index];
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void afterFirstLayout(BuildContext context) {
    PkpassProvider.of(context).value.sendEvent.add(OpenPassesEvent());
    PkpassProvider.of(context).value.sendEvent.add(
        GetSettingsPassEvent(PkpassProvider.of(context).settingsInfo.length));
    PkpassProvider.of(context).value.sendEvent.add(GetFoldersEvent());
  }
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
