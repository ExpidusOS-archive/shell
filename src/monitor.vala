namespace ExpidusOSShell {
	[DBus(name = "com.expidus.shell.Monitor")]
	public class Monitor {
		private Shell _shell;
		private int _index;
		private uint dbus_own_id;

		[DBus(visible = false)]
		public Shell shell {
			get {
				return this._shell;
			}
		}

		public int index {
			get {
				return this._index;
			}
		}

		public string? model {
			get {
				var monitor = this.shell.disp.get_monitor(this.index);
				assert(monitor != null);
				return monitor.model == null ? "(Unknown)" : monitor.model;
			}
		}

		public string? manufacturer {
			get {
				var monitor = this.shell.disp.get_monitor(this.index);
				assert(monitor != null);
				return monitor.manufacturer == null ? "(Unknown)" : monitor.manufacturer;
			}
		}

		public Monitor(Shell shell, int index) throws GLib.IOError {
			this._shell = shell;
			this._index = index;

			this.dbus_own_id = this.shell.conn.register_object("/com/expidus/shell/monitor/" + this.index.to_string(), this);
			stdout.printf("%s %s\n", this.model, this.manufacturer);
		}

		~Monitor() {
			this.shell.conn.unregister_object(this.dbus_own_id);
		}
	}
}
