import 'package:flutter/material.dart';
import 'package:shell/widgets/minidash.dart';
import 'package:shell/widgets/quickswitch.dart';

class OverlayUI extends StatefulWidget {
  @override
  _OverlayUIState createState() => _OverlayUIState();
}

class _OverlayUIState extends State<OverlayUI> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        drawer: QuickSwitch(),
        endDrawer: Minidash());
  }
}
