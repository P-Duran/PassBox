import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:passbox/screens/pass_creator_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:clipboard/clipboard.dart';

class QrDataScreen extends StatefulWidget {
  final String data;
  final String tag;

  const QrDataScreen({Key key, this.data, this.tag}) : super(key: key);

  @override
  _QrDataScreen createState() => new _QrDataScreen();
}

class _QrDataScreen extends State<QrDataScreen> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Hero(
      tag: widget.tag,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: ListView(
              children: [
                ListTile(
                  title: Text(
                    "Create PassBook",
                  ),
                  leading: Icon(Icons.add_circle_outline),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) {
                        return PassCreatorScreen(
                          data: widget.data,
                          tag: widget.tag,
                        );
                      }),
                    );
                  },
                ),
                Divider(),
                ListTile(
                  title: Text(
                    "Open Link",
                  ),
                  leading: Icon(
                    Icons.open_in_new,
                  ),
                  onTap: () async {
                    if (await canLaunch(widget.data)) {
                      await launch(widget.data);
                    } else {
                      showSimpleNotification(
                        Text(
                          "The QR content could not be opened",
                          style: TextStyle(color: Colors.blueGrey[700]),
                        ),
                        background: Colors.white,
                        position: NotificationPosition.bottom,
                        trailing: Icon(
                          Icons.error,
                          color: Colors.blueGrey[700],
                        ),
                      );
                    }
                  },
                ),
                Divider(),
                ListTile(
                  title: Text(
                    "Copy to Clipboard",
                  ),
                  leading: Icon(Icons.content_copy),
                  onTap: () async {
                    FlutterClipboard.copy(widget.data).then(
                      (value) => showSimpleNotification(
                        Text(
                          "QR Conted copied to the clipboard",
                          style: TextStyle(color: Colors.blueGrey[700]),
                        ),
                        background: Colors.white,
                        position: NotificationPosition.bottom,
                        trailing: Icon(
                          Icons.check,
                          color: Colors.blueGrey[700],
                        ),
                      ),
                    );
                  },
                ),
                Divider(),
                ListTile(
                  title: Text("QR Content"),
                  subtitle: Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text(widget.data)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
