import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return ColoredBox(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Container(
            alignment: Alignment.center,
            child: const Text('Work in progress dashboard')));
  }
}
