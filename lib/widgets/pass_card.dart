import 'package:flip_card/flip_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter_swiper/src/swiper_controller.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:passbox/model/pass_info.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:passbox/model/provider.dart';
import 'package:passbox/screens/pass_swiper_screen.dart';

class PassCard extends StatefulWidget {
  final PassInfo passInfo;
  const PassCard({Key key, @required this.passInfo}) : super(key: key);
  @override
  _PassCard createState() => _PassCard();
}

class _PassCard extends State<PassCard> {
  List<AutoSizeGroup> groupList = [
    AutoSizeGroup(),
    AutoSizeGroup(),
    AutoSizeGroup(),
    AutoSizeGroup()
  ];

  bool back = false;
  bool removed = false;
  GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(5, 40, 5, 70),
          child: Hero(
            tag: widget.passInfo.id,
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 200),
              opacity: removed ? 0.0 : 1.0,
              child: FlipCard(
                key: cardKey,
                onFlipDone: (value) {
                  setState(() {
                    back = !value;
                  });
                },
                front: Card(
                  elevation: 20,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  shadowColor: widget.passInfo.labelColor.withAlpha(50),
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(30, 20, 30, 20),
                      child: Column(children: [
                        Padding(
                          padding: EdgeInsets.only(bottom: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [Icon(widget.passInfo.icon, size: 40)],
                          ),
                        ),
                        tableRow(widget.passInfo.headerFields,
                            hascolor: false, group: groupList[0]),
                        tableRow(
                            widget.passInfo.primaryFields.isEmpty
                                ? [Field("", widget.passInfo.logoText, "")]
                                : widget.passInfo.primaryFields,
                            hascolor: true,
                            group: groupList[1]),
                        tableRow(widget.passInfo.auxiliaryFields,
                            group: groupList[2]),
                        tableRow(widget.passInfo.secondaryFields,
                            group: groupList[3]),
                        Divider(),
                        Expanded(
                          child: BarcodeWidget(
                            padding: EdgeInsets.all(20),
                            barcode: widget.passInfo.bcImage.barcode,
                            data: widget.passInfo.bcImage.data,
                          ),
                        ),
                      ]),
                    ),
                  ),
                ),
                back: Card(
                  elevation: 20,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  shadowColor: widget.passInfo.labelColor.withAlpha(50),
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(30, 20, 30, 20),
                      child: ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return LinearGradient(
                            begin: Alignment(0, 1),
                            end: Alignment(0, 0.6),
                            colors: <Color>[Colors.transparent, Colors.white],
                          ).createShader(bounds);
                        },
                        child: ListView.builder(
                            itemCount: widget.passInfo.backFields.length,
                            itemBuilder: (BuildContext ctxt, int index) {
                              return Padding(
                                padding: EdgeInsets.only(bottom: 15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AutoSizeText(
                                      widget.passInfo.backFields[index].label,
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle2
                                          .copyWith(
                                              color:
                                                  widget.passInfo.labelColor),
                                      maxLines: 1,
                                    ),
                                    AutoSizeText(
                                      widget.passInfo.backFields[index].value,
                                      style:
                                          Theme.of(context).textTheme.subtitle2,
                                      maxFontSize: 30,
                                    ),
                                  ],
                                ),
                              );
                            }),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Align(
            alignment: Alignment(0.85, 1),
            child: AnimatedOpacity(
                duration: Duration(milliseconds: back ? 700 : 200),
                opacity: back ? 1.0 : 0.0,
                child: Container(
                  height: 55,
                  width: 55,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Colors.black),
                  child: IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      cardKey.currentState.toggleCard();
                      toast("Pass deleted");
                      PkpassProvider.of(context).value.sendEvent.add(
                          RemovePassEvent(widget.passInfo.appPath,
                              widget.passInfo.passPath));
                    },
                  ),
                )),
          ),
        ),
      ],
    );
  }

  Widget tableRow(List fields, {bool hascolor = false, AutoSizeGroup group}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        hascolor
            ? Divider(
                color: widget.passInfo.labelColor,
              )
            : Container(),
        Row(
          children: List.generate(
            fields.length,
            (index) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AutoSizeText(
                      fields[index].label,
                      style: Theme.of(context).textTheme.subtitle2.copyWith(
                          color: hascolor
                              ? widget.passInfo.labelColor
                              : Colors.black),
                      maxLines: 1,
                      minFontSize: 1,
                      group: group,
                    ),
                    AutoSizeText(
                      fields[index].value,
                      style: Theme.of(context).textTheme.bodyText2.copyWith(),
                      maxLines: 1,
                      minFontSize: 1,
                      group: group,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: hascolor
              ? Divider(
                  color: widget.passInfo.labelColor,
                )
              : Container(),
        ),
      ],
    );
  }
}

class MiniPassCard extends StatefulWidget {
  final int passIndex;
  final List<PassInfo> passList;
  final SwiperController swiperController;
  const MiniPassCard(
      {Key key,
      @required this.passIndex,
      @required this.passList,
      this.swiperController})
      : super(key: key);
  @override
  _MiniPassCard createState() => _MiniPassCard();
}

class _MiniPassCard extends State<MiniPassCard> {
  List<AutoSizeGroup> groupList = [AutoSizeGroup(), AutoSizeGroup()];
  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: widget.passList[widget.passIndex].id,
      child: Card(
        elevation: 20,
        margin: EdgeInsets.fromLTRB(10, 20, 10, 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        shadowColor: widget.passList[widget.passIndex].labelColor.withAlpha(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(30.0),
          onLongPress: () {
            showDialog<void>(
              context: context,
              barrierDismissible: false, // user must tap button!
              builder: (BuildContext context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30.0))),
                  title: Align(
                    alignment: Alignment.topCenter,
                    child: Text(
                      'Deleting Pass',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headline6.copyWith(fontWeight: FontWeight.normal),
                    ),
                  ),
                  content: SingleChildScrollView(
                    child: ListBody(
                      children: <Widget>[
                        Center(
                          child: Text("Are you sure?"),
                        ),
                        Padding(
                          padding: EdgeInsets.all(5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              FlatButton(
                                child: Text(
                                  'Yes',
                                  style: Theme.of(context).textTheme.headline6,
                                ),
                                onPressed: () {
                                  PkpassProvider.of(context)
                                      .value
                                      .sendEvent
                                      .add(RemovePassEvent(
                                          widget.passList[widget.passIndex]
                                              .appPath,
                                          widget.passList[widget.passIndex]
                                              .passPath));
                                  Navigator.of(context).pop();
                                },
                              ),
                              FlatButton(
                                child: Text(
                                  'No',
                                  style: Theme.of(context).textTheme.headline6,
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) {
                return PassSwiperScreen(
                  list: widget.passList,
                  currentIndex: widget.passIndex,
                  swiperController: widget.swiperController,
                );
              }),
            );
          },
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 20, top: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(widget.passList[widget.passIndex].icon, size: 40)
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: tableRow(widget.passList[widget.passIndex].headerFields,
                    hascolor: false, group: groupList[0]),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: tableRow(
                    widget.passList[widget.passIndex].primaryFields.isEmpty
                        ? [
                            Field(
                                "",
                                widget.passList[widget.passIndex].logoText,
                                "Pass")
                          ]
                        : widget.passList[widget.passIndex].primaryFields,
                    hascolor: true,
                    group: groupList[1]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget tableRow(List fields, {bool hascolor = false, AutoSizeGroup group}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        hascolor
            ? Divider(
                color: widget.passList[widget.passIndex].labelColor,
              )
            : Container(),
        Row(
          children: List.generate(
            fields.length,
            (index) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AutoSizeText(
                      fields[index].label,
                      style: Theme.of(context).textTheme.subtitle2.copyWith(
                          color: hascolor
                              ? widget.passList[widget.passIndex].labelColor
                              : Colors.black),
                      maxLines: 1,
                      minFontSize: 1,
                      group: group,
                    ),
                    AutoSizeText(
                      fields[index].value,
                      style: Theme.of(context).textTheme.bodyText2.copyWith(),
                      maxLines: 1,
                      minFontSize: 1,
                      group: group,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: hascolor
              ? Divider(
                  color: widget.passList[widget.passIndex].labelColor,
                )
              : Container(),
        ),
      ],
    );
  }
}
