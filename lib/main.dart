import 'package:flutter/material.dart';
import 'package:shell/theme.dart';
import 'package:shell/widgets/desktop.dart';
import 'package:shell/widgets/overlay.dart';

void main(List<String> args) {
  if (args[1] == 'desktop')
    runApp(DesktopApp());
  else if (args[1] == 'overlay') {
    runApp(OverlayApp()); // TODO: once flutter adds transparency, use it
  } else
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
        title: 'ExpidusOS Shell', theme: tokyoThemeDark, home: DesktopUI());
  }
}

class OverlayApp extends StatefulWidget {
  @override
  _OverlayAppState createState() => _OverlayAppState();
}

class _OverlayAppState extends State<OverlayApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'ExpidusOS Shell', theme: tokyoThemeDark, home: OverlayUI());
  }
}
