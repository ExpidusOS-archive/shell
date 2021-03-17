import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shell/theme.dart';
import 'package:intl/intl.dart';
import 'package:shell/widgets/minidash.dart';
import 'package:shell/widgets/quickswitch.dart';

void main() {
  runApp(DesktopApp());
}

class DesktopApp extends StatefulWidget {
  @override
  PanelAppState createState() => PanelAppState();
}

class PanelAppState extends State<DesktopApp> {
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
        title: 'ExpidusOS Shell',
        theme: tokyoThemeDark,
        home: Scaffold(
          drawer: QuickSwitch(),
          endDrawer: Minidash(),
          appBar: PreferredSize(
              preferredSize: Size.fromHeight(30.0),
              child: AppBar(
                  automaticallyImplyLeading: false,
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
