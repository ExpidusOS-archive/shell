namespace ExpidusOSShell {
	public errordomain ShellErrors {
		INVALID_COMPOSITOR
	}

	[DBus(name = "com.expidus.Shell")]
	public class Shell {
		private Compositor _compositor;
		private DBusConnection conn;
		private uint dbus_own_id;

		[DBus(visible = false)]
		public Compositor compositor {
			get {
				return this._compositor;
			}
		}

		public Shell(string comp) throws ShellErrors, ExpidusOSShell.CompositorErrors, GLib.IOError {
#if ENABLE_X11
			if (comp == "x11") {
				this._compositor = new ExpidusOSShell.X11.Compositor(this, null);
			} else
#endif
#if ENABLE_WAYLAND
			if (comp == "wayland") {
				this._compositor = new ExpidusOSShell.Wayland.Compositor(this);
			} else
#endif
			{
				throw new ShellErrors.INVALID_COMPOSITOR("Invalid compositor: " + comp);
			}

			this.conn = GLib.Bus.get_sync(BusType.SESSION);
			this.dbus_own_id = GLib.Bus.own_name_on_connection(this.conn, "com.expidus.Shell", GLib.BusNameOwnerFlags.NONE);
			this.conn.register_object("/com/expidus/shell", this);
			this.conn.register_object("/com/expidus/compositor", this.compositor);

			this.compositor.new_window.connect((win) => {
				stdout.printf("A new window has been added: %p\n", win);
			});
			this.compositor.init();
		}

		~Shell() {
			GLib.Bus.unown_name(this.dbus_own_id);
		}

		[DBus(visible=false)]
		public bool handle_event() {
			return this.compositor.handle_event();
		}
	}
}
