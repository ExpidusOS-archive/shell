import 'package:flutter/material.dart';

import 'ui/dashboard.dart';
import 'ui/desktop.dart';

void main(List<String> args) {
  if (args[1] == 'desktop')
    runApp(DesktopApp());
  else if (args[1] == 'dashboard')
    runApp(DashboardApp());
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

class DashboardApp extends StatefulWidget {
  @override
  _DashboardAppState createState() => _DashboardAppState();
}

class _DashboardAppState extends State<DashboardApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'ExpidusOS Shell', theme: ThemeData.dark(), home: DashboardUI());
  }
}
