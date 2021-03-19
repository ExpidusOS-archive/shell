import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shell/application.dart';
import 'package:shell/widgets/launcher.dart';

class QuickSwitch extends StatefulWidget {
  final void Function() onDashboard;

  QuickSwitch({@required this.onDashboard}) : super();

  @override
  _QuickSwitchState createState() =>
      _QuickSwitchState(onDashboard: this.onDashboard);
}

class _QuickSwitchState extends State<QuickSwitch> {
  final Future<List<Application>> _favoritesFuture =
      Application.getFavoriteApplications();

  final void Function() onDashboard;

  _QuickSwitchState({@required this.onDashboard}) : super();

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 80,
        child: Drawer(
            child: GridView.count(
          crossAxisCount: 1,
          padding: EdgeInsets.zero,
          children: <Widget>[
            LauncherIcon(
                icon: Icons.apps_outlined, onPressed: this.onDashboard),
            FutureBuilder<List<Application>>(
                future: _favoritesFuture,
                builder: (BuildContext context,
                    AsyncSnapshot<List<Application>> snapshot) {
                  if (snapshot.hasData) {
                    List<Application> apps = snapshot.data;
                    return ListView(
                        children: List.from(apps.map((Application app) =>
                            LauncherIcon(
                                icon: app.getIcon() != null
                                    ? FileImage(new File(app.getIcon()))
                                    : Icons
                                        .cake_outlined, // Have a cake instead of a broken icon
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
