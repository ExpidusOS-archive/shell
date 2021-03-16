import 'package:flutter/material.dart';
import 'package:desktop_window/desktop_window.dart';

void main() {
  runApp(PanelApp());
}

class PanelApp extends StatefulWidget {
  @override
  PanelAppState createState() => PanelAppState();
}

class PanelAppState extends State<PanelApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'ExpidusOS Shell - Panel',
        theme: ThemeData(
            primaryColor: Color.fromARGB(0xff, 0x1a, 0x1b, 0x26),
            backgroundColor: Color.fromARGB(0xff, 0x1a, 0x1b, 0x26),
            scaffoldBackgroundColor: Color.fromARGB(0xff, 0x1a, 0x1b, 0x26),
            colorScheme: ColorScheme.fromSwatch(
                primaryColorDark: Color.fromARGB(0xff, 0x1a, 0x1b, 0x26)),
            textTheme: TextTheme(
                headline1:
                    TextStyle(color: Color.fromARGB(0xff, 0xa9, 0xb1, 0xd6)),
                headline2:
                    TextStyle(color: Color.fromARGB(0xff, 0xa9, 0xb1, 0xd6)),
                headline3:
                    TextStyle(color: Color.fromARGB(0xff, 0xa9, 0xb1, 0xd6)),
                headline4:
                    TextStyle(color: Color.fromARGB(0xff, 0xa9, 0xb1, 0xd6)),
                headline5:
                    TextStyle(color: Color.fromARGB(0xff, 0xa9, 0xb1, 0xd6)),
                headline6:
                    TextStyle(color: Color.fromARGB(0xff, 0xa9, 0xb1, 0xd6)))),
        home: Scaffold(
          appBar: AppBar(title: const Text('ExpidusOS')),
          body: SizedBox.expand(),
        ));
  }
}
