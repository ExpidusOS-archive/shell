import 'dart:io';

import 'package:dbus/dbus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum DashboardUIStartupMode { NONE, LEFT_DRAWER, RIGHT_DRAWER }

class DashboardUI extends StatefulWidget {
  final String backgroundPath;
  final DashboardUIStartupMode startupMode;
  DashboardUI(this.backgroundPath, this.startupMode);

  @override
  _DashboardUIState createState() =>
      _DashboardUIState(this.backgroundPath, this.startupMode);
}

class _DashboardUIState extends State<DashboardUI> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  MethodChannel _channel = MethodChannel('com.expidus.shell/dashboard');

  final String backgroundPath;
  final DashboardUIStartupMode startupMode;
  _DashboardUIState(this.backgroundPath, this.startupMode);

  @override
  void initState() {
    super.initState();
    // TODO: open drawers if the right state is set on startup
    if (startupMode != DashboardUIStartupMode.NONE) {
      Future.microtask(() => startupMode == DashboardUIStartupMode.LEFT_DRAWER
          ? _scaffoldKey.currentState.openDrawer()
          : _scaffoldKey.currentState.openEndDrawer());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        drawer: Drawer(),
        endDrawer: Drawer(),
        body: TextButton(
            onPressed: () => _channel.invokeMethod('hideDashboard'),
            child: Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        colorFilter: ColorFilter.mode(
                            Colors.black.withOpacity(0.3), BlendMode.darken),
                        image: FileImage(new File(this.backgroundPath)))))));
  }
}
