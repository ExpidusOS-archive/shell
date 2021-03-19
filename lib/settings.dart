import 'package:flutter/services.dart';

class Settings {
  final _channel = MethodChannel('com.expidus.shell/settings');

  Settings();

  Future<dynamic> get(String name) {
    return this._channel.invokeMethod('get', name);
  }

  Future<void> set(String name, dynamic value) {
    return this._channel.invokeMethod('set', [name, value]);
  }

  Future<void> reset(String name) {
    return this._channel.invokeMethod('set', [name, null]);
  }
}
