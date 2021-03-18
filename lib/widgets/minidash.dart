import 'package:flutter/material.dart';
import 'package:shell/user.dart';
import 'dart:io';

class Minidash extends StatefulWidget {
  @override
  _MinidashState createState() => _MinidashState();
}

class _MinidashState extends State<Minidash> {
  final Future<User> _userFuture = User.current();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        FutureBuilder<User>(
          future: _userFuture,
          builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
            if (snapshot.hasData) {
              return DrawerHeader(
                  child: Column(children: [
                Center(
                    child: Row(children: [
                  IconButton(
                      icon: const Icon(Icons.wifi),
                      tooltip: 'Toggle WiFi',
                      onPressed: () => {}),
                  IconButton(
                      icon: const Icon(Icons.bluetooth_connected_sharp),
                      tooltip: 'Toggle Bluetooth',
                      onPressed: () => {}),
                  IconButton(
                      icon: const Icon(Icons.location_disabled),
                      tooltip: 'Toggle Location Services',
                      onPressed: () => {}),
                  IconButton(
                      icon: const Icon(Icons.flash_off_outlined),
                      tooltip: 'Toogle flashlight',
                      onPressed: () => {}),
                  IconButton(
                      icon: const Icon(Icons.airplanemode_inactive),
                      tooltip: 'Toggle Airplane mode',
                      onPressed: () => {}),
                  IconButton(
                      icon: const Icon(Icons.settings),
                      tooltip: 'System Settings',
                      onPressed: () {})
                ])),
                SizedBox(height: 5),
                Divider(),
                SizedBox(height: 5),
                Center(
                    child: Row(children: [
                  snapshot.data.getFace().length > 0
                      ? CircleAvatar(
                          radius:
                              Theme.of(context).textTheme.headline3.fontSize *
                                  1.35 /
                                  2,
                          backgroundImage:
                              FileImage(new File(snapshot.data.getFace())))
                      : null,
                  snapshot.data.getFace().length > 0
                      ? SizedBox(width: 10)
                      : null,
                  Text(snapshot.data.getRealName(),
                      style: Theme.of(context).textTheme.headline3)
                ])),
              ]));
            } else {
              return CircularProgressIndicator();
            }
          },
        )
      ],
    ));
  }
}
