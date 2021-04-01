import 'package:flutter/material.dart';

import 'ui/desktop.dart';

void main(List<String> args) {
  if (args[1] == 'desktop')
    runApp(DesktopApp());
  else
    throw new Exception('Invalid runtime mode: ${args[1]}');
}

class DesktopApp extends StatefulWidget {
  @override
  _DesktopAppState createState() => _DesktopAppState();
}

class _DesktopAppState extends State<DesktopApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'ExpidusOS Shell', theme: ThemeData.dark(), home: DesktopUI());
  }
}
