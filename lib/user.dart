import 'package:dbus/dbus.dart';
import 'package:posix/posix.dart';

class User {
  final int uid;
  DBusClient _busClient;
  DBusRemoteObject _busObject;
  String _realName;
  String _face;

  User(this.uid);

  DBusObjectPath getObjectPath() {
    return DBusObjectPath('/org/freedesktop/Accounts/User${this.uid}');
  }

  Future<User> connect() async {
    this._busClient = DBusClient.system();
    this._busObject = DBusRemoteObject(
        this._busClient, 'org.freedesktop.Accounts', this.getObjectPath());

    this._realName = (await this
            ._busObject
            .getProperty('org.freedesktop.Accounts.User', 'RealName'))
        .toNative();

    this._face = (await this
            ._busObject
            .getProperty('org.freedesktop.Accounts.User', 'IconFile'))
        .toNative();
    return this;
  }

  String getRealName() {
    return this._realName;
  }

  String getFace() {
    return this._face;
  }

  static Future<User> current() {
    return new User(getuid()).connect();
  }
}
