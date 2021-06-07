namespace ExpidusOSShell {
	public enum PanelSide {
		LEFT, RIGHT, TOP, BOTTOM
	}

	public abstract class BasePanel : Gtk.Window {
		private static Gdk.Atom _NET_WM_STRUT = Gdk.Atom.intern_static_string("_NET_WM_STRUT");
		private static Gdk.Atom _NET_WM_STRUT_PARTIAL = Gdk.Atom.intern_static_string("_NET_WM_STRUT_PARTIAL");
		private static Gdk.Atom CARDINAL = Gdk.Atom.intern_static_string("CARDINAL");

		private Shell _shell;
		private int _monitor_index;

		public Shell shell {
			get {
				return this._shell;
			}
			set construct {
				this._shell = value;
			}
		}

		public int monitor_index {
			get {
				return this._monitor_index;
			}
			set construct {
				this._monitor_index = monitor_index;
			}
		}

		public abstract Gdk.Rectangle geometry { get; }
		public abstract PanelSide side { get; }

		construct {
			this.resizable = false;
			this.type_hint = Gdk.WindowTypeHint.DOCK;
			this.decorated = false;
			this.skip_pager_hint = true;
			this.skip_taskbar_hint = true;

			this.configure_event.connect((ev) => {
				if (ev.x != this.geometry.x || ev.y != this.geometry.y) this.move(this.geometry.x, this.geometry.y);
				this.set_strut();
				return true;
      });

			this.map_event.connect((ev) => {
				this.set_strut();
			});
		}

		public override void get_preferred_width(out int min_width, out int nat_width) {
			min_width = nat_width = this.geometry.width;
		}

		public override void get_preferred_width_for_height(int height, out int min_width, out int nat_width) {
			this.get_preferred_width(out min_width, out nat_width);
		}

		public override void get_preferred_height(out int min_height, out int nat_height) {
			min_height = nat_height = this.geometry.height;
		}

		public override void get_preferred_height_for_width(int width, out int min_height, out int nat_height) {
			this.get_preferred_height(out min_height, out nat_height);
		}

		public void set_strut() {
			var monitor = this.shell.disp.get_monitor(this.monitor_index);
      ulong strut[12] = {};

			switch (this.side) {
				case PanelSide.LEFT:
					strut[0] = this.geometry.x + this.geometry.width;
					strut[4] = this.geometry.y;
					strut[5] = this.geometry.y + this.geometry.height - 1;
					break;
				case PanelSide.RIGHT:
					strut[1] = monitor.geometry.x + this.geometry.x;
					strut[6] = this.geometry.y;
					strut[7] = this.geometry.y + this.geometry.height - 1;
					break;
				case PanelSide.TOP:
					strut[2] = this.geometry.y + this.geometry.height;
					strut[8] = this.geometry.x;
					strut[9] = this.geometry.x + this.geometry.width - 1;
					break;
				case PanelSide.BOTTOM:
					strut[3] = monitor.geometry.y + this.geometry.y;
					strut[10] = this.geometry.x;
					strut[11] = this.geometry.x + this.geometry.width - 1;
					break;
      }

			Gdk.property_change(this.get_toplevel().get_window(), _NET_WM_STRUT, CARDINAL, 32, Gdk.PropMode.REPLACE, (uint8[])&strut, 4);
			Gdk.property_change(this.get_toplevel().get_window(), _NET_WM_STRUT_PARTIAL, CARDINAL, 32, Gdk.PropMode.REPLACE, (uint8[])&strut, 12);
		}
	}
}
