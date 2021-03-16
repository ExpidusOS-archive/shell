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
          appBar: PreferredSize(
              preferredSize: Size.fromHeight(30.0),
              child: AppBar(
                  title: TextButton(
                      style: ButtonStyle(
                          textStyle: MaterialStateProperty.all(
                              tokyoThemeDark.appBarTheme.textTheme.headline5),
                          backgroundColor: MaterialStateProperty.all(
                              tokyoThemeDark.appBarTheme.backgroundColor),
                          foregroundColor: MaterialStateProperty.all(
                              tokyoThemeDark.appBarTheme.foregroundColor)),
                      onPressed: () {
                        // TODO: open the dashboard or application's menu
                      },
                      child: const Text('ExpidusOS')),
                  actions: [
                    TextButton(
                        style: ButtonStyle(
                            textStyle: MaterialStateProperty.all(
                                tokyoThemeDark.appBarTheme.textTheme.headline5),
                            backgroundColor: MaterialStateProperty.all(
                                tokyoThemeDark.appBarTheme.backgroundColor),
                            foregroundColor: MaterialStateProperty.all(
                                tokyoThemeDark.appBarTheme.foregroundColor)),
                        onPressed: () {},
                        child: const Text('00:00 AM'))
                  ])),
          body: SizedBox.expand(),
        ));
  }
}
