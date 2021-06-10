namespace ExpidusOSShell {
	public errordomain NotificationError {
		INVALID_ID
	}

	public class Notification : GLib.Object {
		private NotificationsDaemon daemon;
		private string _app_name;
		private uint32 _id;
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

		public uint32 id {
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

		public Notification(NotificationsDaemon daemon, uint32 id, string app_name, string app_icon, string summary, string body, string[] actions, GLib.HashTable<string, GLib.Variant> hints, int32 expire_timeout) {
			Object();
			this.daemon = daemon;
			this._id = id;
			this._app_name = app_name;
			this._app_icon = app_icon;
			this._summary = summary;
			this._body = body;
			this._actions = actions;
			this._hints = hints;
			this._expire_timeout = expire_timeout;
			this._created = new GLib.DateTime.now_local();
			this._expires = this._created.add_seconds((int)(this.expire_timeout / 60));

			if (this.expire_timeout > 0) {
				GLib.TimeoutSource timeout = new GLib.TimeoutSource(this.expire_timeout);
				timeout.set_callback(() => {
					this.expired();
					timeout.destroy();
					return false;
				});
				timeout.attach(daemon.shell.main_loop.get_context());
			}
		}

		public void invoke(string key) {
			for (var i = 0; i < this.actions.length; i++) {
				if (this.actions[i] == key) {
					this.action(key, i);
					break;
				}
			}
		}

		public signal void expired();
		public signal void action(string key, int i);
	}

	[DBus(name = "org.freedesktop.Notifications")]
	public class NotificationsDaemon {
		private Shell _shell;
		private DBusConnection conn;
		private uint dbus_own_id;
		private GLib.List<Notification> _notifs;
		private int next_id = 1;

		[DBus(visible = false)]
		public Shell shell {
			get {
				return this._shell;
			}
		}

		[DBus(visible = false)]
		public uint count {
			get {
				return this._notifs.length();
			}
		}

		public NotificationsDaemon(Shell shell) throws GLib.IOError {
			this._shell = shell;
			this.conn = GLib.Bus.get_sync(GLib.BusType.SESSION);
			this.dbus_own_id = GLib.Bus.own_name_on_connection(this.conn, "org.freedesktop.Notifications", GLib.BusNameOwnerFlags.NONE);
			assert(this.dbus_own_id > 0);
			this.conn.register_object("/org/freedesktop/Notifications", this);

			this._notifs = new GLib.List<Notification>();
		}

		[DBus(visible = false)]
		public Notification? notify(string app_name, uint32 replaces_id, string app_icon, string summary, string body, string[] actions, GLib.HashTable<string, GLib.Variant> hints, int32 expire_timeout) {
			var id = replaces_id == 0 ? this.next_id++ : replaces_id;
			var notif = new Notification(this, id, app_name, app_icon, summary, body, actions, hints, expire_timeout);

			notif.expired.connect(() => {
				this.close(notif, 1);
			});

			notif.action.connect((key, i) => {
				this.ActionInvoked(notif.id, key);
			});

			if (replaces_id == 0) {
				this.notified(notif);
			} else {
				var orig = this.find(replaces_id);
				if (orig == null) return null;

				this._notifs.remove(orig);
			}

			this._notifs.append(notif);
			this.changed(this._notifs.length() - 1, 0, replaces_id == 0 ? 1 : 0);
			return notif;
		}

		[DBus(visible = false)]
		public void close(Notification notif, int reason) {
			this.changed(this._notifs.index(notif), 1, 0);
			this._notifs.remove(notif);
			this.NotificationClosed(notif.id, reason);
		}

		[DBus(visible = false)]
		public Notification? find(uint32 id) {
			for (unowned var item = this._notifs.first(); item != null; item = item.next) {
				if (item.data.id == id) return item.data;
			}
			return null;
		}

		[DBus(visible = false)]
		public Notification? get_notification(uint i) {
			return this._notifs.nth_data(i);
		}

		public uint32 Notify(string app_name, uint32 replaces_id, string app_icon, string summary, string body, string[] actions, GLib.HashTable<string, GLib.Variant> hints, int32 expire_timeout) throws GLib.Error {
			var notif = this.notify(app_name, replaces_id, app_icon, summary, body, actions, hints, expire_timeout);
			if (notif == null) throw new NotificationError.INVALID_ID("Replacement ID is invalid");
			return notif.id;
		}

		public void CloseNotification(uint32 id) throws GLib.Error {
			var notif = this.find(id);
			if (notif == null) throw new NotificationError.INVALID_ID(id.to_string() + " is an invalid notification");
			this.close(notif, 3);
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

		[DBus(visible = false)]
		public signal void notified(Notification notif);

		[DBus(visible = false)]
		public signal void changed(uint pos, uint removed, uint added);
	}
}
