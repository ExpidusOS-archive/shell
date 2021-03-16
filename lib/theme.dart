import 'package:flutter/material.dart';

final _TEXT_COLOR_DARK = Color.fromARGB(0xff, 0x78, 0x7c, 0x99);

final _TEXT_STYLE_H1_DARK = TextStyle(color: _TEXT_COLOR_DARK, fontSize: 35);
final _TEXT_STYLE_H2_DARK = TextStyle(color: _TEXT_COLOR_DARK, fontSize: 30);
final _TEXT_STYLE_H3_DARK = TextStyle(color: _TEXT_COLOR_DARK, fontSize: 25);
final _TEXT_STYLE_H4_DARK = TextStyle(color: _TEXT_COLOR_DARK, fontSize: 20);
final _TEXT_STYLE_H5_DARK = TextStyle(color: _TEXT_COLOR_DARK, fontSize: 15);
final _TEXT_STYLE_H6_DARK = TextStyle(color: _TEXT_COLOR_DARK, fontSize: 10);

final _TEXT_THEME_DARK = TextTheme(
    headline1: _TEXT_STYLE_H1_DARK,
    headline2: _TEXT_STYLE_H2_DARK,
    headline3: _TEXT_STYLE_H3_DARK,
    headline4: _TEXT_STYLE_H4_DARK,
    headline5: _TEXT_STYLE_H5_DARK,
    headline6: _TEXT_STYLE_H6_DARK);

final tokyoThemeDark = ThemeData(
    primaryColorDark: Color.fromARGB(0xff, 0x1a, 0x1b, 0x26),
    scaffoldBackgroundColor: Color.fromARGB(0xff, 0x16, 0x16, 0x1e),
    shadowColor: Color.fromARGB(0x00, 0xff, 0xff, 0xff),
    textTheme: _TEXT_THEME_DARK,
    appBarTheme: AppBarTheme(
        textTheme: _TEXT_THEME_DARK,
        backgroundColor: Color.fromARGB(0xff, 0x1a, 0x1b, 0x26),
        foregroundColor: _TEXT_COLOR_DARK));
