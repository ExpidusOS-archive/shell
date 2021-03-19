import 'dart:io';

import 'package:flutter/services.dart';
import 'package:shell/settings.dart';

enum ApplicationType { SYSTEM, USER, OTHER }

final _methodChannel = MethodChannel('com.expidus.shell/applications');

class Application {
  final String id;
  final MethodChannel _channel =
      MethodChannel('com.expidus.shell/applications');

  String _icon;
  String _displayName;

  Application(this.id);

  Future<Application> sync() async {
    if ((await this._channel.invokeMethod('isValid', this.id)) == false) {
      throw new Exception('Invalid application: ${this.id}');
    }

    List<dynamic> values =
        List.from(await this._channel.invokeMethod('getValues', this.id));

    this._icon = values[0] as String;
    this._displayName = values[1] as String;
    return this;
  }

  Future<void> launch() {
    return this._channel.invokeMethod('launch', this.id);
  }

  String getIcon() {
    return this._icon;
  }

  String getDisplayName() {
    return this._displayName;
  }

  ApplicationType getType() {
    if (FileSystemEntity.isFileSync(
        '/opt/expidus-shell/applications/${this.id}.AppImage')) {
      return ApplicationType.SYSTEM;
    }

    final String homedir = Platform.environment['HOME'];
    if (FileSystemEntity.isFileSync(
        '$homedir/.local/share/expidus-shell/applications/${this.id}.AppImage')) {
      return ApplicationType.USER;
    }

    List<String> paths = Platform.environment['PATH'].split(':');
    for (String path in paths) {
      if (FileSystemEntity.isFileSync('$path/${this.id}')) {
        return ApplicationType.OTHER;
      }
    }

    throw new Exception('Cannot locate executable');
  }

  static Future<List<String>> getAllApplicationsByID() async {
    return List.from(
        await _methodChannel.invokeMethod('getAllApplicationsByID'));
  }

  static Future<List<Application>> getAllApplications() async {
    List<String> appIDs = List.from(await Application.getAllApplicationsByID());
    List<Application> apps = [];
    for (var id in appIDs) {
      final app = await new Application(id).sync();
      apps.add(app);
    }
    return apps;
  }

  static Future<List<Application>> getFavoriteApplications() async {
    List<String> appIDs =
        List.from(await new Settings().get('favorite-applications'));
    List<Application> apps = [];
    for (var id in appIDs) {
      final app = await new Application(id).sync();
      apps.add(app);
    }
    return apps;
  }
}
