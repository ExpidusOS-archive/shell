import 'package:flutter/material.dart';

final _TEXT_COLOR_DARK = Color.fromARGB(0xff, 0x78, 0x7c, 0x99);

final tokyoThemeDark = ThemeData(
    primaryColorDark: Color.fromARGB(0xff, 0x1a, 0x1b, 0x26),
    scaffoldBackgroundColor: Color.fromARGB(0xff, 0x16, 0x16, 0x1e),
    shadowColor: Color.fromARGB(0x00, 0xff, 0xff, 0xff),
    textTheme: TextTheme(
        headline1: TextStyle(color: _TEXT_COLOR_DARK),
        headline2: TextStyle(color: _TEXT_COLOR_DARK),
        headline3: TextStyle(color: _TEXT_COLOR_DARK),
        headline4: TextStyle(color: _TEXT_COLOR_DARK),
        headline5: TextStyle(color: _TEXT_COLOR_DARK),
        headline6: TextStyle(color: _TEXT_COLOR_DARK)),
    appBarTheme: AppBarTheme(
        backgroundColor: Color.fromARGB(0xff, 0x1a, 0x1b, 0x26),
        foregroundColor: _TEXT_COLOR_DARK));
