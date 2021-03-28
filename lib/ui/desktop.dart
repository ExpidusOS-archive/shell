import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DesktopUI extends StatefulWidget {
  @override
  _DesktopUIState createState() => _DesktopUIState();
}

class _DesktopUIState extends State<DesktopUI> {
  String _titleString = 'ExpidusOS';
  dynamic _titleIcon = Icons.apps;
  bool _isApp = false;
  final _desktopChannel = MethodChannel('com.expidus.shell/desktop.dart');

  @override
  void initState() {
    super.initState();

    _desktopChannel.setMethodCallHandler((call) {
      if (call.method == 'setCurrentApplication') {
        List<dynamic> args = List.from(call.arguments);
        if (!(args.length > 0 && args.length < 4)) {
          return Future.error(new Exception(
              'Invalid range, must be greater than zero and less than four (${args.length})'));
        }

        final isApp = args[0] as bool;
        final titleString = args.length >= 2 ? args[1] as String : 'ExpidusOS';
        final titleIcon = isApp
            ? (args.length == 3 ? args[2] as String : Icons.archive)
            : Icons.apps;

        setState(() {
          _isApp = isApp;
          _titleString = titleString;
          _titleIcon = titleIcon;
        });
        return Future.value(null);
      }
      return Future.error(call.noSuchMethod(Invocation.genericMethod(
          Symbol(call.method), call.arguments, call.arguments)));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(30),
            child: AppBar(
              automaticallyImplyLeading: false,
              leadingWidth: ((Theme.of(context).appBarTheme.textTheme == null
                                  ? Theme.of(context).textTheme
                                  : Theme.of(context).appBarTheme.textTheme)
                              .headline5
                              .fontSize *
                          _titleString.length) /
                      2 +
                  8,
              leading: TextButton(
                  style: ButtonStyle(
                      textStyle: MaterialStateProperty.all(
                          (Theme.of(context).appBarTheme.textTheme == null
                                  ? Theme.of(context).textTheme
                                  : Theme.of(context).appBarTheme.textTheme)
                              .headline5),
                      backgroundColor: MaterialStateProperty.all(
                          Theme.of(context).appBarTheme.backgroundColor),
                      foregroundColor: MaterialStateProperty.all(
                          Theme.of(context).appBarTheme.foregroundColor)),
                  onPressed: () {},
                  child: FittedBox(
                      fit: BoxFit.fitWidth,
                      child: Row(children: [
                        Center(
                            child: _titleIcon is String
                                ? Image.file(new File(_titleIcon as String),
                                    width: 22, height: 22)
                                : Icon(_titleIcon as IconData, size: 22)),
                        Text(_titleString)
                      ]))),
            )));
  }
}
