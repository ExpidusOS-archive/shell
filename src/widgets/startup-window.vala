namespace ExpidusOSShell {
	public class StartupWindow : Gtk.Window {
		private Shell _shell;
		private int _monitor_index;

		public Shell shell {
			get {
				return this._shell;
			}
		}

		public int monitor_index {
			get {
				return this._monitor_index;
			}
		}

		public StartupWindow(Shell shell, int monitor_index) {
			this._shell = shell;
			this._monitor_index = monitor_index;

			this.resizable = false;
			this.decorated = false;
			this.type_hint = Gdk.WindowTypeHint.SPLASHSCREEN;
			this.skip_pager_hint = true;
			this.skip_taskbar_hint = true;
			this.set_keep_above(true);

			var logo = new Gtk.Image.from_resource("/com/expidus/shell/logo.png");
			logo.set_pixel_size(Utils.dpi(shell, monitor_index, 25));
			var spinner = new Gtk.Spinner();

			var box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
			box.pack_start(logo);
			box.pack_end(spinner);

			var vert_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
			vert_box.set_center_widget(box);
			this.add(vert_box);

			this.show_all();
			var monitor = this.shell.disp.get_monitor(this.monitor_index);
			var geo = monitor.geometry;
			this.move(geo.x, geo.y);

			this.get_window().set_cursor(new Gdk.Cursor.for_display(shell.disp, Gdk.CursorType.BLANK_CURSOR));
			if (monitor.is_primary()) {
//				var seat = shell.disp.get_default_seat();
//				if (seat.grab(this.get_window(), Gdk.SeatCapabilities.ALL, false, null, null, null) != Gdk.GrabStatus.SUCCESS) stderr.printf("expidus-shell: failed to grab the display\n");
				this.get_window().raise();
			}

			spinner.start();
		}

		public override void get_preferred_width(out int min_width, out int nat_width) {
			var geo = this.shell.disp.get_monitor(this.monitor_index).geometry;
			min_width = nat_width = geo.width;
		}

		public override void get_preferred_width_for_height(int height, out int min_width, out int nat_width) {
			this.get_preferred_width(out min_width, out nat_width);
		}

		public override void get_preferred_height(out int min_height, out int nat_height) {
			var geo = this.shell.disp.get_monitor(this.monitor_index).geometry;
			min_height = nat_height = geo.height;
		}

		public override void get_preferred_height_for_width(int width, out int min_height, out int nat_height) {
			this.get_preferred_height(out min_height, out nat_height);
		}
	}
}
