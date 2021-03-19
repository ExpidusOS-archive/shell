import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shell/application.dart';
import 'package:shell/widgets/launcher.dart';

class QuickSwitch extends StatefulWidget {
  @override
  _QuickSwitchState createState() => _QuickSwitchState();
}

class _QuickSwitchState extends State<QuickSwitch> {
  final Future<List<Application>> _favoritesFuture =
      Application.getFavoriteApplications();

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 80,
        child: Drawer(
            child: GridView.count(
          crossAxisCount: 1,
          padding: EdgeInsets.zero,
          children: <Widget>[
            Column(children: [
              IconButton(icon: const Icon(Icons.grid_view), onPressed: () {}),
              const Text('Dashboard')
            ]),
            FutureBuilder<List<Application>>(
                future: _favoritesFuture,
                builder: (BuildContext context,
                    AsyncSnapshot<List<Application>> snapshot) {
                  if (snapshot.hasData) {
                    List<Application> apps = snapshot.data;
                    return ListView(
                        children: List.from(
                            apps.map((Application app) => LauncherIcon(
                                icon: FileImage(new File(app.getIcon())),
                                label: app.getDisplayName(),
                                onPressed: () {
                                  app.launch().then((void none) {
                                    Navigator.pop(context);
                                  }).catchError(
                                      (error) => print(error.toString()));
                                }))));
                  } else if (snapshot.hasError) {
                    throw snapshot.error;
                  }
                  return CircularProgressIndicator();
                })
          ],
        )));
  }
}
