namespace ExpidusOSShell {
	public class XSettings {
		private GLib.HashTable<string, string> props;
		private Shell shell;
		private int _fd;
		private Pid pid;
		private string temp_path;

		public int fd {
			get {
				return this._fd;
			}
		}

		public XSettings(Shell shell) throws GLib.Error {
			this.shell = shell;
			this.props = new GLib.HashTable<string, string>(str_hash, str_equal);

			this._fd = GLib.FileUtils.open_tmp("xsettingsd.XXXXXX", out this.temp_path);
			assert(this.fd > 1);

			this.set_string("Net/ThemeName", this.shell.settings.get_string("theme"));
			this.set_string("Net/IconThemeName", this.shell.settings.get_string("icon-theme"));
			this.write();

			GLib.Process.spawn_async(null, {"xsettingsd", "--config", this.temp_path}, GLib.Environ.get(), GLib.SpawnFlags.STDERR_TO_DEV_NULL | GLib.SpawnFlags.STDOUT_TO_DEV_NULL | GLib.SpawnFlags.SEARCH_PATH, null, out this.pid);
			GLib.ChildWatch.add(this.pid, (pid, status) => {
				GLib.Process.close_pid(pid);
				GLib.Process.exit(status);
			});
		}

		~XSettings() {
			GLib.FileUtils.close(this.fd);
		}

		private void write() throws GLib.FileError {
			var str = "";

			this.props.for_each((k, v) => {
				str += "%s %s\n".printf(k, v);
			});

			GLib.FileUtils.set_contents(this.temp_path, str);
		}

		private void @set(string name, string raw_value) {
			if (this.props.contains(name)) {
				this.props.remove(name);
			}

			this.props.insert(name, raw_value);
		}

		public void set_color(string name, int red, int green, int blue, int alpha)
				requires (red >= 0 && red <= 65535)
				requires (green >= 0 && green <= 65535)
				requires (blue >= 0 && blue <= 65535)
				requires (alpha >= 0 && alpha <= 65535) {
			this.@set(name, "(%d, %d, %d, %d)".printf(red, green, blue, alpha));
		}

		public void set_string(string name, string str) {
			this.@set(name, "\"" + str.replace("\"", "\\\"") + "\"");
		}

		public void set_int(string name, int num) {
			this.@set(name, num.to_string());
		}

		public void update() throws GLib.FileError {
			this.write();
			Posix.kill(this.pid, Posix.Signal.HUP);
		}
	}
}
