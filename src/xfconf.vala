namespace ExpidusOSShell {
	private class XfconfProperty {
		private Variant _value;
		private string _name;

		public string name {
			get {
				return this._name;
			}
		}

		public bool locked = false;

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

		public signal void value_changed();
	}

	private class XfconfChannel {
		private GLib.List<XfconfProperty> props;
		private string _name;

		public string name {
			get {
				return this._name;
			}
		}

		public XfconfChannel(string channel_name) {
			this._name = channel_name;
			this.props = new GLib.List<XfconfProperty>();
		}

		private XfconfProperty? get_property(string name, Variant? val, string cmd) {
			for (unowned var item = this.props.first(); item != null; item = item.next) {
				var prop = item.data;
				if (prop.name == name) {
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
			return prop.locked;
		}

		public void reset(string prop_name, bool recursive) {
			if (recursive) {
				for (unowned var item = this.props.first(); item != null; item = item.next) {
					var prop = item.data;
					if (prop.name.contains(prop_name)) {
						this.props.remove(prop);
						this.prop_removed(prop_name);
					}
				}
			} else {
				for (unowned var item = this.props.first(); item != null; item = item.next) {
					var prop = item.data;
					if (prop.name == prop_name) {
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
			return prop.value;
		}

		public GLib.HashTable<string, Variant> get_all(string prop_base) {
			var table = new GLib.HashTable<string, Variant>(str_hash, direct_equal);
			for (unowned var item = this.props.first(); item != null; item = item.next) {
				var prop = item.data;
				if (prop_base.length > 0) {
					if (prop.name.substring(0, prop_base.length) == prop.name) {
						table.insert(prop.name, prop.value);
					}
				} else {
					table.insert(prop.name, prop.value);
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
		}

		~XfconfDaemon() {
			GLib.Bus.unown_name(this.dbus_own_id);
		}

		private XfconfChannel? get_channel(string channel_name, bool exists, string caller) {
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
			var channel = this.get_channel(channel_name, true, "GetAllProperties");
			if (channel == null) throw new Xfconf.Error.INVALIDCHANNEL("Channel " + channel_name + " does not exist");
			var results = channel.get_all(prop_base);
			if (channel_name == "xfwm4") {
				results.set("/generic/theme", new Variant.string("Tokyo-dark"));
				results.set("/generic/titleless_maximize", new Variant.boolean(this.shell.settings.get_boolean("frameless-maximize")));
			}
			return results;
		}

		public Variant GetProperty(string channel_name, string prop_name) throws GLib.Error {
			if (channel_name == "xfwm4" && prop_name == "/general/theme") return new Variant.string("Tokyo-dark");
			if (channel_name == "xfwm4" && prop_name == "/general/titleless_maximize") return new Variant.boolean(this.shell.settings.get_boolean("frameless-maximize"));
			var channel = this.get_channel(channel_name, false, "GetProperty");
			if (channel == null) throw new Xfconf.Error.INVALIDCHANNEL("Channel " + channel_name + " does not exist");
			return channel.get_prop(prop_name);
		}

		public bool PropertyExists(string channel_name, string prop_name) throws GLib.Error {
			if (channel_name == "xfwm4" && prop_name == "/general/theme") return true;
			if (channel_name == "xfwm4" && prop_name == "/generic/titleless_maximize") return true;

			var channel = this.get_channel(channel_name, true, "PropertyExists");
			if (channel == null) return false;
			return channel.prop_exists(prop_name);
		}

		public bool IsPropertyLocked(string channel_name, string prop_name) throws GLib.Error {
			if (channel_name == "xfwm4" && prop_name == "/general/theme") return true;
			if (channel_name == "xfwm4" && prop_name == "/generic/titleless_maximize") return true;

			var channel = this.get_channel(channel_name, true, "IsPropertyLocked");
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
			var channel = this.get_channel(channel_name, true, "ResetProperty");
			if (channel == null) throw new Xfconf.Error.INVALIDCHANNEL("Channel " + channel_name + " does not exist");
			channel.reset(prop_name, recursive);
		}

		public void SetProperty(string channel_name, string prop_name, Variant val) throws GLib.Error {
			if (channel_name == "xfwm4" && prop_name == "/general/theme") throw new Xfconf.Error.PERMISSIONDENIED("Property is locked");
			if (channel_name == "xfwm4" && prop_name == "/generic/titleless_maximize") throw new Xfconf.Error.PERMISSIONDENIED("Property is locked");

			var channel = this.get_channel(channel_name, false, "SetProperty");
			channel.set_prop(prop_name, val);
		}

		public signal void PropertyChanged(string channel, string prop, Variant val);
		public signal void PropertyRemoved(string channel, string prop);
	}
}
