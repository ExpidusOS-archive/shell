namespace ExpidusOSShell.X11 {
	public class Window : ExpidusOSShell.Window {
		private ExpidusOSShell.Shell _shell;
		private Clutter.Texture? _texture;

		private X.Window _xwin;
		private Gdk.X11.Window _gwin;

		public override ExpidusOSShell.Shell shell {
			get {
				return this._shell;
			}
			set construct {
				this._shell = value;
			}
		}

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

		public Window(ExpidusOSShell.Shell shell, X.Window xwin) {
			Object(shell: shell);

			this._xwin = xwin;
			this._texture = new ClutterX11.TexturePixmap.with_window(xwin);
			this.actor.add(this._texture);

			var comp = this.shell.compositor as Compositor;
			this._gwin = Gdk.X11.Window.lookup_for_display(comp.disp_gdk as Gdk.X11.Display, this.xwin);
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
			this.actor.show();
		}

		public override void hide() {
			this.actor.hide();
		}
	}
}
