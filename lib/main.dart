import 'package:flutter/material.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:shell/theme.dart';

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
        theme: tokyoThemeDark,
        home: Scaffold(
          appBar: AppBar(
              title: TextButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          tokyoThemeDark.appBarTheme.backgroundColor),
                      foregroundColor: MaterialStateProperty.all(
                          tokyoThemeDark.appBarTheme.foregroundColor)),
                  onPressed: () {
                    // TODO: open the dashboard or application's menu
                  },
                  child: const Text('ExpidusOS'))),
          body: SizedBox.expand(),
        ));
  }
}
