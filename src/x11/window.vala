namespace ExpidusOSShell.X11 {
	public class Window : ExpidusOSShell.BaseWindow {
		private Clutter.Texture? _texture;

		private X.Window _xwin;
		private X.Window? framewin = null;
		private Gdk.X11.Window _gwin;

		public X.Window xwin {
			get {
				return this._xwin;
			}
		}

		public override Gdk.Window gwin {
			get {
				return this._gwin;
			}
		}

		public override Clutter.Texture? texture {
			get {
				return this._texture;
			}
		}

		public override bool managed {
			get {
				X.WindowAttributes attrs = {};

				var comp = this.shell.compositor as Compositor;
				comp.disp.get_window_attributes(this.xwin, out attrs);

				return attrs.override_redirect;
			}
			set {
				X.SetWindowAttributes new_attrs = {};
				new_attrs.override_redirect = value;

				var comp = this.shell.compositor as Compositor;
				comp.disp.change_window_attributes(this.xwin, X.CW.OverrideRedirect, new_attrs);
			}
		}

		public override bool is_mapped {
			get {
				X.WindowAttributes attrs = {};

				var comp = this.shell.compositor as Compositor;
				comp.disp.get_window_attributes(this.xwin, out attrs);

				return attrs.map_state == X.MapState.IsViewable;
			}
		}

		public override int x {
			get {
				int x;
				int y;
				this.gwin.get_position(out x, out y);
				return x;
			}
			set {
				var monitor = this.shell.compositor.disp_gdk.get_monitor_at_point(value, this.y);

				var wx = this.width + value;
				if (wx > monitor.workarea.width) {
					this.width = monitor.workarea.width - value;
				}

				var old_x = this.x;
				var comp = this.shell.compositor as Compositor;
				comp.disp.move_window(this.xwin, value, this.y);
				this.resize(old_x, this.y, value, this.y);
			}
		}

		public override int y {
			get {
				int x;
				int y;
				this.gwin.get_position(out x, out y);
				return y;
			}
			set {
				var monitor = this.shell.compositor.disp_gdk.get_monitor_at_point(this.x, value);

				var hy = this.height + value;
				if (hy > monitor.workarea.height) {
					this.height = monitor.workarea.height - value;
				}

				var old_y = this.y;
				var comp = this.shell.compositor as Compositor;
				comp.disp.move_window(this.xwin, this.x, value);
				this.resize(this.x, old_y, this.x, value);
			}
		}

		public override int width {
			get {
				return this.gwin.get_width();
			}
			set {
				var monitor = this.shell.compositor.disp_gdk.get_monitor_at_point(this.x, this.y);

				var wx = value + this.x;
				if (wx > monitor.workarea.width) {
					value = monitor.workarea.width - this.x;
				}

				var old_w = this.width;
				this.gwin.resize(value, this.height);
				this.move(old_w, this.height, value, this.height);
			}
		}

		public override int height {
			get {
				return this.gwin.get_height();
			}
			set {
				var monitor = this.shell.compositor.disp_gdk.get_monitor_at_point(this.x, this.y);

				var hy = value + this.y;
				if (hy > monitor.workarea.height) {
					value = monitor.workarea.height - this.y;
				}

				var old_h = this.height;
				this.gwin.resize(this.width, value);
				this.move(this.width, old_h, this.width, value);
			}
		}

		public Window(ExpidusOSShell.Shell shell, X.Window xwin) {
			base(shell);

			this._xwin = xwin;
			this._texture = new ClutterX11.TexturePixmap.with_window(xwin);

			var comp = this.shell.compositor as Compositor;
			this._gwin = Gdk.X11.Window.lookup_for_display(comp.disp_gdk as Gdk.X11.Display, this.xwin);
			if (this._gwin == null) this._gwin = new Gdk.X11.Window.foreign_for_display(comp.disp_gdk as Gdk.X11.Display, this.xwin);

			if (this.xwin != comp.disp.default_root_window()) {
				if (this.managed) { 
					this.frame();
				}
			}
		}

		public void set_events(uint mask) {
			X.WindowAttributes attrs = {};
			var comp = this.shell.compositor as Compositor;
			comp.disp.get_window_attributes(this.xwin, out attrs);

			X.SetWindowAttributes new_attrs = {};
			new_attrs.event_mask = attrs.all_event_masks | mask;
			comp.disp.change_window_attributes(this.xwin, X.CW.EventMask, new_attrs);
		}

		public override void show() {
			var comp = this.shell.compositor as Compositor;
			if (this.framed && this.framewin != null) {
				comp.disp.map_window(this.framewin);
			} else {
				comp.disp.map_window(this.xwin);
			}

			var monitor = this.shell.compositor.disp_gdk.get_monitor_at_point(this.x, this.y);
			var width = this.width;
			var height = this.height;
			var wx = width + this.x;
			var hy = height + this.y;

			if (wx > monitor.workarea.width) {
				width = monitor.workarea.width - this.x;
			}

			if (hy > monitor.workarea.height) {
				height = monitor.workarea.height - this.y;
			}

			this.gwin.resize(width, height);
			this.map();
		}

		public override void hide() {
			var comp = this.shell.compositor as Compositor;
			if (this.framed && this.framewin != null) {
				comp.disp.unmap_window(this.framewin);
			} else {
				comp.disp.unmap_window(this.xwin);
			}
			this.unmap();
		}

		public override void frame() {
			if (!this.framed && this.framewin == null) {
				stdout.printf("Framing %p\n", this);
				var comp = this.shell.compositor as Compositor;
				this.framewin = X.create_simple_window(comp.disp, comp.disp.default_root_window(), this.x, this.y, this.width, this.height, 3, 0xff0000, 0x0000ff);
				comp.disp.reparent_window(this.xwin, this.framewin, 0, 0);
				if (this.is_mapped) comp.disp.map_window(this.framewin);
				this.framed = true;
			}
		}

		public override void unframe() {
			if (this.framed && this.framewin != null) {
				stdout.printf("Unframing %p\n", this);
				var comp = this.shell.compositor as Compositor;
				comp.disp.reparent_window(this.xwin, comp.disp.default_root_window(), 0, 0);
				if (this.is_mapped) comp.disp.map_window(this.xwin);
				this.framewin = null;
				this.framed = false;
			}
		}
	}
}
