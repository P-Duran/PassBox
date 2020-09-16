import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';

enum PassType { boardingPass, coupon, eventTicket, generic, storeCard }

class PassInfo {
  final String passPath;
  final String appPath;
  final String id;
  final IconData icon;
  final PassType type;
  final Color foregroundColor;
  final Color backgroundColor;
  final Color labelColor;
  final String logoText;
  final String description;
  final BarcodeImage bcImage;
  final List<Field> headerFields;
  final List<Field> primaryFields;
  final List<Field> secondaryFields;
  final List<Field> auxiliaryFields;
  final List<Field> backFields;
  final DateTime relevantDate;
  final DateTime lastModified;

  PassInfo(
      {this.passPath,
      this.appPath,
      this.id,
      this.icon,
      this.type,
      this.foregroundColor,
      this.backgroundColor,
      this.labelColor,
      this.logoText,
      this.description,
      this.bcImage,
      this.headerFields,
      this.primaryFields,
      this.secondaryFields,
      this.auxiliaryFields,
      this.backFields,
      this.lastModified,
      this.relevantDate});

  static PassInfo jsonToPassInfo(
      String json, DateTime lastModified, String appPath, String passPath) {
    String _passPath = passPath;
    String _appPath = appPath;
    DateTime _lastModified = lastModified;
    var bytes1 = utf8.encode(json); // data being hashed
    String id = sha256.convert(bytes1).toString();
    Map<String, dynamic> data = jsonDecode(json);
    Color fColor = Utils.stringToColor(data['foregroundColor']);
    Color bColor = Utils.stringToColor(data['backgroundColor']);
    Color lColor = Utils.stringToColor(data['labelColor']);
    String ltext = data['logoText'] ?? "";
    String desc = data['description'] ?? "";
    BarcodeImage bcImage = BarcodeImage(data['barcode']['message'],
        Utils.stringToBarcodeType(data['barcode']['format']));
    DateTime relDate;
    try {
      if (data['relevantDate'] != null)
          relDate = DateTime.parse(data['relevantDate']); 
    } catch (_) {
      print("No relevant date");
    }
    Map passinfo;
    PassType passType;
    IconData icon;
    if (data['boardingPass'] != null) {
      passinfo = data['boardingPass'];
      passType = PassType.boardingPass;
      icon = Icons.card_travel;
    } else if (data['coupon'] != null) {
      passinfo = data['coupon'];
      passType = PassType.coupon;
      icon = Icons.local_offer;
    } else if (data['eventTicket'] != null) {
      passinfo = data['eventTicket'];
      passType = PassType.eventTicket;
      icon = Icons.event;
    } else if (data['generic'] != null) {
      passinfo = data['generic'];
      passType = PassType.generic;
      icon = Icons.local_activity;
    } else if (data['storeCard'] != null) {
      passinfo = data['storeCard'];
      passType = PassType.storeCard;
      icon = Icons.card_membership;
    }
    List<Field> hFields = Utils.jsonToFieldList(passinfo['headerFields']);
    List<Field> pFields = Utils.jsonToFieldList(passinfo['primaryFields']);
    List<Field> sFields = Utils.jsonToFieldList(passinfo['secondaryFields']);
    List<Field> aFields = Utils.jsonToFieldList(passinfo['auxiliaryFields']);
    List<Field> bFields = Utils.jsonToFieldList(passinfo['backFields']);
    print("rel date "+relDate.toString());
    return PassInfo(
        passPath: _passPath,
        appPath: _appPath,
        id: id,
        icon: icon,
        type: passType,
        foregroundColor: fColor,
        backgroundColor: bColor,
        labelColor: lColor,
        logoText: ltext,
        description: desc,
        bcImage: bcImage,
        headerFields: hFields,
        primaryFields: pFields,
        secondaryFields: sFields,
        auxiliaryFields: aFields,
        backFields: bFields,
        lastModified: _lastModified,
        relevantDate: relDate);
  }
}

class Utils {
  static Color stringToColor(String str) {
    List<Color> colors = [
      Colors.green[800],
      Colors.orange[800],
      Colors.blue[800],
      Colors.brown,
      Colors.purple,
      Colors.lime[700]
    ];
    try {
      List<int> rgb = str
          .substring(4, str.toString().length - 1)
          .split(",")
          .map((e) => int.parse(e))
          .toList();

      return rgb[0] + rgb[1] + rgb[2] < 600
          ? Color.fromRGBO(rgb[0], rgb[1], rgb[2], 1)
          : colors[Random().nextInt(colors.length)];
    } catch (_) {
      return colors[Random().nextInt(colors.length)];
    }
  }

  static Barcode stringToBarcodeType(String str) {
    str = str.toLowerCase();
    if (str.contains("qr")) {
      return Barcode.qrCode();
    }
    if (str.contains("pdf417")) {
      return Barcode.pdf417();
    }
    if (str.contains("aztec")) {
      return Barcode.aztec();
    }
    if (str.contains("code128")) {
      return Barcode.code128();
    }
    return null;
  }

  static List<Field> jsonToFieldList(var passinfo) {
    List<Field> fields = [];
    try {
      for (int i = 0; i < passinfo.length; i++) {
        fields.add(Field(passinfo[i]['key'] ?? "", passinfo[i]['label'] ?? "",
            passinfo[i]['value'] ?? ""));
      }
    } catch (_) {
      print("headerFields empty!!");
    }
    return fields;
  }
}

class Field {
  final String key;
  final String label;
  final String value;

  Field(this.key, this.label, this.value);
}

class BarcodeImage {
  final String data;
  final Barcode barcode;

  BarcodeImage(this.data, this.barcode);
}
