namespace ExpidusOSShell {
	private interface XfconfPropertyBase : GLib.Object {
		public abstract string get_name();
		public abstract bool is_locked();
		public abstract void set_value(Variant val) throws Xfconf.Error;
		public abstract Variant get_value();
		public signal void value_changed();
	}
	private class XfconfPropertyBinder : GLib.Object, XfconfPropertyBase {
		private string prop_name;
		private string name;
		private bool locked;
		private Shell shell;

		public XfconfPropertyBinder(Shell shell, string name, bool locked = false) {
			this.shell = shell;
			this.prop_name = name;
			this.name = name;
			this.locked = locked;
			this.init();
		}

		public XfconfPropertyBinder.with_different_names(Shell shell, string prop_name, string name, bool locked = false) {
			this.shell = shell;
			this.prop_name = name;
			this.name = name;
			this.locked = locked;
			this.init();
		}

		~XfconfPropertyBinder() {
			this.shell.settings.changed[this.prop_name].disconnect(this.on_changed);
		}

		private void on_changed() {
			this.value_changed();
		}

		private void init() {
			this.shell.settings.changed[this.prop_name].connect(this.on_changed);
		}

		public string get_name() {
			return this.name;
		}

		public bool is_locked() {
			return this.locked;
		}

		public void set_value(Variant val) throws Xfconf.Error {
			if (this.locked) {
				throw new Xfconf.Error.PERMISSIONDENIED("Property " + this.name + " is locked and cannot be changed.");
			} else {
				this.shell.settings.set_value(this.prop_name, val);
			}
		}

		public Variant get_value() {
			return this.shell.settings.get_value(this.prop_name);
		}
	}
	private class XfconfProperty : GLib.Object, XfconfPropertyBase {
		private Variant _value;
		private string _name;

		public string name {
			get {
				return this._name;
			}
		}

		public bool locked {
			get {
				return false;
			}
		}

		public Variant value {
			get {
				return this._value;
			}
		}

		public XfconfProperty(string name, Variant val) {
			this._name = name;
			this._value = val;
		}

		public void set_value(Variant val) throws Xfconf.Error {
			if (this.locked) {
				throw new Xfconf.Error.PERMISSIONDENIED("Property " + this.name + " is locked and cannot be changed.");
			} else {
				this._value = val;
				this.value_changed();
			}
		}

		public string get_name() {
			return this._name;
		}

		public bool is_locked() {
			return this.locked;
		}

		public Variant get_value() {
			return this._value;
		}
	}

	private class XfconfChannel {
		public GLib.List<XfconfPropertyBase> props;
		private string _name;

		public string name {
			get {
				return this._name;
			}
		}

		public XfconfChannel(string channel_name) {
			this._name = channel_name;
			this.props = new GLib.List<XfconfPropertyBase>();
		}

		private XfconfPropertyBase? get_property(string name, Variant? val, string cmd) {
			for (unowned var item = this.props.first(); item != null; item = item.next) {
				var prop = item.data;
				if (prop.get_name() == name) {
					return prop;
				}
			}

			if (val == null) return null;

			var prop = new XfconfProperty(name, val);
			this.props.append(prop);
			prop.value_changed.connect(() => {
				this.prop_changed(name, prop.value);
			});
			return prop;
		}

		public bool prop_exists(string prop_name) {
			return this.get_property(prop_name, null, "prop_exists") != null;
		}

		public bool is_property_locked(string prop_name) throws Xfconf.Error {
			var prop = this.get_property(prop_name, null, "is_property_locked");
			if (prop == null) throw new Xfconf.Error.INVALIDPROPERTY("Invalid property " + prop_name);
			return prop.is_locked();
		}

		public void reset(string prop_name, bool recursive) {
			if (recursive) {
				for (unowned var item = this.props.first(); item != null; item = item.next) {
					var prop = item.data;
					if (prop.get_name().contains(prop_name)) {
						this.props.remove(prop);
						this.prop_removed(prop_name);
					}
				}
			} else {
				for (unowned var item = this.props.first(); item != null; item = item.next) {
					var prop = item.data;
					if (prop.get_name() == prop_name) {
						this.props.remove(prop);
						this.prop_removed(prop_name);
					}
				}
			}
		}

		public void set_prop(string prop_name, Variant val) throws Xfconf.Error {
			var prop = this.get_property(prop_name, val, "set_prop");
			prop.set_value(val);
		}

		public Variant get_prop(string prop_name) throws Xfconf.Error {
			var prop = this.get_property(prop_name, null, "get_prop");
			if (prop == null) throw new Xfconf.Error.INVALIDPROPERTY("Property " + prop_name + " does not exist");
			return prop.get_value();
		}

		public GLib.HashTable<string, Variant> get_all(string prop_base) {
			var table = new GLib.HashTable<string, Variant>(str_hash, direct_equal);
			for (unowned var item = this.props.first(); item != null; item = item.next) {
				var prop = item.data;
				if (prop_base.length > 0) {
					if (prop.get_name().substring(0, prop_base.length) == prop.get_name()) {
						table.insert(prop.get_name(), prop.get_value());
					}
				} else {
					table.insert(prop.get_name(), prop.get_value());
				}
			}
			return table;
		}

		public signal void prop_changed(string prop, Variant val);
		public signal void prop_removed(string name);
	}

	[DBus(name = "org.xfce.Xfconf")]
	public class XfconfDaemon {
		private DBusConnection conn;
		private uint dbus_own_id;
		private string path;
		private Shell shell;

		private GLib.List<XfconfChannel> channels;

		public XfconfDaemon(Shell shell) throws GLib.IOError, GLib.Error {
			this.shell = shell;
			this.conn = GLib.Bus.get_sync(GLib.BusType.SESSION);
			this.dbus_own_id = GLib.Bus.own_name_on_connection(this.conn, "org.xfce.Xfconf", GLib.BusNameOwnerFlags.REPLACE);
			assert(this.dbus_own_id > 0);
			this.conn.register_object("/org/xfce/Xfconf", this);

			this.path = GLib.Environment.get_user_config_dir() + "/expidus-shell/xfconf.json";
			this.channels = new GLib.List<XfconfChannel>();

			if (!GLib.FileUtils.test(GLib.Path.get_dirname(this.path), GLib.FileTest.IS_DIR)) {
				GLib.DirUtils.create_with_parents(GLib.Path.get_dirname(this.path), 0600);
			}

			{
				var channel = this.get_channel("xfwm4", false);
				assert(channel != null);
				channel.props.append(new XfconfPropertyBinder.with_different_names(this.shell, "/generic/theme", "theme", true));
				channel.props.append(new XfconfPropertyBinder.with_different_names(this.shell, "/generic/titleless_maximize", "frameless-maximize", true));
			}
		}

		~XfconfDaemon() {
			GLib.Bus.unown_name(this.dbus_own_id);
		}

		private XfconfChannel? get_channel(string channel_name, bool exists) {
			for (unowned var item = this.channels.first(); item != null; item = item.next) {
				var channel = item.data;
				if (channel.name == channel_name) return channel;
			}

			if (exists) return null;
			
			var channel = new XfconfChannel(channel_name);
			channel.prop_changed.connect((prop_name, val) => {
				this.PropertyChanged(channel_name, prop_name, val);
			});
			channel.prop_removed.connect((prop_name) => {
				this.PropertyRemoved(channel_name, prop_name);
			});
			this.channels.append(channel);
			return channel;
		}

		public GLib.HashTable<string, Variant> GetAllProperties(string channel_name, string prop_base) throws GLib.Error {
			var channel = this.get_channel(channel_name, true);
			if (channel == null) throw new Xfconf.Error.INVALIDCHANNEL("Channel " + channel_name + " does not exist");
			return channel.get_all(prop_base);
		}

		public Variant GetProperty(string channel_name, string prop_name) throws GLib.Error {
			var channel = this.get_channel(channel_name, false);
			if (channel == null) throw new Xfconf.Error.INVALIDCHANNEL("Channel " + channel_name + " does not exist");
			return channel.get_prop(prop_name);
		}

		public bool PropertyExists(string channel_name, string prop_name) throws GLib.Error {
			var channel = this.get_channel(channel_name, true);
			if (channel == null) return false;
			return channel.prop_exists(prop_name);
		}

		public bool IsPropertyLocked(string channel_name, string prop_name) throws GLib.Error {
			var channel = this.get_channel(channel_name, true);
			if (channel == null) throw new Xfconf.Error.INVALIDCHANNEL("Channel " + channel_name + " does not exist");
			return channel.is_property_locked(prop_name);
		}

		public string[] ListChannels() throws GLib.Error {
			var list = new string[this.channels.length()];
			var i = 0;
			for (unowned var item = this.channels.first(); item != null; item = item.next) {
				var channel = item.data;
				list[i++] = channel.name;
			}
			return list;
		}

		public void ResetProperty(string channel_name, string prop_name, bool recursive) throws GLib.Error {
			var channel = this.get_channel(channel_name, true);
			if (channel == null) throw new Xfconf.Error.INVALIDCHANNEL("Channel " + channel_name + " does not exist");
			channel.reset(prop_name, recursive);
		}

		public void SetProperty(string channel_name, string prop_name, Variant val) throws GLib.Error {
			var channel = this.get_channel(channel_name, false);
			channel.set_prop(prop_name, val);
		}

		public signal void PropertyChanged(string channel, string prop, Variant val);
		public signal void PropertyRemoved(string channel, string prop);
	}
}
