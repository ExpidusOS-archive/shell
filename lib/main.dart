import 'package:flutter/material.dart';
import 'package:desktop_window/desktop_window.dart';

void main() {
  runApp(PanelApp());
}

class PanelApp extends StatefulWidget {
  @override
  PanelAppState createState() => PanelAppState();
}

class PanelAppState extends State<PanelApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'ExpidusOS Shell - Panel',
        home: Scaffold(
          appBar: AppBar(title: const Text('ExpidusOS')),
        ));
  }
}
