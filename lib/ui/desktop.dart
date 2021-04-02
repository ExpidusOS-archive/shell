import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum _WallpaperStyle {
  NONE,
  WALLPAPER,
  CENTERED,
  SCALED,
  STRETCHED,
  ZOOM,
  SPANNED
}

class DesktopUI extends StatefulWidget {
  @override
  _DesktopUIState createState() => _DesktopUIState();
}

class _DesktopUIState extends State<DesktopUI> {
  String _titleString = 'ExpidusOS';
  dynamic _titleIcon = Icons.apps;
  bool _isApp = false;
  ImageProvider _wallpaper =
      FileImage(new File('/usr/share/backgrounds/wallpaper/default.png'));
  _WallpaperStyle _wallpaperStyle = _WallpaperStyle.NONE;
  final _dartChannel = MethodChannel('com.expidus.shell/desktop.dart');
  final _channel = MethodChannel('com.expidus.shell/desktop');

  @override
  void initState() {
    super.initState();

    _dartChannel.setMethodCallHandler((call) {
      if (call.method == 'setWallpaper') {
        List<dynamic> args = List.from(call.arguments);
        if (args.length != 2) {
          return Future.error(new Exception(
              'Invalid range, must be equal to 2 (${args.length})'));
        }

        final uri = Uri.parse(args[0] as String);
        final opt = args[1] as int;

        setState(() {
          _wallpaper = uri.scheme == 'file'
              ? FileImage(new File(uri.path))
              : NetworkImage(uri.toString());
          _wallpaperStyle = _WallpaperStyle.values[opt];
        });
        return Future.value(null);
      } else if (call.method == 'setCurrentApplication') {
        List<dynamic> args = List.from(call.arguments);
        if (!(args.length > 0 && args.length < 4)) {
          return Future.error(new Exception(
              'Invalid range, must be greater than zero and less than four (${args.length})'));
        }

        final isApp = args[0] as bool;
        final titleString = args.length >= 2 ? args[1] as String : 'ExpidusOS';
        final titleIcon = isApp
            ? (args.length == 3 ? args[2] as String : Icons.archive)
            : Icons.apps;

        setState(() {
          _isApp = isApp;
          _titleString = titleString;
          _titleIcon = titleIcon;
        });
        return Future.value(null);
      }
      return Future.error(call.noSuchMethod(Invocation.genericMethod(
          Symbol(call.method), call.arguments, call.arguments)));
    });

    _channel.invokeMethod('syncWallpaper').onError(
        (error, stackTrace) => print('Failed to sync wallpaper $error'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(30),
            child: TextButton(
              onPressed: () => _channel.invokeMethod('keepFocus').onError(
                  (error, stackTrace) => print('Failed to keep focus: $error')),
              child: AppBar(
                  automaticallyImplyLeading: false,
                  leadingWidth: ((Theme.of(context).appBarTheme.textTheme ==
                                          null
                                      ? Theme.of(context).textTheme
                                      : Theme.of(context).appBarTheme.textTheme)
                                  .headline5
                                  .fontSize *
                              _titleString.length) /
                          2 +
                      8,
                  leading: TextButton(
                      style: ButtonStyle(
                          textStyle: MaterialStateProperty.all(
                              (Theme.of(context).appBarTheme.textTheme == null
                                      ? Theme.of(context).textTheme
                                      : Theme.of(context).appBarTheme.textTheme)
                                  .headline5),
                          backgroundColor: MaterialStateProperty.all(
                              Theme.of(context).appBarTheme.backgroundColor),
                          foregroundColor:
                              MaterialStateProperty.all(Theme.of(context).appBarTheme.foregroundColor)),
                      onPressed: () {
                        _channel.invokeMethod('toggleActionButton').onError(
                            (error, stackTrace) => print(
                                'Failed to toggle the action button: $error'));
                      },
                      child: FittedBox(
                          fit: BoxFit.fitWidth,
                          child: Row(children: [
                            Center(
                                child: _titleIcon is String
                                    ? Image.file(new File(_titleIcon as String),
                                        width: 22, height: 22)
                                    : Icon(_titleIcon as IconData, size: 22)),
                            Text(_titleString)
                          ])))),
            )),
        body: Container(
            constraints: BoxConstraints.tight(Size.infinite),
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: _wallpaper,
                    fit: _wallpaperStyle == _WallpaperStyle.ZOOM
                        ? BoxFit.contain
                        : BoxFit.fill))));
  }
}
