namespace ExpidusOSShell {
	public errordomain ShellErrors {
		INVALID_COMPOSITOR
	}

	[DBus(name = "com.expidus.Shell")]
	public class Shell {
		private DBusConnection conn;
		private uint dbus_own_id;
		private Pid xfwm_pid;
    private XfconfDaemon xfconf;

		private Gdk.Display disp;

		public Shell() throws ShellErrors, GLib.IOError, GLib.SpawnError, GLib.Error {
      this.xfconf = new XfconfDaemon();

			{
				string args[] = {"xfwm4", "--replace"};
				GLib.Process.spawn_async(null, args, GLib.Environ.get(), /*GLib.SpawnFlags.STDERR_TO_DEV_NULL | GLib.SpawnFlags.STDOUT_TO_DEV_NULL |*/ GLib.SpawnFlags.SEARCH_PATH, null, out this.xfwm_pid);
			}

			this.conn = GLib.Bus.get_sync(BusType.SESSION);
			this.dbus_own_id = GLib.Bus.own_name_on_connection(this.conn, "com.expidus.Shell", GLib.BusNameOwnerFlags.NONE);
			this.conn.register_object("/com/expidus/shell", this);

			this.disp = Gdk.Display.get_default();
			assert(this.disp != null);
		}

		~Shell() {
			GLib.Bus.unown_name(this.dbus_own_id);
		}
	}
}
