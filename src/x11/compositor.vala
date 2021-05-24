namespace ExpidusOSShell.X11 {
	public class Compositor : ExpidusOSShell.Compositor {
		private ExpidusOSShell.Shell _shell;
		private X.Display _disp;

		private GLib.List<ExpidusOSShell.X11.Window?> windows;

		public override ExpidusOSShell.Shell shell {
			get {
				return this._shell;
			}
			set construct {
				this._shell = value;
			}
		}

		public X.Display disp {
			get {
				return this._disp;
			}
		}

		public Compositor(ExpidusOSShell.Shell shell) throws ExpidusOSShell.CompositorErrors {
			Object(shell: shell);

			this._disp = new X.Display();
			if (this.disp == null) {
				throw new ExpidusOSShell.CompositorErrors.NO_DISPLAY("A connection to the X11 server could not be established");
			}

			this.windows = new GLib.List<ExpidusOSShell.X11.Window?>();
			ClutterX11.set_display(this.disp);

		}

		public override void init() {
			var win = this.add_window(this.disp.default_root_window());
			win.set_events(X.EventMask.SubstructureNotifyMask | X.EventMask.SubstructureRedirectMask);

			this.disp.grab_server();
			X.Window root;
			X.Window parent;
			X.Window[] children;
			this.disp.query_tree(this.disp.default_root_window(), out root, out parent, out children);

			for (var i = 0; i < children.length; i++) {
				X.WindowAttributes attrs = {};
				this.disp.get_window_attributes(children[i], out attrs);
				if (attrs.override_redirect == false) {
					this.add_window(children[i]);
				}
			}
			this.disp.ungrab_server();
		}

		private bool has_window(X.Window xwin) {
			return this.get_window(xwin) != null;
		}

		private Window? get_window(X.Window xwin) {
			for (var i = 0; i < this.windows.length(); i++) {
				var win = this.windows.nth(i).data;
				var _x = win.xwin;
				stdout.printf("%lu %lu %d\n", _x, xwin, win.xwin == xwin ? 1 : 0);
				if (win.xwin == xwin) return win;
			}
			return null;
		}

		private Window add_window(X.Window xwin) {
			if (!this.has_window(xwin)) {
				var win = new Window(this.shell, xwin);
				this.windows.append(win);
				this.new_window(win);
				return win;
			}
			return this.get_window(xwin);
		}

		public override void handle_event() {
			X.Event ev = {};
			this.disp.next_event(ref ev);
			switch (ev.type) {
				case X.EventType.CreateNotify:
					/* TODO: Fix the five duplicates */
					{
						X.WindowAttributes attrs = {};
						this.disp.get_window_attributes(ev.xcreatewindow.window, out attrs);
						if (attrs.override_redirect == false && this.has_window(ev.xcreatewindow.window) == false) {
							this.add_window(ev.xcreatewindow.window);
						}
					}
					break;
			}
		}
	}
}
