import 'dart:async';
import 'dart:io';

import 'package:dbus/dbus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:posix/posix.dart';
import 'package:nm/nm.dart';
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
  OrgFreedesktopAccounts _accounts = OrgFreedesktopAccounts(
      DBusClient.system(), 'org.freedesktop.Accounts',
      path: DBusObjectPath('/org/freedesktop/Accounts'));
  NetworkManagerClient _nmClient = NetworkManagerClient(DBusClient.system());
  var _indicators = {
    'wifi': true,
    'cellular': true,
    'location': false,
    'bluetooth': false,
    'notifications': true,
    'airplane-mode': false
  };
  String _fullDateTime = '';

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

    this
        ._accounts
        .callFindUserById(getuid())
        .then((String value) => OrgFreedesktopAccountsUser(
                this._accounts.client, 'org.freedesktop.Accounts',
                path: DBusObjectPath(value))
            .getLanguage())
        .then((String lang) => initializeDateFormatting(lang, null));

    _nmClient
        .connect()
        .onError(
            (error, stackTrace) => print('Failed to connect to NM: $error'))
        .then((nullValue) {
      this._indicators['wifi'] = _nmClient.wirelessEnabled;
      this._indicators['cellular'] = _nmClient.wwanEnabled;
    });

    Timer.periodic(
        Duration(seconds: 1),
        (Timer t) => _getTime().onError(
            (error, stackTrace) => print('Failed to update the time: $error')));
  }

  Future<void> _getTime() async {
    final now = DateTime.now();
    final user = await this._accounts.callFindUserById(getuid()).then(
        (String value) => OrgFreedesktopAccountsUser(
            this._accounts.client, 'org.freedesktop.Accounts',
            path: DBusObjectPath(value)));
    final fullDateTime =
        DateFormat('E MMM d, ', await user.getLanguage()).add_jms().format(now);

    setState(() {
      _fullDateTime = fullDateTime;
    });
  }

  Future<Widget> createUserWidget() async {
    final user = await this._accounts.callFindUserById(getuid()).then(
        (String value) => OrgFreedesktopAccountsUser(
            this._accounts.client, 'org.freedesktop.Accounts',
            path: DBusObjectPath(value)));

    final icon = await user.getIconFile();
    final realName = await user.getRealName();
    final username = await user.getUserName();
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Padding(
          padding: const EdgeInsets.only(left: 2.0, right: 2.0),
          child: icon != null
              ? CircleAvatar(foregroundImage: FileImage(new File(icon)))
              : CircleAvatar(child: Icon(Icons.person))),
      Padding(
          padding: const EdgeInsets.only(left: 2.0, right: 2.0),
          child: Text(realName == null ? username : realName))
    ]);
  }

  NetworkManagerDevice _findWiFiDevice() {
    final devs = this._nmClient.allDevices.where((dev) =>
        dev.wireless != null &&
        (dev.deviceType == NetworkManagerDeviceType.wifi ||
            dev.deviceType == NetworkManagerDeviceType.wifi_p2p));
    return devs.isNotEmpty ? devs.first : null;
  }

  NetworkManagerDevice _findCellularModem() {
    final devs = this._nmClient.allDevices.where((dev) =>
        dev.wireless != null &&
        (dev.deviceType == NetworkManagerDeviceType.modem));
    return devs.isNotEmpty ? devs.first : null;
  }

  List<T> _removeEmpty<T>(List<T> l) {
    l.removeWhere((element) => element == null);
    return l;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        drawer: Drawer(),
        onDrawerChanged: (isOpened) {
          if (!isOpened && startupMode == DashboardUIStartupMode.LEFT_DRAWER) {
            _channel.invokeMethod('hideDashboard');
          }
        },
        onEndDrawerChanged: (isOpened) {
          if (!isOpened && startupMode == DashboardUIStartupMode.RIGHT_DRAWER) {
            _channel.invokeMethod('hideDashboard');
          }
        },
        endDrawer: Container(
            width: 360,
            child: new Drawer(
                child: Column(
              children: [
                DrawerHeader(
                    child: new ListView(children: [
                  FutureBuilder<Widget>(
                      future: this.createUserWidget(),
                      builder:
                          (BuildContext context, AsyncSnapshot<Widget> data) {
                        if (data.hasData) {
                          return data.data;
                        } else if (data.hasError) {
                          throw data.error;
                        }
                        return CircularProgressIndicator();
                      }),
                  const Divider(),
                  SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: _removeEmpty<Widget>([
                            this._findWiFiDevice() != null
                                ? TextButton(
                                    child: Icon(_indicators['wifi']
                                        ? Icons.wifi_outlined
                                        : Icons.wifi_off_outlined),
                                    onPressed: () {
                                      setState(() {
                                        _indicators['wifi'] =
                                            !_indicators['wifi'];
                                        this._nmClient.wirelessEnabled =
                                            this._indicators['wifi'];
                                      });
                                    })
                                : null,
                            this._findCellularModem() != null
                                ? TextButton(
                                    child: Icon(_indicators['cellular']
                                        ? Icons.network_cell
                                        : Icons.signal_cellular_null),
                                    onPressed: () {
                                      setState(() {
                                        _indicators['cellular'] =
                                            !_indicators['cellular'];
                                        this._nmClient.wwanEnabled =
                                            this._indicators['cellular'];
                                      });
                                    })
                                : null,
                            TextButton(
                                child: Icon(_indicators['location']
                                    ? Icons.location_on_outlined
                                    : Icons.location_off_outlined),
                                onPressed: () {
                                  setState(() {
                                    _indicators['location'] =
                                        !_indicators['location'];
                                  });
                                }),
                            TextButton(
                                child: Icon(_indicators['bluetooth']
                                    ? Icons.bluetooth_outlined
                                    : Icons.bluetooth_disabled_outlined),
                                onPressed: () {
                                  setState(() {
                                    _indicators['bluetooth'] =
                                        !_indicators['bluetooth'];
                                  });
                                }),
                            TextButton(
                                child: Icon(_indicators['notifications']
                                    ? Icons.notifications_on_outlined
                                    : Icons.notifications_off_outlined),
                                onPressed: () {
                                  setState(() {
                                    _indicators['notifications'] =
                                        !_indicators['notifications'];
                                  });
                                }),
                            TextButton(
                                child: Icon(_indicators['airplane-mode']
                                    ? Icons.airplanemode_on_outlined
                                    : Icons.airplanemode_off_outlined),
                                onPressed: () {
                                  setState(() {
                                    _indicators['airplane-mode'] =
                                        !_indicators['airplane-mode'];
                                  });
                                })
                          ]))),
                  const Divider(),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(children: [Icon(Icons.notifications), Text('0')]),
                        Row(children: [Icon(Icons.battery_std), Text('100%')]),
                        Row(children: [
                          Icon(Icons.access_time),
                          Text(_fullDateTime)
                        ])
                      ])
                ])),
                Spacer(),
                Align(
                    alignment: FractionalOffset.bottomCenter,
                    child: Column(children: [
                      const Divider(),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton(
                                child: Icon(Icons.logout), onPressed: () {}),
                            TextButton(
                                child: Icon(Icons.lock_outlined),
                                onPressed: () {}),
                            TextButton(
                                child: Icon(Icons.power_off_outlined),
                                onPressed: () {})
                          ])
                    ]))
              ],
            ))),
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
