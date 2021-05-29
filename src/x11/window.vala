namespace ExpidusOSShell.X11 {
	public class Window : ExpidusOSShell.BaseWindow {
		private Clutter.Texture? _texture;

		private X.Window _xwin;
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
				var comp = this.shell.compositor as Compositor;
				comp.disp.move_window(this.xwin, value, this.y);
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
				var comp = this.shell.compositor as Compositor;
				comp.disp.move_window(this.xwin, this.x, value);
			}
		}

		public override int width {
			get {
				return this.gwin.get_width();
			}
			set {
				this.gwin.resize(value, this.height);
			}
		}

		public override int height {
			get {
				return this.gwin.get_height();
			}
			set {
				this.gwin.resize(this.width, value);
			}
		}

		public Window(ExpidusOSShell.Shell shell, X.Window xwin) {
			base(shell);

			this._xwin = xwin;
			this._texture = new ClutterX11.TexturePixmap.with_window(xwin);

			var comp = this.shell.compositor as Compositor;
			this._gwin = Gdk.X11.Window.lookup_for_display(comp.disp_gdk as Gdk.X11.Display, this.xwin);

			if (this.xwin != comp.disp.default_root_window()) {
				if (this.managed) { 
					this.frame();
				} else {
					this.unframe();
				}

				comp.disp.add_to_save_set(this.xwin);
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
			this.map();
		}

		public override void hide() {
			this.unmap();
		}
	}
}
