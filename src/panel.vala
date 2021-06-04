namespace ExpidusOSShell {
	public class Panel : Gtk.Window {
		private static Gdk.Atom _NET_WM_STRUT = Gdk.Atom.intern_static_string("_NET_WM_STRUT");
		private static Gdk.Atom _NET_WM_STRUT_PARTIAL = Gdk.Atom.intern_static_string("_NET_WM_STRUT_PARTIAL");
		private static Gdk.Atom CARDINAL = Gdk.Atom.intern_static_string("CARDINAL");

		private Shell _shell;
		private int _monitor_index;

		public Shell shell {
			get {
				return this._shell;
			}
		}

		public Panel(Shell shell, int monitor_index) {
			this._shell = shell;
			this._monitor_index = monitor_index;

			this.resizable = false;
			this.type_hint = Gdk.WindowTypeHint.DOCK;
			this.decorated = false;
			this.skip_pager_hint = true;
			this.skip_taskbar_hint = true;

			this.show_all();
			this.sync();
		}

		public override void get_preferred_width(out int min_width, out int nat_width) {
			var geo = this.shell.disp.get_monitor(this._monitor_index).geometry;
			min_width = nat_width = geo.width;
		}

		public override void get_preferred_width_for_height(int height, out int min_width, out int nat_width) {
			this.get_preferred_width(out min_width, out nat_width);
		}

		public override void get_preferred_height(out int min_height, out int nat_height) {
			var geo = this.shell.disp.get_monitor(this._monitor_index).geometry;
			min_height = nat_height = (int)(geo.height * 0.05);
		}

		public override void get_preferred_height_for_width(int width, out int min_height, out int nat_height) {
			this.get_preferred_height(out min_height, out nat_height);
		}

		public override void size_allocate(Gtk.Allocation alloc) {
			var geo = this.shell.disp.get_monitor(this._monitor_index).geometry;
			alloc.x = geo.x;
			alloc.y = geo.y;
			this.set_allocation(alloc);
		}

		public void sync() {
			var monitor = this.shell.disp.get_monitor(this._monitor_index);
			var geo = monitor.geometry;
			this.move(geo.x, geo.y);
			this.queue_resize();

			ulong strut_partial[12] = {
				/* left, right */
				0, 0,

				/* top, bottom */
				(geo.y + (int)(geo.height * 0.25)) * monitor.scale_factor, 0,

				/* left_start_y, left_end_y */
				0, 0,

				/* right_start_y, right_end_y */
				0, 0,

				/* top_start_x, top_end_x */
				geo.x * monitor.scale_factor, (geo.x + geo.width) * monitor.scale_factor,

				/* bottom_start_x, bottom_end_x */
				0, 0
			};

			ulong strut[4] = {
				geo.x, geo.x + geo.width,
				geo.y, geo.y + (int)(geo.height * 0.25)
			};

			Gdk.property_change(this.get_toplevel().get_window(), _NET_WM_STRUT, CARDINAL, 32, Gdk.PropMode.REPLACE, (uint8[])&strut, strut.length);
			Gdk.property_change(this.get_toplevel().get_window(), _NET_WM_STRUT_PARTIAL, CARDINAL, 32, Gdk.PropMode.REPLACE, (uint8[])&strut_partial, strut_partial.length);
		}
	}
}
