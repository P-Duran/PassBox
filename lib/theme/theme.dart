import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    backgroundColor: Colors.black,
    focusColor: Colors.white,
    inputDecorationTheme:
        InputDecorationTheme(focusColor: Colors.blueGrey[700]),
    textTheme: TextTheme(
      subtitle2: TextStyle(fontWeight: FontWeight.bold),
      headline5:
          TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey[700]),
      headline6:
          TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey[700]),
    ),
    fontFamily: "Varela");
