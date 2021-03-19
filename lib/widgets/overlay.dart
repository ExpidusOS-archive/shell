import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shell/widgets/dashboard.dart';
import 'package:shell/widgets/minidash.dart';
import 'package:shell/widgets/quickswitch.dart';

final _overlayMessageChannel = MethodChannel('com.expidus.shell/overlay');

enum _OverlayUIMode { DESKTOP, LOCK, DASHBOARD }

class OverlayUI extends StatefulWidget {
  @override
  _OverlayUIState createState() => _OverlayUIState();
}

class _OverlayUIState extends State<OverlayUI> {
  _OverlayUIMode _mode = _OverlayUIMode.DESKTOP;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        drawer: QuickSwitch(onDashboard: () {
          _overlayMessageChannel
              .invokeMethod('onDashboard', _mode == _OverlayUIMode.DASHBOARD)
              .then((dynamic args) => setState(() {
                    _mode = _mode == _OverlayUIMode.DASHBOARD
                        ? _OverlayUIMode.DESKTOP
                        : _OverlayUIMode.DASHBOARD;
                  }))
              .catchError((error) => print(error.toString()));
        }),
        endDrawer: Minidash(),
        body: _mode == _OverlayUIMode.DESKTOP
            ? ColoredBox(color: Colors.transparent)
            : Dashboard(),
        onDrawerChanged: (isOpened) {
          _overlayMessageChannel
              .invokeMethod('onDrawerChanged', isOpened)
              .onError((error, stackTrace) => {print(error.toString())});
        },
        onEndDrawerChanged: (isOpened) {
          _overlayMessageChannel
              .invokeMethod('onEndDrawerChanged', isOpened)
              .onError((error, stackTrace) => {print(error.toString())});
        });
  }
}
