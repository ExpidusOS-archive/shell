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

		public Shell(string comp, string[] args) throws ShellErrors, ExpidusOSShell.CompositorErrors, GLib.IOError {
#if ENABLE_X11
			if (comp == "x11") {
				this._compositor = new ExpidusOSShell.X11.Compositor(this, null, args);
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
				win.map.connect(() => {	
					/*var monitor = this.compositor.disp_gdk.get_monitor_at_window(win.gwin);
					stdout.printf("%d, %d %dx%d\n", monitor.workarea.x, monitor.workarea.y, monitor.workarea.width, monitor.workarea.height);
					if ((win.width + win.x) > monitor.workarea.width) {
						win.width = monitor.workarea.width - win.x;
					}

					if ((win.height + win.y) > monitor.workarea.height) {
						win.height = monitor.workarea.height - win.y;
					}*/
				});
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
