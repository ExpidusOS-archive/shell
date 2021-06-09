namespace ExpidusOSShell {
	public errordomain NotificationError {
		INVALID_ID
	}

	public class Notification {
		private string _app_name;
		private int _id;
		private string _app_icon;
		private string _summary;
		private string _body;
		private string[] _actions;
		private GLib.HashTable<string, GLib.Variant> _hints;
		private int32 _expire_timeout;
		private GLib.DateTime _created;
		private GLib.DateTime _expires;

		public string app_name {
			get {
				return this._app_name;
			}
		}

		public int id {
			get {
				return this._id;
			}
		}

		public string app_icon {
			get {
				return this._app_icon;
			}
		}

		public string summary {
			get {
				return this._summary;
			}
		}

		public string body {
			get {
				return this._body;
			}
		}

		public string[] actions {
			get {
				return this._actions;
			}
		}

		public GLib.HashTable<string, GLib.Variant> hints {
			get {
				return this._hints;
			}
		}

		public int32 expire_timeout {
			get {
				return this._expire_timeout;
			}
		}

		public GLib.DateTime created {
			get {
				return this._created;
			}
		}

		public GLib.DateTime expires {
			get {
				return this._expires;
			}
		}

		public Notification(string app_name, string app_icon, string summary, string body, string[] actions, GLib.HashTable<string, GLib.Variant> hints, int32 expire_timeout) {
			this._app_name = app_name;
			this._app_icon = app_icon;
			this._summary = summary;
			this._body = body;
			this._actions = actions;
			this._hints = hints;
			this._expire_timeout = expire_timeout;
			this._created = new GLib.DateTime.now_local();
			this._expires = this._created.add_seconds((int)(this.expire_timeout / 60));
			// TODO: use a signal to well... signal when the notification has expired
		}
	}

	[DBus(name = "org.freedesktop.Notifications")]
	public class NotificationsDaemon {
		private Shell shell;
		private DBusConnection conn;
		private uint dbus_own_id;
		private GLib.List<Notification> _notifs;

		public uint count {
			get {
				return this._notifs.length();
			}
		}

		public NotificationsDaemon(Shell shell) throws GLib.IOError {
			this.shell = shell;
			this.conn = GLib.Bus.get_sync(GLib.BusType.SESSION);
			this.dbus_own_id = GLib.Bus.own_name_on_connection(this.conn, "org.freedesktop.Notifications", GLib.BusNameOwnerFlags.NONE);
			assert(this.dbus_own_id > 0);
			this.conn.register_object("/org/freedesktop/Notifications", this);

			this._notifs = new GLib.List<Notification>();
		}

		[DBus(visible = false)]
		public bool close_notif(uint32 i, int reason) {
			var notif = this._notifs.nth_data(i);
			if (notif == null) return false;

			this._notifs.remove(notif);
			this.NotificationClosed(i + 1, reason);
			return true;
		}

		[DBus(visible = false)]
		public Notification? get_notification(int i) {
			return this._notifs.nth_data(i);
		}

		public uint32 Notify(string app_name, uint32 replaces_id, string app_icon, string summary, string body, string[] actions, GLib.HashTable<string, GLib.Variant> hints, int32 expire_timeout) throws GLib.Error {
			var id = this._notifs.length() + 1;
			var notif = new Notification(app_name, app_icon, summary, body, actions, hints, expire_timeout);
			if (replaces_id == 0) {
				this._notifs.append(notif);
			} else {
				if ((replaces_id - 1) > this._notifs.length()) throw new NotificationError.INVALID_ID("Replacement ID is invalid");

				this._notifs.remove(this._notifs.nth_data((replaces_id - 1)));
				this._notifs.insert(notif, (int)(replaces_id - 1));
				return replaces_id;
			}
			return id;
		}

		public void CloseNotification(uint32 id) throws GLib.Error {
			if (!this.close_notif(id - 1, 3)) throw new NotificationError.INVALID_ID(id.to_string() + " is an invalid notification");
		}

		public string[] GetCapabilities() throws GLib.Error {
			return {"actions", "body", "persistence"};
		}

		public void GetServerInformation(out string name, out string vendor, out string version, out string spec_version) throws GLib.Error {
			name = "ExpidusOS Shell";
			vendor = "Midstall Software";
			version = "0.1.0-prealpha";
			spec_version = "1.2";
		}

		public signal void ActionInvoked(uint32 id, string action_key);
		public signal void NotificationClosed(uint32 id, uint32 reason);
	}
}
