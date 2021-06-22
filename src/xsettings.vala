namespace ExpidusOSShell {
	private enum XSettingPropertyType {
		INT,
		STR,
		COL
	}

	public struct XSettingColor {
		int16 red;
		int16 green;
		int16 blue;
		int16 alpha;
	}

	private class XSettingProperty {
		private int _num = 0;
		private string _str = null;
		private XSettingColor? _col = null;
		private XSettingPropertyType _type = XSettingPropertyType.INT;
		private string _name;

		public XSettingPropertyType prop_type {
			get {
				return this._type;
			}
		}

		public int num {
			get {
				return this._num;
			}
			set {
				this._type = XSettingPropertyType.INT;
				this._num = value;
				this._str = null;
				this._col = null;
			}
		}

		public string? str {
			get {
				return this._str;
			}
			set {
				this._type = XSettingPropertyType.STR;
				this._num = 0;
				this._str = value;
				this._col = null;
			}
		}

		public XSettingColor? col {
			get {
				return this._col;
			}
			set {
				this._type = XSettingPropertyType.COL;
				this._num = 0;
				this._str = null;
				this._col = value;
			}
		}

		public string name {
			get {
				return this._name;
			}
		}

		public XSettingProperty(string name) {
			this._name = name;
		}

		public void reset() {
			this._num = 0;
			this._str = null;
			this._col = null;
			this._type = XSettingPropertyType.INT;
		}
	}

	public class XSettings {
		private static Gdk.Atom _XSETTINGS_SETTINGS = Gdk.Atom.intern_static_string("_XSETTINGS_SETTINGS");

		private GLib.List<XSettingProperty> props;
		private Shell shell;
		private Gdk.Window win;
		private int32 serial = 0;
		private int32 old_serial = 0;

		public XSettings(Shell shell) {
			this.shell = shell;
			this.props = new GLib.List<XSettingProperty>();

			var disp = this.shell.disp as Gdk.X11.Display;
			assert(disp != null);

			var screen = this.shell.disp.get_default_screen() as Gdk.X11.Screen;
			assert(screen != null);

			var rootwin = screen.get_root_window() as Gdk.X11.Window;
			assert(rootwin != null);
			
			Gdk.WindowAttr attrs = {};
			attrs.override_redirect = true;
			attrs.width = attrs.height = 1;
			attrs.x = attrs.y = -1;
			attrs.window_type = Gdk.WindowType.TOPLEVEL;
			this.win = new Gdk.Window(rootwin, attrs, Gdk.WindowAttributesType.NOREDIR | Gdk.WindowAttributesType.X | Gdk.WindowAttributesType.Y);

			var xwin = this.win as Gdk.X11.Window;
			assert(xwin != null);

			long data[] = {
				(long)new GLib.DateTime.now().to_unix(),
				(long)xwin.get_xid(),
				(long)Gdk.X11.atom_to_xatom(Gdk.Atom.intern_static_string("_XSETTINGS_S" + screen.get_screen_number().to_string())),
				0
			};
			X.Event ev = {};
			ev.xclient = {};
			ev.xclient.type = X.EventType.ClientMessage;
			ev.xclient.window = rootwin.get_xid();
			ev.xclient.message_type = Gdk.X11.atom_to_xatom(Gdk.Atom.intern_static_string("MANAGER"));
			ev.xclient.format = 32;
			ev.xclient.l = data;
			disp.get_xdisplay().send_event(rootwin.get_xid(), false, X.EventMask.SubstructureNotifyMask, ref ev);
		}

		public bool has_prop(string name) {
			for (unowned var item = this.props.first(); item != null; item = item.next) {
				if (item.data.name == name) return true;
			}

			return false;
		}

		private XSettingProperty? get_prop(string name) {
			for (unowned var item = this.props.first(); item != null; item = item.next) {
				if (item.data.name == name) return item.data;
			}

			return null;
		}

		public void set_color(string name, int16 red, int16 green, int16 blue, int16 alpha = 256) {
			var prop = this.get_prop(name);
			if (prop == null) prop = new XSettingProperty(name);
			XSettingColor val = {
				red,
				green,
				blue,
				alpha
			};
			prop.col = val;
			if (!this.has_prop(name)) {
				this.props.append(prop);
			}
		}

		public void set_string(string name, string str) {
			var prop = this.get_prop(name);
			if (prop == null) prop = new XSettingProperty(name);
			prop.str = str;
			if (!this.has_prop(name)) {
				this.props.append(prop);
			}
		}

		public void set_int(string name, int num) {
			var prop = this.get_prop(name);
			if (prop == null) prop = new XSettingProperty(name);
			prop.num = num;
			if (!this.has_prop(name)) {
				this.props.append(prop);
			}
		}

		public void update() {
			var ba = new GLib.ByteArray();
			this.old_serial = this.serial;
			ba.append(new GLib.Variant("(yyyyhh)", 0, 0, 0, 0, this.serial++, this.props.length()).get_data_as_bytes().get_data());

			for (unowned var item = this.props.first(); item != null; item = item.next) {
				var prop = item.data;

				ba.append(new GLib.Variant("(yyhs)", prop.prop_type, 0, prop.name.length, prop.name).get_data_as_bytes().get_data());

				var padding = (4 - (prop.name.length % 4)) % 4;
				for (var i = 0; i < padding; i++) {
					ba.append({ 0 });
				}

				ba.append(new GLib.Variant("h", this.old_serial).get_data_as_bytes().get_data());

				switch (prop.prop_type) {
					case XSettingPropertyType.COL:
						ba.append(new GLib.Variant("(nnn)", prop.col.red, prop.col.green, prop.col.blue, prop.col.alpha).get_data_as_bytes().get_data());
						break;
					case XSettingPropertyType.STR:
						ba.append(new GLib.Variant("(hs)", prop.str.length, prop.str).get_data_as_bytes().get_data());
						padding = (4 - (prop.str.length % 4)) % 4;
						for (var i = 0; i < padding; i++) {
							ba.append({ 0 });
						}
						break;
					case XSettingPropertyType.INT:
						ba.append(new GLib.Variant("h", prop.num).get_data_as_bytes().get_data());
						break;
				}
			}
			Gdk.property_change(this.win, _XSETTINGS_SETTINGS, _XSETTINGS_SETTINGS, 8, Gdk.PropMode.REPLACE, ba.data, (int)ba.len);
		}
	}
}
