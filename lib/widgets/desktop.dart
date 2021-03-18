import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shell/widgets/minidash.dart';
import 'package:shell/widgets/quickswitch.dart';

final _overlayMessageChannel = MethodChannel('com.expidus.shell/overlay');

class DesktopUI extends StatefulWidget {
  @override
  _DesktopUIState createState() => _DesktopUIState();
}

class _DesktopUIState extends State<DesktopUI> {
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
    return Scaffold(
        drawer: QuickSwitch(),
        endDrawer: Minidash(),
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(30.0),
            child: AppBar(
                automaticallyImplyLeading: false,
                title: TextButton(
                    style: ButtonStyle(
                        textStyle: MaterialStateProperty.all(
                            Theme.of(context).appBarTheme.textTheme.headline5),
                        backgroundColor: MaterialStateProperty.all(
                            Theme.of(context).appBarTheme.backgroundColor),
                        foregroundColor: MaterialStateProperty.all(
                            Theme.of(context).appBarTheme.foregroundColor)),
                    onPressed: () {
                      // TODO: open the dashboard or application's menu
                    },
                    child: const Text('ExpidusOS')),
                actions: [
                  TextButton(
                      style: ButtonStyle(
                          textStyle: MaterialStateProperty.all(Theme.of(context)
                              .appBarTheme
                              .textTheme
                              .headline5),
                          backgroundColor: MaterialStateProperty.all(
                              Theme.of(context).appBarTheme.backgroundColor),
                          foregroundColor: MaterialStateProperty.all(
                              Theme.of(context).appBarTheme.foregroundColor)),
                      onPressed: () {
                        // TODO: add menu for calendar, right click for settings
                      },
                      child: Text(_timeString.toString()))
                ])),
        body: SizedBox.expand(),
        onDrawerChanged: (isOpened) {
          _overlayMessageChannel
              .invokeMethod('onDrawerChanged', isOpened)
              .onError((error, stackTrace) => {print(error.toString())});
        },
        onEndDrawerChanged: (isOpened) {
          _overlayMessageChannel
              .invokeMethod('onEndDrawerChanged', isOpened)
              .onError((error, stackTrace) => {print(error.toString())});
        });
  }
}
