import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shell/widgets/minidash.dart';
import 'package:shell/widgets/quickswitch.dart';

final _overlayMessageChannel = MethodChannel('com.expidus.shell/overlay');

class OverlayUI extends StatefulWidget {
  @override
  _OverlayUIState createState() => _OverlayUIState();
}

class _OverlayUIState extends State<OverlayUI> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        drawer: Container(width: 80, child: QuickSwitch()),
        endDrawer: Container(width: 300, child: Minidash()),
        onDrawerChanged: (isOpened) {
          _overlayMessageChannel
              .invokeMethod('onDrawerChanged', isOpened)
              .then((dynamic res) => {print('done')})
              .onError((error, stackTrace) => {print(error.toString())});
        },
        onEndDrawerChanged: (isOpened) {
          _overlayMessageChannel
              .invokeMethod('onEndDrawerChanged', isOpened)
              .then((dynamic res) => {print('done')})
              .onError((error, stackTrace) => {print(error.toString())});
        });
  }
}
