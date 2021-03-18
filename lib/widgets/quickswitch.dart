import 'package:flutter/material.dart';

class QuickSwitch extends StatefulWidget {
  @override
  _QuickSwitchState createState() => _QuickSwitchState();
}

class _QuickSwitchState extends State<QuickSwitch> {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 80,
        child: Drawer(
            child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[],
        )));
  }
}
