namespace ExpidusOSShell.X11 {
	public class Compositor : ExpidusOSShell.Compositor {
		private ExpidusOSShell.Shell _shell;
		private X.Display _disp;
		private Gdk.X11.Display _gdisp;

		private GLib.List<ExpidusOSShell.X11.Window?> windows;

		public override ExpidusOSShell.Shell shell {
			get {
				return this._shell;
			}
			set construct {
				this._shell = value;
			}
		}

		public override Gdk.Display disp_gdk {
			get {
				return this._gdisp;
			}
		}

		public X.Display disp {
			get {
				return this._disp == null ? this._gdisp.get_xdisplay() : this._disp;
			}
		}

		public Compositor(ExpidusOSShell.Shell shell, string? disp_name, string[] args) throws ExpidusOSShell.CompositorErrors {
			Object(shell: shell);
			if (disp_name == null) disp_name = GLib.Environment.get_variable("DISPLAY") != null ? GLib.Environment.get_variable("DISPLAY") : ":0";

			this._disp = new X.Display(disp_name);
			if (this.disp == null) {
				throw new ExpidusOSShell.CompositorErrors.NO_DISPLAY("A connection to the X11 server could not be established");
			}
			
			this._gdisp = Gdk.X11.Display.lookup_for_xdisplay(this.disp);
			if (this._gdisp == null) {
				this._gdisp = Gdk.Display.open(disp_name) as Gdk.X11.Display;
				this._disp = null;
			}

			this.windows = new GLib.List<ExpidusOSShell.X11.Window?>();
			Clutter.set_windowing_backend("x11");
			ClutterX11.set_display(this.disp);
			GtkClutter.init(ref args);

			if (!ClutterX11.has_composite_extension()) {
				throw new ExpidusOSShell.CompositorErrors.INCOMPATIBLE("X11 composite extension is required");
			}
		}

		public override void init() {
			var win = this.add_window(this.disp.default_root_window());
			win.set_events(X.EventMask.SubstructureNotifyMask | X.EventMask.SubstructureRedirectMask);
			win.gwin.set_events(Gdk.EventMask.ALL_EVENTS_MASK);

			this.disp.grab_server();
			X.Window root;
			X.Window parent;
			X.Window[] children;
			this.disp.query_tree(this.disp.default_root_window(), out root, out parent, out children);

			for (var i = 0; i < children.length; i++) {
				this.add_window(children[i]);
			}
			this.disp.ungrab_server();
		}

		public bool has_window(X.Window xwin) {
			return this.get_window(xwin) != null;
		}

		public Window? get_window(X.Window xwin) {
			for (var i = 0; i < this.windows.length(); i++) {
				var win = this.windows.nth(i).data;
				if (win.xwin == xwin) return win;
			}
			return null;
		}

		public Window add_window(X.Window xwin) {
			if (!this.has_window(xwin)) {
				var win = new Window(this.shell, xwin);
				this.windows.append(win);
				this.new_window(win);
				return win;
			}
			return this.get_window(xwin);
		}

		public override bool handle_event() {
			X.Event ev = {};
			stdout.printf("Receiving event\n");
			this.disp.next_event(ref ev);
			switch (ev.type) {
				case X.EventType.CreateNotify:
					{
						X.WindowAttributes attrs = {};
						this.disp.get_window_attributes(ev.xcreatewindow.window, out attrs);

						var win = this.get_window(ev.xcreatewindow.window);
						if (win == null && attrs.override_redirect == false) {
							win = this.add_window(ev.xcreatewindow.window);
						}
					}
					break;
				case X.EventType.MapNotify:
					{
						var win = this.get_window(ev.xmap.window);
						if (win != null) {
							win.show();
						}
					}
					break;
				case X.EventType.MapRequest:
					{
						var win = this.get_window(ev.xmaprequest.window);
						if (win != null) {
							win.show();
						} else {
							this.disp.map_window(ev.xmaprequest.window);
						}
					}
					break;
			}
			ClutterX11.handle_event(ev);
			return true;
		}
	}
}
