namespace ExpidusOSShell.X11 {
	public class Window : ExpidusOSShell.Window {
		private ExpidusOSShell.Shell _shell;
		private Clutter.Stage? _stage;

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

		public override Clutter.Stage? stage {
			get {
				return this._stage;
			}
		}

		public Window(ExpidusOSShell.Shell shell, X.Window xwin) {
			Object(shell: shell);

			this._xwin = xwin;
			this._stage = ClutterX11.get_stage_from_window(xwin);

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
	}
}
