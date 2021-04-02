import 'package:flutter/material.dart';

import 'ui/dashboard.dart';
import 'ui/desktop.dart';

void main(List<String> args) {
  if (args[1] == 'desktop')
    runApp(DesktopApp());
  else if (args[1] == 'dashboard')
    runApp(DashboardApp(
        args[2], DashboardUIStartupMode.values[int.parse(args[3])]));
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
  final String backgroundPath;
  final DashboardUIStartupMode startupMode;
  DashboardApp(this.backgroundPath, this.startupMode);

  @override
  _DashboardAppState createState() =>
      _DashboardAppState(this.backgroundPath, this.startupMode);
}

class _DashboardAppState extends State<DashboardApp> {
  final String backgroundPath;
  final DashboardUIStartupMode startupMode;
  _DashboardAppState(this.backgroundPath, this.startupMode);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'ExpidusOS Shell',
        theme: ThemeData.dark(),
        home: DashboardUI(this.backgroundPath, this.startupMode));
  }
}
