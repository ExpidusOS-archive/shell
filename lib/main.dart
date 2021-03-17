import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shell/theme.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(PanelApp());
}

class PanelApp extends StatefulWidget {
  @override
  PanelAppState createState() => PanelAppState();
}

class PanelAppState extends State<PanelApp> {
  String _timeString;
  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 1), (Timer t) => _getTime());
  }

  void _getTime() {
    // TODO: add settings for seconds on clock (use jms)
    final time = DateFormat('jm').format(DateTime.now()).toString();
    setState(() {
      _timeString = time;
    });
  }

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
                        onPressed: () {
                          // TODO: add menu for calendar, right click for settings
                        },
                        child: Text(_timeString.toString()))
                  ])),
          body: SizedBox.expand(),
        ));
  }
}
