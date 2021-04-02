import 'dart:io';

import 'package:dbus/dbus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:posix/posix.dart';
import 'package:shell/dbus/org.freedesktop.Accounts-remote.dart';
import 'package:shell/dbus/org.freedesktop.Accounts.User-remote.dart';

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
  DBusClient _dBusClient = DBusClient.system();
  OrgFreedesktopAccounts _accounts = OrgFreedesktopAccounts(
      DBusClient.system(), 'org.freedesktop.Accounts',
      path: DBusObjectPath('/org/freedesktop/Accounts'));

  final String backgroundPath;
  final DashboardUIStartupMode startupMode;
  _DashboardUIState(this.backgroundPath, this.startupMode);

  @override
  void initState() {
    super.initState();
    if (startupMode != DashboardUIStartupMode.NONE) {
      Future.microtask(() => startupMode == DashboardUIStartupMode.LEFT_DRAWER
          ? _scaffoldKey.currentState.openDrawer()
          : _scaffoldKey.currentState.openEndDrawer());
    }
  }

  Future<Widget> createUserWidget() async {
    final user = await this._accounts.callFindUserById(getuid()).then(
        (String value) => OrgFreedesktopAccountsUser(
            this._accounts.client, 'org.freedesktop.Accounts',
            path: DBusObjectPath(value)));

    final icon = await user.getIconFile();
    return DrawerHeader(
        child: new ListView(children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Padding(
            padding: const EdgeInsets.only(left: 2.0, right: 2.0),
            child: icon != null
                ? CircleAvatar(foregroundImage: FileImage(new File(icon)))
                : CircleAvatar(child: Icon(Icons.person))),
        Padding(
            padding: const EdgeInsets.only(left: 2.0, right: 2.0),
            child: Text(await user.getRealName()))
      ])
    ]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        drawer: Drawer(),
        endDrawer: new Drawer(
            child: new ListView(
          children: [
            FutureBuilder<Widget>(
                future: this.createUserWidget(),
                builder: (BuildContext context, AsyncSnapshot<Widget> data) {
                  if (data.hasData) {
                    return data.data;
                  } else if (data.hasError) {
                    throw data.error;
                  }
                  return CircularProgressIndicator();
                })
          ],
        )),
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
